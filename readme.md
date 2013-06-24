Natural Resources Wales FishMap Mon
===================================

Dependencies
------------

The dependencies for the Python web applicaion are defined in webapp/REQUIREMENTS and can be installed using pip, it is assumed that the application is installed with a Python 2.7 virtualenv. Additional dependencies include:

* ppa:ubuntugis/ppa
    * cgi-mapserver
    * postgresql-9.1-postgis

For fuzzy search:
* postgresql-contrib

For Python PostgreSQL driver
* python-dev
* libpq-dev

Notes
-----

### Data

To create the OS raster tile index:

    cd ~/Downloads/naturalresourceswales/FMM/Data_for_Contractor/BaseMapping
    gdaltindex ./OS250k/os250k.shp ./OS250k/*.TIF

    This shouldn't be necessary if the expected Mapserver paths are used.

### Translations

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
<tr><td>fixed_pots       </td><td> days/year </td><td> # anchors  </td><td> # pots     </td><td>           </td><td> </td></tr>
<tr><td>rsa_charterboats </td><td> days/year </td><td> avg. hours </td><td> # rods     </td><td>           </td><td> </td></tr>
<tr><td>rsa_commercial   </td><td> days/year </td><td> avg. hours </td><td> # rods     </td><td>           </td><td> </td></tr>
<tr><td>rsa_noncharter   </td><td> days/year </td><td> avg. hours </td><td> # rods     </td><td>           </td><td> </td></tr>
<tr><td>rsa_shore        </td><td> days/year </td><td> avg. hours </td><td> # rods     </td><td>           </td><td> </td></tr>
<tr><td>cas_hand_gath    </td><td> days/year </td><td> avg. hours </td><td> # people   </td><td>           </td><td> </td></tr>
<tr><td>pro_hand_gath    </td><td> days/year </td><td> avg. hours </td><td> # people   </td><td>           </td><td> </td></tr>
</table>



#### Example URLs

* SLD
    * Single layer (English): http://localhost/en/sld?layers=intertidal_habitats
    * Multiple layers (Welsh): http://localhost/cy/sld?layers=project_area,intertidal_habitats

* Legends
    * English: http://localhost/en/wms/map=fishmap?LAYER=intertidal_habitats&VERSION=1.1.1&FORMAT=image%2Fpng&SERVICE=WMS&REQUEST=GetLegendGraphic&SLD=http%3A//localhost%3A5000/en/sld%3Flayers%3Dintertidal_habitats
    * Welsh: http://localhost/cy/wms/map=fishmap?LAYER=intertidal_habitats&VERSION=1.1.1&FORMAT=image%2Fpng&SERVICE=WMS&REQUEST=GetLegendGraphic&SLD=http%3A//localhost%3A5000/cy/sld%3Flayers%3Dintertidal_habitats

* Map
    * http://localhost/en/wms/map=fishmap?LAYERS=subtidal_habitats&VERSION=1.1.1&FORMAT=image%2Fpng&TRANSPARENT=TRUE&SERVICE=WMS&REQUEST=GetMap&STYLES=&SRS=EPSG%3A27700&BBOX=221800,352075,275000,385125&WIDTH=1064&HEIGHT=661&SLD=http%3A//localhost%3A5000/en/sld%3Flayers%3Dsubtidal_habitats
    * Calling with custom parameters for project - http://localhost/wms?map=fishmap&LAYERS=project_area%2Cvessels_lvls_project&VERSION=1.1.1&FORMAT=image%2Fpng&TRANSPARENT=TRUE&SERVICE=WMS&REQUEST=GetMap&STYLES=&SRS=EPSG%3A27700&BBOX=170375,315250,317075,445000&WIDTH=978&HEIGHT=865&FISHING=king_scallops&WKT=POLYGON((257765%20399710,%20271127%20408059,%20266732%20401588,%20260503%20396375,%20257765%20399710))&COUNT=1


* GetFeatureInfo
    * GML: localhost/en/wms/map=fishmap?LAYERS=intertidal_habitats&QUERY_LAYERS=intertidal_habitats&STYLES=&SERVICE=WMS&VERSION=1.1.1&REQUEST=GetFeatureInfo&BBOX=246750%2C368462.5%2C273350%2C374937.5&FEATURE_COUNT=10&HEIGHT=259&WIDTH=1064&FORMAT=image%2Fpng&INFO_FORMAT=application/vnd.ogc.gml&SRS=EPSG%3A27700&X=603&Y=47

