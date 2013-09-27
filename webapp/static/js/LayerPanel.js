LayerPanel = OpenLayers.Class({

    /**
    * Constructor: LayerPanel
    *
    * Parameters:
    * options - {Object} Options for panel.
    */
    initialize: function(options) {
        this.init(options);
        this.draw();
    },

    init: function(options) {
        this.layers = options.layers;
        this.div = jQuery(options.div);
        this.events = new OpenLayers.Events(this, this.div.get(0), null, true);
        this.showLayerTmpl = jQuery.trim(jQuery('#showLayerTmpl').html());
        this.hideLayerTmpl = jQuery.trim(jQuery('#hideLayerTmpl').html());
        this.showHeaderTmpl = jQuery.trim(jQuery('#showHeaderTmpl').html());
        this.hideHeaderTmpl = jQuery.trim(jQuery('#hideHeaderTmpl').html());
    },

    draw: function() {
        var panel = this;
        var tmpl = jQuery('#treeTmpl').html();
        var treeElm = jQuery.mustache(tmpl, jQuery.extend(this.layers, FISH_MAP.tmplView));

        this.div.append(treeElm);

        this.div.find('input').change(function() {
            panel.events.triggerEvent("layerchange", {layer: this.value, state: this.checked});
        });

        this.div.find('h3').click(function() {
            jQuery(this).toggleClass('collapsed').siblings().toggle();
        }).click().first().click();

        this.addTooltips();

        return this.div;
    },

    addTooltips: function() {
        var panel = this;

        function setLayerTooltip(input) {
            var elm = jQuery(input),
            label = jQuery("label[for='" + input.id + "']");
            elm.add(label).attr('title', panel.getLayerTooltip(label.text(), input.checked));
        }

        function setHeaderTooltip(header) {
            var elm = jQuery(header);
            elm.attr('title', panel.getHeaderTooltip(elm.text(), (elm.hasClass('collapsed') === false)));
        }

        // NOTE: Use :not([title]) to only target elements that we have not
        // already added the behaviour to (don't have a title attribute)

        jQuery('ul.tree input:checkbox:not([title])', this.div).change(function() {
            setLayerTooltip(this);
        }).each(function () {
            setLayerTooltip(this);
        });

        jQuery('ul.tree h3:not([title])', this.div).click(function() {
            setHeaderTooltip(this);
        }).each(function () {
            setHeaderTooltip(this);
        });
    },

    getLayerTooltip: function(text, checked) {
        var tmpl = (checked) ? this.hideLayerTmpl : this.showLayerTmpl;
        return jQuery.mustache(tmpl, {"text": text});
    },

    getHeaderTooltip: function(text, open) {
        var tmpl = (open) ? this.hideHeaderTmpl : this.showHeaderTmpl;
        return jQuery.mustache(tmpl, {"text": text});
    }

});
