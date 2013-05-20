(function(){
    var controls = [
        new OpenLayers.Control.TouchNavigation({
            dragPanOptions: {
                enableKinetic: true
            }
        }),
        new OpenLayers.Control.Attribution(),
        new OpenLayers.Control.Scale(),
        new OpenLayers.Control.Navigation(),
        new OpenLayers.Control.LayerSwitcher(),
        new OpenLayers.Control.MousePosition(),
        new OpenLayers.Control.PanZoomBar()
    ];

    map = new OpenLayers.Map('map', {controls: controls});

    var base_osm = new OpenLayers.Layer.OSM("OpenStreetMap");
    map.addLayer(base_osm);

    map.setCenter(
        new OpenLayers.LonLat(-4.356, 53.286).transform(
            new OpenLayers.Projection("EPSG:4326"),
            map.getProjectionObject()
        ),
        10
    );

})();
