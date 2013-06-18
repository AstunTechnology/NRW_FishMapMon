<NamedLayer>
    <Name>{{info['name']}}</Name>
    <UserStyle>
        <Name>name</Name>
        <FeatureTypeStyle>
            <Rule>
                <Name>{{ _('Unknown') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>sensitivityconfidence</PropertyName>
                        <Literal>Unknown</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#CFCFCF</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Low') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>sensitivityconfidence</PropertyName>
                        <Literal>Low</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#FF5500</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Moderate') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>sensitivityconfidence</PropertyName>
                        <Literal>Moderate</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#FFFF7F</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('High') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>sensitivityconfidence</PropertyName>
                        <Literal>High</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#00AA7F</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
        </FeatureTypeStyle>
    </UserStyle>
</NamedLayer>
