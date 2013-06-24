import os
import re
import requests

from flask import Flask
from flask import g
from flask import make_response
from flask import render_template
from flask import request
from flask.ext.security import RoleMixin
from flask.ext.security import Security
from flask.ext.security import SQLAlchemyUserDatastore
from flask.ext.security import UserMixin
from flask.ext.security import current_user
from flask.ext.security.utils import encrypt_password
from flask.ext.sqlalchemy import SQLAlchemy
from flask_mail import Mail
from flaskext.babel import Babel
from sqlalchemy.exc import IntegrityError

LOCALES = {
    'en': 'English',
    'cy': 'Cymraeg',
}

SALT = os.environ.get('FISHMAP_SALT')
PASSWORD = os.environ.get('FISHMAP_PASSWORD')

assert SALT
assert PASSWORD

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
app.config['WMS_URL'] = 'http://127.0.0.1:5001/cgi-bin/mapserv?'
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
            email='fmm@astuntechnology.com',
            password=encrypt_password('<password>'))
        default_dev.roles = [auth_datastore.find_role('dev')]
        auth_datastore.commit()
    except IntegrityError:
        auth_db.session.rollback()  # user exists


@app.before_request
def before_request():
    set_locale()
    g.user = current_user


@app.route('/')
def home():
    return render_template('index.html', user=g.user)


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
    resp.headers['Content-Type'] = r.headers['Content-Type']

    return resp


@app.route('/wms')
def wms():

    try:
        args = update_wms_args(request.args.copy(), g.user.is_authenticated())
    except (InvalidWmsArgs) as ex:
        return (ex.message, 500)

    layers = args.get('LAYERS') or args.get('LAYER')
    sld = render_sld(layers.split(','), args)
    args['SLD_BODY'] = sld

    args['map'] = get_mapserver_map_arg(args.get('map'))

    r = requests.post(
        app.config['WMS_URL'],
        data=args
    )

    resp = make_response(r.content)
    resp.headers['Content-Type'] = r.headers['Content-Type']

    return resp


class InvalidWmsArgs(Exception):
    def __init__(self, message=''):
        Exception.__init__(self, message)


def update_wms_args(args, auth):
    """ Update the WMS request parameters before they are passed to the back
    end. Raises InvalidWmsArgs if the args to be returned are invalid such as
    the LAYER or LAYERS arg does not have a value """

    # Update the LAYER of LAYERS parameter
    layers = None
    layer_arg = next((a for a in ['LAYERS', 'LAYER'] if a in args), None)
    if layer_arg:
        layers = update_wms_layers(args[layer_arg].split(','), auth)

    if layers:
        layers = ','.join(layers)
    else:
        raise InvalidWmsArgs('No valid layers')

    args[layer_arg] = layers

    # Check QUERY_LAYERS passed by GetFeatureInfo in addition to LAYERS
    if 'QUERY_LAYERS' in args:
        args['QUERY_LAYERS'] = layers

    return args


