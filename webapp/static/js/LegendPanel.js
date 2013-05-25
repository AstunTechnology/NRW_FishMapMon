OpenLayers.Control.LegendPanel = OpenLayers.Class(OpenLayers.Control, {

/**
 * Constructor: OpenLayers.Control.LegendPanel
 *
 * Parameters:
 * options - {Object} Options for control.
 */
initialize: function(options) {
    this.layer = options.layer;
    OpenLayers.Control.prototype.initialize.apply(this, arguments);
},

showLayers: function(layers) {
    var tmpl = jQuery('#legendTmpl').html();
    jQuery('.content', this.legendDiv).empty();
    for (var n = 0, lyr; n < layers.length; n++) {
        lyr = layers[n];
        var legendElm = jQuery.mustache(tmpl, {
            "url": FISH_MAP.WMS_OVERLAY_URL + "&LAYER=" + lyr + "&VERSION=1.1.1&SERVICE=WMS&REQUEST=GetLegendGraphic&FORMAT=image/png&SLD=" + encodeURIComponent(FISH_MAP.SLD_URL + lyr),
            "name": function() {
                return window.FISH_MAP.text[lyr];
            }
        });
        jQuery('.content', this.legendDiv).append(legendElm);
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
    this.legendDiv.innerHTML = "<h2>Legend</h2><div class='content'></div>";
    this.div.appendChild(this.legendDiv);

    jQuery('.legend', this.div).children().prev().click(function(evt) {
        jQuery(this).siblings().toggle();
        jQuery(this).parent().toggleClass('open')
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

CLASS_NAME: "OpenLayers.Control.LegendPanel"
});
