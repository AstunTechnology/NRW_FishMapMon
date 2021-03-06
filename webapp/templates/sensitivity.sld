<NamedLayer>
    <Name>{{info['name']}}</Name>
    <UserStyle>
        <Name>sensitivity</Name>
        <FeatureTypeStyle>
            <Rule>
                <Name>{{ _('Low') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>sensitivity_level</PropertyName>
                        <Literal>1</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#d9b0ff</SvgParameter>
                    </Fill>
                    <Stroke>
                        <SvgParameter name="stroke">#d9b0ff</SvgParameter>
                    </Stroke>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Medium') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>sensitivity_level</PropertyName>
                        <Literal>2</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#b060ff</SvgParameter>
                    </Fill>
                    <Stroke>
                        <SvgParameter name="stroke">#b060ff</SvgParameter>
                    </Stroke>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('High') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>sensitivity_level</PropertyName>
                        <Literal>3</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#480090</SvgParameter>
                    </Fill>
                    <Stroke>
                        <SvgParameter name="stroke">#480090</SvgParameter>
                    </Stroke>
                </PolygonSymbolizer>
            </Rule>
        </FeatureTypeStyle>
    </UserStyle>
</NamedLayer>
