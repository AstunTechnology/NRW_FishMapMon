<NamedLayer>
    <Name>{{info['name']}}</Name>
    <UserStyle>
        <Name>intensity</Name>
        <FeatureTypeStyle>
            {% for band in info['bands'] %}
            <Rule>
                <Name>{{band['name']}}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>intensity_level</PropertyName>
                        <Literal>{{band['value']}}</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">{{band['color']}}</SvgParameter>
                    </Fill>
                    <Stroke>
                        <SvgParameter name="stroke">{{band['color']}}</SvgParameter>
                    </Stroke>
                </PolygonSymbolizer>
            </Rule>
        {% endfor %}
        </FeatureTypeStyle>
    </UserStyle>
</NamedLayer>
