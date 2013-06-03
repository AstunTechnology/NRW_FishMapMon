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


@fm.route('/')
def home():
    return render_template('index.html')


@fm.route('/wms')
def wms():
    r = requests.get(
        '%s%s.map' % (app.config['WMS_URL'], request.args.get('map')),
        params=request.args
    )
    resp = make_response(r.content)
    resp.headers['Content-Type'] = r.headers['Content-Type']
    return resp


@fm.route('/sld')
def sld():
    layers = request.args.get('layers')
    if layers:
        layer_info = []
        for layer in layers.split(','):
            template = '%s.sld' % layer
            if layer.startswith('intensity_'):
                template = 'intensity.sld'
            if layer.startswith('vessels_'):
                template = 'vessels.sld'
            if layer.startswith('sensitivity_'):
                template = 'sensitivity.sld'
            layer_info.append({'template': template, 'name': layer})
        resp = make_response(
            render_template('base.sld', layer_info=layer_info)
        )
        resp.headers['Content-Type'] = 'text/xml'
        return resp
    else:
        return ''


app = Flask(__name__)
app.register_blueprint(fm)
babel = Babel(app)

# Set basic config
app.config['WMS_URL'] = 'http://localhost/cgi-bin/mapserv?' \
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
    app.run(debug=True, processes=4)
