import datetime
import os
import re
import requests
import xml.etree.ElementTree as ET

from flask import Flask
from flask import g
from flask import make_response
from flask import render_template
from flask import request
from flask import url_for
from flask import jsonify
from flask import send_file
from flask.ext.security import RoleMixin
from flask.ext.security import Security
from flask.ext.security import SQLAlchemyUserDatastore
from flask.ext.security import UserMixin
from flask.ext.security import current_user
from flask.ext.security.forms import Form
from flask.ext.security.forms import NewPasswordFormMixin
from flask.ext.security.forms import PasswordConfirmFormMixin
from flask.ext.security.forms import UniqueEmailFormMixin
from flask.ext.security.utils import encrypt_password
from flask.ext.sqlalchemy import SQLAlchemy
from flask_mail import Mail
from flask_wtf import SubmitField
from flaskext.babel import _
from flaskext.babel import Babel
from sqlalchemy.exc import IntegrityError

from rq import Queue
from rq.job import Job
from redis import Redis

from export import export_image

# Tell RQ what Redis connection to use
redis_conn = Redis()
q = Queue(connection=redis_conn)  # no args implies the default queue

LOCALES = {
    'en': 'English',
    'cy': 'Cymraeg',
}

SALT = os.environ.get('FISHMAP_SALT')
PASSWORD = os.environ.get('FISHMAP_PASSWORD')
DEV_USER = os.environ.get('FISHMAP_DEV_USER')
DEV_PASS = os.environ.get('FISHMAP_DEV_PASS')

assert SALT
assert PASSWORD
assert DEV_USER
assert DEV_PASS

app = Flask(__name__)
babel = Babel(app)
mail = Mail()  # config initialized with locale

# Set basic config
app.config['SECRET_KEY'] = 'it-would-be-a-good-idea-to-override-this!'

# Flask-Security settings
app.config['SECURITY_PASSWORD_HASH'] = 'bcrypt'
app.config['SECURITY_RECOVERABLE'] = False
app.config['SEND_REGISTER_EMAIL'] = False

# Flask-Security string overrides
app.config.from_object('security_strings')

# Own settings
app.config['WMS_URL'] = 'http://127.0.0.1/cgi-bin/mapserv?'
app.config['AUTH_USER'] = 'fishmap_webapp'
app.config['AUTH_DB'] = 'fishmap_auth'

# Import local overrides
if os.environ.get('FISHMAP_CONFIG_FILE'):
    app.config.from_envvar('FISHMAP_CONFIG_FILE')

# Settings derived from those above
app.config['SQLALCHEMY_DATABASE_URI'] = \
    'postgresql+psycopg2://{}:{}@/{}'.format(app.config['AUTH_USER'], PASSWORD,
                                             app.config['AUTH_DB'])
app.config['SECURITY_PASSWORD_SALT'] = SALT

auth_db = SQLAlchemy(app)

users_roles = auth_db.Table('users_roles',
                            auth_db.Column('user_id', auth_db.Integer(),
                                           auth_db.ForeignKey('user.id')),
                            auth_db.Column('role_id', auth_db.Integer(),
                                           auth_db.ForeignKey('role.id')))


class Role(auth_db.Model, RoleMixin):
    id = auth_db.Column(auth_db.Integer(), primary_key=True)
    name = auth_db.Column(auth_db.String(80), unique=True)
    description = auth_db.Column(auth_db.String())


class User(auth_db.Model, UserMixin):
    id = auth_db.Column(auth_db.Integer(), primary_key=True)
    email = auth_db.Column(auth_db.String(), unique=True)
    password = auth_db.Column(auth_db.String())
    active = auth_db.Column(auth_db.Boolean())
    confirmed_at = auth_db.Column(auth_db.DateTime())
    last_login_at = auth_db.Column(auth_db.DateTime())
    current_login_at = auth_db.Column(auth_db.DateTime())
    last_login_ip = auth_db.Column(auth_db.String(15))
    current_login_ip = auth_db.Column(auth_db.String(15))
    login_count = auth_db.Column(auth_db.Integer())
    roles = auth_db.relationship('Role', secondary=users_roles,
                                 backref=auth_db.backref('users',
                                                         lazy='dynamic'))


