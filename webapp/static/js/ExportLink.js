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
        this.urlPrefix = options.urlPrefix || '/export?';
        // Text visible to the user
        this.buttonText = options.buttonText || 'Export image';
        this.waitText = options.waitText || 'Please wait...';
        this.errorMessage = options.errorMessage || 'An error occured, please try again';
        this.downloadText = options.downloadText || 'Download image';
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
            .text(this.buttonText)
            .addClass('button');
        jQuery(this.div).append(link);

        var msg = jQuery('<p/>')
            .addClass('info')
            .on('click', '*', function() {
                msg.removeClass('active');
            });
        jQuery(this.div).append(msg);

        var ctrl = this;
        link.click(function() {
            if (jQuery(ctrl.div).hasClass('loading')) {
                // Do nothing as a request is pending
            } else {
                jQuery.getJSON(ctrl.getUrl(), function(data) {
                    ctrl.hideMsg();
                    jQuery(ctrl.div).addClass('loading');
                    ctrl.setLinkText(ctrl.waitText);
                    ctrl.poll(data.job_key);
                });
            }
            return false;
        });

        jQuery('body').bind("click touchstart", function() {
            ctrl.hideMsg();
        });

        return this.div;
    },

    poll: function(job_key) {
        var ctrl = this;
        jQuery.getJSON('/export/status/' + job_key)
        .done(function(data) {
            if (data.status === 'pending') {
                window.setTimeout(function () {
                    ctrl.poll(job_key)
                }, 2000);
            } else {
                // Download the image (Flask should send it as an attachment so
                // the user will be prompted to download and the current page
                // will not be replaced)
                // window.location.href = data.result;
                ctrl.showMsg('<a href="' + data.result + '">' + ctrl.downloadText + '</a>');
            }
        })
        .fail(function () {
            ctrl.showMsg(ctrl.errorMessage, 5000);
        })
        .always(function(data) {
            // If we're either done or an error occured then tidy up the button
            // state and text
            if (data.status !== 'pending') {
                jQuery(ctrl.div).removeClass('loading');
                ctrl.setLinkText(ctrl.buttonText);
            }
        });
    },

    setLinkText: function(txt) {
        jQuery('a.button', this.div).text(txt);
    },

    showMsg: function(msg, timeout) {
        jQuery('p.info', this.div).empty().append(msg).addClass('active');
        var ctrl = this;
        if (timeout) {
            setTimeout(function() {ctrl.hideMsg()}, timeout);
        }
    },

    hideMsg: function() {
        jQuery('p.info', this.div).removeClass('active');
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

            params.mode = 'export';

            return params;
        }

        return {};
    },

    getUrl: function(layer) {
        var params = this.getParams();
        var url = [];
        for (var name in params) {
            url.push(name + '=' + encodeURIComponent(params[name]));
        }
        return this.urlPrefix + url.join('&');
    },

    CLASS_NAME: "OpenLayers.Control.ExportLink"

});
