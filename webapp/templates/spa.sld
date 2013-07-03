<NamedLayer>
    <Name>{{info['name']}}</Name>
    <UserStyle>
        <Name>name</Name>
        <FeatureTypeStyle>
            <Rule>
                <Name>{{ _('SPA') }}</Name>
                <PolygonSymbolizer>
                    <Fill>
                        <GraphicFill>
                            <Graphic>
                                <ExternalGraphic>
                                    <OnlineResource xlink:type="simple" xlink:href="symbols/images/mapinfo_brush_18_darkgreen.png" />
                                    <Format>image/png</Format>
                                </ExternalGraphic>
                            </Graphic>
                        </GraphicFill>
                    </Fill>
                    <Stroke>
                        <CssParameter name="stroke">#3d7a17</CssParameter>
                        <CssParameter name="stroke-width">0.26</CssParameter>
                    </Stroke>
                </PolygonSymbolizer>
            </Rule>
        </FeatureTypeStyle>
    </UserStyle>
</NamedLayer>