class NewUserForm(Form, NewPasswordFormMixin, PasswordConfirmFormMixin,
                  UniqueEmailFormMixin):
    submit = SubmitField(_('Register user'))


auth_datastore = SQLAlchemyUserDatastore(auth_db, User, Role)
security = Security(app, auth_datastore)

auth_db.create_all()  # create tables if don't already exist

auth_datastore.find_or_create_role(
    'user', description=
    'User authorised to view information denied to the public')
auth_datastore.find_or_create_role(
    'admin', description='Administrator of Users')
auth_datastore.find_or_create_role(
    'dev', description='Developer of entire system')

auth_datastore.commit()


def set_locale():
    if('locale' in request.args):
        l = request.args.get('locale')
    else:
        l = request.accept_languages.best_match(LOCALES.keys())

    if not hasattr(g, 'locale') or l != g.locale and l in LOCALES.keys():
        g.locale = l
        if not hasattr(g, 'other_locales') or g.locale in g.other_locales:
            g.other_locales = dict()
            for locale in LOCALES:
                if locale != g.locale:
                    g.other_locales[locale] = LOCALES[locale]
        if ('LOCALE_SMTP' in app.config
                and g.locale in app.config['LOCALE_SMTP']):
            smtp = app.config['LOCALE_SMTP']
            app.config['MAIL_SERVER'] = smtp.get('server', 'localhost')
            app.config['MAIL_PORT'] = smtp.get('port', 25)
            app.config['MAIL_USE_TLS'] = smtp.get('use_tls', False)
            app.config['MAIL_USE_SSL'] = smtp.get('use_ssl', False)
            app.config['MAIL_USERNAME'] = smtp.get('username', None)
            app.config['MAIL_PASSWORD'] = smtp.get('password', None)
            app.config['MAIL_DEFAULT_SENDER'] = smtp.get('sender', None)
            app.config['MAIL_MAX_EMAILS'] = smtp.get('max_emails', None)
            mail.init_app(app)

    if not hasattr(g, 'locale_uris') and 'LOCALE_HOSTS' in app.config:
        g.locale_uris = dict()
        for locale in app.config['LOCALE_HOSTS']:
            if locale in LOCALES and app.config['LOCALE_HOSTS'][locale]:
                g.locale_uris[locale] = app.config['LOCALE_HOSTS'][locale]


@babel.localeselector
def get_locale():
    return g.locale


@app.before_first_request
def before_first_request():
    try:
        default_dev = auth_datastore.create_user(
            email=DEV_USER,
            password=encrypt_password(DEV_PASS))
        default_dev.roles = [auth_datastore.find_role('dev')]
        auth_datastore.commit()
    except IntegrityError:
        auth_db.session.rollback()  # user exists


@app.before_request
def before_request():
    set_locale()
    g.user = current_user
    g.layer_info_url = 'http://naturalresourceswales.gov.uk/our-work/about-us/nrw-funded-projects/fishmap-mon/fishmap-mon-info/?lang=en'
    if g.locale == 'cy':
        g.layer_info_url = 'http://cyfoethnaturiolcymru.gov.uk/our-work/about-us/nrw-funded-projects/fishmap-mon/fishmap-mon-info/?lang=cy'


@app.route('/')
def home():
    resp = make_response(render_template('index.html', user=g.user))
    resp.headers['X-UA-Compatible'] = 'IE=edge'
    return resp


@app.route('/user_add', methods=['POST', 'GET'])
def user_add():
    if (g.user.is_authenticated() and ('dev' in g.user.roles
                                       or 'admin' in g.user.roles)):
        form = NewUserForm(request.form)
        msg = None
        try:
            email = str(form.email.data)
            if form.validate_on_submit():
                new_user = auth_datastore.create_user(
                    email=email,
                    password=encrypt_password(str(form.password.data)))
                new_user.roles = [auth_datastore.find_role('user')]
                auth_datastore.commit()
                msg = 'User {} created'.format(email)
        except KeyError, IntegrityError:
            auth_db.session.rollback()  # user exists
            msg = ('User {} not created - user already exists'
                       .format(email))
        return render_template('user_add.html',
                               user=g.user, new_user_form=form, msg=msg)
    else:
        abort(404)


