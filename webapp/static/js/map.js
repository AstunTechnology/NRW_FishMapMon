(function(){

    var controls = [
        new OpenLayers.Control.TouchNavigation({
            dragPanOptions: {
                enableKinetic: true
            }
        }),
        new OpenLayers.Control.Attribution(),
        new OpenLayers.Control.Scale(),
        new OpenLayers.Control.Navigation(),
        new OpenLayers.Control.LayerSwitcher(),
        new OpenLayers.Control.MousePosition(),
        new OpenLayers.Control.PanZoomBar()
    ];

    map = new OpenLayers.Map('map', {controls: controls});

    var charts = wmsLayer(
        "Charts",
        'http://localhost/cgi-bin/mapserv?map=/home/matt/Software/FishMap/config/mapserver/charts.map',
        {
            layers: 'charts',
            transparent: false
        },
        {
            resolutions: [4, 8, 12, 25, 75, 150, 300]
        }
    );
    map.addLayer(charts);

    var base_osm = new OpenLayers.Layer.OSM("OpenStreetMap");
    map.addLayer(base_osm);

    var project_area = wmsLayer(
        "Overlays",
        'http://localhost/cgi-bin/mapserv?map=/home/matt/Software/FishMap/config/mapserver/fishmap.map',
        {
            // layers: 'project_area,subtidal_habitats'
            layers: 'project_area'
        },
        {}
    );
    map.addLayer(project_area);

    map.setCenter(
        new OpenLayers.LonLat(-4.356, 53.286).transform(
            new OpenLayers.Projection("EPSG:4326"),
            map.getProjectionObject()
        ),
        10
    );

    function wmsLayer(name, path, wms_options, layer_options) {
        var urls = path;
        var lyr = new OpenLayers.Layer.WMS(name, urls,
                    OpenLayers.Util.applyDefaults(wms_options,
                        {
                            version: '1.1.1',
                            format: 'image/png',
                            transparent: true
                        }),
                    OpenLayers.Util.applyDefaults(layer_options,
                        {
                            projection: 'EPSG:900913',
                            singleTile: true,
                            buffer: 0,
                            ratio: 1
                        })
                );
        map.addLayer(lyr);
        return lyr;
    }
})();
