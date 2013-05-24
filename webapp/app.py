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

app = Flask(__name__)
app.register_blueprint(fm)
babel = Babel(app)


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


@app.route('/sld')
def sld():
    layers = request.args.get('layers')
    if layers:
        layers = ['%s.sld' % layer for layer in layers.split(',')]
        resp = make_response(render_template('base.sld', layers=layers))
        resp.headers['Content-Type'] = 'text/xml'
        return resp
    else:
        return ('Please specify one or more layers', 500)


if __name__ == '__main__':
    app.run(debug=True)