@app.route('/gaz')
def gaz():

    args = {
        "qstr": request.args.get('q'),
        "SERVICE": "WFS",
        "VERSION": "1.0.0",
        "REQUEST": "getfeature",
        "TYPENAME": "gaz",
        "MAXFEATURES": "20"
    }

    # Set the MapServer map parameter specifiying a path relative the this app
    args['map'] = get_mapserver_map_arg('gaz')

    r = requests.get(
        app.config['WMS_URL'],
        params=args
    )

    resp = make_response(r.content)
    resp.headers['Content-Type'] = r.headers.get('Content-Type')
    resp.headers.add('Cache-Control', 'max-age=3600')

    return resp


@app.route('/wms')
def wms():

    try:
        args, cacheable = update_wms_args(request.args.copy(),
                                          g.user.is_authenticated())
    except (InvalidWmsArgs) as ex:
        return (ex.message, 500)

    layers = args.get('LAYERS') or args.get('LAYER')
    if 'GetFeatureInfo' not in args['REQUEST']:
        sld = render_sld(layers.split(','), args)
        args['SLD_BODY'] = sld

    args['map'] = get_mapserver_map_arg(args.get('map'))

    r = requests.post(
        app.config['WMS_URL'],
        data=args
    )

    body = r.content
    if 'GetFeatureInfo' in args['REQUEST']:
        body = process_feature_info(layers.split(','),
                                    r.text, g.user.is_authenticated())

    resp = make_response(body, r.status_code)
    resp.headers['Content-Type'] = r.headers['Content-Type']

    if cacheable:
        dt = datetime.datetime.utcnow()
        modified = dt.strftime('%a, %d %b %Y %T GMT')
        resp.headers.add('Last-Modified', modified)
        resp.headers.add('Cache-Control', 'max-age=29030400')
    else:
        resp.headers.add('Cache-Control', 'no-cache, no-store, max-age=0')

    return resp


@app.route('/export')
def export():
    args = request.args.copy()
    args['_external'] = True
    url = url_for('home', **args)
    sub = '://%s:%s@' % (os.environ.get('HTTP_AUTH_USER', ''),
                         os.environ.get('HTTP_AUTH_PASS', ''))
    url = re.sub(r'://', sub, url)
    job = q.enqueue(export_image, url)
    return jsonify(job_key=job.key.replace('rq:job:', ''))


@app.route('/export/status/<job_key>', methods=['GET'])
def export_status(job_key):
    job = Job.fetch(job_key, connection=redis_conn)
    if job.is_finished:
        url = url_for('export_result', job_key=job_key)
        return jsonify(status="complete", result=url), 200
    elif job.is_failed:
        return jsonify(status="failed"), 500
    else:
        return jsonify(status="pending"), 202


@app.route('/export/result/<job_key>', methods=['GET'])
def export_result(job_key):
    return send_file('static/tmp/%s.png' % job_key,
                     as_attachment=True, attachment_filename='nrw-fmm.png')


def process_feature_info(layers, body, auth):
    """ Update the GetFeatureInfo response to remove any references to whether
    the data is generalised or detailed and apply suppression to the vessel
    count fields """

    ET.register_namespace('gml', 'http://www.opengis.net/gml')
    tree = ET.fromstring(body)

    # Remove suffixes
    suffix = get_layer_suffix(auth)
    for layer in layers:
        tag = '%s_layer' % layer
        for elm in tree.iter(tag):
            elm.tag = elm.tag.replace(suffix, '')
            gml_name = elm.find('{http://www.opengis.net/gml}name')
            gml_name.text = gml_name.text.replace(suffix, '')
        tag = '%s_feature' % layer
        for elm in tree.iter(tag):
            elm.tag = elm.tag.replace(suffix, '')

    # Suppress low vessel values if not logged in
    if not auth:
        vessel_fields = ['_overlaps', 'num_gatherers_year', 'num_anglers_year']
        for vessel_field in vessel_fields:
            # There could be more than one layer with the vessel field so use
            # an iterator
            for elm in tree.iter(vessel_field):
                if int(elm.text, 10) <= 2:
                    elm.text = '2 or less'

    body = ET.tostring(tree, encoding='utf8', method='xml')
    return body


class InvalidWmsArgs(Exception):
    def __init__(self, message=''):
        Exception.__init__(self, message)


