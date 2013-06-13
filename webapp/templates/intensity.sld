<NamedLayer>
    <Name>{{info['name']}}</Name>
    <UserStyle>
        <Name>intensity</Name>
        <FeatureTypeStyle>
            <Rule>
                <Name>1</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>intensity_level</PropertyName>
                        <Literal>1</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#ffff71</SvgParameter>
                    </Fill>
                    <Stroke>
                        <SvgParameter name="stroke">#ffff71</SvgParameter>
                    </Stroke>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>2</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>intensity_level</PropertyName>
                        <Literal>2</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#ffa84f</SvgParameter>
                    </Fill>
                    <Stroke>
                        <SvgParameter name="stroke">#ffa84f</SvgParameter>
                    </Stroke>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>3</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>intensity_level</PropertyName>
                        <Literal>3</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#a15001</SvgParameter>
                    </Fill>
                    <Stroke>
                        <SvgParameter name="stroke">#a15001</SvgParameter>
                    </Stroke>
                </PolygonSymbolizer>
            </Rule>
        </FeatureTypeStyle>
    </UserStyle>
</NamedLayer>
