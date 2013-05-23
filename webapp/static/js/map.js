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

    map = new OpenLayers.Map('map', {
        projection: "EPSG:27700",
        units: "m",
        maxExtent: new OpenLayers.Bounds(-3276800,-3276800,3276800,3276800),
        controls: controls
    });

    var os = wmsLayer(
        "OS Map",
        'http://localhost/cgi-bin/mapserv?map=/home/matt/Software/FishMap/config/mapserver/os.map',
        {
            layers: 'os',
            transparent: false
        },
        {
            resolutions: [2.5, 5, 10, 25, 50, 100, 150]
        }
    );
    map.addLayer(os);

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

    // var base_osm = new OpenLayers.Layer.OSM("OpenStreetMap");
    // map.addLayer(base_osm);

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

    map.setCenter(new OpenLayers.LonLat(241500, 379000), 10);

    // map.setCenter(
    //     new OpenLayers.LonLat(-4.356, 53.286).transform(
    //         new OpenLayers.Projection("EPSG:4326"),
    //         map.getProjectionObject()
    //     ),
    //     10
    // );

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
                            // projection: 'EPSG:900913',
                            projection: 'EPSG:27700',
                            singleTile: true,
                            buffer: 0,
                            ratio: 1
                        })
                );
        map.addLayer(lyr);
        return lyr;
    }
})();