def update_wms_layers(layers, auth):
    """ Updates a list of layers to remove restricted layers if the user is not
    logged in and add the appropriate suffix to project output layers depending
    no whether a user is logged in or not """

    def update_layer(layer):
        """ Updates project output layers to include the _det or _gen suffix
        based on whether the user is logged in or not. All other layers just
        pass through with the same name """
        if layer.startswith(('intensity', 'vessels')):
            suffix = '_det' if auth else '_gen'
            return '%s%s' % (layer, suffix)
        return layer

    def authorise_layer(layer):
        """ Tests if the current user has access to the specified layer """
        restricted_layers = [
            'activity_commercial_fishing_polygon',
            'activity_noncommercial_fishing_point',
            'activity_noncommercial_fishing_polygon']
        return layer not in restricted_layers or auth

    layers = [
        update_layer(layer)
        for layer in layers
        if authorise_layer(layer)
    ]

    return layers


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
            "queen_scallops": ["&lt;0.8", "0.8 - 3", "&gt;3"],
            "mussels": ["&lt;0.4", "0.4 - 3", "&gt;3"],
            "lot": ["&lt;0.93", "0.93 - 6.95", "&gt;6.95"],
            "nets": ["&lt;33.9", "33.9 - 254.6", "&gt;254.6"],
            "fixed_pots": ["&lt;2", "2 - 5", "&gt;5"],
            "rsa_charterboats": ["&lt;5", "6 - 20", "&gt;20"],
            "rsa_commercial": ["&lt;5", "6 - 20", "&gt;20"],
            "rsa_noncharter": ["&lt;5", "6 - 20", "&gt;20"],
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
                {"name": "2 or less", "type": "PropertyIsLessThanOrEqualTo", "value": 2, "color": "#A0E0FF"},
                {"name": "3", "type": "PropertyIsEqualTo", "value": 3, "color": "#60CBFF"},
                {"name": "4 or more", "type": "PropertyIsGreaterThanOrEqualTo", "value": 4, "color": "#508BFF"}
            ],
            "queen_scallops": [
                {"name": "2 or less", "type": "PropertyIsLessThanOrEqualTo", "value": 2, "color": "#A0E0FF"},
                {"name": "3", "type": "PropertyIsEqualTo", "value": 3, "color": "#60CBFF"},
                {"name": "4 or more", "type": "PropertyIsGreaterThanOrEqualTo", "value": 4, "color": "#508BFF"}
            ],
            "mussels": [
                {"name": "2 or less", "type": "PropertyIsLessThanOrEqualTo", "value": 2, "color": "#A0E0FF"},
                {"name": "3 or more", "type": "PropertyIsGreaterThanOrEqualTo", "value": 3, "color": "#60CBFF"}
            ],
            "lot": [
                {"name": "2 or less", "type": "PropertyIsLessThanOrEqualTo", "value": 2, "color": "#A0E0FF"},
                {"name": "3 or more", "type": "PropertyIsGreaterThanOrEqualTo", "value": 3, "color": "#60CBFF"}
            ],
            "nets": [
                {"name": "2 or less", "type": "PropertyIsLessThanOrEqualTo", "value": 2, "color": "#A0E0FF"},
                {"name": "3 or more", "type": "PropertyIsGreaterThanOrEqualTo", "value": 3, "color": "#60CBFF"}
            ],
            "fixed_pots": [
                {"name": "2 or less", "type": "PropertyIsLessThanOrEqualTo", "value": 2, "color": "#A0E0FF"},
                {"name": "3", "type": "PropertyIsEqualTo", "value": 3, "color": "#60CBFF"},
                {"name": "4", "type": "PropertyIsEqualTo", "value": 4, "color": "#508BFF"},
                {"name": "5", "type": "PropertyIsEqualTo", "value": 5, "color": "#2020FF"},
                {"name": "6", "type": "PropertyIsEqualTo", "value": 6, "color": "#000040"},
                {"name": "7 or more", "type": "PropertyIsGreaterThanOrEqualTo", "value": 7, "color": "#380070"}
            ],
            "rsa_charterboats": [
                {"name": "2 or less", "type": "PropertyIsLessThanOrEqualTo", "value": 2, "color": "#A0E0FF"},
                {"name": "3", "type": "PropertyIsEqualTo", "value": 3, "color": "#60CBFF"},
                {"name": "4", "type": "PropertyIsEqualTo", "value": 4, "color": "#508BFF"},
                {"name": "5", "type": "PropertyIsEqualTo", "value": 5, "color": "#2020FF"},
                {"name": "6", "type": "PropertyIsEqualTo", "value": 6, "color": "#000040"},
                {"name": "7 or more", "type": "PropertyIsGreaterThanOrEqualTo", "value": 7, "color": "#380070"}
            ],
            "rsa_commercial": [
                {"name": "2 or less", "type": "PropertyIsLessThanOrEqualTo", "value": 2, "color": "#A0E0FF"},
                {"name": "3", "type": "PropertyIsEqualTo", "value": 3, "color": "#60CBFF"},
                {"name": "4", "type": "PropertyIsEqualTo", "value": 4, "color": "#508BFF"},
                {"name": "5", "type": "PropertyIsEqualTo", "value": 5, "color": "#2020FF"},
                {"name": "6 or more", "type": "PropertyIsGreaterThanOrEqualTo", "value": 6, "color": "#000040"}
            ],
            "rsa_noncharter": [
                {"name": "3 or less", "type": "PropertyIsLessThanOrEqualTo", "value": 3, "color": "#A0E0FF"},
                {"name": "4 - 7", "type": "PropertyIsBetween", "lower": 4, "upper": 7, "color": "#60CBFF"},
                {"name": "8 - 9", "type": "PropertyIsBetween", "lower": 8, "upper": 9, "color": "#508BFF"},
                {"name": "10 - 12", "type": "PropertyIsBetween", "lower": 10, "upper": 12, "color": "#2020FF"},
                {"name": "13 - 16", "type": "PropertyIsBetween", "lower": 13, "upper": 16, "color": "#000040"},
                {"name": "17 or more", "type": "PropertyIsGreaterThanOrEqualTo", "value": 17, "color": "#380070"}
            ],
            "rsa_shore": [
                {"name": "11 or less", "type": "PropertyIsLessThanOrEqualTo", "value": 11, "color": "#A0E0FF"},
                {"name": "12 - 21", "type": "PropertyIsBetween", "lower": 12, "upper": 21, "color": "#60CBFF"},
                {"name": "22 - 31", "type": "PropertyIsBetween", "lower": 22, "upper": 31, "color": "#508BFF"},
                {"name": "32 - 51", "type": "PropertyIsBetween", "lower": 32, "upper": 51, "color": "#2020FF"},
                {"name": "52 - 118", "type": "PropertyIsBetween", "lower": 52, "upper": 118, "color": "#000040"},
                {"name": "119 or more", "type": "PropertyIsGreaterThanOrEqualTo", "value": 119, "color": "#380070"}
            ],
            "cas_hand_gath": [
                {"name": "2 or less", "type": "PropertyIsLessThanOrEqualTo", "value": 2, "color": "#A0E0FF"},
                {"name": "3", "type": "PropertyIsEqualTo", "value": 3, "color": "#60CBFF"},
                {"name": "4 or more", "type": "PropertyIsGreaterThanOrEqualTo", "value": 4, "color": "#508BFF"}
            ],
            "pro_hand_gath": [
                {"name": "2 or less", "type": "PropertyIsLessThanOrEqualTo", "value": 2, "color": "#A0E0FF"},
                {"name": "3", "type": "PropertyIsEqualTo", "value": 3, "color": "#60CBFF"},
                {"name": "4 or more", "type": "PropertyIsGreaterThanOrEqualTo", "value": 4, "color": "#508BFF"}
            ],
        }
        data['bands'] = vessels_bands[layer]
    return data

if __name__ == '__main__':
    app.run(debug=True, processes=1)
