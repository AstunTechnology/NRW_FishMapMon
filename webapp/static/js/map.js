(function(){

    window.FISH_MAP.ROOT_URL = window.location.protocol + '//' + window.location.host + window.location.pathname;
    window.FISH_MAP.SLD_URL = FISH_MAP.ROOT_URL + 'sld?layers=';

    window.FISH_MAP.WMS_ROOT_URL = window.location.protocol + '//' + window.location.host + '/cgi-bin/mapserv?map=/home/matt/Software/FishMap/config/mapserver/';
    window.FISH_MAP.WMS_OVERLAY_URL = FISH_MAP.WMS_ROOT_URL + 'fishmap.map';
    window.FISH_MAP.WMS_OS_URL = FISH_MAP.WMS_ROOT_URL + 'os.map';
    window.FISH_MAP.WMS_CHARTS_URL = FISH_MAP.WMS_ROOT_URL + 'charts.map';

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
                        "visible": true,
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

    // Allow layers to be quickly looked up on layer name
    overlayLayers.layers = {};
    for (var m = 0, grp; m < overlayLayers.length; m++) {
        grp = overlayLayers[m];
        for (var n = 0, lyr; n < grp.layers.length; n++) {
            lyr = grp.layers[n];
            overlayLayers.layers[lyr.id] = lyr;
        }
    }

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
        FISH_MAP.WMS_OS_URL,
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
        FISH_MAP.WMS_CHARTS_URL,
        {
            layers: 'charts',
            transparent: false
        },
        {
            resolutions: [4, 8, 12, 25, 75, 150]
        }
    );
    map.addLayer(charts);

    var visibleOverlays = getVisibleOverlays(overlayLayers);
    var overlays = wmsLayer(
        "Overlays",
        FISH_MAP.WMS_OVERLAY_URL,
        {
            layers: visibleOverlays.join(','),
            sld: FISH_MAP.SLD_URL + visibleOverlays.join(',')
        },
        {}
    );
    map.addLayer(overlays);

    var legendPanel = new OpenLayers.Control.LegendPanel({layers: [overlays]});
    map.addControl(legendPanel);
    legendPanel.showLayers(visibleOverlays);

    info = new OpenLayers.Control.WMSGetFeatureInfo({
        url: FISH_MAP.WMS_OVERLAY_URL, 
        infoFormat: 'application/vnd.ogc.gml',
        queryVisible: true,
        eventListeners: {
            beforegetfeatureinfo: function(event) {

                this.popup = new OpenLayers.Popup.FramedCloud(
                    'info',
                    map.getLonLatFromPixel(event.xy),
                    null,
                    '<div id="popup_content"><p class="loading">Loading...</p></div>',
                    null,
                    true
                );
                this.map.addPopup(this.popup, true);

            },
            getfeatureinfo: function(event) {

                var features = [];
                for (var i = 0, feature; i < event.features.length; i++) {
                    feature = event.features[i];
                    if (overlayLayers.layers[feature.type].info) {
                        features.push(feature);
                    }
                }

                if (features.length) {

                    // Assign features to an lookup keyed on layer name
                    // for use in the template
                    var lookup = {
                        "lang": function() {
                            return function(id) {
                                // console.log(id);
                                return window.FISH_MAP.text[id];
                            }
                        }
                    };

                    for (var i = 0, feature; i < features.length; i++) {
                        feature = features[i];
                        if (!lookup[feature.type]) {
                            lookup[feature.type] = {
                                features: []
                            };
                        }
                        lookup[feature.type].features.push(feature);
                    }

                    var content = jQuery('#popup_content');
                    jQuery('.loading', content).detach();

                    var tmpl = jQuery('#infoTmpl').html();
                    var html = jQuery.mustache(tmpl, lookup);
                    content.append(jQuery.mustache(tmpl, lookup));
                    this.popup.updateSize();

                } else {

                    this.map.removePopup(this.popup);

                }

            }
        }
    });
    map.addControl(info);
    info.activate();

    map.setCenter(new OpenLayers.LonLat(260050, 371700), 3);
    // map.setCenter(new OpenLayers.LonLat(241500, 379000), 10);

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

    function layer_toggle(groups, id, visible) {
        // Update the model
        getLayerById(groups, id).visible = visible;
        // Refresh the overlay WMS layer
        var visibleLayers = getVisibleOverlays(groups);
        // Hide the layer if there are no visible layers to avoid an invalid
        // WMS request being generated
        overlays.setVisibility(visibleLayers.length);
        overlays.mergeNewParams({
            'LAYERS': visibleLayers.join(','),
            'SLD': FISH_MAP.SLD_URL + visibleLayers.join(',')
        });
        legendPanel.showLayers(visibleLayers);
    }

    createLayerTree(overlayLayers, jQuery('.overlays'), layer_toggle);

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

    function createLayerTree(groups, container, toggleCallback) {
        var tmpl = jQuery('#treeTmpl').html();
        var treeElm = jQuery.mustache(tmpl, {
            "groups": groups,
            "name": function() {
                return window.FISH_MAP.text[this.id];
            }
        });
        // console.log(treeElm);
        var tree$ = jQuery(container).append(treeElm);
        tree$.find('input').change(function() {
            toggleCallback(groups, this.value, this.checked);
        });
    }

})();

