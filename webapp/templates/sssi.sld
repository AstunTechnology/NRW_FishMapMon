<NamedLayer>
    <Name>{{info['name']}}</Name>
    <UserStyle>
        <Name>name</Name>
        <FeatureTypeStyle>
            <Rule>
                <Name>{{ _('SSSI') }}</Name>
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
                    <Stroke>
                        <CssParameter name="stroke">#ff0000</CssParameter>
                        <CssParameter name="stroke-width">0.26</CssParameter>
                    </Stroke>
                </PolygonSymbolizer>
            </Rule>
        </FeatureTypeStyle>
    </UserStyle>
</NamedLayer>
