OutputPanel = OpenLayers.Class({

    /**
    * Constructor: OutputPanel
    *
    * Parameters:
    * options - {Object} Options for panel.
    */
    initialize: function(options) {
        this.layers = options.layers;
        this.activities = options.activities;
        this.div = jQuery(options.div);
        this.controller = options.controller;
        this.events = new OpenLayers.Events(this, this.div.get(0), null, true);
        var that = this;
        this.controller.on({
            'predrawpolygon': function(e) {
                that.showInfo('predrawpolygon');
                jQuery('.new_scenario').parent().hide();
            },
            'polygondrawn': function(e) {
                that.showInfo('polygondrawn');
                that.showScenarioForm();
            },
            'scenariocalculated': function(e) {
                that.showInfo('scenariocalculated');
                that.drawActivityLayers();
            },
            'clearscenario': function(e) {
                that.showInfo('clearscenario');
                that.hideScenarioForm();
                that.drawActivityLayers();
                jQuery('.new_scenario').parent().show();
            }
        });
    },

    getActivity: function() {
        return this._activity;
    },

    _setActivity: function(activity) {
        this._activity = activity;
        this.events.triggerEvent("activitychange", {activity: this.getActivity()});
        return this.getActivity();
    },

    /**
    * Method: draw
    *
    * Returns:
    * {DOMElement} A reference to the DIV DOMElement containing the panel.
    */
    draw: function() {

        var panel = this;

        var tmpl = jQuery('#outputTmpl').html();
        var model = {"layers": this.layers, "activities": this.activities};
        var panelHtml = jQuery.mustache(tmpl, jQuery.extend(model, FISH_MAP.tmplView));
        this.div.append(panelHtml);

        this.showInfo('none');

        this.drawActivityLayers();

        this.div.delegate('h3', 'click', function() {
            jQuery(this).toggleClass('collapsed').siblings().toggle();
        });

        this.div.find('h3').click().first().click();

        this.div.delegate('input:checkbox', 'change', function() {
            // Ensure only one activity layer is visible at a time
            if (jQuery(this).parents().hasClass('activity') && this.checked) {
                var that = this;
                panel.div.find('.activity input:checkbox:checked').filter(function() {
                    // return (jQuery(this).val().match(panel.getActivity()) && this !== that);
                    return (this !== that);
                }).each(function() {
                    this.checked = false;
                    panel.events.triggerEvent("layerchange", {layer: this.value, state: this.checked});
                });
            }
            panel.events.triggerEvent("layerchange", {layer: this.value, state: this.checked});
        });

        // Add a 'clicked' class to checkboxes clicked by the user, used in the
        // logic that ensures the associated extents are shown when the fishing
        // activity changes. Checking the box via the keyboard should also
        // trigger the click event which is what we want
        this.div.delegate('input:checkbox', 'click', function() {
            jQuery(this).addClass('clicked');
        });

        this.div.find('select').change(function() {
            panel._setActivity(this.value);
            panel.syncLayers();
        }).change();

        jQuery('a.new_scenario', panel.div).click(function() {
            panel.events.triggerEvent("newscenario");
            return false;
        });

        jQuery('input[name=clear_scenario]', panel.div).click(function() {
            panel.events.triggerEvent("clearscenario");
            return false;
        });

        jQuery('input[name=show_scenario]', panel.div).click(function() {
            var args = [];
            jQuery('form fieldset:visible').each(function() {
                var val = 0;
                jQuery(this).find('input:text').each(function() {
                    val += parseInt(this.value, 10);
                })
                args.push(val);
            });
            panel.events.triggerEvent("showscenario", {args: args});
            return false;
        });

        return this.div;

    },

    syncLayers: function() {
        // Ensure that the appropriate extent layer is enabled for the selected
        // activity
        var panel = this;
        jQuery('.extents_grp input:checkbox', this.div).each(function() {
            var elm = jQuery(this);
            // Uncheck all layers that the user has not selected themselves
            if (elm.hasClass('clicked') === false) {
                this.checked = false;
            }
            // Always check the layer that is assocaiated with the current
            // activity
            if (this.id.match(panel.getActivity())) {
                this.checked = true;
            }
        }).change();
    },

    drawActivityLayers: function() {
        var activityTmpl = jQuery('#activityLayersTmpl').html();
        var activityHtml = jQuery.mustache(activityTmpl, {"layers": this.layers});
        // Clear the existing activity layer tree and append the new version
        this.div.find('.activity-tree').children().detach().end().append(activityHtml);
        this.syncLayers();
    },

    showInfo: function(state) {
        this.div.find('.info').hide();
        this.div.find('.info.' + state).show();
    },

    showScenarioForm: function() {
        jQuery('form fieldset', this.div).hide();
        var fields = this.scenarioFields[this.getActivity()];
        for (var i = 0, fld; i < fields.length; i++) {
            fld = fields[i];
            jQuery('form fieldset.' + fld, this.div).show();
        }
        jQuery('form').show();
    },

    hideScenarioForm: function() {
        jQuery('form', this.div).hide();
    },

    /**
     * Lookup of activity to scenario fields
     */
    scenarioFields: {
        "king_scallops": ['dpm', 'gear_speed', 'gear_time', 'gear_width', 'num_dredges'],
        "queen_scallops": ['dpm', 'gear_speed', 'gear_time', 'gear_width', 'num_dredges'],
        "mussels": ['dpm', 'gear_speed', 'gear_time', 'gear_width', 'num_dredges'],
        "lot": ['dpm', 'gear_speed', 'gear_time', 'gear_width'],
        "nets": ['dpm', 'net_len', 'num_nets'],
        "pots_commercial": ['dpm', 'num_pots', 'num_anchors'],
        "pots_recreational": ['dpm', 'num_pots', 'num_anchors'],
        "pots_combined": ['dpm', 'num_pots', 'num_anchors'],
        "rsa_charterboats": ['dpm', 'num_rods', 'avg_hours'],
        "rsa_noncharter": ['dpm', 'num_rods', 'avg_hours'],
        "rsa_combined": ['dpm', 'num_rods', 'avg_hours'],
        "rsa_shore": ['dpm', 'num_rods', 'avg_hours'],
        "cas_hand_gath": ['dpm', 'num_gath', 'avg_hours'],
        "pro_hand_gath": ['dpm', 'num_gath', 'avg_hours']
    }

});
