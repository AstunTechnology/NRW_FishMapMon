<NamedLayer>
    <Name>{{info['name']}}</Name>
    <UserStyle>
        <Name>name</Name>
        <FeatureTypeStyle>
            <Rule>
                <Name>{{ _('Mud and Sand Flats') }}</Name>
                <ogc:Filter>
                    <ogc:PropertyIsEqualTo>
                        <ogc:PropertyName>feature_type</ogc:PropertyName>
                        <ogc:Literal>Mud and Sand Flats</ogc:Literal>
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
                <Name>{{ _('Shallow Inlets and Bays') }}</Name>
                <ogc:Filter>
                    <ogc:PropertyIsEqualTo>
                        <ogc:PropertyName>feature_type</ogc:PropertyName>
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
                <Name>{{ _('Reefs') }}</Name>
                <ogc:Filter>
                    <ogc:PropertyIsEqualTo>
                        <ogc:PropertyName>feature_type</ogc:PropertyName>
                        <ogc:Literal>Reefs</ogc:Literal>
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
                        <ogc:PropertyName>feature_type</ogc:PropertyName>
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
                <Name>{{ _('Sea Caves') }}</Name>
                <ogc:Filter>
                    <ogc:PropertyIsEqualTo>
                        <ogc:PropertyName>feature_type</ogc:PropertyName>
                        <ogc:Literal>Sea Caves</ogc:Literal>
                    </ogc:PropertyIsEqualTo>
                </ogc:Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <CssParameter name="fill">#FF00FF</CssParameter>
                    </Fill>
                    <Stroke>
                        <CssParameter name="stroke">#FF00FF</CssParameter>
                        <CssParameter name="stroke-width">2</CssParameter>
                    </Stroke>
                </PolygonSymbolizer>
            </Rule>
        </FeatureTypeStyle>
    </UserStyle>
</NamedLayer>
