<NamedLayer>
    <Name>subtidal_habitats</Name>
    <UserStyle>
        <Name>name</Name>
        <FeatureTypeStyle>
            <Rule>
                <Name>{{ _('Erect and Branching Species That are Very Slow Growing') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>summary</PropertyName>
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
                <Name>{{ _('Sand and Gravels with Long Lived Bivalves') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>summary</PropertyName>
                        <Literal>16</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#a0a000</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Maerl Beds') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>summary</PropertyName>
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
                <Name>{{ _('Stable Subtidal Fine Sands') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>summary</PropertyName>
                        <Literal>18</Literal>
                    </PropertyIsEqualTo>
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
                    <PropertyIsEqualTo>
                        <PropertyName>summary</PropertyName>
                        <Literal>19</Literal>
                    </PropertyIsEqualTo>
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
                    <PropertyIsEqualTo>
                        <PropertyName>summary</PropertyName>
                        <Literal>20</Literal>
                    </PropertyIsEqualTo>
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
                    <PropertyIsEqualTo>
                        <PropertyName>summary</PropertyName>
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
                <Name>{{ _('Shallow Subtidal Rock with Kelp') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>summary</PropertyName>
                        <Literal>22</Literal>
                    </PropertyIsEqualTo>
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
                    <PropertyIsEqualTo>
                        <PropertyName>summary</PropertyName>
                        <Literal>23</Literal>
                    </PropertyIsEqualTo>
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
                    <PropertyIsEqualTo>
                        <PropertyName>summary</PropertyName>
                        <Literal>24</Literal>
                    </PropertyIsEqualTo>
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
                    <PropertyIsEqualTo>
                        <PropertyName>summary</PropertyName>
                        <Literal>25</Literal>
                    </PropertyIsEqualTo>
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
                    <PropertyIsEqualTo>
                        <PropertyName>summary</PropertyName>
                        <Literal>26</Literal>
                    </PropertyIsEqualTo>
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
                    <PropertyIsEqualTo>
                        <PropertyName>summary</PropertyName>
                        <Literal>27</Literal>
                    </PropertyIsEqualTo>
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
                    <PropertyIsEqualTo>
                        <PropertyName>summary</PropertyName>
                        <Literal>28</Literal>
                    </PropertyIsEqualTo>
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
                    <PropertyIsEqualTo>
                        <PropertyName>summary</PropertyName>
                        <Literal>29</Literal>
                    </PropertyIsEqualTo>
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
                    <PropertyIsEqualTo>
                        <PropertyName>summary</PropertyName>
                        <Literal>30</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#7ccf00</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Stable but Tidal Swept Cobbles, Pebbles and Gravel') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>summary</PropertyName>
                        <Literal>31</Literal>
                    </PropertyIsEqualTo>
                </Filter>
                <PolygonSymbolizer>
                    <Fill>
                        <SvgParameter name="fill">#3fbfff</SvgParameter>
                    </Fill>
                </PolygonSymbolizer>
            </Rule>
            <Rule>
                <Name>{{ _('Mosaic of Rock and Sediment') }}</Name>
                <Filter>
                    <PropertyIsEqualTo>
                        <PropertyName>summary</PropertyName>
                        <Literal>32</Literal>
                    </PropertyIsEqualTo>
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