def update_wms_args(args, auth):
    """ Update the WMS request parameters before they are passed to the back
    end. Raises InvalidWmsArgs if the args to be returned are invalid such as
    the LAYER or LAYERS arg does not have a value """

    cacheable = True

    # Update the LAYER of LAYERS parameter
    layers = None
    layer_arg = next((a for a in ['LAYERS', 'LAYER'] if a in args), None)
    if layer_arg and args.get('map') == 'fishmap':
        layers, cacheable = update_wms_layers(args[layer_arg].split(','), auth)
    else:
        layers = args[layer_arg].split(',')

    if layers:
        layers = ','.join(layers)
    else:
        raise InvalidWmsArgs('No valid layers')

    args[layer_arg] = layers

    # Check QUERY_LAYERS passed by GetFeatureInfo in addition to LAYERS
    if 'QUERY_LAYERS' in args:
        args['QUERY_LAYERS'] = layers

    return args, cacheable


def update_wms_layers(layers, auth):
    """ Updates a list of layers to remove restricted layers if the user is not
    logged in and add the appropriate suffix to project output layers depending
    no whether a user is logged in or not """

    cacheable = True

    restricted_layers = [
        'activity_commercial_fishing_polygon',
        'activity_noncommercial_fishing_point',
        'activity_noncommercial_fishing_polygon']

    detailed_layers = ('intensity', 'vessels', 'sensitivity')

    def update_layer(layer):
        """ Updates project output layers to include the _det or _gen suffix
        based on whether the user is logged in or not. All other layers just
        pass through with the same name """
        if layer.startswith(detailed_layers):
            suffix = get_layer_suffix(auth)
            return '%s%s' % (layer, suffix)
        return layer

    def authorise_layer(layer):
        """ Tests if the current user has access to the specified layer """
        return layer not in restricted_layers or auth

    layers = [
        update_layer(layer)
        for layer in layers
        if authorise_layer(layer)
    ]

    for layer in layers:
        if layer in restricted_layers or layer.startswith(detailed_layers):
            cacheable = False
            break

    return layers, cacheable


def get_layer_suffix(auth):
    suffix = '_det' if auth else '_gen'
    return suffix


def render_sld(layers, args):
    """ Render an SLD document as a string for the list of layers passed """
    if layers:
        layer_info = []
        common_slds = ['intensity', 'vessels', 'sensitivity', 'sensvtyconf']
        for layer in layers:
            template = '%s.sld' % layer
            info = {'template': template, 'name': layer}
            split_layer = layer.split('_')
            if split_layer[0] in common_slds:
                info['template'] = '%s.sld' % split_layer[0]
            info.update(get_extra_sld_info(layer, args))
            layer_info.append(info)

        return render_template('base.sld', layer_info=layer_info)


def get_mapserver_map_arg(map_name):
    """ Set the MapServer map parameter specifiying a path relative the this
    app """
    return '%s/../config/mapserver/%s.map' % (app.root_path, map_name)


