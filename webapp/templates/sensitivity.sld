<NamedLayer>
    <Name>{{info['name']}}</Name>
    <UserStyle>
        <Name>name</Name>
        <FeatureTypeStyle>
            <Rule>
                <Name>{{ _('Low (1)') }}</Name>
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
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Medium (2)') }}</Name>
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
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('High (2)') }}</Name>
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
                </PolygonSymbolizer>
            </Rule>
        </FeatureTypeStyle>
    </UserStyle>
</NamedLayer>
