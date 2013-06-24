<NamedLayer>
    <Name>{{info['name']}}</Name>
    <UserStyle>
        <Name>vessels</Name>
        <FeatureTypeStyle>
            {% for band in info['bands'] %}
            <Rule>
                <Name>{{band['name']}}</Name>
                <Filter>
                    {% if band['type'] in [
                        'PropertyIsLessThanOrEqualTo',
                        'PropertyIsEqualTo',
                        'PropertyIsGreaterThanOrEqualTo'] %}
                    {# Use the band type as the element name as all of these
                        filters have the same arguments #}
                    <{{band['type']}}>
                        <PropertyName>_overlaps</PropertyName>
                        <Literal>{{band['value']}}</Literal>
                    </{{band['type']}}>
                    {% endif %}
                    {% if band['type'] == 'PropertyIsBetween' %}
                    <PropertyIsBetween>
                        <PropertyName>_overlaps</PropertyName>
                        <ogc:LowerBoundary>
                            <Literal>{{band['lower']}}</Literal>
                        </ogc:LowerBoundary>
                        <ogc:UpperBoundary>
                            <Literal>{{band['upper']}}</Literal>
                        </ogc:UpperBoundary>
                    </PropertyIsBetween>
                    {% endif %}
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
