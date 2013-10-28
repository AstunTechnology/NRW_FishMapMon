<NamedLayer>
    <Name>habitats</Name>
    <UserStyle>
        <Name>habitats</Name>
        <FeatureTypeStyle>
            <Rule>
                <Name>1 {{ _('Upper Shore Stable Rock with Lichens and Algal Crusts') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>1</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#A0A0FF</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>2 {{ _('Wave Exposed Intertidal Stable Rock') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>2</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#E8D0FF</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>3 {{ _('Moderately Exposed Intertidal Rock') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>3</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#C080FF</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>4 {{ _('Seaweeds and Mussels on Moderately Exposed Rock') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>4</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#480090</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>5 {{ _('Mussels and Piddocks on Intertidal Clay and Peat') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>5</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#E0FFB0</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>6 {{ _('Honeycomb Worm Reefs') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>6</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#00C0C0</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>7 {{ _('Sheltered Bedrock, Boulders and Cobbles') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>7</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#700070</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>8 {{ _('Rockpools and Overhangs') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>8</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#FF80FF</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>9 {{ _('Intertidal brown seaweeds, barnacles or ephemeral seaweeds on boulders, cobbles and pebbles') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>9</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#FF40A0</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>10 {{ _('Muddy Sands - Excluding Gaper Clams') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>10</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#D09C00</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>11 {{ _('Muds and Sands - Including Gaper Clams') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>11</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#806000</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>12 {{ _('Intertidal Muds') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>12</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#502800</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>13 {{ _('Saltmarshes') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>13</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#FFD0E8</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>14 {{ _('Vertical Subtidal Rock with Associated Community') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>14</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#cf6700</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>15 {{ _('Erect and Branching Species That are Very Slow Growing') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>15</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#ffc3af</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>16 {{ _('Sand and Gravels with Long Lived Bivalves') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>16</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#A0A000</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>17 {{ _('Maerl Beds') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>17</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#a0a0a0</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>18 {{ _('Stable Subtidal Fine Sands') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>18</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#D06800</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>19 {{ _('Stable Muddy Sands, Sandy Muds and Muds') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>19</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#FFFF00</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>20 {{ _('Rockwith Low-lying Fast Growing Faunal Turf') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>20</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#FF4040</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>21 {{ _('Rock with Erect and Branching Species') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>21</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#900000</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>22 {{ _('Shallow Subtidal Rock with Kelp') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>22</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#005000</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>23 {{ _('Kelp and Seaweeds on Sand Scoured Rock') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>23</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#00A000</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>24 {{ _('Dynamic, Shallow Water Fine Sands') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>24</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#FFECB0</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>25 {{ _('Oyster Beds') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>25</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#DFDFDF</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>26 {{ _('Underboulder communities on lower shore and shallow subtidal boulders') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>26</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#C00060</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>27 {{ _('Biogenic Reef on Sediment') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>27</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#B0FFFF</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>28 {{ _('Stable, Species Rich Mixed Sediments') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>28</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#90FFC8</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>29 {{ _('Unstable cobbles, pebbles, gravels and/or coarse sands supporting relatively robust communities') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>29</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#0000D0</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>30 {{ _('Seagrass Beds') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>30</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#7DD000</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>31 {{ _('Stable but Tidal Swept Cobbles, Pebbles and Gravel') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>habitat_code</PropertyName>
                        <Literal>31</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#40C0FF</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>32 / 101 {{ _('Mosaic of Rock and Sediment') }}</Name>
                <Filter>
                    <Or>
                        <PropertyIsEqualTo>
                            <PropertyName>habitat_code</PropertyName>
                            <Literal>32</Literal>
                        </PropertyIsEqualTo>
                        <PropertyIsEqualTo>
                            <PropertyName>habitat_code</PropertyName>
                            <Literal>101</Literal>
                        </PropertyIsEqualTo>
                    </Or>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#000000</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
        </FeatureTypeStyle>
    </UserStyle>
</NamedLayer>
