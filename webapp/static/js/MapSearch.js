OpenLayers.Control.MapSearch = OpenLayers.Class(OpenLayers.Control, {

    /**
    * Constructor: OpenLayers.Control.MapSearch
    *
    * Parameters:
    * options - {Object} Options for control.
    */
    initialize: function(options) {
        this.tooltip = (options.tooltip) ? options.tooltip : 'Search for place name or postcode';
        this.noResultsMessage = (options.noResultsMessage) ? options.noResultsMessage : 'No results found';
        OpenLayers.Control.prototype.initialize.apply(this, arguments);
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

        this.input = jQuery('<input title="' + this.tooltip + '" />');

        this.div.appendChild(this.input.get(0));

        var that = this;
        this.input.autocomplete({
            source: function(req, callback) {
                jQuery.get(FISH_MAP.GAZ_URL + req.term).done(function(self, status, resp) {
                    var gmlFormat = new OpenLayers.Format.GML();
                    var features = gmlFormat.read(resp.responseText);
                    var candidates = [];
                    for (var i = 0, feat; i < features.length; i++) {
                        feat = features[i];
                        candidates.push({label: feat.attributes.name, value: feat});
                    }
                    if (candidates.length === 0) {
                        that.flashMsg(that.noResultsMessage);
                    }
                    callback(candidates);
                });
            },
            select: function(event, data) {
                that.map.zoomToExtent(data.item.value.bounds);
                that.map.setCenter(null, 3);
                jQuery(this).blur();
                // Prevent the input being updated with the value associated
                // with the current item as in our case the value is an object
                return false;
            },
            focus: function(event, data) {
                // Prevent the input being updated with the value associated
                // with the current item as in our case the value is an object
                return false;
            },
            minLength: 2
        });

        this.input.click(function() {
            jQuery(this).autocomplete("search");
        });

        jQuery('body').click(function() {
            jQuery(that.input).autocomplete("close");
        });

        this.events = new OpenLayers.Events(this, this.div, null, true);

        var stopEvt = function(evt) {
            OpenLayers.Event.stop(evt, true);
        };

        this.events.on({
            "mousedown": stopEvt,
            "mousemove": stopEvt,
            "mouseup": stopEvt,
            "click": stopEvt,
            "mouseout": stopEvt,
            "dblclick": stopEvt,
            scope: this
        });

        return this.div;
    },

    flashMsg: function(msg) {
        jQuery('.msg', this.div).hide();
        var markup = '<div class="msg">' + msg + '</div>';
        jQuery(markup).appendTo(this.div).delay(800).fadeOut(400);

    },

    CLASS_NAME: "OpenLayers.Control.MapSearch"

});
