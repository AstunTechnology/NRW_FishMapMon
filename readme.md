Natural Resources Wales FishMap Mon
===================================

Set-up notes
------------

All data is displayed in Spherical Mercator, to enable MapServer to output data in this format the following definition must be added to /usr/share/proj/epsg:

    <900913> +proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs

Notes
-----

### Data

To create the OS raster tile index:

    cd ~/Downloads/naturalresourceswales/FMM/Data_for_Contractor/BaseMapping
    gdaltindex ./OS250k/os250k.shp ./OS250k/*.TIF

### Translations

#### Adding Translations

From the webapp directory first scan templates and python files for strings to translate by running:

    pybabel extract -F babel.cfg -o strings.pot .

Create files for all languages that contain the translated text:

    pybabel update -i strings.pot -d translations

Edit translations/cy/LC_MESSAGES/messages.po to add the msgstr value for each string that needs translating. Then to compile run:

    pybabel compile -f -d translations

### MapServer

#### Paths

We need to work out how to handle the following paths which are currently hard coded:

* Path to mapfiles
* Path to data

#### Example URLs

* SLD
** Single layer (English): http://localhost:5000/en/sld?layers=intertidal_habitats
** Multiple layers (Welsh): http://localhost:5000/cy/sld?layers=project_area,intertidal_habitats

* Legends
** English: http://localhost/cgi-bin/mapserv?map=/home/matt/Software/FishMap/config/mapserver/fishmap.map&LAYER=intertidal_habitats&VERSION=1.1.1&FORMAT=image%2Fpng&SERVICE=WMS&REQUEST=GetLegendGraphic&SLD=http%3A//localhost%3A5000/en/sld%3Flayers%3Dintertidal_habitats
** Welsh: http://localhost/cgi-bin/mapserv?map=/home/matt/Software/FishMap/config/mapserver/fishmap.map&LAYER=intertidal_habitats&VERSION=1.1.1&FORMAT=image%2Fpng&SERVICE=WMS&REQUEST=GetLegendGraphic&SLD=http%3A//localhost%3A5000/cy/sld%3Flayers%3Dintertidal_habitats

* Map
** http://localhost/cgi-bin/mapserv?map=/home/matt/Software/FishMap/config/mapserver/fishmap.map&LAYERS=subtidal_habitats&VERSION=1.1.1&FORMAT=image%2Fpng&TRANSPARENT=TRUE&SERVICE=WMS&REQUEST=GetMap&STYLES=&SRS=EPSG%3A27700&BBOX=221800,352075,275000,385125&WIDTH=1064&HEIGHT=661&SLD=http%3A//localhost%3A5000/en/sld%3Flayers%3Dsubtidal_habitats
