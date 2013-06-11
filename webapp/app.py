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
from flaskext.babel import Babel

LOCALES = {
    'en': 'English',
    'cy': 'Cymraeg',
}


app = Flask(__name__)
babel = Babel(app)

# Set basic config
app.config['WMS_URL'] = 'http://127.0.0.1:5001/cgi-bin/mapserv?'
# Import local settings
if os.environ.get('FISHMAP_CONFIG_FILE'):
    app.config.from_envvar('FISHMAP_CONFIG_FILE')


@babel.localeselector
def get_locale():
    return g.locale


@app.before_request
def before_request():
    if not hasattr(g, 'locale'):
        g.locale = request.accept_languages.best_match(LOCALES.keys())
        if('locale' in request.args):
            l = request.args.get('locale')
            if l in LOCALES.keys():
                g.locale = l

    if not hasattr(g, 'locale_uris') and 'LOCALE_HOSTS' in app.config:
        g.locale_uris = dict()
        for locale in app.config['LOCALE_HOSTS']:
            if locale in LOCALES and app.config['LOCALE_HOSTS'][locale]:
                g.locale_uris[locale] = app.config['LOCALE_HOSTS'][locale]


    if not hasattr(g, 'other_locales') or g.locale in g.other_locales:
        g.other_locales = dict()
        for locale in LOCALES:
            if locale != g.locale:
                g.other_locales[locale] = LOCALES[locale]
    # Mock user
    g.user = False


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
    app.run(debug=True, processes=8)
