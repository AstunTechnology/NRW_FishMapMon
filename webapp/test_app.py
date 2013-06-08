from app import app, update_wms_layers, render_sld
from nose.tools import eq_


class TestUpdateWmsLayers():

    def test_update_wms_layers_param(self):
        """ Public layers are returned untouched """
        layers_in = ["project_area", "subtidal_habitats"]
        layers_out = update_wms_layers(layers_in, False)
        eq_(layers_in, layers_out)

    def test_update_wms_restricted_not_logged_in(self):
        """ Restricted layers removed when user not logged in """
        layers_in = ["activity_commercial_fishing_polygon"]
        layers_out = update_wms_layers(layers_in, False)
        eq_(layers_out, [])

    def test_update_wms_mixed_not_logged_in(self):
        """ Restricted layers removed, public layers retained for public user
        """
        layers_in = ["project_area", "activity_commercial_fishing_polygon"]
        layers_out = update_wms_layers(layers_in, False)
        eq_(layers_out, ["project_area"])

    def test_update_wms_restricted_logged_in(self):
        """ Restricted layers returned when the user is logged in """
        layers_in = ["activity_commercial_fishing_polygon"]
        layers_out = update_wms_layers(layers_in, True)
        eq_(layers_out, layers_in)

    def test_update_wms_mixed_logged_in(self):
        """ Public and restricted layers returned when the user is logged in
        """
        layers_in = ["project_area", "activity_commercial_fishing_polygon"]
        layers_out = update_wms_layers(layers_in, True)
        eq_(
            layers_out,
            layers_in
        )

    def test_update_wms_output_layer_not_logged_in(self):
        """ Project output layer has _gen suffix when user is not logged in """
        layers_in = [
            "intensity_lvls_cas_hand_gath",
            "vessels_lvls_fixed_pots",
            "sensitivity_lvls_foot_access"
        ]
        layers_out = update_wms_layers(layers_in, False)
        eq_(
            layers_out,
            [
                "intensity_lvls_cas_hand_gath_gen",
                "vessels_lvls_fixed_pots_gen",
                "sensitivity_lvls_foot_access"
            ]
        )

    def test_update_wms_output_layer_logged_in(self):
        """ Project output layer has _det suffix when user is logged in """
        layers_in = [
            "intensity_lvls_cas_hand_gath",
            "vessels_lvls_fixed_pots",
            "sensitivity_lvls_foot_access"
        ]
        layers_out = update_wms_layers(layers_in, True)
        eq_(
            layers_out,
            [
                "intensity_lvls_cas_hand_gath_det",
                "vessels_lvls_fixed_pots_det",
                "sensitivity_lvls_foot_access"
            ]
        )


class TestRenderSld():
    """ Test render_sld function which """

    def test_single(self):
        """ Single layer results in a single NamedLayer """
        with app.test_client() as c:
            c.get("/")
            sld = render_sld(["subtidal_habitats"])
            assert "subtidal_habitats" in sld
            assert sld.count('<NamedLayer>') == 1

    def test_multiple(self):
        """ A NamedLayer per layer """
        with app.test_client() as c:
            c.get("/")
            sld = render_sld([
                "subtidal_habitats",
                "intensity_lvls_cas_hand_gath"
            ])
            assert "intensity_lvls_cas_hand_gath" in sld
            assert "subtidal_habitats" in sld
            assert sld.count('<NamedLayer>') == 2

    def test_output_layers(self):
        """ Output layers uses a common sld one per type """
        with app.test_client() as c:
            c.get("/")
            sld = render_sld([
                "intensity_lvls_cas_hand_gath_gen",
                "vessels_lvls_fixed_pots_gen",
                "sensitivity_lvls_foot_access_gen"
            ])
            assert "intensity_lvls_cas_hand_gath_gen" in sld
            assert "vessels_lvls_fixed_pots_gen" in sld
            assert "sensitivity_lvls_foot_access_gen" in sld
            assert "<Name>intensity</Name>" in sld
            assert "<Name>vessels</Name>" in sld
            assert "<Name>sensitivity</Name>" in sld

    def test_layer_with_no_template_ignored(self):
        """ Layers without a template are just ignored """
        with app.test_client() as c:
            c.get("/")
            sld = render_sld([
                "subtidal_habitats",
                "intensity_lvls_cas_hand_gath",
                "this_layer_does_not_have_a_template"
            ])
            assert "intensity_lvls_cas_hand_gath" in sld
            assert "subtidal_habitats" in sld
            assert "this_layer_does_not_have_a_template" not in sld
            assert sld.count('<NamedLayer>') == 2
