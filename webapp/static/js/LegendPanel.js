OpenLayers.Control.LegendPanel = OpenLayers.Class(OpenLayers.Control, {

    /**
    * Constructor: OpenLayers.Control.LegendPanel
    *
    * Parameters:
    * options - {Object} Options for control.
    */
    initialize: function(options) {
        this.layer = options.layer;
        this.title = (options.title) ? options.title : 'Legend';
        OpenLayers.Control.prototype.initialize.apply(this, arguments);
    },

    showLayers: function(layers) {
        var tmpl = jQuery('#legendTmpl').html();
        jQuery('.content', this.legendDiv).empty();
        if (layers.length) {
            for (var n = 0, lyr; n < layers.length; n++) {
                lyr = layers[n];
                var qsChar = (FISH_MAP.WMS_OVERLAY_URL.indexOf("?") === -1) ? "?" : "&";
                var legendElm = jQuery.mustache(tmpl, jQuery.extend({
                        "url": FISH_MAP.WMS_OVERLAY_URL + qsChar + "LAYER=" + lyr + "&FISHING=" + FISH_MAP.fishingactivity + "&VERSION=1.1.1&SERVICE=WMS&REQUEST=GetLegendGraphic&FORMAT=image/png",
                        "id": (lyr._fullName) ? lyr._fullName : lyr.id,
                        "desc": lyr.desc
                    }, FISH_MAP.tmplView));
                jQuery('.content', this.legendDiv).append(legendElm);
            }
            jQuery(this.div).show();
        } else {
            jQuery(this.div).hide();
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

        this.legendDiv = document.createElement('div');
        jQuery(this.legendDiv).addClass("legend").addClass("open");
        this.legendDiv.innerHTML = "<h2>" + this.title + "</h2><div class='content'></div>";
        this.div.appendChild(this.legendDiv);

        jQuery('.legend', this.div).children().prev().bind("click touchstart", function(evt) {
            jQuery(this).siblings().toggle();
            jQuery(this).parent().toggleClass('open');
            return false;
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
            "touchstart": stopEvt,
            "mouseout": stopEvt,
            "dblclick": stopEvt,
            scope: this
        });

        return this.div;
    },

    CLASS_NAME: "OpenLayers.Control.LegendPanel"
});
