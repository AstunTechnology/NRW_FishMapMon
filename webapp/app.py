from flask import Flask
from flask import render_template
from flask import request

app = Flask(__name__)


@app.route('/')
def home():
    return render_template('index.html')


@app.route('/sld')
def sld():
    layer = request.args.get('layer')
    return render_template(('%s.sld' % layer))


if __name__ == '__main__':
    app.run(debug=True)
