Natural Resources Wales FishMap Mon
===================================

Dependencies
------------

The dependencies for the Python web application are defined in webapp/REQUIREMENTS and can be installed using pip, it is assumed that the application is installed with a Python 2.7 virtualenv. Additional dependencies include:

From `ppa:ubuntugis/ppa`:

* `cgi-mapserver`
* `postgresql-9.1-postgis`

For fuzzy search:

* `postgresql-contrib`

For Python PostgreSQL driver

* `python-dev`
* `libpq-dev`

For Export Image functionality:

* `redis-server`
* `phantomjs`
* `casperjs`

### Install PhantomJS & CasperJS

    # All software installed in /usr/local/src
    cd /usr/local/src

    # Install PhantomJS
    sudo wget https://phantomjs.googlecode.com/files/phantomjs-1.9.2-linux-x86_64.tar.bz2
    sudo tar -xvf phantomjs-1.9.2-linux-x86_64.tar.bz2
    sudo mv phantomjs-1.9.2-linux-x86_64 phantomjs
    sudo ln -sf /usr/local/src/phantomjs/bin/phantomjs /usr/local/bin/phantomjs

    # Install CasperJS
    sudo git clone git://github.com/n1k0/casperjs.git
    sudo ln -sf /usr/local/src/casperjs/bin/casperjs /usr/local/bin/casperjs

### Install Python dependencies

It is recommended that python-virtualenv (or virtualenvwrapper) are used to create a standalone environment for the application. Installing either package will provide access to `pip` the Python package manager which can be used to install all Python dependencies. The file `webapp/REQUIREMENTS` contains a list of all of the packages and their versions. Once the virtual environment is activated run `pip pip install -r REQUIREMENTS` from the `webapp` directory.

Running the application
-----------------------

### Development

During development the application can be run using the builtin Flask web server. Simply run `python app.py` from the `webapp` directory once you have activated the virtual environment and installed the dependencies. The application will then be available at: http://localhost:5000/

### Production

In production there are various ways to run a Python Flask web application including running under [Gunicorn](http://gunicorn.org/) using [Nginx](http://nginx.com/) as a front-end web server. The application sets HTTP headers to enable caching of most content including map images using something like [Varnish](https://www.varnish-cache.org/).

Configuration
-------------

The application requires the following configuration be set in it's environment:

### Required Environment Variables

* `FISHMAP_SALT` - The password salt used with authenticated users passwords
* `FISHMAP_PASSWORD` - Password for the fishmap database user
* `FISHMAP_DEV_USER` - Username of development superuser
* `FISHMAP_DEV_PASS` - Password of development superuser

### Optional Environment Variables

* `HTTP_AUTH_USER` - Username for basic HTTP auth (only required if the app is protected with basic auth)
* `HTTP_AUTH_PASS` - Password for basic HTTP auth (only required if the app is protected with basic auth)
* `FISHMAP_CONFIG_FILE` - Path to a configuration file that overrides settings in app.py

### Overriding Configuration

The default configuration in `app.py` can be overridden by specifying a configuration to load via the `FISHMAP_CONFIG_FILE` environment variable which must point to a Python ini style configuration file with a value per line.

### MapServer encryption key

The password used to connect to the PostgreSQL database within the MapServer mapfile is encrypted. In order to render maps do the following:

Create a key file:

    msencrypt -keygen fishmap.key

Generate an encrypted password and update `config/mapserver/pgconnection.inc` with the value output:

    msencrypt -key fishmap.key "<password>"

Update the `MS_ENCRYPTION_KEY` setting in `config/mapserver/fishmap.map` with the path to your key file.

Further details on [msencrypt are available in the MapServer docs](http://www.mapserver.org/utilities/msencrypt.html).

Notes
-----

### Data

To create the OS raster tile index:

    cd data/BaseMapping
    gdaltindex ./OS250k/os250k.shp ./OS250k/*.tif

### Translations

From the webapp directory first scan templates and python files for strings to translate by running:

    pybabel extract -F babel.cfg -k lazy_gettext -o strings.pot .

Create files for all languages that contain the translated text:

    pybabel update -i strings.pot -d translations

Edit translations/cy/LC_MESSAGES/messages.po to add the msgstr value for each string that needs translating. Then to compile run:

    pybabel compile -f -d translations

#### Custom parameters

For requests made to show impact of project area selection the following custom parameters are used:

* Vessels (vessels\_lvl\_project\_det and vessels\_lvl\_project\_gen)
    * FISHING (name of type of fishing as used in other layers and underlying tables)
    * COUNT (number of vessels in custom area(s))
    * WKT (WKT representation of project area(s))
* Intensity (project\_intensity\_lvls\_new\_det, project\_intensity\_lvls\_new\_gen, project\_intensity\_lvls\_combined\_det and project\_intensity\_lvls\_combined\_gen)
    * FISHING (name of type of fishing as used in other layers and underlying tables)
    * WKT (WKT representation of project area(s))
    * ARGn (number of numeric arguments, see below as to what they refer to for each FISHING type)

Arguments for each fishing activity in intensity calculations

    | FISHING          | ARG1      | ARG2       | ARG3       | ARG4      | ARG5    |
    -------------------------------------------------------------------------------
    | king_scallops    | days/year | speed      | avg. hours | net width | # boats |
    | queen_scallops   | days/year | speed      | avg. hours | net width | # boats |
    | mussels          | days/year | speed      | avg. hours | net width | # boats |
    | lot              | days/year | speed      | avg. hours | net width |         |
    | nets             | days/year | net length | # nets     |           |         |
    | pots_combined    | days/year | # anchors  | # pots     |           |         |
    | rsa_charterboats | days/year | rods       | avg. hours |           |         |
    | rsa_combined     | days/year | rods       | avg. hours |           |         |
    | rsa_noncharter   | days/year | rods       | avg. hours |           |         |
    | rsa_shore        | days/year | rods       | avg. hours |           |         |
    | cas_hand_gath    | days/year | avg. hours | # people   |           |         |
    | pro_hand_gath    | days/year | avg. hours | # people   |           |         |
