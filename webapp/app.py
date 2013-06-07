from flask import Blueprint
from flask import Flask
from flask import g
from flask import make_response
from flask import redirect
from flask import render_template
from flask import request
from flask import url_for
from flaskext.babel import Babel
import requests

LOCALES = {
    'en': 'English',
    'cy': 'Cymraeg',
}

fm = Blueprint('fishmap', __name__, url_prefix='/<locale>')


@fm.url_defaults
def add_language_code(endpoint, values):
    values.setdefault('locale', g.locale)


@fm.url_value_preprocessor
def pull_locale(endpoint, values):
    g.locale = values.pop('locale')


@fm.before_request
def before_request_fm():
    if not hasattr(g, 'other_locales') or g.locale in g.other_locales:
        g.other_locales = dict()
        for locale in LOCALES:
            if locale != g.locale:
                g.other_locales[locale] = LOCALES[locale]
    # Mock user
    g.user = False


@fm.route('/')
def home():
    return render_template('index.html', user=g.user)


@fm.route('/wms')
def wms():

    try:
        args = update_wms_args(request.args.copy(), g.user)
    except (InvalidWmsArgs) as ex:
        return (ex.message, 500)

    r = requests.get(
        '%s%s.map' % (app.config['WMS_URL'], request.args.get('map')),
        params=args
    )

    app.logger.debug('WMS Request: %s' % r.url)

    resp = make_response(r.content)
    resp.headers['Content-Type'] = r.headers['Content-Type']

    return resp


@fm.route('/sld')
def sld():
    resp = ''
    layers = request.args.get('layers')
    if layers:
        layer_info = []
        common_slds = ['intensity', 'vessels', 'sensitivity']
        for layer in layers.split(','):
            template = '%s.sld' % layer
            split_layer = layer.split('_')
            if split_layer[0] in common_slds:
                template = '%s.sld' % split_layer[0]
            layer_info.append({'template': template, 'name': layer})
        resp = make_response(
            render_template('base.sld', layer_info=layer_info)
        )
        resp.headers['Content-Type'] = 'text/xml'
    return resp


app = Flask(__name__)
app.register_blueprint(fm)
babel = Babel(app)

# Set basic config
app.config['WMS_URL'] = 'http://127.0.0.1:5001/cgi-bin/mapserv?' \
                        'map=%s/../config/mapserver/' % app.root_path


@babel.localeselector
def get_locale():
    return g.locale


@app.before_request
def before_request():
    if not hasattr(g, 'locale'):
        g.locale = request.accept_languages.best_match(LOCALES.keys())


@app.route('/')
def redirect_to_home():
    return redirect(url_for('fishmap.home', locale=g.locale))


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

    # Add SLD parameter for all layers passed. A single LAYER parameter will be
    # passed for GetLegendInfo while LAYERS is passed with GetMap
    args['SLD'] = url_for(
        '.sld',
        layers='%s' % layers,
        _external=True
    )

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


if __name__ == '__main__':
    app.run(debug=True, processes=8)
