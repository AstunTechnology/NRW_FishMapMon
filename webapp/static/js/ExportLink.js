OpenLayers.Control.ExportLink = OpenLayers.Class(OpenLayers.Control, {

    /**
    * Constructor: OpenLayers.Control.ExportLink
    *
    * Parameters:
    * options - {Object} Options for control.
    */
    initialize: function(options) {
        OpenLayers.Control.prototype.initialize.apply(this, arguments);
        this.overlayLayers = options.overlayLayers;
        this.outputPanel = options.outputPanel;
        this.urlPrefix = '?';
        if (options.urlPrefix) {
            this.urlPrefix = options.urlPrefix;
        }
        this.linkText = 'Export Image';
        if (options.linkText) {
            this.linkText = options.linkText;
        }
    },

    /**
    * Method: draw
    * Initialize control.
    *
    * Returns:
    * {DOMElement} A reference to the DIV DOMElement containing the control
    */
    draw: function() {
        OpenLayers.Control.prototype.draw.apply(this, arguments);

        var link = jQuery('<a/>')
            .attr('href', '#')
            .attr('id', 'export_link')
            .text(this.linkText);
        jQuery(this.div).append(link);

        var ctrl = this;
        link.on('focus', function() {
            // Update the url on focus to ensure it has the correct parameters
            // prior to clicking
            ctrl.updateUrl();
        });

        return this.div;
    },

    getParams: function(layer) {

        var center = map.getCenter();
        if (center) {

            var params = {
                "locale": FISH_MAP.locale,
                "x": center.lon,
                "y": center.lat,
                "z": map.getZoom(),
                "overlays": this.overlayLayers.getVisibleLayers().join(','),
                "basemap": map.baseLayer.layername
            };

            if (FISH_MAP.fishingactivity) {
                params.fishing = FISH_MAP.fishingactivity;
                if (FISH_MAP.scenario) {
                    if (FISH_MAP.scenario.feature) {
                        params.wkt = FISH_MAP.scenario.feature.geometry.toString();
                        var items = this.outputPanel.getRawFormValues();
                        for (var i = 0, item; i < items.length; i++) {
                            item = items[i];
                            params[item.id] = item.val;
                        }
                    }
                }
            }

            if (FISH_MAP.info) {
                params.infox = FISH_MAP.info.x;
                params.infoy = FISH_MAP.info.y;
            }

            // params.mode = 'export';

            return params;
        }

        return {};
    },

    updateUrl: function(layer) {
        var params = this.getParams();
        var url = [];
        for (var name in params) {
            url.push(name + '=' + encodeURIComponent(params[name]));
        }

        jQuery('a', this.div).attr('href', this.urlPrefix + url.join('&'));
    },

    CLASS_NAME: "OpenLayers.Control.ExportLink"

});
