<NamedLayer>
    <Name>habitats_confidence</Name>
    <UserStyle>
        <Name>name</Name>
        <FeatureTypeStyle>
            <Rule>
                <Name>{{ _('Poor') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_confidence</PropertyName>
                        <Literal>Poor</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#ff7040</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Fair') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_confidence</PropertyName>
                        <Literal>Fair</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#cdff80</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Good') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_confidence</PropertyName>
                        <Literal>Good</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#00ff00</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
              </Rule>
              <Rule>
                <Name>{{ _('Unknown') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_confidence</PropertyName>
                        <Literal>Unknown</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#e0e0e0</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
        </FeatureTypeStyle>
    </UserStyle>
</NamedLayer>
