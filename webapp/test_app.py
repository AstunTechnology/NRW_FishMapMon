from app import app, update_wms_layers, render_sld, process_feature_info
import xml.etree.ElementTree as ET
from nose.tools import eq_


class TestUpdateWmsLayers():

    def test_update_wms_layers_param(self):
        """ Public layers are returned untouched """
        layers_in = ["project_area", "habitats"]
        layers_out, cachable = update_wms_layers(layers_in, False)
        eq_(layers_in, layers_out)

    def test_update_wms_restricted_not_logged_in(self):
        """ Restricted layers removed when user not logged in """
        layers_in = ["activity_commercial_fishing_polygon"]
        layers_out, cacheable = update_wms_layers(layers_in, False)
        eq_(layers_out, [])

    def test_update_wms_mixed_not_logged_in(self):
        """ Restricted layers removed, public layers retained for public user
        """
        layers_in = ["project_area", "activity_commercial_fishing_polygon"]
        layers_out, cacheable = update_wms_layers(layers_in, False)
        eq_(layers_out, ["project_area"])

    def test_update_wms_restricted_logged_in(self):
        """ Restricted layers returned when the user is logged in """
        layers_in = ["activity_commercial_fishing_polygon"]
        layers_out, cacheable = update_wms_layers(layers_in, True)
        eq_(layers_out, layers_in)

    def test_update_wms_mixed_logged_in(self):
        """ Public and restricted layers returned when the user is logged in
        """
        layers_in = ["project_area", "activity_commercial_fishing_polygon"]
        layers_out, cacheable = update_wms_layers(layers_in, True)
        eq_(
            layers_out,
            layers_in
        )

    def test_update_wms_output_layer_not_logged_in(self):
        """ Project output layer has _gen suffix when user is not logged in """
        layers_in = [
            "intensity_lvls_cas_hand_gath",
            "vessels_lvls_pots_combined",
            "sensitivity_lvls_nets"
        ]
        layers_out, cacheable = update_wms_layers(layers_in, False)
        eq_(
            layers_out,
            [
                "intensity_lvls_cas_hand_gath_gen",
                "vessels_lvls_pots_combined_gen",
                "sensitivity_lvls_nets_gen"
            ]
        )

    def test_update_wms_output_layer_logged_in(self):
        """ Project output layer has _det suffix when user is logged in """
        layers_in = [
            "intensity_lvls_cas_hand_gath",
            "vessels_lvls_pots_combined",
            "sensitivity_lvls_nets"
        ]
        layers_out, cacheable = update_wms_layers(layers_in, True)
        eq_(
            layers_out,
            [
                "intensity_lvls_cas_hand_gath_det",
                "vessels_lvls_pots_combined_det",
                "sensitivity_lvls_nets_det"
            ]
        )


class TestRenderSld():
    """ Test render_sld function which """

    def test_single(self):
        """ Single layer results in a single NamedLayer """
        with app.test_client() as c:
            c.get("/")
            sld = render_sld(["habitats"], {})
            assert "habitats" in sld
            assert sld.count('<NamedLayer>') == 1

    def test_multiple(self):
        """ A NamedLayer per layer """
        with app.test_client() as c:
            c.get("/")
            sld = render_sld([
                "habitats",
                "intensity_lvls_official_gen"
            ], {"FISHING": "cas_hand_gath"})
            assert "intensity_lvls_official_gen" in sld
            assert "habitats" in sld
            assert sld.count('<NamedLayer>') == 2

    def test_output_layers(self):
        """ Output layers uses a common sld one per type """
        with app.test_client() as c:
            c.get("/")
            sld = render_sld([
                "intensity_lvls_official_gen",
                "vessels_lvls_official_gen",
                "sensitivity_lvls_official_gen"
            ], {"FISHING": "cas_hand_gath"})
            assert "intensity_lvls_official_gen" in sld
            assert "vessels_lvls_official_gen" in sld
            assert "sensitivity_lvls_official_gen" in sld
            assert "<Name>intensity</Name>" in sld
            assert "<Name>vessels</Name>" in sld
            assert "<Name>sensitivity</Name>" in sld

    def test_layer_with_no_template_ignored(self):
        """ Layers without a template are just ignored """
        with app.test_client() as c:
            c.get("/")
            sld = render_sld([
                "habitats",
                "intensity_lvls_official_gen",
                "this_layer_does_not_have_a_template"
            ], {"FISHING": "cas_hand_gath"})
            assert "intensity_lvls_official" in sld
            assert "habitats" in sld
            assert "this_layer_does_not_have_a_template" not in sld
            assert sld.count('<NamedLayer>') == 2

    def test_vessels_bands(self):
        """ The appropriate bands are present for vessels layers"""
        with app.test_client() as c:
            c.get("/")
            sld = render_sld([
                "vessels_lvls_official"
            ], {"FISHING": "king_scallops"})
            assert sld.count('<Rule>') == 3
            sld = render_sld([
                "vessels_lvls_official"
            ], {"FISHING": "rsa_combined"})
            assert sld.count('<Rule>') == 5


