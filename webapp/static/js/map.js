(function(){

    var overlayLayers =
        [
            {
                "id": "project_area_grp", 
                "layers": [
                    {
                        "id": "project_area", 
                        "visible": true,
                        "info": false, 
                        "legend": false
                    }
                ]
            }, 
            {
                "id": "habitats_grp", 
                "layers": [
                    {
                        "id": "intertidal_habitats", 
                        "visible": false,
                        "info": true, 
                        "legend": true
                    }, 
                    {
                        "id": "subtidal_habitats", 
                        "visible": false,
                        "info": true, 
                        "legend": true
                    }, 
                    {
                        "id": "subtidal_habitats_confidence", 
                        "visible": false,
                        "info": true, 
                        "legend": true
                    }
                ]
            }
        ];

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
            resolutions: [4, 8, 12, 25, 75, 150]
        }
    );
    map.addLayer(charts);

    var overlays = wmsLayer(
        "Overlays",
        'http://localhost/cgi-bin/mapserv?map=/home/matt/Software/FishMap/config/mapserver/fishmap.map',
        {
            layers: getVisibleOverlays(overlayLayers).join(',')
        },
        {}
    );
    map.addLayer(overlays);

    map.setCenter(new OpenLayers.LonLat(241500, 379000), 10);

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

    function getVisibleOverlays(groups) {
        var visible = [];
        for (var m = 0, grp; m < groups.length; m++) {
            grp = groups[m];
            for (var n = 0, lyr; n < grp.layers.length; n++) {
                lyr = grp.layers[n];
                if (lyr.visible) {
                    visible.push(lyr.id);
                }
            }
        }
        return visible;
    }

    function getLayerById(groups, id) {
        for (var m = 0, grp; m < groups.length; m++) {
            grp = groups[m];
            for (var n = 0, lyr; n < grp.layers.length; n++) {
                lyr = grp.layers[n];
                if (lyr.id === id) {
                    return lyr;
                }
            }
        }
    }

    function layer_toggle(groups, id, visible) {
        // Update the model
        getLayerById(groups, id).visible = visible;
        // Refresh the overlay WMS layer
        var visibleLayers = getVisibleOverlays(groups);
        // Hide the layer if there are no visible layers to avoid an invalid
        // WMS request being generated
        overlays.setVisibility(visibleLayers.length);
        overlays.mergeNewParams({'LAYERS': visibleLayers.join(',')});
    }

    createLayerTree(overlayLayers, jQuery('.overlays'), layer_toggle);

    function createLayerTree(groups, container, toggleCallback) {
        var tmpl = jQuery('#treeTmpl').html();
        var treeElm = jQuery.mustache(tmpl, {"groups": groups});
        // console.log(treeElm);
        var tree$ = jQuery(container).append(treeElm);
        tree$.find('input').change(function() {
            toggleCallback(groups, this.value, this.checked);
        });
    }

})();

