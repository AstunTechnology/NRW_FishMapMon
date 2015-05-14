(function(){

    /**
     * jQuery browser detection taken from jquery-migrate-1.2.1.js
     */
    jQuery.uaMatch = function( ua ) {
        ua = ua.toLowerCase();

        var match = /(chrome)[ \/]([\w.]+)/.exec( ua ) ||
            /(webkit)[ \/]([\w.]+)/.exec( ua ) ||
            /(opera)(?:.*version|)[ \/]([\w.]+)/.exec( ua ) ||
            /(msie) ([\w.]+)/.exec( ua ) ||
            ua.indexOf("compatible") < 0 && /(mozilla)(?:.*? rv:([\w.]+)|)/.exec( ua ) ||
            [];

        return {
            browser: match[ 1 ] || "",
            version: match[ 2 ] || "0"
        };
    };

    // Make some decisions base on browser for printing (really rather not do
    // this but IE can be harsh sometimes...)
    var ua = jQuery.uaMatch(navigator.userAgent);

    var tileWidth = 512,
        layerRatio = 1,
        layerBuffer = 0;

    if (ua.browser === 'msie' && parseInt(ua.version, 10) < 9) {
        tileWidth = 256;
        layerRatio = 1;
        layerBuffer = 0;
    }

    window.onbeforeprint = function() {
        // console.log('onbeforeprint');
        // Clear any tiles outside of the map viewport if the browser is IE8 to
        // limit the affect of map images being shown on subsiquent pages
        var ua = jQuery.uaMatch(navigator.userAgent);
        if (ua.browser === 'msie' && ua.version ==="8.0") {
            var extent = map.getExtent();
            for (var i = 0, lyr; i < map.layers.length; i++) {
                var lyr = map.layers[i];
                if (lyr.grid) {
                    for (var iRow=0, len=lyr.grid.length; iRow<len; iRow++) {
                        var row = lyr.grid[iRow];
                        for(var iCol=0, clen=row.length; iCol<clen; iCol++) {
                            var tile = row[iCol];
                            if (tile.bounds.intersectsBounds(extent) === false) {
                                tile.clear();
                            }
                        }
                    }
                }
            }
        }
    };

    window.onafterprint = function() {
        // console.log('onafterprint');
        for (var i = 0, lyr; i < map.layers.length; i++) {
            var lyr = map.layers[i];
            lyr.redraw();
        }
    }

    // Commonly used app config
    var overlayLayers = FISH_MAP.overlayLayers;
    var outputActivities = FISH_MAP.outputActivities;
    var outputTypes = FISH_MAP.outputTypes;
    var scenarioLayerNames = FISH_MAP.scenarioLayerNames;

    overlayLayers = layersCollection(overlayLayers);
    overlayLayers.events.register('visiblechange', this, function(e) {
        refreshCalculatedLayer();
        refreshOverlayLayers();
    });

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

    window.map = new OpenLayers.Map('map', {
        projection: "EPSG:27700",
        units: "m",
        resolutions: [2.5, 5, 10, 25, 50, 100, 150],
        maxExtent: new OpenLayers.Bounds(-3276800,-3276800,3276800,3276800),
        restrictedExtent: new OpenLayers.Bounds(120000, 130000, 375000, 445000),
        controls: controls,
        tileManager: null,
        zoomMethod: OpenLayers.Easing.Expo.easeOut
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

    // var os = wmsLayer(
    //     'os',
    //     FISH_MAP.WMS_OS_URL,
    //     {
    //         layers: 'os',
    //         transparent: false
    //     },
    //     {
    //         attribution: FISH_MAP.getText('os_copy'),
    //         singleTile: true
    //     }
    // );
    // map.addLayer(os);

    var charts = new OpenLayers.Layer.TMS(
        FISH_MAP.getText("admiralty_chart"),
        "http://tms.oceanwise.eu/NRW/BNG",
        {
            attribution: FISH_MAP.getText('chart_copy'),
            layername: 'RCx',
            type: 'png',
            serviceVersion: ''
        }
    );
    map.addLayer(charts);

    // var charts = wmsLayer(
    //     'charts',
    //     FISH_MAP.WMS_CHARTS_URL,
    //     {
    //         layers: 'charts',
    //         transparent: false
    //     },
    //     {
    //         attribution: FISH_MAP.getText('os_copy'),
    //         singleTile: true
    //     }
    // );
    // map.addLayer(charts);

    var visibleOverlays = overlayLayers.getVisibleLayers();

    // Add a layer for each static overlay
    var overlays = {};
    for (var i = 0; i < overlayLayers.list.length; i++) {
        var layer = overlayLayers.list[i];
        var overlay = wmsLayer(
            layer.id,
            FISH_MAP.WMS_OVERLAY_URL,
            {
                layers: layer.id 
            },
            {
                attribution: FISH_MAP.getText('os_copy'),
                singleTile: false,
                tileSize: new OpenLayers.Size(tileWidth, tileWidth),
                createBackBuffer: function() {return null}
            }
        );
        overlay.setVisibility(layer.getVisible());
        overlays[layer.id] = overlay;
        map.addLayer(overlay);
    }

    // Add a single layer for calculated layers
    var calculated = wmsLayer(
        "Calculated",
        FISH_MAP.WMS_OVERLAY_URL,
        {
            layers: visibleOverlays.join(',')
        },
        {
            transitionEffect: null,
            singleTile: true
        }
    );
    map.addLayer(calculated);
    calculated.setVisibility(false);

    var legendPanel = new OpenLayers.Control.LegendPanel({
        div: jQuery('#legend').get(0),
        layers: [overlays],
        title: FISH_MAP.getText('legend')
    });
    map.addControl(legendPanel);
    legendPanel.showLayers(jQuery.grep(visibleOverlays, function(item) {return item.legend}));

    var mapPanel = jQuery('#mappanel');

    var mapSearch = new OpenLayers.Control.MapSearch({
        tooltip: FISH_MAP.getText('search_tooltip'),
        noResultsMessage: FISH_MAP.getText('search_noresults'),
        div: mapPanel.find('.olControlMapSearch').get(0)
    });
    map.addControl(mapSearch);

    var baseMapSwitcher = new OpenLayers.Control.BaseMapSwitcher({
        div: mapPanel.find('.olControlBaseMapSwitcher').get(0)
    });
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
                    this.vendorParams['COUNT'] = FISH_MAP.scenario.count;
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
                    true,
                    function(e) {
                        // Clear the last info coords to avoid maps being
                        // exported with popups when the current map is not
                        // displaying a popup
                        FISH_MAP.info = null;
                        // Now do the default OpenLayers stuff to close the
                        // popup
                        this.hide();
                        OpenLayers.Event.stop(e);
                    }
                );
                this.popup.panMapIfOutOfView = true;
                this.map.addPopup(this.popup, true);

            },
            getfeatureinfo: function(event) {

                // Build a list of features that we want to display info for
                var features = [];
                for (var i = 0, feature; i < event.features.length; i++) {
                    feature = event.features[i];
                    if (overlayLayers.getLayerById(feature.type).info) {
                        features.push(feature);
                    }
                }

                if (features.length) {

                    // Record the last x/y location so we can reproduce the
                    // current view in ExportLink
                    var lonLat = map.getLonLatFromPixel(event.xy);
                    FISH_MAP.info = {
                        x: lonLat.lon,
                        y: lonLat.lat
                    };

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

                    // Force the popup to resize based on the content and
                    // ensure it's visible
                    this.popup.updateSize();
                    this.popup.panIntoView();

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
                            buffer: layerBuffer,
                            ratio: layerRatio
                        })
                );
        map.addLayer(lyr);
        return lyr;
    }

    function layer_toggle(layers, id, visible) {
        // Update the model
        l = layers.getLayerById(id)
        l.setVisible(visible);
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

    function refreshOverlayLayers() {
        // Refresh the overlay WMS layers
        var activity = FISH_MAP.fishingactivity;
        for (var i = 0; i < overlayLayers.list.length; i++) {
            var layer = overlayLayers.list[i];
            if (overlays[layer.id]) {
                var overlay = overlays[layer.id];
                if (layer.getVisible()) {
                    if (layer.output_layer) {
                        if (activity) {
                            if (overlay.params.FISHING !== activity) {
                                overlay.mergeNewParams({'FISHING': activity});
                            }
                        } else {
                            // The fishing activity must be defined for us to
                            // show output layers as the activity is used to
                            // determine which data to show
                            overlay.setVisibility(false);
                        }
                    }
                }
                overlay.setVisibility(layer.getVisible());
            }
        }
        var visibleLayers = overlayLayers.getVisibleLayers();
        legendPanel.showLayers(jQuery.grep(visibleLayers, function(item) {return item.legend}));
    }

    function refreshCalculatedLayer() {

        // Hide the layer until we have set the new parameters
        calculated.setVisibility(false);

        // Refresh the calculated WMS layer
        var visibleLayers = overlayLayers.getVisibleLayers();
        var visibleCalculated = [];
        for (var i = 0; i < visibleLayers.length; i++) {
            var layer = visibleLayers[i];
            if (layer.calculated) {
                visibleCalculated.push(layer);
            }
        }

        var params = {
            'LAYERS': visibleCalculated.join(',')
        };

        params['FISHING'] = FISH_MAP.fishingactivity;
        if (FISH_MAP.scenario && FISH_MAP.scenario.feature) {
            params['COUNT'] = FISH_MAP.scenario.count || 1;
            params['WKT'] = FISH_MAP.scenario.feature.geometry.toString();
        }
        if (FISH_MAP.scenario && FISH_MAP.scenario.args) {
            for (var i = 0, arg; i < FISH_MAP.scenario.args.length; i++) {
                arg = FISH_MAP.scenario.args[i];
                params['ARG' + (i + 1)] = arg;
            }
        }

        calculated.mergeNewParams(params);

        // Only show the layer if there are visible layers to avoid an invalid
        // WMS request being generated
        calculated.setVisibility(visibleCalculated.length);

        legendPanel.showLayers(jQuery.grep(visibleLayers, function(item) {return item.legend}));
    }

    var layerPanel = new LayerPanel({
        layers: overlayLayers,
        div: jQuery('.overlays').get(0)
    });

    layerPanel.events.on({
        'layerchange': function(e) {
            layer_toggle(layerPanel.layers, e.layer, e.state);
        }
    });

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
            var activity = outputPanel.getActivity();

            // Record the activity for use elsewhere
            FISH_MAP.fishingactivity = activity;

            // Update the activity layers
            var grps = overlayLayers.getGroupsByProperty('activity', true);

            // If no activity is chosen then hide the activity layers
            if (activity === null) {
                for (var m = 0, grp; m < grps.length; m++) {
                    grp = grps[m];
                    grp.fishingactivity = activity;
                    for (var n = 0, lyr; n < grp.layers.length; n++) {
                        lyr = grp.layers[n];
                        lyr.setVisible(false);
                    }
                }
            }

            // Add a _fullName property and desc to all activity layers which
            // can be used in templates etc.
            for (var m = 0, grp; m < grps.length; m++) {
                grp = grps[m];
                grp.fishingactivity = activity;
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

            // Enable the appropriate extents layer based on current fishing
            // activity
            if (activity) {
                var grp = overlayLayers.getGroupsByProperty('id', 'extents_grp')[0];
                for (var i = 0, l; i < grp.layers.length; i++) {
                    l = grp.layers[i];
                    if (l.id == 'extents_' + activity) {
                        l.setVisible(true);
                    } else {
                        if (!l.clicked) {
                            l.setVisible(false);
                        }
                    }
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
            showScenario(e.args, e.count);
        }
    });

    var exportLink = new OpenLayers.Control.ExportLink({
        overlayLayers: overlayLayers,
        outputPanel: outputPanel,
        buttonText: FISH_MAP.getText('export_export_image'),
        waitText: FISH_MAP.getText('export_wait'),
        errorMessage: FISH_MAP.getText('export_error'),
        downloadText: FISH_MAP.getText('export_download'),
        div: mapPanel.find('.olControlExportLink').get(0)
    });
    map.addControl(exportLink);

    function layersCollection(layers) {

        // Allow layers to be quickly looked up on layer name and add a toString
        // function to each layer to make getting a list of id's as simple as
        // calling join on an Array of layer objects

        // Define lookup for layers
        layers.layers = {};

        // Ordered list of layers
        layers.list = [];

        layers.events = new OpenLayers.Events(layers, null, null, true);

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
                lyr = decorateLyr(lyr, grp);
                layers.list.push(lyr);
                var prefix = lyr.id.split('_')[0];
                lyr.output_layer = false;
                for (var p = 0; p < FISH_MAP.outputTypes.length; p++) {
                    if(FISH_MAP.outputTypes[p] === prefix) {
                        lyr.output_layer = true;
                        break;
                    }
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

        layers.getGroupsByProperty = function(name, val) {
            return getGroupsByProperty(this, name, val);
        };

        // Private functions

        function _toString() {
            return this.id;
        }

        function _setVisible(lyr, visible) {
            // console.log('_setVisible', lyr, visible);
            if (lyr.visible !== visible) {
                var changed = [lyr];
                lyr.visible = visible;
                if (lyr.visible && lyr.output_layer) {
                    // Ensure only one output layer is visible at a time
                    var visLyrs = layers.getVisibleLayers();
                    for (var i = 0, l; i < visLyrs.length; i++) {
                        l = visLyrs[i];
                        if (l !== lyr && l.output_layer) {
                            if (l.visible) {
                                l.visible = false;
                                changed.push(l);
                            }
                        }
                    }
                }
                layers.events.triggerEvent("visiblechange", {"changed": changed});
            }
            return lyr.visible;
        }

        function _getVisible(lyr) {
            // console.log('_getVisible', lyr);
            return lyr.visible;
        }

        function decorateLyr(lyr, grp) {
            // Add the layer to the lookup
            layers.layers[lyr.id] = lyr;
            // Add the toString function
            lyr.toString = _toString
            // Allow us to get the group from the layer
            lyr._group = grp;
            // Add method to get/set visibility
            lyr.setVisible = function(visible) {
                return _setVisible(lyr, visible);
            };
            lyr.getVisible = function() {
                return _getVisible(lyr);
            };
            return lyr;
        }

        function addLayer(grp, lyr) {
            removeLayer(lyr);
            lyr = decorateLyr(lyr, grp);
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
        refreshCalculatedLayer();
    }

    function addScenarioLayers() {
        // Add the additional layers to the activity groups if they don't
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
                    "visible": false,
                    "calculated": true,
                    "output_layer": true
                };
                var layerInfo = FISH_MAP.getLayerInfo(lyr.id);
                lyr._fullName = layerInfo.fullName;
                grp.addLayer(lyr);
            }
        }

        // Correct z-index of calculated layer so that it falls just below the
        // first extents layer
        for (var i = 0, layer; i < overlayLayers.list.length; i++) {
            layer = overlayLayers.list[i];
            if (layer.id.indexOf('extents_') === 0) {
                // "calculated" is an OpenLayers layer and "overlays" is a hash of
                // OpenLayers layers
                calculated.setZIndex(overlays[layer.id].getZIndex() - 1);
                break;
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
        events.triggerEvent('polygondrawn', {"polygon": feature});
    }

    function showScenario(args, count) {
        FISH_MAP.scenario.args = args;
        FISH_MAP.scenario.count = count;
        addScenarioLayers();
        events.triggerEvent('scenariocalculated');
        // Make a default scenario layer visible to help the user out
        var defaultLayer = overlayLayers.getLayerById('intensity_lvls_scenario');
        defaultLayer.setVisible(true);
        // Refresh the map state
        refreshCalculatedLayer();
    }

    /**
     * Set the state of the application based on passed parameters.
     * Used with server-side image export but also possible to use to bookmark
     * a given view of the application
     */
    function setView(params) {
        if (params) {
            // console.log(params);

            // Map view
            if (params.x && params.y && params.z) {
                map.setCenter(new OpenLayers.LonLat(params.x, params.y), params.z);
            }

            // Base map
            if (params.basemap) {
                for (var i = 0, layer; i < map.layers.length; i++) {
                    layer = this.map.layers[i];
                    if (layer.isBaseLayer) {
                        if (layer.layername === params.basemap) {
                            map.setBaseLayer(layer);
                            break;
                        }
                    }
                }
            }

            // Selected fishing activity
            if (params.fishing) {
                outputPanel.setActivity(params.fishing);
                // Scenario (depends on fishing activity)
                if (params.wkt) {
                    newScenario();
                    drawCtrl.deactivate();
                    var wkt = decodeURIComponent(params.wkt).replace(/\+/g, ' ');
                    var feats = (new OpenLayers.Format.WKT()).read(wkt);
                    scenarioLayer.addFeatures(feats);
                    scenarioAddFeature(feats);
                    outputPanel.setFormValues(params);
                    var args = outputPanel.calcArgs();
                    var count = outputPanel.calcCount(args);
                    showScenario(args, params.count);
                }
            }

            // Overlays (including any related to the current fishing activity
            // and scenario
            if (params.overlays) {
                var lyrs = decodeURIComponent(params.overlays).split(',');
                for (var i = 0; i < lyrs.length; i++) {
                    overlayLayers.getLayerById(lyrs[i]).setVisible(true);
                }
            }

            // Layout
            if (params.mode === 'export') {
                jQuery('#print_css').get(0).media = 'all';
            }

            if (params.infox && params.infoy) {
                var xy = map.getPixelFromLonLat(new OpenLayers.LonLat(params.infox, params.infoy));
                info.getInfoForClick({xy: xy})
            }
        }
    }

    /**
     * Set the initial view based on the query string parameters
     * Example urls for testing:
     * Set the view and enable some overlay layers:
     *   http://localhost:5000/?locale=en&z=3&y=386534&x=254249&overlays=habitats,wrecks
     * Also pre-select the fishing activity and show it's intensity:
     *   http://localhost:5000/?locale=en&z=3&y=386534&x=254249&overlays=habitats,wrecks,intensity_lvls_official&basemap=os&fishing=lot
     * Create a scenario including an area of interest:
     *   http://localhost:5000/?locale=en&z=3&y=386534&x=254249&overlays=habitats,wrecks,intensity_lvls_scenario&basemap=os&fishing=lot&wkt=POLYGON%28%28251399%20393996.5%2C253574%20388896.5%2C251224%20388896.5%2C249649%20390171.5%2C251399%20393996.5%29%29&dpm_0=0&dpm_1=0&dpm_2=0&dpm_3=0&dpm_4=0&dpm_5=2&dpm_6=3&dpm_7=0&dpm_8=0&dpm_9=0&dpm_10=0&dpm_11=0&gear_speed=2&gear_time=6&gear_width=8&vessels=9
     * Create a scenario and also switch to 'export' mode which uses the print style sheet
     *   http://localhost:5000/?locale=en&z=3&y=386534&x=254249&overlays=habitats,wrecks,intensity_lvls_scenario&basemap=os&fishing=lot&wkt=POLYGON%28%28251399%20393996.5%2C253574%20388896.5%2C251224%20388896.5%2C249649%20390171.5%2C251399%20393996.5%29%29&dpm_0=0&dpm_1=0&dpm_2=0&dpm_3=0&dpm_4=0&dpm_5=2&dpm_6=3&dpm_7=0&dpm_8=0&dpm_9=0&dpm_10=0&dpm_11=0&gear_speed=2&gear_time=6&gear_width=8&vessels=9&mode=export
     * Show info popup with infox / infoy
     *   http://localhost:5000/?locale=en&z=3&y=386534&x=254249&overlays=habitats,wrecks,intensity_lvls_scenario&basemap=os&fishing=lot&wkt=POLYGON%28%28251399%20393996.5%2C253574%20388896.5%2C251224%20388896.5%2C249649%20390171.5%2C251399%20393996.5%29%29&dpm_0=0&dpm_1=0&dpm_2=0&dpm_3=0&dpm_4=0&dpm_5=2&dpm_6=3&dpm_7=0&dpm_8=0&dpm_9=0&dpm_10=0&dpm_11=0&gear_speed=2&gear_time=6&gear_width=8&vessels=9&mode=export&infox=387&infoy=236
     */
    setView(parseUri(window.location).queryKey);

})();
