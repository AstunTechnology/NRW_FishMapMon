import os
import requests

from flask import Blueprint
from flask import Flask
from flask import g
from flask import make_response
from flask import redirect
from flask import render_template
from flask import request
from flask import url_for
from flask.ext.security import RoleMixin
from flask.ext.security import Security
from flask.ext.security import SQLAlchemyUserDatastore
from flask.ext.security import UserMixin
from flask.ext.security import current_user
from flask.ext.security import login_required
from flask.ext.sqlalchemy import SQLAlchemy
from flask_mail import Mail
from flaskext.babel import Babel

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
app.config['SECURITY_RECOVERABLE'] = True
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
    auth_db.create_all()


@app.before_request
def before_request():
    set_locale()
    g.user = current_user


@app.route('/')
def home():
    return render_template('index.html', user=g.user)


@app.route('/wms')
def wms():

    try:
        args = update_wms_args(request.args.copy(), g.user)
    except (InvalidWmsArgs) as ex:
        return (ex.message, 500)

    layers = args.get('LAYERS') or args.get('LAYER')
    sld = render_sld(layers.split(','))
    args['SLD_BODY'] = sld

    # Set the MapServer map parameter specifiying a path relative the this app
    args['map'] = \
        '%s/../config/mapserver/%s.map' % (app.root_path, args.get('map'))

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


def update_wms_args(args, user):
    """ Update the WMS request parameters before they are passed to the back
    end. Raises InvalidWmsArgs if the args to be returned are invalid such as
    the LAYER or LAYERS arg does not have a value """

    # Update the LAYER of LAYERS parameter
    layers = None
    layer_arg = next((a for a in ['LAYERS', 'LAYER'] if a in args), None)
    if layer_arg:
        layers = update_wms_layers(args[layer_arg].split(','), user)

    if layers:
        layers = ','.join(layers)
    else:
        raise InvalidWmsArgs('No valid layers')

    args[layer_arg] = layers

    # Check QUERY_LAYERS passed by GetFeatureInfo in addition to LAYERS
    if 'QUERY_LAYERS' in args:
        args['QUERY_LAYERS'] = layers

    return args


def update_wms_layers(layers, user):
    """ Updates a list of layers to remove restricted layers if the user is not
    logged in and add the appropriate suffix to project output layers depending
    no whether a user is logged in or not """

    def update_layer(layer):
        """ Updates project output layers to include the _det or _gen suffix
        based on whether the user is logged in or not. All other layers just
        pass through with the same name """
        if layer.startswith(('intensity', 'vessels')):
            suffix = '_det' if user else '_gen'
            return '%s%s' % (layer, suffix)
        return layer

    def authorise_layer(layer):
        """ Tests if the current user has access to the specified layer """
        restricted_layers = [
            'activity_commercial_fishing_polygon',
            'activity_noncommercial_fishing_point',
            'activity_noncommercial_fishing_polygon']
        return layer not in restricted_layers or user

    layers = [
        update_layer(layer)
        for layer in layers
        if authorise_layer(layer)
    ]

    return layers


def render_sld(layers):
    """ Render an SLD document as a string for the list of layers passed """
    if layers:
        layer_info = []
        common_slds = ['intensity', 'vessels', 'sensitivity']
        for layer in layers:
            template = '%s.sld' % layer
            split_layer = layer.split('_')
            if split_layer[0] in common_slds:
                template = '%s.sld' % split_layer[0]
            layer_info.append({'template': template, 'name': layer})
        return render_template('base.sld', layer_info=layer_info)


if __name__ == '__main__':
    app.run(debug=True, processes=1)