class TestProcessFeatureInfo():

    def test_low_vessels_suppressed(self):
        """ Suppress low vessel numbers when not logged in """

        body = """<?xml version="1.0" encoding="ISO-8859-1"?>
                    <msGMLOutput
                        xmlns:gml="http://www.opengis.net/gml"
                        xmlns:xlink="http://www.w3.org/1999/xlink"
                        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                        <extents_mussels_layer>
                        <gml:name>extents_mussels</gml:name>
                            <extents_mussels_feature>
                                <ogc_fid>1</ogc_fid>
                                <id>0</id>
                            </extents_mussels_feature>
                        </extents_mussels_layer>
                        <vessels_lvls_official_gen_layer>
                        <gml:name>vessels_lvls_official_gen</gml:name>
                            <vessels_lvls_official_gen_feature>
                                <ogc_fid>11</ogc_fid>
                                <fishingtype>3</fishingtype>
                                <gearclass>Mobile</gearclass>
                                <intensity_value>0.3038</intensity_value>
                                <intensity_level>1</intensity_level>
                                <_overlaps>2</_overlaps>
                                <num_gatherers_year>2</num_gatherers_year>
                                <num_anglers_year>2</num_anglers_year>
                            </vessels_lvls_official_gen_feature>
                        </vessels_lvls_official_gen_layer>
                    </msGMLOutput>"""

        layers = ['project_area', 'mask', 'extents_mussels',
                  'vessels_lvls_official_gen']

        body = process_feature_info(layers, body, False)

        ET.register_namespace('gml', 'http://www.opengis.net/gml')
        tree = ET.fromstring(body)

        eq_(next(tree.iter('_overlaps')).text, '2 or less')
        eq_(next(tree.iter('num_gatherers_year')).text, '2 or less')
        eq_(next(tree.iter('num_anglers_year')).text, '2 or less')

    def test_vessels_not_suppressed_when_auth(self):
        """ Vessels values are not suppressed when logged in """

        body = """<?xml version="1.0" encoding="ISO-8859-1"?>
        <msGMLOutput
             xmlns:gml="http://www.opengis.net/gml"
             xmlns:xlink="http://www.w3.org/1999/xlink"
             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <extents_mussels_layer>
            <gml:name>extents_mussels</gml:name>
                <extents_mussels_feature>
                    <ogc_fid>1</ogc_fid>
                    <id>0</id>
                </extents_mussels_feature>
            </extents_mussels_layer>
            <vessels_lvls_official_det_layer>
            <gml:name>vessels_lvls_official_det</gml:name>
                <vessels_lvls_official_det_feature>
                    <ogc_fid>11</ogc_fid>
                    <activity>Commercial Fishing</activity>
                    <gearclass>Mobile</gearclass>
                    <geartype>Mussel dredge</geartype>
                    <intensity_value>0.1803</intensity_value>
                    <intensity_level>1</intensity_level>
                    <species>mussels</species>
                    <bycatch>green crab</bycatch>
                    <userid>c37</userid>
                    <_overlaps>1</_overlaps>
                    <num_gatherers_year>1</num_gatherers_year>
                    <num_anglers_year>1</num_anglers_year>
                    <gear_time>0</gear_time>
                    <gear_speed>3</gear_speed>
                    <gear_gearwidth>3</gear_gearwidth>
                    <gear_nodredges>4</gear_nodredges>
                    <daysperyear>8</daysperyear>
                    <jan>0</jan>
                    <feb>0</feb>
                    <mar>0</mar>
                    <apr>0</apr>
                    <may>0</may>
                    <jun>0</jun>
                    <jul>7</jul>
                    <aug>0</aug>
                    <sep>1</sep>
                    <oct>0</oct>
                    <nov>0</nov>
                    <dec_>0</dec_>
                </vessels_lvls_official_det_feature>
            </vessels_lvls_official_det_layer>
        </msGMLOutput>"""

        layers = ['project_area', 'mask', 'extents_mussels',
                  'vessels_lvls_official_det']

        body = process_feature_info(layers, body, True)

        ET.register_namespace('gml', 'http://www.opengis.net/gml')
        tree = ET.fromstring(body)

        eq_(next(tree.iter('_overlaps')).text, '1')
        eq_(next(tree.iter('num_gatherers_year')).text, '1')
        eq_(next(tree.iter('num_anglers_year')).text, '1')

    def test_suffix_removed(self):
        """ Suffixes are removed from layer names """

        body = """<?xml version="1.0" encoding="ISO-8859-1"?>
                    <msGMLOutput
                        xmlns:gml="http://www.opengis.net/gml"
                        xmlns:xlink="http://www.w3.org/1999/xlink"
                        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                        <extents_mussels_layer>
                        <gml:name>extents_mussels</gml:name>
                            <extents_mussels_feature>
                                <ogc_fid>1</ogc_fid>
                                <id>0</id>
                            </extents_mussels_feature>
                        </extents_mussels_layer>
                        <vessels_lvls_official_gen_layer>
                        <gml:name>vessels_lvls_official_gen</gml:name>
                            <vessels_lvls_official_gen_feature>
                                <ogc_fid>11</ogc_fid>
                                <fishingtype>3</fishingtype>
                                <gearclass>Mobile</gearclass>
                                <intensity_value>0.3038</intensity_value>
                                <intensity_level>1</intensity_level>
                                <_overlaps>2</_overlaps>
                            </vessels_lvls_official_gen_feature>
                        </vessels_lvls_official_gen_layer>
                    </msGMLOutput>"""

        # Layers have their prefix at this point ("_det" for logged in users,
        # "_gen" for not)
        layers = ['project_area', 'mask',
                  'extents_mussels', 'vessels_lvls_official_gen']

        body = process_feature_info(layers, body, False)

        ET.register_namespace('gml', 'http://www.opengis.net/gml')
        tree = ET.fromstring(body)

        eq_(tree.find('.//vessels_lvls_official_gen_feature'), None)
        assert tree.find('.//vessels_lvls_official_feature') is not None

        eq_(tree.find('.//vessels_lvls_official_gen_layer'), None)
        assert tree.find('.//vessels_lvls_official_layer') is not None
