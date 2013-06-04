Natural Resources Wales FishMap Mon
===================================

Dependencies
------------

The dependencies for the Python web applicaion are defined in webapp/REQUIREMENTS and can be installed using pip, it is assumed that the application is installed with a Python 2.7 virtualenv. Additional dependencies include:

* ppa:ubuntugis/ppa
    * cgi-mapserver
    * postgresql-9.1-postgis

Notes
-----

### Data

To create the OS raster tile index:

    cd ~/Downloads/naturalresourceswales/FMM/Data_for_Contractor/BaseMapping
    gdaltindex ./OS250k/os250k.shp ./OS250k/*.TIF

    This shouldn't be necessary if the expected Mapserver paths are used.

### Translations

#### Adding Translations

From the webapp directory first scan templates and python files for strings to translate by running:

    pybabel extract -F babel.cfg -o strings.pot .

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


#### MapServer

##### Paths

Mapfiles: /usr/share/mapserver
Basemap data: /usr/share/mapserver/data/fishmap/basemaps

##### Example URLs

* SLD
    * Single layer (English): http://localhost/en/sld?layers=intertidal_habitats
    * Multiple layers (Welsh): http://localhost/cy/sld?layers=project_area,intertidal_habitats

* Legends
    * English: http://localhost/geoservices/fishmap?LAYER=intertidal_habitats&VERSION=1.1.1&FORMAT=image%2Fpng&SERVICE=WMS&REQUEST=GetLegendGraphic&SLD=http%3A//localhost%3A5000/en/sld%3Flayers%3Dintertidal_habitats
    * Welsh: http://localhost/geoservices/fishmap?LAYER=intertidal_habitats&VERSION=1.1.1&FORMAT=image%2Fpng&SERVICE=WMS&REQUEST=GetLegendGraphic&SLD=http%3A//localhost%3A5000/cy/sld%3Flayers%3Dintertidal_habitats

* Map
    * http://localhost/geoservices/fishmap?LAYERS=subtidal_habitats&VERSION=1.1.1&FORMAT=image%2Fpng&TRANSPARENT=TRUE&SERVICE=WMS&REQUEST=GetMap&STYLES=&SRS=EPSG%3A27700&BBOX=221800,352075,275000,385125&WIDTH=1064&HEIGHT=661&SLD=http%3A//localhost%3A5000/en/sld%3Flayers%3Dsubtidal_habitats

* GetFeatureInfo
    * GML: localhost/geoservices/fishmap?LAYERS=intertidal_habitats&QUERY_LAYERS=intertidal_habitats&STYLES=&SERVICE=WMS&VERSION=1.1.1&REQUEST=GetFeatureInfo&BBOX=246750%2C368462.5%2C273350%2C374937.5&FEATURE_COUNT=10&HEIGHT=259&WIDTH=1064&FORMAT=image%2Fpng&INFO_FORMAT=application/vnd.ogc.gml&SRS=EPSG%3A27700&X=603&Y=47
