<NamedLayer>
    <Name>{{info['name']}}</Name>
    <UserStyle>
        <Name>name</Name>
        <FeatureTypeStyle>
            <Rule>
                <Name>0 (n/a)</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>_overlaps</PropertyName>
                        <Literal>0</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#aaaaaa</SvgParameter>
                    </Fill>
                    <Stroke>
                        <SvgParameter name="stroke">#666666</SvgParameter>
                    </Stroke>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>1</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>_overlaps</PropertyName>
                        <Literal>1</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#a1e0ff</SvgParameter>
                    </Fill>
                    <Stroke>
                        <SvgParameter name="stroke">#666666</SvgParameter>
                    </Stroke>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>2</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>_overlaps</PropertyName>
                        <Literal>2</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#51c5ff</SvgParameter>
                    </Fill>
                    <Stroke>
                        <SvgParameter name="stroke">#666666</SvgParameter>
                    </Stroke>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>3</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>_overlaps</PropertyName>
                        <Literal>3</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#3075ff</SvgParameter>
                    </Fill>
                    <Stroke>
                        <SvgParameter name="stroke">#666666</SvgParameter>
                    </Stroke>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>4</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>_overlaps</PropertyName>
                        <Literal>4</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#0000d0</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
        </FeatureTypeStyle>
    </UserStyle>
</NamedLayer>
