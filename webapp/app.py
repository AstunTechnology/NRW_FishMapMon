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
    args = request.args.copy()

    def update_layer(layer):
        """ Updates project output layers to include the _det or _gen suffix
        based on whether the user is logged in or not. All other layers just
        pass through with the same name """
        if layer.startswith(('intensity', 'vessels')):
            suffix = '_det' if g.user else '_gen'
            return '%s%s' % (layer, suffix)
        return layer

    def authorise_layer(layer):
        """ Tests if the current user has access to the specified layer """
        restricted_layers = [
            'activity_commercial_fishing_polygon',
            'activity_noncommercial_fishing_point',
            'activity_noncommercial_fishing_polygon']
        return layer not in restricted_layers or g.user

    # Check the LAYERS parameter passed with GetMap and GetFeatrueInfo requests
    if 'LAYERS' in args:
        layers = args['LAYERS'].split(',')

        layers = [
            update_layer(layer)
            for layer in layers
            if authorise_layer(layer)
        ]

        if layers:
            layers = ','.join(layers)
        else:
            return ('No valid layers', 500)

        args['LAYERS'] = layers

        # Check QUERY_LAYERS passed by GetFeatureInfo in addition to LAYERS
        if 'QUERY_LAYERS' in args:
            args['QUERY_LAYERS'] = layers

    # Check the LAYER parameter passed by GetLegendInfo
    if 'LAYER' in args:
        layer = args['LAYER']
        if authorise_layer(layer):
            args['LAYER'] = update_layer(layer)
        else:
            return ('No valid layers', 500)

    # Add SLD parameter for all layers passed. A single LAYER parameter will be
    # passed for GetLegendInfo while LAYERS is passed with GetMap
    layer_arg = next((a for a in ['LAYERS', 'LAYER'] if a in args), None)
    if layer_arg:
        args['SLD'] = url_for(
            '.sld',
            layers='%s' % args[layer_arg],
            _external=True
        )

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


if __name__ == '__main__':
    app.run(debug=True, processes=8)
