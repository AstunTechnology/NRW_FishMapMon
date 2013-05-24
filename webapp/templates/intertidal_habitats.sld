<NamedLayer>
    <Name>intertidal_habitats</Name>
    <UserStyle>
        <Name>name</Name>
        <FeatureTypeStyle>
            <Rule>
                <Name>{{ _('Upper Shore Stable Rock with Lichens and Algal Crusts') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>type</PropertyName>
                        <Literal>1</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#a0a0ff</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Wave Exposed Intertidal Stable Rock') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>type</PropertyName>
                        <Literal>2</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#e8cfff</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Moderately Exposed Intertidal Rock') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>type</PropertyName>
                        <Literal>3</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#bf80ff</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Seaweeds and Mussels on Moderately Exposed Rock') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>type</PropertyName>
                        <Literal>4</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#480090</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Mussels and Piddocks on Intertidal Clay and Peat') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>type</PropertyName>
                        <Literal>5</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#dfffaf</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Honeycomb Worm Reefs') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>type</PropertyName>
                        <Literal>6</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#00bfbf</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Sheltered Bedrock, Boulders and Cobbles') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>type</PropertyName>
                        <Literal>7</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#700070</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Rockpools and Overhangs') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>type</PropertyName>
                        <Literal>8</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#ff80ff</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Brown Seaweeds, Barnacles and Fucoids') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>type</PropertyName>
                        <Literal>9</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#ff3fa0</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Muddy Sands - Excluding Gaper Clams') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>type</PropertyName>
                        <Literal>10</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#cf9c00</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Muds and Sands - Including Gaper Clams') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>type</PropertyName>
                        <Literal>11</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#806000</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Intertidal Muds') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>type</PropertyName>
                        <Literal>12</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#4f2800</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Saltmarshes') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>type</PropertyName>
                        <Literal>13</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#ffcfe8</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Vertical Subtidal Rock with Associated Community') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>type</PropertyName>
                        <Literal>14</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#cf6700</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Stable Subtidal Fine Sands') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>type</PropertyName>
                        <Literal>18</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#cf6700</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Stable Muddy Sands, Sandy Muds and Muds') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>type</PropertyName>
                        <Literal>19</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#ffff00</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Rockwith Low-lying Fast Growing Faunal Turf') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>type</PropertyName>
                        <Literal>20</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#ff3f3f</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Rock with Erect and Branching Species') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>type</PropertyName>
                        <Literal>21</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#900000</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Shallow Subtidal Rock with Kelp') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>type</PropertyName>
                        <Literal>22</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#004f00</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Kelp and Seaweeds on Sand Scoured Rock') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>type</PropertyName>
                        <Literal>23</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#00a000</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Dynamic, Shallow Water Fine Sands') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>type</PropertyName>
                        <Literal>24</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#ffebaf</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Oyster Beds') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>type</PropertyName>
                        <Literal>25</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#dfdfdf</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Underboulder and Cobbles Shallow Subtidal Community') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>type</PropertyName>
                        <Literal>26</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#bf0060</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Biogenic Reef on Sediment') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>type</PropertyName>
                        <Literal>27</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#afffff</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Stable, Species Rich Mixed Sediments') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>type</PropertyName>
                        <Literal>28</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#90ffc8</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Unstable Coarse Sediments - Robust Fauna') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>type</PropertyName>
                        <Literal>29</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#0000cf</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Seagrass Beds') }}</Name>
                <Filter>
                    <PropertyIsLike escape="\" singleChar="_" wildCard="%">
                        <PropertyName>type</PropertyName>
                        <Literal>30</Literal>
                    </PropertyIsLike>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#7ccf00</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
        </FeatureTypeStyle>
    </UserStyle>
</NamedLayer>
