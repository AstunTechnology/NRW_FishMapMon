(function(){

    // Commonly used app config
    var overlayLayers = FISH_MAP.overlayLayers;
    var outputActivities = FISH_MAP.outputActivities;
    var outputTypes = FISH_MAP.outputTypes;

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
        new OpenLayers.Control.MousePosition({
            prefix: 'OSGB: ',
            displayClass: 'olControlMousePosition OSGB',
            numDigits: 2
        }),
        new OpenLayers.Control.MousePosition({
            prefix: 'WGS84: ',
            displayClass: 'olControlMousePosition WGS84',
            displayProjection: new OpenLayers.Projection("EPSG:4326")
        }),
        new OpenLayers.Control.PanZoomBar(),
        new OpenLayers.Control.ScaleLine()
    ];

    var map = new OpenLayers.Map('map', {
        projection: "EPSG:27700",
        units: "m",
        resolutions: [2.5, 5, 10, 25, 50, 100, 150],
        maxExtent: new OpenLayers.Bounds(-3276800,-3276800,3276800,3276800),
        restrictedExtent: new OpenLayers.Bounds(120000, 130000, 375000, 445000),
        controls: controls
    });

    var nomap = new OpenLayers.Layer.TMS(
        FISH_MAP.getText("no_map"),
        FISH_MAP.TMS_ROOT_URL,
        {
            layername: 'nomap',
            type: 'png'
        }
    );
    map.addLayer(nomap);

    // var blank = new OpenLayers.Layer(FISH_MAP.getText('no_map'), {isBaseLayer: true});
    // map.addLayer(blank);

    var os = new OpenLayers.Layer.TMS(
        FISH_MAP.getText("os_map"),
        FISH_MAP.TMS_ROOT_URL,
        {
            layername: 'os',
            type: 'png'
        }
    );
    map.addLayer(os);

    var charts = new OpenLayers.Layer.TMS(
        FISH_MAP.getText("admiralty_chart"),
        FISH_MAP.TMS_ROOT_URL,
        {
            attribution: FISH_MAP.getText('chart_copy'),
            layername: 'charts',
            type: 'png'
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
        {
            attribution: FISH_MAP.getText('os_copy'),
            singleTile: false,
            tileSize: new OpenLayers.Size(512, 512)
        }
    );
    map.addLayer(overlays);

    var legendPanel = new OpenLayers.Control.LegendPanel({
        layers: [overlays],
        title: FISH_MAP.getText('legend')
    });
    map.addControl(legendPanel);
    legendPanel.showLayers(jQuery.grep(visibleOverlays, function(item) {return item.legend}));

    var mapSearch = new OpenLayers.Control.MapSearch({
        tooltip: FISH_MAP.getText('search_tooltip'),
        noResultsMessage: FISH_MAP.getText('search_noresults')
    });
    map.addControl(mapSearch);

    var baseMapSwitcher = new OpenLayers.Control.BaseMapSwitcher();
    map.addControl(baseMapSwitcher);


    info = new OpenLayers.Control.WMSGetFeatureInfo({
        url: FISH_MAP.WMS_OVERLAY_URL, 
        infoFormat: 'application/vnd.ogc.gml',
        queryVisible: true,
        eventListeners: {
            beforegetfeatureinfo: function(event) {

                this.vendorParams = {}
                this.vendorParams['FISHING'] = FISH_MAP.fishingactivity;
                if (FISH_MAP.scenario && FISH_MAP.scenario.feature) {
                    this.vendorParams['COUNT'] = 1;
                    this.vendorParams['WKT'] = FISH_MAP.scenario.feature.geometry.toString();
                }
                if (FISH_MAP.scenario && FISH_MAP.scenario.args) {
                    for (var i = 0, arg; i < FISH_MAP.scenario.args.length; i++) {
                        arg = FISH_MAP.scenario.args[i];
                        this.vendorParams['ARG' + (i + 1)] = arg;
                    }
                }

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
                   var model = jQuery.extend({"layers":{}}, FISH_MAP.tmplView);

                   for (var i = 0, feature; i < features.length; i++) {
                        feature = features[i];
                        var key = feature.type;
                        // Determine if the feature is from an output layer and
                        // if it is use the output type as the key and add
                        // properties to allow it's name to be determined and
                        // column names to be looked up
                        // ('intensity', 'vessels', 'sensitivity' or 'extents')
                        var layerInfo = FISH_MAP.getLayerInfo(feature.type);
                        if (layerInfo.outputType) {
                            key = layerInfo.outputType;
                            feature.type = layerInfo.fullName;
                            feature.fishingactivity = layerInfo.activity;
                        }
                        // Special case for extent layers
                        var prefix = key.match(/^(extents)_/);
                        if (prefix && prefix.length === 2) {
                            key = prefix[1];
                        }
                        if (!model.layers[key]) {
                            model.layers[key] = {
                                "id": feature.type,
                                "key": key,
                                "features": []
                            };
                        }
                        model.layers[key].features.push(feature);
                    }

                    var content = jQuery('#popup_content');
                    jQuery('.loading', content).detach();

                    var tmpl = jQuery('#infoTmpl').html();
                    content.append(jQuery.mustache(tmpl, model));

                    // De-duplicate content
                    for (key in model.layers) {
                        tbodys = content.find('tbody.info.' + key);
                        tbodys.each(function() {
                            var tbody = this;
                            // Only check for duplicates if the current element has
                            // a parent and hence has not been removed from the DOM
                            // in a previous pass
                            if (jQuery(tbody).parent().length) {
                                // Find all other tbody elements that belong to
                                // the same tbody and that have the same
                                // content and remove them
                                tbodys.filter(function() {
                                    return this != tbody && this.innerHTML == tbody.innerHTML;
                                }).remove();
                            }
                        });
                    }

                    // Remove rows with empty values
                    jQuery('td:empty()', content).parent().remove();

                    // Force the popup to resize based on the content
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
        refreshOverlayLayer();
    }

    function deleteScenarioParams(params) {
        var scenarioParams = {
            "WKT": true,
            "COUNT": true,
            "ARG1": true,
            "ARG2": true,
            "ARG3": true,
            "ARG4": true,
            "ARG5": true,
            "ARG6": true,
            "ARG7": true,
            "ARG8": true
        };
        for (var param in params) {
            if (scenarioParams[param]) {
                delete params[param];
            }
        }
        return params;
    }

    function refreshOverlayLayer() {
        deleteScenarioParams(overlays.params);
        // Refresh the overlay WMS layer
        var visibleLayers = overlayLayers.getVisibleLayers();
        // Hide the layer if there are no visible layers to avoid an invalid
        // WMS request being generated
        overlays.setVisibility(visibleLayers.length);
        var params = {
            'LAYERS': visibleLayers.join(',')
        };
        params['FISHING'] = FISH_MAP.fishingactivity;
        if (FISH_MAP.scenario && FISH_MAP.scenario.feature) {
            params['COUNT'] = 1;
            params['WKT'] = FISH_MAP.scenario.feature.geometry.toString();
        }
        if (FISH_MAP.scenario && FISH_MAP.scenario.args) {
            for (var i = 0, arg; i < FISH_MAP.scenario.args.length; i++) {
                arg = FISH_MAP.scenario.args[i];
                params['ARG' + (i + 1)] = arg;
            }
        }
        overlays.mergeNewParams(params);
        legendPanel.showLayers(jQuery.grep(visibleLayers, function(item) {return item.legend}));
    }

    createLayerTree(overlayLayers, jQuery('.overlays'), layer_toggle);

    var events = new OpenLayers.Events(this, jQuery('#map').get(0), null, true);

    var outputPanel = new OutputPanel({
        layers: overlayLayers,
        activities: outputActivities,
        div: jQuery('.outputs').get(0),
        controller: events
    });

    outputPanel.events.on({
        'layerchange': function(e) {
            layer_toggle(outputPanel.layers, e.layer, e.state);
        },
        'activitychange': function(e) {
            FISH_MAP.fishingactivity = outputPanel.getActivity();
            // Add a _fullName property and desc to all activity layers which
            // can be used in templates etc.
            var grps = overlayLayers.getGroupsByProperty('activity', true);
            for (var m = 0, grp; m < grps.length; m++) {
                grp = grps[m];
                for (var n = 0, lyr; n < grp.layers.length; n++) {
                    lyr = grp.layers[n];
                    // Lookup the full name for the layer which includes the
                    // current fishing activity so it can be uniquely identified.
                    // Example fullName: intensity_lvls_official_cas_hand_gath
                    var layerInfo = FISH_MAP.getLayerInfo(lyr.id);
                    lyr._fullName = layerInfo.fullName;
                    // Look up description for this layer, getText return the
                    // string used to lookup the description then set it to
                    // false as there is no desciption defined.
                    // Example id: intensity_cas_hand_gath_desc
                    var descTextId = layerInfo.outputType + '_' + layerInfo.activity + '_desc';
                    var descText = FISH_MAP.getText(descTextId);
                    lyr.desc = (descText != descTextId) ? descText : false;
                }
            }
            clearScenario();
        },
        'newscenario': function(e) {
            newScenario();
        },
        'clearscenario': function(e) {
            clearScenario();
        },
        'showscenario': function(e) {
            showScenario(e.args);
        }
    });

    outputPanel.draw();

    function layersCollection(layers) {

        // Allow layers to be quickly looked up on layer name and add a toString
        // function to each layer to make getting a list of id's as simple as
        // calling join on an Array of layer objects

        // Define lookup for layers
        layers.layers = {};

        for (var m = 0, grp; m < layers.groups.length; m++) {
            grp = layers.groups[m];
            grp.addLayer = function(lyr) {
                return addLayer(this, lyr);
            };
            grp.removeLayer = function(lyr) {
                return removeLayer(lyr);
            };
            for (var n = 0, lyr; n < grp.layers.length; n++) {
                lyr = grp.layers[n];
                decorateLyr(lyr, grp);
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

        layers.getGroupsByProperty = function(name, val) {
            return getGroupsByProperty(this, name, val);
        };

        // Private functions

        function _toString() {
            return this.id;
        }

        function decorateLyr(lyr, grp) {
            // Add the layer to the lookup
            layers.layers[lyr.id] = lyr;
            // Add the toString function
            lyr.toString = _toString
            // Allow us to get the group from the layer
            lyr._group = grp;
            return lyr;
        }

        function addLayer(grp, lyr) {
            removeLayer(lyr);
            decorateLyr(lyr, grp);
            grp.layers.push(lyr);
        }

        function removeLayer(lyr) {
            if (lyr) {
                delete layers.layers[lyr.id];
                // Find the items index in the grp.layers array
                if (lyr._group) {
                    var idx = null;
                    for (var i = 0, l; i < lyr._group.layers.length; i++) {
                        l = lyr._group.layers[i];
                        if (l.id === lyr.id) {
                            idx = i;
                            break;
                        }
                    }
                    lyr._group.layers.splice(idx, 1);
                }
            }
            return lyr;
        }

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

        function getGroupsByProperty(layers, name, val) {
            var matched = [];
            for (var m = 0, grp; m < layers.groups.length; m++) {
                grp = layers.groups[m];
                if (grp[name] === val) {
                    matched.push(grp);
                }
            }
            return matched;
        }

        return layers;
    }

    function createLayerTree(layers, container, toggleCallback) {
        var tmpl = jQuery('#treeTmpl').html();
        var treeElm = jQuery.mustache(tmpl, jQuery.extend(layers, FISH_MAP.tmplView));
        var panel = jQuery(container).append(treeElm);
        panel.find('input').change(function() {
            toggleCallback(layers, this.value, this.checked);
        });
        panel.find('h3').click(function() {
            jQuery(this).toggleClass('collapsed').siblings().toggle();
        }).click().first().click();
    }

    var defaultStyle = OpenLayers.Util.applyDefaults({
        strokeWidth: 3,
        strokeColor: '#FF0000',
        strokeOpacity: 0.8,
        fillOpacity: 0.0
    }, OpenLayers.Feature.Vector.style["default"]);

    var scenarioLayer = new OpenLayers.Layer.Vector("scenario", {style: defaultStyle});
    map.addLayer(scenarioLayer);

    var drawCtrl = new OpenLayers.Control.DrawFeature(scenarioLayer, OpenLayers.Handler.Polygon);
    map.addControl(drawCtrl);

    drawCtrl.events.register("featureadded", drawCtrl, function(e) {
        drawCtrl.deactivate();
        scenarioAddFeature(e.feature);
    });


    FISH_MAP.scenario = null;
    function newScenario() {
        clearScenario();
        FISH_MAP.scenario = {};
        FISH_MAP.scenario.fishing = outputPanel.getActivity();
        drawCtrl.activate();
        events.triggerEvent("predrawpolygon");
    }

    function clearScenario() {
        FISH_MAP.scenario = null;
        var layer = map.getLayersByName("scenario")[0];
        if (layer) {
            layer.removeAllFeatures();
        }
        removeScenarioLayers();
        events.triggerEvent('clearscenario');
        // Refresh the map state
        refreshOverlayLayer();
    }

    function addScenarioLayers() {
        // Add the additional layers to the activiy groups if they dont'
        // already exist
        for (var i = 0, type, grp, lyrId, lyr; i < FISH_MAP.scenarioLayerNames.length; i++) {
            lyrId = FISH_MAP.scenarioLayerNames[i];
            if (!overlayLayers.getLayerById(lyrId)) {
                type = lyrId.split('_')[0];
                grp = overlayLayers.getGroupsByProperty('id', type + '_grp')[0];
                lyr = {
                    "id": lyrId,
                    "info": true,
                    "legend": true,
                    "visible": false
                };
                var layerInfo = FISH_MAP.getLayerInfo(lyr.id);
                lyr._fullName = layerInfo.fullName;
                grp.addLayer(lyr);
            }
        }
    }

    function removeScenarioLayers() {
        // Remove scenario layers
        for (var i = 0, type, grp, lyrId, lyr; i < FISH_MAP.scenarioLayerNames.length; i++) {
            lyrId = FISH_MAP.scenarioLayerNames[i];
            type = lyrId.split('_')[0];
            grp = overlayLayers.getGroupsByProperty('id', type + '_grp')[0];
            lyr = overlayLayers.getLayerById(lyrId);
            grp.removeLayer(lyr);
        }
    }

    function scenarioAddFeature(feature) {
        FISH_MAP.scenario.feature = feature;
        // outputPanel.showScenarioForm();
        events.triggerEvent('polygondrawn');
    }

    function showScenario(args) {
        FISH_MAP.scenario.args = args
        addScenarioLayers();
        events.triggerEvent('scenariocalculated');
        // Refresh the map state
        refreshOverlayLayer();
    }

})();
