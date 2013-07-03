<NamedLayer>
    <Name>{{info['name']}}</Name>
    <UserStyle>
        <Name>name</Name>
        <FeatureTypeStyle>
            <Rule>
                <Name>{{ _('Shallow Inlets and Bays') }}</Name>
                <ogc:Filter>
                    <ogc:PropertyIsEqualTo>
                        <ogc:PropertyName>general_feature</ogc:PropertyName>
                        <ogc:Literal>Shallow Inlets and Bays</ogc:Literal>
                    </ogc:PropertyIsEqualTo>
                </ogc:Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <GraphicFill>
                            <Graphic>
                                <ExternalGraphic>
                                    <OnlineResource xlink:type="simple" xlink:href="symbols/images/mapinfo_brush_17_paleblue.png" />
                                    <Format>image/png</Format>
                                </ExternalGraphic>
                            </Graphic>
                        </GraphicFill>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Mudflats and Sandflats') }}</Name>
                <ogc:Filter>
                    <ogc:PropertyIsEqualTo>
                        <ogc:PropertyName>general_feature</ogc:PropertyName>
                        <ogc:Literal>Mudflats and Sandflats</ogc:Literal>
                    </ogc:PropertyIsEqualTo>
                </ogc:Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <GraphicFill>
                            <Graphic>
                                <ExternalGraphic>
                                    <OnlineResource xlink:type="simple" xlink:href="symbols/images/mapinfo_brush_14_orange.png" />
                                    <Format>image/png</Format>
                                </ExternalGraphic>
                            </Graphic>
                        </GraphicFill>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Reefs') }}</Name>
                <ogc:Filter>
                    <ogc:PropertyIsEqualTo>
                        <ogc:PropertyName>general_feature</ogc:PropertyName>
                        <ogc:Literal>reefs</ogc:Literal>
                    </ogc:PropertyIsEqualTo>
                </ogc:Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <GraphicFill>
                            <Graphic>
                                <ExternalGraphic>
                                    <OnlineResource xlink:type="simple" xlink:href="symbols/images/mapinfo_brush_18_red.png" />
                                    <Format>image/png</Format>
                                </ExternalGraphic>
                            </Graphic>
                        </GraphicFill>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Sandbanks') }}</Name>
                <ogc:Filter>
                    <ogc:PropertyIsEqualTo>
                        <ogc:PropertyName>general_feature</ogc:PropertyName>
                        <ogc:Literal>Sandbanks</ogc:Literal>
                    </ogc:PropertyIsEqualTo>
                </ogc:Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <GraphicFill>
                            <Graphic>
                                <ExternalGraphic>
                                    <OnlineResource xlink:type="simple" xlink:href="symbols/images/mapinfo_brush_48_yellow.png" />
                                    <Format>image/png</Format>
                                </ExternalGraphic>
                            </Graphic>
                        </GraphicFill>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <!-- This is a place holder for the sea caves features which
                     are actually held in a seperate sac_features_line table
                     which is styled via a CLASS in the mapfile itself and
                     displayed via a REQUIRES statement -->
                <Name>{{ _('Sea Caves') }}</Name>
                <ogc:Filter>
                    <ogc:PropertyIsEqualTo>
                        <ogc:PropertyName>general_feature</ogc:PropertyName>
                        <ogc:Literal>Sea Caves (dummy)</ogc:Literal>
                    </ogc:PropertyIsEqualTo>
                </ogc:Filter>
                <PolygonSymbolizer>
                    <Stroke>
                        <CssParameter name="stroke">#FF00FF</CssParameter>
                        <CssParameter name="stroke-width">2</CssParameter>
                    </Stroke>
                </PolygonSymbolizer>
            </Rule>
        </FeatureTypeStyle>
    </UserStyle>
</NamedLayer>
