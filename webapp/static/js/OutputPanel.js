OutputPanel = OpenLayers.Class(LayerPanel, {

    /**
    * Constructor: OutputPanel
    *
    * Parameters:
    * options - {Object} Options for panel.
    */
    initialize: function(options) {

        this.init(options);

        this.activities = options.activities;

        this.layers.events.register('visiblechange', this, function(e) {
            // console.log('OutputPanel.js visiblechange', e);
            this.syncActivityLayers(e.changed);
        });

        this.controller = options.controller;
        var that = this;
        this.controller.on({
            'predrawpolygon': function(e) {
                that.showInfo('predrawpolygon');
                jQuery('.new_scenario').parent().hide();
            },
            'polygondrawn': function(e) {
                // Calculate the area and show it in the form
                var area = (e.polygon.geometry.getArea()/1000000);
                area = area.toFixed(2)
                that.div.find('#scenario_area').val(area);
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

        this.draw();

    },

    setActivity: function(activity) {
        // console.log('setActivity, ' + activity);
        this.div.find('select').val(activity);
        this._setActivity(activity);
        // console.log(this.div.find('select').val());
    },

    getActivity: function() {
        return this._activity;
    },

    _setActivity: function(activity) {
        // console.log('_setActivity, ' + activity);
        this._activity = (activity === "") ? null : activity;
        this.events.triggerEvent("activitychange", {"activity": this.getActivity()});
        if (this._activity === null) {
            this.div.find('.activity-tree, p.buttons').hide();
        } else {
            this.div.find('.activity-tree, p.buttons').show();
        }
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
            panel.events.triggerEvent("layerchange", {layer: this.value, state: this.checked});
        });

        // Add a 'clicked' class to checkboxes clicked by the user, used in the
        // logic that ensures the associated extents are shown when the fishing
        // activity changes. Checking the box via the keyboard should also
        // trigger the click event which is what we want
        this.div.delegate('input:checkbox', 'click', function() {
            var l = panel.layers.getLayerById(this.id);
            l.clicked = (this.checked);
        });

        this.div.find('select').change(function() {
            panel._setActivity(this.value);
        }).change();

        jQuery('a.new_scenario', panel.div).click(function() {
            panel.events.triggerEvent("newscenario");
            return false;
        });

        jQuery('input[name=clear_scenario]', panel.div).click(function() {
            panel.events.triggerEvent("clearscenario");
            return false;
        });

        // Define specific validation rules for some inputs
        var rsvRules = [
            "range=0-31,dpm_0,Please enter a number of days per month.",
            "range=0-31,dpm_1,Please enter a number of days per month.",
            "range=0-31,dpm_2,Please enter a number of days per month.",
            "range=0-31,dpm_3,Please enter a number of days per month.",
            "range=0-31,dpm_4,Please enter a number of days per month.",
            "range=0-31,dpm_5,Please enter a number of days per month.",
            "range=0-31,dpm_6,Please enter a number of days per month.",
            "range=0-31,dpm_7,Please enter a number of days per month.",
            "range=0-31,dpm_8,Please enter a number of days per month.",
            "range=0-31,dpm_9,Please enter a number of days per month.",
            "range=0-31,dpm_10,Please enter a number of days per month.",
            "range=0-31,dpm_11,Please enter a number of days per month."
        ];

        // Then add generic for all
        jQuery('form div.variable input', panel.div).each(function () {
            rsvRules.push("required," + this.name + ",Please enter a number.");
        });

        /**
         * Custom validation function used with RSV that uses 'int' and 'float'
         * classes assigned to the inputs to determine how the field should be
         * validated
         */
        window.checkNumber = function() {
            var valid = true;
            jQuery('form div.variable input.float', panel.div).each(function () {
                if (isNaN(parseFloat(this.value))) {
                    valid = [[this, "Please enter a number (decimal places are allowed)"]];
                    return false;
                }
            });
            jQuery('form div.variable input.int', panel.div).each(function () {
                var n = parseFloat(this.value, 10);
                if (isNaN(n) || (n % 1 != 0)) {
                    valid = [[this, "Please enter a whole number (no decimal places)"]];
                    return false;
                }
            });
            return valid;
        };
        rsvRules.push("function,window.checkNumber");

        jQuery('form', panel.div).RSV({
            onCompleteHandler: function() {
                var args = panel.calcArgs();
                var count = panel.calcCount(args);
                panel.events.triggerEvent("showscenario", {"args": args, "count": count});
                return false;
            },
            displayType: "alert-one",
            "rules": rsvRules
        });

        this.addTooltips();

        return this.div;

    },

    setFormValues: function(controls) {
        for (var id in controls) {
            jQuery('#' + id, this.div).val(controls[id]);
        }
    },

    calcArgs: function() {
        var args = [];

        jQuery('form div.variable fieldset:visible', this.div).each(function() {
            var val = 0;
            jQuery(this).find('input:text').each(function() {
                val += parseFloat(this.value);
            })
            args.push(val);
        });

        return args;
    },

    calcCount: function(args) {
        var count = 1;
        var activity = this.getActivity();
        var countField = this.countFields[activity];
        if (countField) {
            count = jQuery("input#" + countField).val();
            if (countField != "vessels") {
                // Number of visits so multiply by days, always the first arg 
                count = count * args[0];
            }
        }
        return count;
    },

    getRawFormValues: function() {
        var panel = this;
        var controls = [];
        jQuery('form div.variable fieldset:visible', panel.div).each(function() {
            jQuery(this).find('input:text').each(function() {
                controls.push({id: this.id, val: parseFloat(this.value)});
            })
        });
        return controls;
    },

    drawActivityLayers: function() {
        var activityTmpl = jQuery('#activityLayersTmpl').html();
        var activityHtml = jQuery.mustache(activityTmpl, {"layers": this.layers});
        // Clear the existing activity layer tree and append the new version
        this.div.find('.activity-tree').children().detach().end().append(activityHtml);
        this.addTooltips();
    },

    syncActivityLayers: function(changed) {
        for (var i = 0, lyr; i < changed.length; i++) {
            lyr = changed[i];
            jQuery('#' + lyr.id).get(0).checked = lyr.getVisible();
        }
    },

    showInfo: function(state) {
        this.div.find('.info').hide();
        this.div.find('.info.' + state).show();
    },

    showScenarioForm: function() {
        jQuery('form div.variable fieldset', this.div).hide();
        var fields = this.scenarioFields[this.getActivity()];
        for (var i = 0, fld; i < fields.length; i++) {
            fld = fields[i];
            jQuery('form fieldset.' + fld, this.div)
                .find('input').val(0).end().show();
        }
        jQuery('form', this.div).show();
    },

    hideScenarioForm: function() {
        jQuery('form', this.div).hide();
    },

    /**
     * Lookup of activity to scenario fields
     */
    scenarioFields: {
        "king_scallops": ['dpm', 'gear_speed', 'gear_time', 'gear_width', 'num_dredges', "vessels"],
        "queen_scallops": ['dpm', 'gear_speed', 'gear_time', 'gear_width', 'num_dredges', "vessels"],
        "mussels": ['dpm', 'gear_speed', 'gear_time', 'gear_width', 'num_dredges', "vessels"],
        "lot": ['dpm', 'gear_speed', 'gear_time', 'gear_width', "vessels"],
        "nets": ['dpm', 'net_len', 'num_nets', "vessels"],
        "pots_commercial": ['dpm', 'num_pots', 'num_anchors', "vessels"],
        "pots_recreational": ['dpm', 'num_pots', 'num_anchors', "vessels"],
        "pots_combined": ['dpm', 'num_pots', 'num_anchors', "vessels"],
        "rsa_charterboats": ['dpm', 'num_rods', 'avg_hours', "vessels"],
        "rsa_noncharter": ['dpm', 'num_rods', 'avg_hours', "vessels"],
        "rsa_combined": ['dpm', 'num_rods', 'avg_hours', "vessels"],
        "rsa_shore": ['dpm', 'num_rods', 'avg_hours'],
        "cas_hand_gath": ['dpm', 'num_gath', 'avg_hours'],
        "pro_hand_gath": ['dpm', 'num_gath', 'avg_hours']
    },

    /** 
     * 'COUNT' field used for "vessel" calculations
     */
    countFields: {
        "king_scallops": "vessels",
        "queen_scallops": "vessels",
        "mussels": "vessels",
        "lot": "vessels",
        "nets": "vessels",
        "pots_commercial": "vessels",
        "pots_recreational": "vessels",
        "pots_combined": "vessels",
        "rsa_charterboats": "vessels",
        "rsa_noncharter": "vessels",
        "rsa_combined": "vessels",
        "rsa_shore": "num_rods",
        "cas_hand_gath": "num_gath",
        "pro_hand_gath": "num_gath"
    }
});
