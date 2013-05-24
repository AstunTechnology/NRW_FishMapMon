<NamedLayer>
    <Name>subtidal_habitats_confidence</Name>
    <UserStyle>
        <Name>name</Name>
        <FeatureTypeStyle>
            <Rule>
                <Name>{{ _('Very poor') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>confiden11</PropertyName>
                        <Literal>very poor</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#d22d2d</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Poor') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>confiden11</PropertyName>
                        <Literal>poor</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#ffa850</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Fair') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>confiden11</PropertyName>
                        <Literal>fair</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#a0ffa0</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Good') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>confiden11</PropertyName>
                        <Literal>good</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#00d000</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
        </FeatureTypeStyle>
    </UserStyle>
</NamedLayer>
