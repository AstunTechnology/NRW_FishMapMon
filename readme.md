Natural Resources Wales FishMap Mon
===================================

Dependencies
------------

The dependencies for the Python web applicaion are defined in webapp/REQUIREMENTS and can be installed using pip, it is assumed that the application is installed with a Python 2.7 virtualenv. Additional dependencies include:

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

## Install PhantomJS & CasperJS

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

Running the application
-----------------------

There are various ways to run a Python Flask web application including running under [Gunicorn](http://gunicorn.org/) using [Nginx](http://nginx.com/) as a front-end web server. The application sets HTTP headers to enable caching of most content including map images using something like [Varnish](https://www.varnish-cache.org/).

Configuration
-------------

The application requires the following configuration be set in it's environment:

### Required Enviroment Variables

* `FISHMAP_SALT` - The password salt used with authenticated users passwords
* `FISHMAP_PASSWORD` - Password for the fishmap database user
* `FISHMAP_DEV_USER` - Username of development superuser
* `FISHMAP_DEV_PASS` - Password of development superuser

### Optional Enviroment Variables

* `HTTP_AUTH_USER` - Username for basic HTTP auth (only required if the app is protected with basic auth)
* `HTTP_AUTH_PASS` - Password for basic HTTP auth (only required if the app is protected with basic auth)
* `FISHMAP_CONFIG_FILE` - Path to a configuration file that overrides settings in app.py

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

## WebServices

FishMap is expected to be run as two services behind a single front-end web server. 

### Web server
**Nginx** (sample config supplied) or similar. This is used to pass on dynamic requests to the two services and to serve static files.

*TODO*: Sample config update to serve static files.


### Webapp service
A **Flask** application listening to port 5000, spawned by a WSGI server like Gunicorn.

Can be started manually for development purposes.

*TODO*: Sample config for Gunicorn

### Geodata service
Ultimately this is Mapserver, but runs behind MapProxy to provide layer security.

*TODO*: Replace **lighttpd** config with MapProxy.


### MapServer 

#### Paths

Mapfiles: [project_root]/config/mapserver

Basemap data: [project_root]/data/BaseMapping

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

<table>
<caption>Arguments for each fishing activity in intensity calculations</caption>
<tr><th>FISHING          </th><th> ARG1      </th><th> ARG2       </th><th> ARG3       </th><th> ARG4      </th><th> ARG5</th></tr>
<tr><td>king_scallops    </td><td> days/year </td><td> speed      </td><td> avg. hours </td><td> net width </td><td> # boats</td></tr>
<tr><td>queen_scallops   </td><td> days/year </td><td> speed      </td><td> avg. hours </td><td> net width </td><td> # boats</td></tr>
<tr><td>mussels          </td><td> days/year </td><td> speed      </td><td> avg. hours </td><td> net width </td><td> # boats</td></tr>
<tr><td>lot              </td><td> days/year </td><td> speed      </td><td> avg. hours </td><td> net width </td><td> </td></tr>
<tr><td>nets             </td><td> days/year </td><td> net length </td><td> # nets     </td><td>           </td><td> </td></tr>
<tr><td>pots_combined    </td><td> days/year </td><td> # anchors  </td><td> # pots     </td><td>           </td><td> </td></tr>
<tr><td>rsa_charterboats </td><td> days/year </td><td> rods       </td><td> avg. hours </td><td>           </td><td> </td></tr>
<tr><td>rsa_combined     </td><td> days/year </td><td> rods       </td><td> avg. hours </td><td>           </td><td> </td></tr>
<tr><td>rsa_noncharter   </td><td> days/year </td><td> rods       </td><td> avg. hours  </td><td>           </td><td> </td></tr>
<tr><td>rsa_shore        </td><td> days/year </td><td> rods       </td><td> avg. hours  </td><td>           </td><td> </td></tr>
<tr><td>cas_hand_gath    </td><td> days/year </td><td> avg. hours </td><td> # people   </td><td>           </td><td> </td></tr>
<tr><td>pro_hand_gath    </td><td> days/year </td><td> avg. hours </td><td> # people   </td><td>           </td><td> </td></tr>
</table>

