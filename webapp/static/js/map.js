(function(){

    // Commonly used app config
    var overlayLayers = FISH_MAP.overlayLayers;
    var outputActivities = FISH_MAP.outputActivities;
    var outputTypes = FISH_MAP.outputTypes;

    // Add the project output layers to the overlayLayers model, one per type /
    // activity before any other output groups
    var outputGrpIdx = overlayLayers.groups.length - 1;
    for (var m = 0, grp; m < overlayLayers.groups.length; m++) {
        grp = overlayLayers.groups[m];
        if (grp.output) {
            outputGrpIdx = m;
            break;
        }
    }
    for (var m = 0, type, grp; m < outputTypes.length; m++) {
        type = outputTypes[m];
        grp = {
            "id": type + "_grp",
            "output": true,
            "activity": true,
            "layers":[]
        };
        overlayLayers.groups.splice(outputGrpIdx, 0, grp);
        outputGrpIdx += 1;
        for (var n = 0, activity, lyr; n < outputActivities.length; n++) {
            activity = outputActivities[n];
            lyr = {
                "id": type + "_lvls_" + activity,
                "info": true,
                "legend": true,
                "visible": false
            };
            grp.layers.push(lyr);
        }
    }

    overlayLayers = layersCollection(overlayLayers);

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

    var map = new OpenLayers.Map('map', {
        projection: "EPSG:27700",
        units: "m",
        resolutions: [2.5, 5, 10, 25, 50, 100, 150],
        maxExtent: new OpenLayers.Bounds(-3276800,-3276800,3276800,3276800),
        controls: controls
    });

    var nomap = wmsLayer(
        FISH_MAP.getText('no_map'),
        FISH_MAP.WMS_NOMAP_URL,
        {
            layers: 'nomap',
            transparent: false
        },
        {
            singleTile: false,
            tileSize: new OpenLayers.Size(512, 512)
        }
    );
    map.addLayer(nomap);

    var os = wmsLayer(
        FISH_MAP.getText('os_map'),
        FISH_MAP.WMS_OS_URL,
        {
            layers: 'os',
            transparent: false
        },
        {
            attribution: "&copy; Ordnance Survey",
            singleTile: false,
            tileSize: new OpenLayers.Size(512, 512)
        }
    );
    map.addLayer(os);

    var charts = wmsLayer(
        FISH_MAP.getText('admiralty_chart'),
        FISH_MAP.WMS_CHARTS_URL,
        {
            layers: 'charts',
            transparent: false
        },
        {
            attribution: "&copy; UK Hydrographic Office",
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

                // Build a list of features that we want to display info for
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

                    // Assign features to a model keyed on layer name
                    // for use in the info template. Project output layers are
                    // a bit special as they all use the same template
                   var model = jQuery.extend({}, FISH_MAP.tmplView);

                    for (var i = 0, feature; i < features.length; i++) {
                        feature = features[i];
                        var key = feature.type;
                        // Determine if the feature is from an output layer and
                        // if it is just use the output type as the key
                        // ('intensity', 'vessels', 'sensitivity' or 'extents')
                        var prefix = key.match(/^(\w+)_lvls_/);
                        if (prefix && prefix.length === 2) {
                            key = prefix[1];
                        } else {
                            prefix = key.match(/^(extents)_/);
                            if (prefix && prefix.length === 2) {
                                key = prefix[1];
                            }
                        }
                        if (!model[key]) {
                            model[key] = {
                                id: feature.type,
                                features: []
                            };
                        }
                        model[key].features.push(feature);
                    }

                    var content = jQuery('#popup_content');
                    jQuery('.loading', content).detach();

                    var tmpl = jQuery('#infoTmpl').html();
                    var html = jQuery.mustache(tmpl, model);
                    content.append(jQuery.mustache(tmpl, model));
                    this.popup.updateSize();

                } else {

                    this.map.removePopup(this.popup);

                }

            }
        }
    });
    map.addControl(info);
    info.activate();

    map.setCenter(new OpenLayers.LonLat(243725, 380125), 0);

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

    createOutputPanel(overlayLayers, outputActivities, jQuery('.outputs'), layer_toggle);

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
                lyr.toString = function() {
                    return this.id;
                }

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
        var curType = null;
        var tmpl = jQuery('#outputTmpl').html();
        var model = {"layers": layers, "activities": activities};
        var treeElm = jQuery.mustache(tmpl, jQuery.extend(model, FISH_MAP.tmplView));
        var tree$ = jQuery(container).append(treeElm);
        tree$.find('input').change(function() {
            // Ensure only one activity layer is visible at a time
            if (jQuery(this).parents().hasClass('activity') && this.checked) {
                var that = this;
                jQuery(tree$).find('.activity input:checkbox').filter(function() {
                    return (jQuery(this).val().match(curType) && this !== that);
                }).each(function() {
                    this.checked = false;
                    toggleCallback(layers, this.value, this.checked);
                });
            }
            toggleCallback(layers, this.value, this.checked);
        });
        addLayerTreeToggle(tree$);
        var select = jQuery(container).find('select');
        select.change(function() {
            curType = this.value;
            // Only show the intensity, vessels and sensitivity layers for the
            // selected activity
            jQuery('.activity li.layer', container).hide().filter(function () {
                var val = jQuery(this).find('input').val();
                return val.match(curType);
            }).show();
            // If the user is showing an intensity, vessels or sensitivity
            // layer then hide the old layer and show the one associated with
            // the current activity
            jQuery('.activity li.layer input:checked').each(function() {
                this.checked = false;
                jQuery(this).change();
                var prefix = this.value.match(/^\w+_lvls_/)[0];
                jQuery('input#' + prefix + curType).prop('checked', true).change();
            });
        }).change();
    }

})();
