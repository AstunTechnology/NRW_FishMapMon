(function(){

    FISH_MAP.ROOT_URL = window.location.protocol + '//' + window.location.host + window.location.pathname;
    FISH_MAP.WMS_ROOT_URL = FISH_MAP.ROOT_URL + 'wms?map=';
    FISH_MAP.WMS_OVERLAY_URL = FISH_MAP.WMS_ROOT_URL + 'fishmap';
    FISH_MAP.WMS_OS_URL = FISH_MAP.WMS_ROOT_URL + 'os';
    FISH_MAP.WMS_CHARTS_URL = FISH_MAP.WMS_ROOT_URL + 'charts';

    var overlayLayers = layersCollection({
            "groups": [
                {
                    "id": "project_area_grp", 
                    "shown": true,
                    "layers": [
                        {
                            "id": "project_area", 
                            "info": false, 
                            "legend": false, 
                            "visible": true
                        }
                    ]
                }, 
                {
                    "id": "habitats_grp", 
                    "shown": true,
                    "layers": [
                        {
                            "id": "intertidal_habitats", 
                            "info": true, 
                            "legend": true, 
                            "visible": false
                        }, 
                        {
                            "id": "subtidal_habitats", 
                            "info": true, 
                            "legend": true, 
                            "visible": false
                        }, 
                        {
                            "id": "subtidal_habitats_confidence", 
                            "info": true, 
                            "legend": true, 
                            "visible": false
                        }
                    ]
                }, 
                {
                    "id": "restricted_grp", 
                    "shown": true,
                    "layers": [
                        {
                            "id": "restricted_closed_scalloping", 
                            "info": true, 
                            "legend": true, 
                            "visible": false
                        }, 
                        {
                            "id": "several_and_regulatory_orders", 
                            "info": true, 
                            "legend": true, 
                            "visible": false
                        }
                    ]
                }, 
                {
                    "id": "rsa_sites_grp", 
                    "shown": true,
                    "layers": [
                        {
                            "id": "rsa_standing_areas", 
                            "info": true, 
                            "legend": true, 
                            "visible": false
                        }, 
                        {
                            "id": "rsa_casting_sites", 
                            "info": true, 
                            "legend": true, 
                            "visible": false
                        }
                    ]
                }, 
                {
                    "id": "contextual_grp", 
                    "shown": true,
                    "layers": [
                        {
                            "id": "national_limits", 
                            "info": false, 
                            "legend": false, 
                            "visible": false
                        },
                        {
                            "id": "wrecks_polygon", 
                            "info": true,
                            "legend": false,
                            "visible": false
                        }
                    ]
                },
                {
                    "id": "intensity_grp", 
                    "shown": false,
                    "layers": [
                        {
                            "id": "intensity_lvls_cas_hand_gath", 
                            "info": true, 
                            "legend": true, 
                            "visible": false
                        },
                        {
                            "id": "intensity_lvls_nets", 
                            "info": true, 
                            "legend": true, 
                            "visible": false
                        }
                    ]
                },
                {
                    "id": "vessels_grp", 
                    "shown": false,
                    "layers": [
                        {
                            "id": "vessels_lvls_cas_hand_gath", 
                            "info": true, 
                            "legend": true, 
                            "visible": false
                        },
                        {
                            "id": "vessels_lvls_nets", 
                            "info": true, 
                            "legend": true, 
                            "visible": false
                        }
                    ]
                },
                {
                    "id": "sensitivity_grp", 
                    "shown": false,
                    "layers": [
                        {
                            "id": "sensitivity_lvls_cas_hand_gath", 
                            "info": true, 
                            "legend": true, 
                            "visible": false
                        },
                        {
                            "id": "sensitivity_lvls_nets", 
                            "info": true, 
                            "legend": true, 
                            "visible": false
                        }
                    ]
                }
            ]
        }
    );

    var controls = [
        new OpenLayers.Control.TouchNavigation({
            dragPanOptions: {
                enableKinetic: true
            }
        }),
        new OpenLayers.Control.Attribution(),
        new OpenLayers.Control.Scale(),
        new OpenLayers.Control.Navigation(),
        new OpenLayers.Control.MousePosition(),
        new OpenLayers.Control.PanZoomBar()
    ];

    map = new OpenLayers.Map('map', {
        projection: "EPSG:27700",
        units: "m",
        resolutions: [2.5, 5, 10, 25, 50, 100, 150],
        maxExtent: new OpenLayers.Bounds(-3276800,-3276800,3276800,3276800),
        controls: controls
    });

    var os = wmsLayer(
        FISH_MAP.getText('os_map'),
        FISH_MAP.WMS_OS_URL,
        {
            layers: 'os',
            transparent: false
        },
        {
            singleTile: false,
            tileSize: new OpenLayers.Size(512, 512)
        }
    );
    map.addLayer(os);

    var blank = new OpenLayers.Layer(FISH_MAP.getText('no_map'), {isBaseLayer: true});
    map.addLayer(blank);

    var charts = wmsLayer(
        FISH_MAP.getText('admiralty_chart'),
        FISH_MAP.WMS_CHARTS_URL,
        {
            layers: 'charts',
            transparent: false
        },
        {
            singleTile: false,
            tileSize: new OpenLayers.Size(512, 512)
        }
    );
    map.addLayer(charts);

    var visibleOverlays = overlayLayers.getVisibleLayers();
    var overlays = wmsLayer(
        "Overlays",
        FISH_MAP.WMS_OVERLAY_URL,
        {
            layers: visibleOverlays.join(',')
        },
        {}
    );
    map.addLayer(overlays);

    var legendPanel = new OpenLayers.Control.LegendPanel({layers: [overlays]});
    map.addControl(legendPanel);
    legendPanel.showLayers(jQuery.grep(visibleOverlays, function(item) {return item.legend}));

    var baseMapSwitcher = new OpenLayers.Control.BaseMapSwitcher();
    map.addControl(baseMapSwitcher);


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
                    // "Correct" the layer name (type) if it ends with
                    // _gen or _det, this should probably be done server-side
                    // but that would require rewriting the gml response
                    feature.type = feature.type.replace(/(_gen|_det)$/, '')
                    if (overlayLayers.getLayerById(feature.type).info) {
                        features.push(feature);
                    }
                }

                if (features.length) {

                    // Assign features to an lookup keyed on layer name
                    // for use in the template
                   var lookup = jQuery.extend({}, FISH_MAP.tmplView);

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

    function layer_toggle(layers, id, visible) {
        // Update the model
        layers.getLayerById(id).visible = visible;
        // Refresh the overlay WMS layer
        var visibleLayers = layers.getVisibleLayers();
        // Hide the layer if there are no visible layers to avoid an invalid
        // WMS request being generated
        overlays.setVisibility(visibleLayers.length);
        overlays.mergeNewParams({
            'LAYERS': visibleLayers.join(',')
        });
        legendPanel.showLayers(jQuery.grep(visibleLayers, function(item) {return item.legend}));
    }

    createLayerTree(overlayLayers, jQuery('.overlays'), layer_toggle);

    var activites = [
        {"id": "cas_hand_gath", "name": "Casual Hand Gather"},
        {"id": "fixed_pots", "name": "Potting"},
        {"id": "foot_access", "name": "Foot Access"},
        {"id": "king_scallops", "name": "King Scallops"},
        {"id": "lot", "name": "Light Otter Trawl"},
        {"id": "mussels", "name": "Mussels"},
        {"id": "nets", "name": "Netting"},
        {"id": "pro_hand_gath", "name": "Professional Hand Gather"},
        {"id": "queen_scallops", "name": "Queen Scallops"},
        {"id": "rsa_charterboats", "name": "RSA Charter Boats"},
        {"id": "rsa_commercial", "name": "RSA Commercial"},
        {"id": "rsa_noncharter", "name": "RSA Non Charter Boats"},
        {"id": "rsa_shore", "name": "RSA Shore Fishing"}
    ];

    createOutputPanel(overlayLayers, activites, jQuery('.outputs'), layer_toggle);

    function layersCollection(layers) {

        // Allow layers to be quickly looked up on layer name and add a toString
        // function to each layer to make getting a list of id's as simple as
        // calling join on an Array of layer objects

        // Define lookup for layers
        layers.layers = {};

        for (var m = 0, grp; m < layers.groups.length; m++) {
            grp = layers.groups[m];
            for (var n = 0, lyr; n < grp.layers.length; n++) {
                lyr = grp.layers[n];

                // Add the layer to the lookup
                layers.layers[lyr.id] = lyr;

                // Add the toString function
                jQuery.extend(lyr, {
                    toString: function() {
                        return this.id;
                    }
                });

            }
        }

        // Add convience functions to the layers object

        layers.getLayerById = function(id) {
            // return getLayerById(this, id);
            return getLayersByProperty(this, 'id', id)[0];
        };

        layers.getVisibleLayers = function() {
            return getLayersByProperty(this, 'visible', true);
        };

        function getLayersByProperty(layers, name, val) {
            var matched = [];
            for (var m = 0, grp; m < layers.groups.length; m++) {
                grp = layers.groups[m];
                for (var n = 0, lyr; n < grp.layers.length; n++) {
                    lyr = grp.layers[n];
                    if (lyr[name] === val) {
                        matched.push(lyr);
                    }
                }
            }
            return matched;
        }

        return layers;
    }

    function createLayerTree(layers, container, toggleCallback) {
        var tmpl = jQuery('#treeTmpl').html();
        var treeElm = jQuery.mustache(tmpl, jQuery.extend(layers, FISH_MAP.tmplView));
        // console.log(treeElm);
        var tree$ = jQuery(container).append(treeElm);
        tree$.find('input').change(function() {
            toggleCallback(layers, this.value, this.checked);
        });
        addLayerTreeToggle(tree$);
    }

    /**
     * Adds toggle behaviour to a tree of layers
     */
    function addLayerTreeToggle(tree$) {
        tree$.find('h3').click(function() {
            jQuery(this).toggleClass('collapsed').siblings().toggle();
        }).click().first().click();
    }

    function createOutputPanel(layers, activities, container, toggleCallback) {
        var tmpl = jQuery('#outputTmpl').html();
        var model = {layers: layers, activites: activites};
        var treeElm = jQuery.mustache(tmpl, jQuery.extend(model, FISH_MAP.tmplView));
        var tree$ = jQuery(container).append(treeElm);
        tree$.find('input').change(function() {
            toggleCallback(layers, this.value, this.checked);
        });
        addLayerTreeToggle(tree$);
        var select = jQuery(container).find('select');
        select.change(function() {
            var val = this.value;
            // Only show the intensity, vessels and sensitivity layers for the
            // selected activity
            jQuery('li.layer', container).hide().filter(function () {
                return jQuery(this).find('input').val().match(val);
            }).show();
            // If the user is showing an intensity, vessels or sensitivity
            // layer then hide the old layer and show the one associated with
            // the current activity
            jQuery('li.layer input:checked').each(function() {
                this.checked = false;
                jQuery(this).change();
                var prefix = this.value.match(/^\w+_lvls_/)[0];
                jQuery('input#' + prefix + val).prop('checked', true).change();
            });
        }).change();
    }

})();
