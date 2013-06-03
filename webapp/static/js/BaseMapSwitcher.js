OpenLayers.Control.BaseMapSwitcher = OpenLayers.Class(OpenLayers.Control, {

    /**
    * Constructor: OpenLayers.Control.BaseMapSwitcher
    *
    * Parameters:
    * options - {Object} Options for control.
    */
    initialize: function(options) {
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

        for (var i = 0, layer, link; i < this.map.layers.length; i++) {
            layer = this.map.layers[i];
            if (layer.isBaseLayer) {
                link = jQuery('<a/>')
                        .attr('href', '#')
                        .attr('id', layer.id)
                        .text(layer.name)
                        .toggleClass('active', layer.visibility);
                jQuery(this.div).append(link);
            }
        }

        jQuery('a', this.div).click(function() {
            jQuery(this)
                .addClass('active')
                .siblings().removeClass('active');
            map.setBaseLayer(map.getLayer(this.id));
            return false;
        });

        return this.div;
    },

    CLASS_NAME: "OpenLayers.Control.BaseMapSwitcher"

});