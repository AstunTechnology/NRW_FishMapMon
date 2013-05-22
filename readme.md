Natural Resources Wales FishMap Mon
===================================

Set-up notes
------------

All data is displayed in Spherical Mercator, to enable MapServer to output data in this format the following definition must be added to /usr/share/proj/epsg:

`<900913> +proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs`

Notes
-----

To create the OS raster tile index:

`cd ~/Downloads/naturalresourceswales/FMM/Data_for_Contractor/BaseMapping`
`gdaltindex ./OS250k/os250k.shp ./OS250k/*.TIF`