def get_extra_sld_info(layer, args):
    data = {}
    split_layer = layer.split('_')
    if split_layer[0] == 'intensity':
        layer = args.get('FISHING')
        intensity_bands = {
            "king_scallops": ["&lt;0.8", "0.8 - 3", "&gt;3"],
            "queen_scallops": ["&lt;1.35", "1.35 - 10.2", "&gt;10.2"],
            "mussels": ["&lt;0.4", "0.4 - 3", "&gt;3"],
            "lot": ["&lt;0.93", "0.93 - 6.95", "&gt;6.95"],
            "nets": ["&lt;33.9", "33.9 - 254.6", "&gt;254.6"],
            "pots_commercial": ["&lt;2", "2 - 5", "&gt;5"],
            "pots_recreational": ["&lt;2", "2 - 5", "&gt;5"],
            "pots_combined": ["&lt;2", "2 - 5", "&gt;5"],
            "rsa_charterboats": ["&lt;5", "6 - 20", "&gt;20"],
            "rsa_noncharter": ["&lt;5", "6 - 20", "&gt;20"],
            "rsa_combined": ["&lt;5", "6 - 20", "&gt;20"],
            "rsa_shore": ["&lt;5", "6 - 20", "&gt;20"],
            "cas_hand_gath": ["&lt;3", "3 - 10", "&gt;10"],
            "pro_hand_gath": ["&lt;3", "3 - 10", "&gt;10"],
        }
        intensity_colors = ['#ffff71',  '#ffa84f', '#a15001']
        bands = []
        for idx, item in enumerate(intensity_bands[layer]):
            val = idx + 1
            bands.append({
                'name': '%s (%s)' % (val, item),
                'value': val,
                'color': intensity_colors[idx]
            })
        data['bands'] = bands
    if split_layer[0] == 'vessels':
        layer = args.get('FISHING')
        vessels_bands = {
            "king_scallops": [
                {"name": "2 or less", "type": "PropertyIsLessThanOrEqualTo", "value": 2, "color": "#A0FFFF"},
                {"name": "3", "type": "PropertyIsEqualTo", "value": 3, "color": "#00ABFF"},
                {"name": "4 or more", "type": "PropertyIsGreaterThanOrEqualTo", "value": 4, "color": "#0000A0"}
            ],
            "queen_scallops": [
                {"name": "2 or less", "type": "PropertyIsLessThanOrEqualTo", "value": 2, "color": "#A0FFFF"},
                {"name": "3", "type": "PropertyIsEqualTo", "value": 3, "color": "#00ABFF"},
                {"name": "4 or more", "type": "PropertyIsGreaterThanOrEqualTo", "value": 4, "color": "#0000A0"}
            ],
            "mussels": [
                {"name": "2 or less", "type": "PropertyIsLessThanOrEqualTo", "value": 2, "color": "#A0FFFF"},
                {"name": "3 or more", "type": "PropertyIsGreaterThanOrEqualTo", "value": 3, "color": "#00ABFF"}
            ],
            "lot": [
                {"name": "2 or less", "type": "PropertyIsLessThanOrEqualTo", "value": 2, "color": "#A0FFFF"},
                {"name": "3 or more", "type": "PropertyIsGreaterThanOrEqualTo", "value": 3, "color": "#00ABFF"}
            ],
            "nets": [
                {"name": "2 or less", "type": "PropertyIsLessThanOrEqualTo", "value": 2, "color": "#A0FFFF"},
                {"name": "3 or more", "type": "PropertyIsGreaterThanOrEqualTo", "value": 3, "color": "#00ABFF"}
            ],
            "pots_commercial": [
                {"name": "2 or less", "type": "PropertyIsLessThanOrEqualTo", "value": 2, "color": "#A0FFFF"},
                {"name": "3", "type": "PropertyIsEqualTo", "value": 3, "color": "#80D5FF"},
                {"name": "4", "type": "PropertyIsEqualTo", "value": 4, "color": "#00ABFF"},
                {"name": "5", "type": "PropertyIsEqualTo", "value": 5, "color": "#004BE0"},
                {"name": "6 or more", "type": "PropertyIsGreaterThanOrEqualTo", "value": 6, "color": "#0000A0"}
            ],
            "pots_recreational": [
                {"name": "2 or less", "type": "PropertyIsLessThanOrEqualTo", "value": 2, "color": "#A0FFFF"},
                {"name": "3 - 4", "type": "PropertyIsBetween", "lower": 3, "upper": 4, "color": "#80D5FF"},
                {"name": "5 - 6", "type": "PropertyIsBetween", "lower": 5, "upper": 6, "color": "#00ABFF"},
                {"name": "7 - 8", "type": "PropertyIsBetween", "lower": 7, "upper": 8, "color": "#2020FF"},
                {"name": "9 or more", "type": "PropertyIsGreaterThanOrEqualTo", "value": 9, "color": "#0000A0"}
            ],
            "pots_combined": [
                {"name": "2 or less", "type": "PropertyIsLessThanOrEqualTo", "value": 2, "color": "#A0FFFF"},
                {"name": "3 - 4", "type": "PropertyIsBetween", "lower": 3, "upper": 4, "color": "#80D5FF"},
                {"name": "5 - 6", "type": "PropertyIsBetween", "lower": 5, "upper": 6, "color": "#00ABFF"},
                {"name": "7 - 9", "type": "PropertyIsBetween", "lower": 7, "upper": 9, "color": "#2020FF"},
                {"name": "10 or more", "type": "PropertyIsGreaterThanOrEqualTo", "value": 10, "color": "#0000A0"}
            ],
            "rsa_charterboats": [
                {"name": "2 or less", "type": "PropertyIsLessThanOrEqualTo", "value": 2, "color": "#A0FFFF"},
                {"name": "3 - 4", "type": "PropertyIsBetween", "lower": 3, "upper": 4, "color": "#80D5FF"},
                {"name": "5 - 6", "type": "PropertyIsBetween", "lower": 5, "upper": 6, "color": "#00ABFF"},
                {"name": "7 - 9", "type": "PropertyIsBetween", "lower": 7, "upper": 9, "color": "#2020FF"},
                {"name": "10 or more", "type": "PropertyIsGreaterThanOrEqualTo", "value": 10, "color": "#0000A0"}
            ],
            "rsa_noncharter": [
                {"name": "2 or less", "type": "PropertyIsLessThanOrEqualTo", "value": 2, "color": "#A0FFFF"},
                {"name": "3 - 4", "type": "PropertyIsBetween", "lower": 3, "upper": 4, "color": "#80D5FF"},
                {"name": "5 - 6", "type": "PropertyIsBetween", "lower": 5, "upper": 6, "color": "#00ABFF"},
                {"name": "7 - 9", "type": "PropertyIsBetween", "lower": 7, "upper": 9, "color": "#2020FF"},
                {"name": "10 or more", "type": "PropertyIsGreaterThanOrEqualTo", "value": 10, "color": "#0000A0"}
            ],
            "rsa_combined": [
                {"name": "2 or less", "type": "PropertyIsLessThanOrEqualTo", "value": 2, "color": "#A0FFFF"},
                {"name": "3 - 6", "type": "PropertyIsBetween", "lower": 3, "upper": 6, "color": "#80D5FF"},
                {"name": "7 - 10", "type": "PropertyIsBetween", "lower": 7, "upper": 10, "color": "#00ABFF"},
                {"name": "11 - 14", "type": "PropertyIsBetween", "lower": 11, "upper": 14, "color": "#2020FF"},
                {"name": "15 or more", "type": "PropertyIsGreaterThanOrEqualTo", "value": 15, "color": "#000040"}
            ],
            "rsa_shore": [
                {"name": "9 or less", "type": "PropertyIsLessThanOrEqualTo", "value": 9, "color": "#A0FFFF"},
                {"name": "10 - 99", "type": "PropertyIsBetween", "lower": 10, "upper": 99, "color": "#80D5FF"},
                {"name": "100 - 249", "type": "PropertyIsBetween", "lower": 100, "upper": 249, "color": "#00ABFF"},
                {"name": "250 - 749", "type": "PropertyIsBetween", "lower": 250, "upper": 749, "color": "#2020FF"},
                {"name": "750 or more", "type": "PropertyIsGreaterThanOrEqualTo", "value": 750, "color": "#0000A0"}
            ],
            "cas_hand_gath": [
                {"name": "39 or less", "type": "PropertyIsLessThanOrEqualTo", "value": 39, "color": "#A0FFFF"},
                {"name": "40 - 69", "type": "PropertyIsBetween", "lower": 40, "upper": 69, "color": "#80D5FF"},
                {"name": "70 - 99", "type": "PropertyIsBetween", "lower": 70, "upper": 99, "color": "#00ABFF"},
                {"name": "100 - 149", "type": "PropertyIsBetween", "lower": 100, "upper": 149, "color": "#004BE0"},
                {"name": "150 or more", "type": "PropertyIsGreaterThanOrEqualTo", "value": 150, "color": "#0000A0"}
            ],
            "pro_hand_gath": [
                {"name": "39 or less", "type": "PropertyIsLessThanOrEqualTo", "value": 39, "color": "#A0FFFF"},
                {"name": "40 - 69", "type": "PropertyIsBetween", "lower": 40, "upper": 69, "color": "#80D5FF"},
                {"name": "70 - 99", "type": "PropertyIsBetween", "lower": 70, "upper": 99, "color": "#00ABFF"},
                {"name": "100 - 149", "type": "PropertyIsBetween", "lower": 100, "upper": 149, "color": "#004BE0"},
                {"name": "150 or more", "type": "PropertyIsGreaterThanOrEqualTo", "value": 150, "color": "#0000A0"}
            ],
        }
        data['bands'] = vessels_bands[layer]
    return data

if __name__ == '__main__':
    app.run(debug=True, processes=1, host='0.0.0.0')
