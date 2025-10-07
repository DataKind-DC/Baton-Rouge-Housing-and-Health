// Baton Rouge Housing and Health Map Application
mapboxgl.accessToken = 'pk.eyJ1Ijoicm1jYXJkZXIxIiwiYSI6ImNtN2pqOG56cjA3bXMybXE0dnhmMm9xM2wifQ.O2mYeNpbnS7TA-J_0q2wkg';

// Configuration
const CONFIG = {
    map: {
        style: 'mapbox://styles/mapbox/light-v11',
        center: [-91.08, 30.48],
        zoom: 10.31
    },
    colors: {
        counts: ['#f7f4f9', '#e7e1ef', '#d4b9da', '#c994c7', '#df65b0', '#e7298a', '#ce1256', '#91003f'],
        percentages: ['#fff5f0', '#fee0d2', '#fcbba1', '#fc9272', '#fb6a4a', '#ef3b2c', '#cb181d', '#a50f15'],
        demographics: ['#fff7f3','#fde0dd','#fcc5c0','#fa9fb5','#f768a1','#dd3497','#ae017e','#7a0177'],
        housing: ['#ffffd9','#edf8b1','#c7e9b4','#7fcdbb','#41b6c4','#1d91c0','#225ea8','#0c2c84'],
        health: ['#ffffcc','#ffeda0','#fed976','#feb24c','#fd8d3c','#fc4e2a','#e31a1c','#b10026'],
        race: {
            'White': '#feb24c',
            'Black': '#fa9fb5',
            'Latino': '#c7e9b4',
            'Asian': '#41b6c4'
        }
    },
    categoryOrder: {
        race: ['White', 'Black', 'Latino', 'Asian']
    }
};

// Global variables
let map;
let currentLayer = 'Total_Population';
let currentXAxis = 'rank';
let demographicsData = null;
let currentHoveredFeature = null;
let scatterPlot = null;
let isFrozen = false;
let originalMapView = null;
let parishTotals = null;
let tractRankings = null;
let mapPopup = null;

// Data layer configurations
const layerConfig = {
    // Demographics
    'Total_Population': { label: 'Total Population', type: 'count', category: 'demographics' },
    'Median_Household_Income': { label: 'Median Household Income', type: 'count', category: 'demographics' },
    'Percent_Below_Poverty': { label: 'Below Poverty %', type: 'percentage', category: 'demographics' },
    'Percent_Low_Income_Under_35K': { label: 'Low Income % (<$35K)', type: 'percentage', category: 'demographics' },
    'Percent_High_Income_100K_Plus': { label: 'High Income % ($100K+)', type: 'percentage', category: 'demographics' },
    'Percent_White': { label: 'White %', type: 'percentage', category: 'demographics' },
    'Percent_Black': { label: 'Black %', type: 'percentage', category: 'demographics' },
    'Percent_Hispanic': { label: 'Hispanic/Latino %', type: 'percentage', category: 'demographics' },
    'Percent_Family_Households': { label: 'Family Households %', type: 'percentage', category: 'demographics' },
    'Percent_Households_With_Children': { label: 'Households With Children %', type: 'percentage', category: 'demographics' },
    'Percent_Children_Below_Poverty': { label: 'Children in Poverty %', type: 'percentage', category: 'demographics' },
    'crime_count': { label: 'Crime Count', type: 'count', category: 'demographics' },

    // Housing
    'Median_Home_Value': { label: 'Median Home Value', type: 'count', category: 'housing' },
    'Median_Gross_Rent': { label: 'Median Gross Rent', type: 'count', category: 'housing' },
    'Percent_Renter_Occupied': { label: 'Renter-Occupied %', type: 'percentage', category: 'housing' },
    'Percent_Owner_Occupied': { label: 'Owner-Occupied %', type: 'percentage', category: 'housing' },
    'Percent_Built_Pre_1980': { label: 'Built Pre-1980 %', type: 'percentage', category: 'housing' },
    'Percent_High_Rent_Burden_30_Plus': { label: 'Rent Burden 30%+', type: 'percentage', category: 'housing' },
    'Percent_High_Rent_Burden_50_Plus': { label: 'Rent Burden 50%+', type: 'percentage', category: 'housing' },
    'PNP_Mean_Perc': { label: 'Poor Perception %', type: 'percentage', category: 'housing' },
    'PI_Mean_Perc': { label: 'Poor Conditions %', type: 'percentage', category: 'housing' },
    'blight_count': { label: 'Blight Count', type: 'count', category: 'housing' },
    'Percent_Single_Family': { label: 'Single-Family %', type: 'percentage', category: 'housing' },
    'Percent_Two_Plus_Bedrooms': { label: 'Two+ Bedrooms %', type: 'percentage', category: 'housing' },
    'permits_res_count': { label: 'Building Permits', type: 'count', category: 'housing' },
    'Percent_Vacant': { label: 'Vacancy Rate %', type: 'percentage', category: 'housing' },

    // Health
    'GENERAL.HEALTH': { label: 'Poor General Health', type: 'health', category: 'health' },
    'POOR.PHYSICAL.HEALTH': { label: 'Poor Physical Health', type: 'health', category: 'health' },
    'POOR.MENTAL.HEALTH': { label: 'Poor Mental Health', type: 'health', category: 'health' },
    'HIGH.BLOOD.PRESSURE': { label: 'High Blood Pressure', type: 'health', category: 'health' },
    'BINGE.DRINKING': { label: 'Binge Drinking', type: 'health', category: 'health' },
    'CANCER..EXCLUDING.SKIN.CANCER.': { label: 'Cancer (excl. skin)', type: 'health', category: 'health' },
    'ASTHMA': { label: 'Asthma', type: 'health', category: 'health' },
    'DIABETES': { label: 'Diabetes', type: 'health', category: 'health' },
    'CORONARY.HEART.DISEASE': { label: 'Coronary Heart Disease', type: 'health', category: 'health' },
    'OBESITY': { label: 'Obesity', type: 'health', category: 'health' },
    'DEPRESSION': { label: 'Depression', type: 'health', category: 'health' },

    'rank': { label: 'Rank', type: 'rank', category: 'other' }
};

document.addEventListener('DOMContentLoaded', function() {
    setupUI();
    loadData();
});

function setupUI() {
    setTimeout(() => {
        const layerBtn = document.getElementById('toggle-layer-controls');
        const xAxisBtn = document.getElementById('toggle-xaxis-controls');
        
        if (layerBtn) {
            layerBtn.addEventListener('click', function(e) {
                e.preventDefault();
                e.stopPropagation();
                const layerPanel = document.getElementById('layer-controls-panel');
                const xAxisPanel = document.getElementById('xaxis-controls-panel');
                xAxisPanel.classList.remove('open');
                layerPanel.classList.toggle('open');
            });
        }

        if (xAxisBtn) {
            xAxisBtn.addEventListener('click', function(e) {
                e.preventDefault();
                e.stopPropagation();
                const layerPanel = document.getElementById('layer-controls-panel');
                const xAxisPanel = document.getElementById('xaxis-controls-panel');
                layerPanel.classList.remove('open');
                xAxisPanel.classList.toggle('open');
            });
        }

        const closeLayerBtn = document.getElementById('close-layer-controls');
        const closeXAxisBtn = document.getElementById('close-xaxis-controls');
        
        if (closeLayerBtn) {
            closeLayerBtn.addEventListener('click', function() {
                document.getElementById('layer-controls-panel').classList.remove('open');
            });
        }

        if (closeXAxisBtn) {
            closeXAxisBtn.addEventListener('click', function() {
                document.getElementById('xaxis-controls-panel').classList.remove('open');
            });
        }
    }, 100);

    document.addEventListener('click', function(e) {
        const layerPanel = document.getElementById('layer-controls-panel');
        const xAxisPanel = document.getElementById('xaxis-controls-panel');
        const layerBtn = document.getElementById('toggle-layer-controls');
        const xAxisBtn = document.getElementById('toggle-xaxis-controls');
        
        if (!layerPanel.contains(e.target) && !layerBtn.contains(e.target) &&
            !xAxisPanel.contains(e.target) && !xAxisBtn.contains(e.target) &&
            !e.target.closest('.control-btn')) {
            layerPanel.classList.remove('open');
            xAxisPanel.classList.remove('open');
        }
    });
}

async function loadData() {
    try {
        const response = await fetch('data/BR_Combined_Tract_Data.geojson');
        demographicsData = await response.json();
        console.log('Data loaded successfully:', demographicsData.features.length, 'features');
        calculateParishTotals();
        calculateRankings();
        initializeMap();
        initializeScatterPlot();

        // Initialize the tract details with parish totals
        // Need to render the DOM first, then populate with data
        updateTractDetails(parishTotals, true);
    } catch (error) {
        console.error('Error loading data:', error);
        showError('Failed to load demographics data. Please check your data file.');
    }
}

function calculateParishTotals() {
    parishTotals = {
        Total_Population: 0,
        White_Alone: 0,
        Black_Alone: 0,
        Asian_Alone: 0,
        Hispanic_Latino: 0,
        Below_Poverty_Level: 0,
        Owner_Occupied: 0,
        Renter_Occupied: 0,
        Single_Family_Detached: 0,
        Multi_Family_All_Units: 0,
        Households_With_Children_Under_18: 0,
        Total_Households: 0,
        Total_Housing_Units: 0
    };

    let incomeSum = 0;
    let incomeCount = 0;
    let pre1980Sum = 0;
    let post2000Sum = 0;
    let housingUnitsCount = 0;

    demographicsData.features.forEach(feature => {
        const props = feature.properties;
        parishTotals.Total_Population += props.Total_Population || 0;
        parishTotals.White_Alone += props.White_Alone || 0;
        parishTotals.Black_Alone += props.Black_Alone || 0;
        parishTotals.Asian_Alone += props.Asian_Alone || 0;
        parishTotals.Hispanic_Latino += props.Hispanic_Latino || 0;
        parishTotals.Below_Poverty_Level += props.Below_Poverty_Level || 0;
        parishTotals.Owner_Occupied += props.Owner_Occupied || 0;
        parishTotals.Renter_Occupied += props.Renter_Occupied || 0;
        parishTotals.Single_Family_Detached += props.Single_Family_Detached || 0;
        parishTotals.Multi_Family_All_Units += props.Multi_Family_All_Units || 0;
        parishTotals.Households_With_Children_Under_18 += props.Households_With_Children_Under_18 || 0;
        parishTotals.Total_Households += props.Total_Households || 0;
        parishTotals.Total_Housing_Units += props.Total_Housing_Units || 0;

        if (props.Median_Household_Income && props.Median_Household_Income > 0) {
            incomeSum += props.Median_Household_Income;
            incomeCount++;
        }

        if (props.Total_Housing_Units > 0) {
            const units = props.Total_Housing_Units;
            pre1980Sum += units * (props.Percent_Built_Pre_1980 || 0) / 100;
            post2000Sum += units * (props.Percent_Built_2000_Plus || 0) / 100;
            housingUnitsCount += units;
        }
    });

    parishTotals.Percent_White = parishTotals.White_Alone / parishTotals.Total_Population;
    parishTotals.Percent_Black = parishTotals.Black_Alone / parishTotals.Total_Population;
    parishTotals.Percent_Asian = parishTotals.Asian_Alone / parishTotals.Total_Population;
    parishTotals.Percent_Hispanic = parishTotals.Hispanic_Latino / parishTotals.Total_Population;
    parishTotals.Percent_Below_Poverty = parishTotals.Below_Poverty_Level / parishTotals.Total_Population;
    parishTotals.Median_Household_Income = incomeCount > 0 ? incomeSum / incomeCount : 0;
    parishTotals.Percent_Built_Pre_1980 = housingUnitsCount > 0 ? (pre1980Sum / housingUnitsCount) : 0;
    parishTotals.Percent_Built_2000_Plus = housingUnitsCount > 0 ? (post2000Sum / housingUnitsCount) : 0;
    parishTotals.NAME = 'East Baton Rouge Parish';

    // Calculate medians for lollipop chart variables
    const lollipopVars = [
        'Median_Household_Income', 'Percent_Below_Poverty', 'Percent_Low_Income_Under_35K',
        'Percent_High_Income_100K_Plus', 'Percent_White', 'Percent_Black', 'Percent_Hispanic',
        'Percent_Family_Households', 'Percent_Households_With_Children', 'Percent_Children_Below_Poverty',
        'crime_count',
        'Median_Home_Value', 'Median_Gross_Rent', 'Percent_Renter_Occupied', 'Percent_Built_Pre_1980',
        'Percent_High_Rent_Burden_30_Plus', 'PNP_Mean_Perc', 'PI_Mean_Perc', 'blight_count',
        'Percent_Single_Family', 'Percent_Two_Plus_Bedrooms', 'permits_res_count',
        'GENERAL.HEALTH', 'POOR.PHYSICAL.HEALTH', 'POOR.MENTAL.HEALTH', 'HIGH.BLOOD.PRESSURE',
        'BINGE.DRINKING', 'CANCER..EXCLUDING.SKIN.CANCER.', 'ASTHMA', 'DIABETES',
        'CORONARY.HEART.DISEASE', 'OBESITY', 'DEPRESSION'
    ];

    lollipopVars.forEach(varName => {
        const values = demographicsData.features
            .map(f => parseFloat(f.properties[varName]))
            .filter(v => v !== null && v !== undefined && !isNaN(v))
            .sort((a, b) => a - b);

        if (values.length > 0) {
            const median = values.length % 2 === 0
                ? (values[values.length / 2 - 1] + values[values.length / 2]) / 2
                : values[Math.floor(values.length / 2)];
            parishTotals[varName] = median;
        } else {
            parishTotals[varName] = 0;
        }
    });
}

function calculateRankings() {
    tractRankings = {};
    const metrics = ['Total_Population', 'Median_Household_Income', 'Percent_Below_Poverty'];
    
    metrics.forEach(metric => {
        const sorted = demographicsData.features
            .map(f => ({ geoid: f.properties.GEOID, value: f.properties[metric] || 0 }))
            .sort((a, b) => b.value - a.value);
        
        sorted.forEach((item, index) => {
            if (!tractRankings[item.geoid]) {
                tractRankings[item.geoid] = {};
            }
            tractRankings[item.geoid][metric] = index + 1;
        });
    });
}

function initializeMap() {
    map = new mapboxgl.Map({
        container: 'map',
        style: CONFIG.map.style,
        center: CONFIG.map.center,
        zoom: CONFIG.map.zoom
    });

    // Initialize popup
    mapPopup = new mapboxgl.Popup({
        closeButton: false,
        closeOnClick: false,
        className: 'map-hover-popup'
    });

    map.on('load', function() {
        originalMapView = { center: CONFIG.map.center, zoom: CONFIG.map.zoom };
        setupMap();
        setupEventListeners();
    });
}

function setupMap() {
    map.addSource('demographics', { type: 'geojson', data: demographicsData });
    map.addSource('highlight', { type: 'geojson', data: { type: 'FeatureCollection', features: [] } });
    addDataLayer(currentLayer);
    map.addLayer({
        id: 'highlight-layer',
        type: 'line',
        source: 'highlight',
        layout: {},
        paint: { 'line-color': '#1F2052', 'line-width': 3, 'line-opacity': 0.8 }
    });
    updateLegend(currentLayer);
}

function setupEventListeners() {
    map.on('mousemove', 'demographics-layer', handleMapHover);
    map.on('mousemove', updatePopupPosition);
    map.on('mouseleave', 'demographics-layer', handleMapLeave);
    map.on('click', 'demographics-layer', handleMapClick);
    map.on('click', function(e) {
        const features = map.queryRenderedFeatures(e.point, { layers: ['demographics-layer'] });
        if (features.length === 0 && isFrozen) unfreeze();
    });

    document.querySelectorAll('input[name="dataLayer"]').forEach(radio => {
        radio.addEventListener('change', function() {
            if (this.checked) {
                currentLayer = this.value;
                updateLayer(currentLayer);
                updateLegend(currentLayer);
                updateScatterPlot();
                if (!isFrozen) showParishTotals();
                document.getElementById('layer-controls-panel').classList.remove('open');
            }
        });
    });

    document.querySelectorAll('input[name="xAxisVar"]').forEach(radio => {
        radio.addEventListener('change', function() {
            if (this.checked) {
                currentXAxis = this.value;
                updateScatterPlot();
                document.getElementById('xaxis-controls-panel').classList.remove('open');
            }
        });
    });

    window.addEventListener('resize', () => {
        map.resize();
        if (scatterPlot) scatterPlot.resize();
    });
}

function handleMapClick(e) {
    const feature = e.features[0];
    if (feature) {
        if (isFrozen && feature.properties.GEOID === currentHoveredFeature) {
            unfreeze();
        } else {
            freeze(feature.properties);
            zoomToTract(feature);
        }
    }
}

function zoomToTract(feature) {
    const bounds = new mapboxgl.LngLatBounds();
    
    if (feature.geometry.type === 'Polygon') {
        feature.geometry.coordinates[0].forEach(coord => bounds.extend(coord));
    } else if (feature.geometry.type === 'MultiPolygon') {
        feature.geometry.coordinates.forEach(polygon => {
            polygon[0].forEach(coord => bounds.extend(coord));
        });
    }
    
    if (!bounds.isEmpty()) {
        map.fitBounds(bounds, { padding: 100, maxZoom: 14, duration: 1000 });
    }
}

function zoomToOriginalView() {
    map.flyTo({ center: originalMapView.center, zoom: originalMapView.zoom, duration: 1000 });
}

function freeze(properties) {
    isFrozen = true;
    currentHoveredFeature = properties.GEOID;
    updateTractDetails(properties);
    if (scatterPlot) scatterPlot.highlightBubble(properties.GEOID);
    highlightMapFeature(properties.GEOID);
}

function unfreeze() {
    isFrozen = false;
    currentHoveredFeature = null;
    showParishTotals();
    clearMapHighlight();
    zoomToOriginalView();
    if (scatterPlot) {
        scatterPlot.clearHighlight();
        scatterPlot.reorderBubbles();
    }
}

function handleMapHover(e) {
    if (isFrozen) return;
    const feature = e.features[0];
    if (feature) {
        if (feature.properties.GEOID !== currentHoveredFeature) {
            currentHoveredFeature = feature.properties.GEOID;
            updateTractDetails(feature.properties);
            if (scatterPlot) scatterPlot.highlightBubble(feature.properties.GEOID);

            // Update popup content
            const props = feature.properties;
            const yValue = props[currentLayer];
            const xValue = props[currentXAxis];

            const yConfig = layerConfig[currentLayer];
            const xConfig = layerConfig[currentXAxis];

            // Calculate ranks
            const totalTracts = demographicsData.features.length;
            let yRank = 'N/A';

            if (currentLayer !== 'rank' && yValue != null) {
                const yValues = demographicsData.features
                    .map(f => parseFloat(f.properties[currentLayer]))
                    .filter(v => v != null && !isNaN(v))
                    .sort((a, b) => b - a);
                yRank = `${yValues.indexOf(parseFloat(yValue)) + 1} of ${totalTracts}`;
            }

            const formattedYValue = formatValue(yValue, yConfig?.type === 'percentage' || yConfig?.type === 'health', currentLayer);

            let popupHTML = `
                <div style="font-size: 0.75rem; min-width: 150px;">
                    <div style="font-weight: bold; margin-bottom: 4px; border-bottom: 1px solid #ddd; padding-bottom: 2px;">
                        Census Tract ${props.NAME || ''}
                    </div>
                    <div style="margin-bottom: 2px;">
                        <strong>${yConfig?.label || currentLayer}:</strong> ${formattedYValue}<br>
                        <span style="font-size: 0.7rem; color: #666;">Rank: ${yRank}</span>
                    </div>`;

            // Only show X-axis variable if it's not rank
            if (currentXAxis !== 'rank' && xValue != null) {
                const xValues = demographicsData.features
                    .map(f => parseFloat(f.properties[currentXAxis]))
                    .filter(v => v != null && !isNaN(v))
                    .sort((a, b) => b - a);
                const xRank = `${xValues.indexOf(parseFloat(xValue)) + 1} of ${totalTracts}`;
                const formattedXValue = formatValue(xValue, xConfig?.type === 'percentage' || xConfig?.type === 'health', currentXAxis);

                popupHTML += `
                    <div>
                        <strong>${xConfig?.label || currentXAxis}:</strong> ${formattedXValue}<br>
                        <span style="font-size: 0.7rem; color: #666;">Rank: ${xRank}</span>
                    </div>`;
            }

            popupHTML += `
                </div>
            `;

            mapPopup.setLngLat(e.lngLat).setHTML(popupHTML).addTo(map);
        }
        map.getCanvas().style.cursor = 'pointer';
    }
}

function updatePopupPosition(e) {
    if (isFrozen || !currentHoveredFeature) return;
    const features = map.queryRenderedFeatures(e.point, { layers: ['demographics-layer'] });
    if (features.length > 0 && mapPopup.isOpen()) {
        mapPopup.setLngLat(e.lngLat);
    }
}

function handleMapLeave() {
    if (isFrozen) return;
    currentHoveredFeature = null;
    showParishTotals();
    clearMapHighlight();
    if (scatterPlot) {
        scatterPlot.clearHighlight();
        scatterPlot.reorderBubbles();
    }
    map.getCanvas().style.cursor = '';

    // Remove popup
    if (mapPopup) {
        mapPopup.remove();
    }
}

function showParishTotals() {
    updateTractDetails(parishTotals, true);
}

function updateTractDetails(properties, isParishView = false) {
    const tractInfo = document.getElementById('tract-info');
    const rankings = isParishView ? {} : (tractRankings[properties.GEOID] || {});
    const totalTracts = demographicsData.features.length;
    const chartsExist = tractInfo.querySelector('#race-chart') !== null;

    // Store current properties for tab switching
    window.currentTractProperties = properties;

    if (!chartsExist) {
        tractInfo.innerHTML = `
            <div class="tract-summary-stats">
                <div class="summary-stat-box">
                    <div class="summary-stat-value" id="total-pop-value">${Number(properties.Total_Population).toLocaleString()} <span class="inline-rank" id="total-pop-rank">${rankings.Total_Population ? `#${rankings.Total_Population}` : ''}</span></div>
                    <div class="summary-stat-label">Total Population</div>
                </div>
                <div class="summary-stat-box">
                    <div class="summary-stat-value" id="median-income-value">$${Number(properties.Median_Household_Income).toLocaleString()} <span class="inline-rank" id="median-income-rank">${rankings.Median_Household_Income ? `#${rankings.Median_Household_Income}` : ''}</span></div>
                    <div class="summary-stat-label">Median Income</div>
                </div>
                <div class="summary-stat-box">
                    <div class="summary-stat-value" id="poverty-value">${(properties.Percent_Below_Poverty ).toFixed(1)}% <span class="inline-rank" id="poverty-rank">${rankings.Percent_Below_Poverty ? `#${rankings.Percent_Below_Poverty}` : ''}</span></div>
                    <div class="summary-stat-label">Below Poverty</div>
                </div>
            </div>

            <div class="chart-section race-bar-section">
                <div id="race-chart"></div>
            </div>

            <!-- Tabbed Section -->
            <div class="tabs-container">
                <div class="tabs-header">
                    <button class="tab-btn active" data-tab="demographics">Demographics</button>
                    <button class="tab-btn" data-tab="housing">Housing</button>
                    <button class="tab-btn" data-tab="health">Health</button>
                </div>

                <div class="tabs-content">
                    <div class="tab-pane active" id="tab-demographics">
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Median Income</div>
                            <div class="chart-container-inline" id="median-income-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">% Below Poverty</div>
                            <div class="chart-container-inline" id="below-poverty-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">% Low Income</div>
                            <div class="chart-container-inline" id="low-income-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">% High Income</div>
                            <div class="chart-container-inline" id="high-income-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">% White</div>
                            <div class="chart-container-inline" id="white-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">% Black</div>
                            <div class="chart-container-inline" id="black-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">% Hispanic</div>
                            <div class="chart-container-inline" id="hispanic-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">% Family Households</div>
                            <div class="chart-container-inline" id="family-households-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">% With Children</div>
                            <div class="chart-container-inline" id="households-children-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">% Children in Poverty</div>
                            <div class="chart-container-inline" id="children-poverty-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Crime Count</div>
                            <div class="chart-container-inline" id="crime-count-chart"></div>
                        </div>
                    </div>

                    <div class="tab-pane" id="tab-housing">
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Median Home Value</div>
                            <div class="chart-container-inline" id="median-home-value-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Median Gross Rent</div>
                            <div class="chart-container-inline" id="median-rent-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">% Renter</div>
                            <div class="chart-container-inline" id="renter-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">% Pre-1980</div>
                            <div class="chart-container-inline" id="pre1980-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">% Rent Burden 30+</div>
                            <div class="chart-container-inline" id="rent-burden-30-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">% Poor Perception</div>
                            <div class="chart-container-inline" id="pnp-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">% Poor Conditions</div>
                            <div class="chart-container-inline" id="pi-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Blight Count</div>
                            <div class="chart-container-inline" id="blight-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">% Single Family</div>
                            <div class="chart-container-inline" id="single-family-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">% Two+ Bedrooms</div>
                            <div class="chart-container-inline" id="two-plus-bedrooms-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Building Permits</div>
                            <div class="chart-container-inline" id="permits-chart"></div>
                        </div>
                    </div>

                    <div class="tab-pane" id="tab-health">
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Poor General Health</div>
                            <div class="chart-container-inline" id="general-health-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Poor Physical Health</div>
                            <div class="chart-container-inline" id="poor-physical-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Poor Mental Health</div>
                            <div class="chart-container-inline" id="poor-mental-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">High Blood Pressure</div>
                            <div class="chart-container-inline" id="hbp-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Binge Drinking</div>
                            <div class="chart-container-inline" id="binge-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Cancer (excl. skin)</div>
                            <div class="chart-container-inline" id="cancer-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Asthma</div>
                            <div class="chart-container-inline" id="asthma-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Diabetes</div>
                            <div class="chart-container-inline" id="diabetes-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Coronary Heart Disease</div>
                            <div class="chart-container-inline" id="chd-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Obesity</div>
                            <div class="chart-container-inline" id="obesity-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Depression</div>
                            <div class="chart-container-inline" id="depression-chart"></div>
                        </div>
                    </div>
                </div>
            </div>
        `;

        // Setup tab switching
        setupTabs();

        // Create charts
        createRaceChart(properties);
        createMedianIncomeChart(properties);
        createBelowPovertyChart(properties);
        createLowIncomeChart(properties);
        createHighIncomeChart(properties);
        createWhiteChart(properties);
        createBlackChart(properties);
        createHispanicChart(properties);
        createFamilyHouseholdsChart(properties);
        createHouseholdsWithChildrenChart(properties);
        createChildrenPovertyChart(properties);
        createCrimeCountChart(properties);
        createMedianHomeValueChart(properties);
        createMedianRentChart(properties);
        createRenterPctChart(properties);
        createPre1980Chart(properties);
        createRentBurden30Chart(properties);
        createPNPChart(properties);
        createPIChart(properties);
        createBlightCountChart(properties);
        createSingleFamilyPctChart(properties);
        createTwoPlusBedroomsChart(properties);
        createPermitsChart(properties);
        createGeneralHealthChart(properties);
        createPoorPhysicalHealthChart(properties);
        createPoorMentalHealthChart(properties);
        createHighBloodPressureChart(properties);
        createBingeDrinkingChart(properties);
        createCancerChart(properties);
        createAsthmaChart(properties);
        createDiabetesChart(properties);
        createCoronaryHeartDiseaseChart(properties);
        createObesityChart(properties);
        createDepressionChart(properties);
    } else {
        document.getElementById('total-pop-value').innerHTML = `${Number(properties.Total_Population).toLocaleString()} <span class="inline-rank" id="total-pop-rank">${rankings.Total_Population ? `#${rankings.Total_Population}` : ''}</span>`;
        document.getElementById('median-income-value').innerHTML = `$${Number(properties.Median_Household_Income).toLocaleString()} <span class="inline-rank" id="median-income-rank">${rankings.Median_Household_Income ? `#${rankings.Median_Household_Income}` : ''}</span>`;
        document.getElementById('poverty-value').innerHTML = `${(properties.Percent_Below_Poverty ).toFixed(1)}% <span class="inline-rank" id="poverty-rank">${rankings.Percent_Below_Poverty ? `#${rankings.Percent_Below_Poverty}` : ''}</span>`;
        createRaceChart(properties);
        createMedianIncomeChart(properties);
        createBelowPovertyChart(properties);
        createLowIncomeChart(properties);
        createHighIncomeChart(properties);
        createWhiteChart(properties);
        createBlackChart(properties);
        createHispanicChart(properties);
        createFamilyHouseholdsChart(properties);
        createHouseholdsWithChildrenChart(properties);
        createChildrenPovertyChart(properties);
        createCrimeCountChart(properties);
        createMedianHomeValueChart(properties);
        createMedianRentChart(properties);
        createRenterPctChart(properties);
        createPre1980Chart(properties);
        createRentBurden30Chart(properties);
        createPNPChart(properties);
        createPIChart(properties);
        createBlightCountChart(properties);
        createSingleFamilyPctChart(properties);
        createTwoPlusBedroomsChart(properties);
        createPermitsChart(properties);
        createGeneralHealthChart(properties);
        createPoorPhysicalHealthChart(properties);
        createPoorMentalHealthChart(properties);
        createHighBloodPressureChart(properties);
        createBingeDrinkingChart(properties);
        createCancerChart(properties);
        createAsthmaChart(properties);
        createDiabetesChart(properties);
        createCoronaryHeartDiseaseChart(properties);
        createObesityChart(properties);
        createDepressionChart(properties);
    }
}

function setupTabs() {
    const tabButtons = document.querySelectorAll('.tab-btn');
    const tabPanes = document.querySelectorAll('.tab-pane');

    tabButtons.forEach(button => {
        button.addEventListener('click', () => {
            const targetTab = button.getAttribute('data-tab');

            // Remove active class from all buttons and panes
            tabButtons.forEach(btn => btn.classList.remove('active'));
            tabPanes.forEach(pane => pane.classList.remove('active'));

            // Add active class to clicked button and corresponding pane
            button.classList.add('active');
            document.getElementById(`tab-${targetTab}`).classList.add('active');

            // Re-render demographics charts when demographics tab is activated
            if (targetTab === 'demographics') {
                const currentProperties = window.currentTractProperties || parishTotals;
                createMedianIncomeChart(currentProperties);
                createBelowPovertyChart(currentProperties);
                createLowIncomeChart(currentProperties);
                createHighIncomeChart(currentProperties);
                createWhiteChart(currentProperties);
                createBlackChart(currentProperties);
                createHispanicChart(currentProperties);
                createFamilyHouseholdsChart(currentProperties);
                createHouseholdsWithChildrenChart(currentProperties);
                createChildrenPovertyChart(currentProperties);
                createCrimeCountChart(currentProperties);
            }

            // Re-render housing charts when housing tab is activated
            if (targetTab === 'housing') {
                const currentProperties = window.currentTractProperties || parishTotals;
                createMedianHomeValueChart(currentProperties);
                createMedianRentChart(currentProperties);
                createRenterPctChart(currentProperties);
                createPre1980Chart(currentProperties);
                createRentBurden30Chart(currentProperties);
                createPNPChart(currentProperties);
                createPIChart(currentProperties);
                createBlightCountChart(currentProperties);
                createSingleFamilyPctChart(currentProperties);
                createTwoPlusBedroomsChart(currentProperties);
                createPermitsChart(currentProperties);
            }

            // Re-render health charts when health tab is activated
            if (targetTab === 'health') {
                const currentProperties = window.currentTractProperties || parishTotals;
                createGeneralHealthChart(currentProperties);
                createPoorPhysicalHealthChart(currentProperties);
                createPoorMentalHealthChart(currentProperties);
                createHighBloodPressureChart(currentProperties);
                createBingeDrinkingChart(currentProperties);
                createCancerChart(currentProperties);
                createAsthmaChart(currentProperties);
                createDiabetesChart(currentProperties);
                createCoronaryHeartDiseaseChart(currentProperties);
                createObesityChart(currentProperties);
                createDepressionChart(currentProperties);
            }
        });
    });
}

function createRaceChart(properties) {
    const container = d3.select('#race-chart');
    const white = properties.White_Alone || 0;
    const black = properties.Black_Alone || 0;
    const asian = properties.Asian_Alone || 0;
    const latino = properties.Hispanic_Latino || 0;
    const total = white + black + asian + latino;
    
    const data = CONFIG.categoryOrder.race.map(category => {
        let count;
        switch(category) {
            case 'White': count = white; break;
            case 'Black': count = black; break;
            case 'Asian': count = asian; break;
            case 'Latino': count = latino; break;
            default: count = 0;
        }
        return {
            label: category,
            count: count,
            percentage: total > 0 ? count / total : 0,
            color: CONFIG.colors.race[category]
        };
    });
    
    createBarChart(container, data, 'race');
}

function createLollipopChart(container, value, property, chartType = 'housing') {
    const containerNode = container.node();
    const width = containerNode.clientWidth;
    const height = containerNode.clientHeight;

    // Determine if this is a count variable (not a percentage)
    const isCurrencyVariable = property === 'Median_Household_Income' || property === 'Median_Home_Value' || property === 'Median_Gross_Rent';
    const isCountVariable = property === 'blight_count' || property === 'permits_res_count' || property === 'crime_count' || isCurrencyVariable;

    // Get min/max/median from all features for this property
    const allValues = demographicsData.features
        .map(f => parseFloat(f.properties[property]))
        .filter(v => v !== null && v !== undefined && !isNaN(v));
    const minValue = Math.min(...allValues);
    const maxValue = Math.max(...allValues);

    // Calculate median
    const sortedValues = [...allValues].sort((a, b) => a - b);
    const medianValue = sortedValues.length % 2 === 0
        ? (sortedValues[sortedValues.length / 2 - 1] + sortedValues[sortedValues.length / 2]) / 2
        : sortedValues[Math.floor(sortedValues.length / 2)];

    // Calculate rank (higher value = better rank)
    const sortedDesc = [...allValues].sort((a, b) => b - a);
    const rank = sortedDesc.indexOf(value) + 1;
    const totalTracts = allValues.length;

    let svg = container.select('svg');
    const isFirstTime = svg.empty();
    if (isFirstTime) {
        svg = container.append('svg');
        // Create a valid CSS ID by replacing dots with dashes
        const tooltipId = `tooltip-${chartType}-${property.replace(/\./g, '-')}`;
        let tooltip = d3.select('body').select(`#${tooltipId}`);
        if (tooltip.empty()) {
            tooltip = d3.select('body').append('div')
                .attr('id', tooltipId)
                .attr('class', 'tooltip')
                .style('position', 'absolute')
                .style('background', 'rgba(0, 0, 0, 0.8)')
                .style('color', 'white')
                .style('padding', '8px 12px')
                .style('border-radius', '4px')
                .style('font-size', '0.75rem')
                .style('pointer-events', 'none')
                .style('opacity', 0)
                .style('z-index', '10000');
        }
    }

    svg.attr('width', width).attr('height', height);

    const margin = { left: 5, right: 75, top: 0, bottom: 0 };
    const chartWidth = width - margin.left - margin.right;
    const centerY = height / 2;

    // Create scale
    const xScale = d3.scaleLinear()
        .domain([minValue, maxValue])
        .range([margin.left, margin.left + chartWidth]);

    // Get color based on value and chart type
    let colors;
    if (chartType === 'health') {
        colors = CONFIG.colors.health;
    } else if (chartType === 'demographics') {
        colors = CONFIG.colors.demographics;
    } else {
        colors = CONFIG.colors.housing;
    }
    const colorScale = d3.scaleQuantize()
        .domain([minValue, maxValue])
        .range(colors);

    const color = colorScale(value);

    // Draw line (no animation)
    let line = svg.select('.lollipop-line');
    if (line.empty()) {
        line = svg.append('line')
            .attr('class', 'lollipop-line')
            .attr('stroke', '#ddd')
            .attr('stroke-width', 2);
    }
    line.attr('x1', margin.left)
        .attr('x2', margin.left + chartWidth)
        .attr('y1', centerY)
        .attr('y2', centerY);

    // Draw median tick mark (no animation)
    let medianTick = svg.select('.median-tick');
    if (medianTick.empty()) {
        medianTick = svg.append('line')
            .attr('class', 'median-tick')
            .attr('stroke', '#999')
            .attr('stroke-width', 2);
    }
    medianTick.attr('x1', xScale(medianValue))
        .attr('x2', xScale(medianValue))
        .attr('y1', centerY - 6)
        .attr('y2', centerY + 6);

    // Draw value circle
    let circle = svg.select('.lollipop-circle');
    if (circle.empty()) {
        circle = svg.append('circle')
            .attr('class', 'lollipop-circle')
            .attr('r', 7)
            .style('cursor', 'pointer')
            .style('stroke', '#999')
            .style('stroke-width', 1);
    }

    const tooltipId = `tooltip-${chartType}-${property.replace(/\./g, '-')}`;
    const tooltip = d3.select(`#${tooltipId}`);

    circle
        .on('mouseover', function(event) {
            tooltip.transition().duration(200).style('opacity', 1);
            const valueStr = isCountVariable ? value.toFixed(0) : `${value.toFixed(1)}%`;
            const medianStr = isCountVariable ? medianValue.toFixed(0) : `${medianValue.toFixed(1)}%`;
            tooltip.html(`<strong>Value:</strong> ${valueStr}<br><strong>Rank:</strong> ${rank} of ${totalTracts}<br><strong>Median:</strong> ${medianStr}`);
            tooltip.style('left', (event.pageX + 10) + 'px').style('top', (event.pageY - 10) + 'px');
            d3.select(this).attr('r', 9);
        })
        .on('mouseout', function() {
            tooltip.transition().duration(100).style('opacity', 0);
            d3.select(this).attr('r', 7);
        })
        .on('mousemove', function(event) {
            tooltip.style('left', (event.pageX + 10) + 'px').style('top', (event.pageY - 10) + 'px');
        });

    circle.transition().duration(300)
        .attr('cx', xScale(value))
        .attr('cy', centerY)
        .attr('fill', color);

    // Draw value label (position static, only text updates)
    let label = svg.select('.lollipop-label');
    if (label.empty()) {
        label = svg.append('text')
            .attr('class', 'lollipop-label')
            .style('font-size', '9px')
            .style('font-weight', '600')
            .style('fill', '#333')
            .style('text-anchor', 'start');
    }
    // Check if we're showing parish median (value equals median)
    const isMedianView = Math.abs(value - medianValue) < 0.001;
    const rankText = isMedianView ? '(Median)' : `(#${rank})`;

    let labelText;
    if (isCurrencyVariable) {
        labelText = `$${value.toFixed(0).replace(/\B(?=(\d{3})+(?!\d))/g, ',')} ${rankText}`;
    } else if (isCountVariable) {
        labelText = `${value.toFixed(0)} ${rankText}`;
    } else {
        labelText = `${value.toFixed(1)}% ${rankText}`;
    }
    label.attr('x', margin.left + chartWidth + 8)
        .attr('y', centerY)
        .attr('dy', '0.35em')
        .text(labelText);
}

function createBarChart(container, data, chartType = 'race') {
    const containerNode = container.node();
    const width = containerNode.clientWidth;
    const height = containerNode.clientHeight;

    let svg = container.select('svg');
    const isFirstTime = svg.empty();
    if (isFirstTime) {
        svg = container.append('svg');
        const tooltipId = `tooltip-${chartType}`;
        let tooltip = d3.select('body').select(`#${tooltipId}`);
        if (tooltip.empty()) {
            tooltip = d3.select('body').append('div')
                .attr('id', tooltipId)
                .attr('class', 'tooltip')
                .style('position', 'absolute')
                .style('background', 'rgba(0, 0, 0, 0.8)')
                .style('color', 'white')
                .style('padding', '8px 12px')
                .style('border-radius', '4px')
                .style('font-size', '0.75rem')
                .style('pointer-events', 'none')
                .style('opacity', 0)
                .style('z-index', '10000');
        }
    }

    svg.attr('width', width).attr('height', height);
    const barHeight = height * 0.7;
    const barY = (height - barHeight) / 2;

    let cumulativeWidth = 0;
    const segmentData = data.map(d => {
        const segmentWidth = width * d.percentage;
        const result = { ...d, x: cumulativeWidth, width: segmentWidth };
        cumulativeWidth += segmentWidth;
        return result;
    });

    const segments = svg.selectAll('.bar-segment').data(segmentData, d => d.label);
    const segmentsEnter = segments.enter()
        .append('rect')
        .attr('class', 'bar-segment')
        .attr('y', barY)
        .attr('height', barHeight)
        .attr('x', 0)
        .attr('width', 0)
        .attr('fill', d => d.color)
        .style('cursor', 'pointer')
        .style('opacity', 1);

    const tooltipId = `tooltip-${chartType}`;
    const tooltip = d3.select(`#${tooltipId}`);

    segmentsEnter.on('mouseover', function(event, d) {
        if (d.count === 0) return;
        tooltip.transition().duration(200).style('opacity', 1);
        tooltip.html(`<strong>${d.label}</strong><br>Count: ${d.count.toLocaleString()}<br>Percentage: ${(d.percentage).toFixed(1)}%`);
        tooltip.style('left', (event.pageX + 10) + 'px').style('top', (event.pageY - 10) + 'px');
        d3.select(this).style('opacity', 0.8);
    })
    .on('mouseout', function() {
        tooltip.transition().duration(100).style('opacity', 0);
        d3.select(this).style('opacity', 1);
    })
    .on('mousemove', function(event, d) {
        if (d.count === 0) return;
        tooltip.style('left', (event.pageX + 10) + 'px').style('top', (event.pageY - 10) + 'px');
    });

    segments.merge(segmentsEnter).transition().duration(100)
        .attr('x', d => d.x).attr('width', d => d.width).attr('fill', d => d.color);

    const labels = svg.selectAll('.bar-label').data(segmentData.filter(d => d.width > 20), d => d.label);
    labels.exit().transition().duration(100).style('opacity', 0).remove();

    const labelsEnter = labels.enter().append('text')
        .attr('class', 'bar-label')
        .attr('y', barY + barHeight / 2)
        .attr('dy', '0.35em')
        .style('font-size', '8px')
        .style('font-weight', '500')
        .style('fill', '#333')
        .style('text-anchor', 'middle')
        .style('pointer-events', 'none')
        .style('opacity', 0)
        .text(d => d.label);

    labels.merge(labelsEnter).transition().duration(100)
        .attr('x', d => d.x + d.width / 2).style('opacity', 1);
}

function createRenterPctChart(properties) {
    const container = d3.select('#renter-chart');
    const renterPct = properties.Percent_Renter_Occupied || 0;
    createLollipopChart(container, renterPct, 'Percent_Renter_Occupied', 'housing');
}

function createSingleFamilyPctChart(properties) {
    const container = d3.select('#single-family-chart');
    const singlePct = properties.Percent_Single_Family || 0;
    createLollipopChart(container, singlePct, 'Percent_Single_Family', 'housing');
}

function createPre1980Chart(properties) {
    const container = d3.select('#pre1980-chart');
    const pre1980Pct = properties.Percent_Built_Pre_1980 || 0;
    createLollipopChart(container, pre1980Pct, 'Percent_Built_Pre_1980', 'housing');
}

function createRentBurden30Chart(properties) {
    const container = d3.select('#rent-burden-30-chart');
    const value = properties.Percent_High_Rent_Burden_30_Plus || 0;
    createLollipopChart(container, value, 'Percent_High_Rent_Burden_30_Plus', 'housing');
}

function createRentBurden50Chart(properties) {
    const container = d3.select('#rent-burden-50-chart');
    const value = properties.Percent_High_Rent_Burden_50_Plus || 0;
    createLollipopChart(container, value, 'Percent_High_Rent_Burden_50_Plus', 'housing');
}

function createBlightCountChart(properties) {
    const container = d3.select('#blight-chart');
    const value = properties.blight_count || 0;
    createLollipopChart(container, value, 'blight_count', 'housing');
}

function createPNPChart(properties) {
    const container = d3.select('#pnp-chart');
    const value = properties.PNP_Mean_Perc || 0;
    createLollipopChart(container, value, 'PNP_Mean_Perc', 'housing');
}

function createPIChart(properties) {
    const container = d3.select('#pi-chart');
    const value = properties.PI_Mean_Perc || 0;
    createLollipopChart(container, value, 'PI_Mean_Perc', 'housing');
}

function createTwoPlusBedroomsChart(properties) {
    const container = d3.select('#two-plus-bedrooms-chart');
    const value = properties.Percent_Two_Plus_Bedrooms || 0;
    createLollipopChart(container, value, 'Percent_Two_Plus_Bedrooms', 'housing');
}

function createPermitsChart(properties) {
    const container = d3.select('#permits-chart');
    const value = properties.permits_res_count || 0;
    createLollipopChart(container, value, 'permits_res_count', 'housing');
}

function createHighBloodPressureChart(properties) {
    const container = d3.select('#hbp-chart');
    const value = parseFloat(properties['HIGH.BLOOD.PRESSURE']) || 0;
    createLollipopChart(container, value, 'HIGH.BLOOD.PRESSURE', 'health');
}

function createBingeDrinkingChart(properties) {
    const container = d3.select('#binge-chart');
    const value = parseFloat(properties['BINGE.DRINKING']) || 0;
    createLollipopChart(container, value, 'BINGE.DRINKING', 'health');
}

function createCancerChart(properties) {
    const container = d3.select('#cancer-chart');
    const value = parseFloat(properties['CANCER..EXCLUDING.SKIN.CANCER.']) || 0;
    createLollipopChart(container, value, 'CANCER..EXCLUDING.SKIN.CANCER.', 'health');
}

function createAsthmaChart(properties) {
    const container = d3.select('#asthma-chart');
    const value = parseFloat(properties['ASTHMA']) || 0;
    createLollipopChart(container, value, 'ASTHMA', 'health');
}

function createDiabetesChart(properties) {
    const container = d3.select('#diabetes-chart');
    const value = parseFloat(properties['DIABETES']) || 0;
    createLollipopChart(container, value, 'DIABETES', 'health');
}

function createCoronaryHeartDiseaseChart(properties) {
    const container = d3.select('#chd-chart');
    const value = parseFloat(properties['CORONARY.HEART.DISEASE']) || 0;
    createLollipopChart(container, value, 'CORONARY.HEART.DISEASE', 'health');
}

function createPoorPhysicalHealthChart(properties) {
    const container = d3.select('#poor-physical-chart');
    const value = parseFloat(properties['POOR.PHYSICAL.HEALTH']) || 0;
    createLollipopChart(container, value, 'POOR.PHYSICAL.HEALTH', 'health');
}

function createObesityChart(properties) {
    const container = d3.select('#obesity-chart');
    const value = parseFloat(properties['OBESITY']) || 0;
    createLollipopChart(container, value, 'OBESITY', 'health');
}

function createDepressionChart(properties) {
    const container = d3.select('#depression-chart');
    const value = parseFloat(properties['DEPRESSION']) || 0;
    createLollipopChart(container, value, 'DEPRESSION', 'health');
}

function createPoorMentalHealthChart(properties) {
    const container = d3.select('#poor-mental-chart');
    const value = parseFloat(properties['POOR.MENTAL.HEALTH']) || 0;
    createLollipopChart(container, value, 'POOR.MENTAL.HEALTH', 'health');
}

function createMedianIncomeChart(properties) {
    const container = d3.select('#median-income-chart');
    const value = properties.Median_Household_Income || 0;
    createLollipopChart(container, value, 'Median_Household_Income', 'demographics');
}

function createWhiteChart(properties) {
    const container = d3.select('#white-chart');
    const value = parseFloat(properties.Percent_White) || 0;
    createLollipopChart(container, value, 'Percent_White', 'demographics');
}

function createBlackChart(properties) {
    const container = d3.select('#black-chart');
    const value = parseFloat(properties.Percent_Black) || 0;
    createLollipopChart(container, value, 'Percent_Black', 'demographics');
}

function createHispanicChart(properties) {
    const container = d3.select('#hispanic-chart');
    const value = parseFloat(properties.Percent_Hispanic) || 0;
    createLollipopChart(container, value, 'Percent_Hispanic', 'demographics');
}

function createLowIncomeChart(properties) {
    const container = d3.select('#low-income-chart');
    const value = parseFloat(properties.Percent_Low_Income_Under_35K) || 0;
    createLollipopChart(container, value, 'Percent_Low_Income_Under_35K', 'demographics');
}

function createHighIncomeChart(properties) {
    const container = d3.select('#high-income-chart');
    const value = parseFloat(properties.Percent_High_Income_100K_Plus) || 0;
    createLollipopChart(container, value, 'Percent_High_Income_100K_Plus', 'demographics');
}

function createBelowPovertyChart(properties) {
    const container = d3.select('#below-poverty-chart');
    const value = parseFloat(properties.Percent_Below_Poverty) || 0;
    createLollipopChart(container, value, 'Percent_Below_Poverty', 'demographics');
}

function createFamilyHouseholdsChart(properties) {
    const container = d3.select('#family-households-chart');
    const value = parseFloat(properties.Percent_Family_Households) || 0;
    createLollipopChart(container, value, 'Percent_Family_Households', 'demographics');
}

function createHouseholdsWithChildrenChart(properties) {
    const container = d3.select('#households-children-chart');
    const value = parseFloat(properties.Percent_Households_With_Children) || 0;
    createLollipopChart(container, value, 'Percent_Households_With_Children', 'demographics');
}

function createChildrenPovertyChart(properties) {
    const container = d3.select('#children-poverty-chart');
    const value = parseFloat(properties.Percent_Children_Below_Poverty) || 0;
    createLollipopChart(container, value, 'Percent_Children_Below_Poverty', 'demographics');
}

function createCrimeCountChart(properties) {
    const container = d3.select('#crime-count-chart');
    const value = properties.crime_count || 0;
    createLollipopChart(container, value, 'crime_count', 'demographics');
}

function createMedianHomeValueChart(properties) {
    const container = d3.select('#median-home-value-chart');
    const value = properties.Median_Home_Value || 0;
    createLollipopChart(container, value, 'Median_Home_Value', 'housing');
}

function createMedianRentChart(properties) {
    const container = d3.select('#median-rent-chart');
    const value = properties.Median_Gross_Rent || 0;
    createLollipopChart(container, value, 'Median_Gross_Rent', 'housing');
}

function createGeneralHealthChart(properties) {
    const container = d3.select('#general-health-chart');
    const value = parseFloat(properties['GENERAL.HEALTH']) || 0;
    createLollipopChart(container, value, 'GENERAL.HEALTH', 'health');
}

function highlightMapFeature(geoid) {
    const feature = demographicsData.features.find(f => f.properties.GEOID === geoid);
    if (feature && map.getSource('highlight')) {
        map.getSource('highlight').setData({ type: 'FeatureCollection', features: [feature] });
    }
}

function clearMapHighlight() {
    if (map.getSource('highlight')) {
        map.getSource('highlight').setData({ type: 'FeatureCollection', features: [] });
    }
}

function getDataExtent(property) {
    const values = demographicsData.features.map(f => {
        let val = f.properties[property];
        // Health values are now numbers, not strings with %
        return parseFloat(val);
    }).filter(v => v !== null && v !== undefined && !isNaN(v));

    if (values.length === 0) return [0, 1];
    return [Math.min(...values), Math.max(...values)];
}

function getColorExpression(property) {
    const [min, max] = getDataExtent(property);
    const config = layerConfig[property];

    // Determine color scheme based on category
    let colors;
    if (config?.category === 'demographics') {
        colors = CONFIG.colors.demographics;
    } else if (config?.category === 'housing') {
        colors = CONFIG.colors.housing;
    } else if (config?.category === 'health' || config?.type === 'health') {
        colors = CONFIG.colors.health;
    } else if (config?.type === 'percentage') {
        colors = CONFIG.colors.percentages;
    } else {
        colors = CONFIG.colors.counts;
    }

    if (min === max) return colors[Math.floor(colors.length / 2)];

    const step = (max - min) / (colors.length - 1);
    const stops = [];
    for (let i = 0; i < colors.length; i++) {
        stops.push(min + (step * i), colors[i]);
    }

    if (config?.type === 'health') {
        // Health values are now stored as numbers (e.g., 14 for 14%), not strings
        return ['interpolate', ['linear'], ['coalesce', ['get', property], 0], ...stops];
    }

    return ['interpolate', ['linear'], ['coalesce', ['get', property], 0], ...stops];
}

function getColorForValue(value, property) {
    const [min, max] = getDataExtent(property);
    const config = layerConfig[property];

    // Determine color scheme based on category
    let colors;
    if (config?.category === 'demographics') {
        colors = CONFIG.colors.demographics;
    } else if (config?.category === 'housing') {
        colors = CONFIG.colors.housing;
    } else if (config?.category === 'health' || config?.type === 'health') {
        colors = CONFIG.colors.health;
    } else if (config?.type === 'percentage') {
        colors = CONFIG.colors.percentages;
    } else {
        colors = CONFIG.colors.counts;
    }

    // Health values are now numbers, no conversion needed
    value = parseFloat(value);

    if (min === max) return colors[Math.floor(colors.length / 2)];

    const normalizedValue = (value - min) / (max - min);
    const colorIndex = Math.min(Math.floor(normalizedValue * colors.length), colors.length - 1);
    return colors[colorIndex];
}

function findFirstLabelLayer() {
    const layers = map.getStyle().layers;
    const labelPatterns = ['place-', 'poi-', 'road-', 'transit-', 'settlement-', '-label'];
    
    for (const layer of layers) {
        if (layer.type === 'symbol' && labelPatterns.some(pattern => layer.id.includes(pattern))) {
            return layer.id;
        }
    }
    
    for (const layer of layers) {
        if (layer.type === 'symbol') return layer.id;
    }
    
    return undefined;
}

function addDataLayer(property) {
    if (map.getLayer('demographics-layer')) map.removeLayer('demographics-layer');
    const labelLayerId = findFirstLabelLayer();
    map.addLayer({
        id: 'demographics-layer',
        type: 'fill',
        source: 'demographics',
        layout: {},
        paint: { 'fill-color': getColorExpression(property), 'fill-opacity': 0.7, 'fill-outline-color': '#ffffff' }
    }, labelLayerId);
}

function updateLayer(property) {
    if (map.getLayer('demographics-layer')) {
        map.setPaintProperty('demographics-layer', 'fill-color', getColorExpression(property));
    } else {
        addDataLayer(property);
    }
}

function updateLegend(property) {
    const [min, max] = getDataExtent(property);
    const config = layerConfig[property];
    const isPercentage = config?.type === 'percentage' || config?.type === 'health';

    // Use category-based colors to match the map
    let colors;
    if (config?.category === 'demographics') {
        colors = CONFIG.colors.demographics;
    } else if (config?.category === 'housing') {
        colors = CONFIG.colors.housing;
    } else if (config?.category === 'health' || config?.type === 'health') {
        colors = CONFIG.colors.health;
    } else if (config?.type === 'percentage') {
        colors = CONFIG.colors.percentages;
    } else {
        colors = CONFIG.colors.counts;
    }

    const step = (max - min) / (colors.length - 1);

    const legendContent = document.getElementById('legend-content');
    if (!legendContent) return;

    legendContent.innerHTML = '';
    const title = document.createElement('div');
    title.style.marginBottom = '10px';
    title.style.fontWeight = 'bold';
    title.style.fontSize = '0.85rem';
    title.textContent = layerConfig[property]?.label || property;
    legendContent.appendChild(title);

    for (let i = colors.length - 1; i >= 0; i--) {
        const value = min + (step * i);
        const formattedValue = formatValue(value, isPercentage, property);
        const item = document.createElement('div');
        item.className = 'legend-item';
        item.innerHTML = `<div class="legend-color" style="background-color: ${colors[i]}"></div><span>${formattedValue}</span>`;
        legendContent.appendChild(item);
    }
}

function formatValue(value, isPercentage, property) {
    const config = layerConfig[property];
    if (config?.type === 'health') {
        // Health values are now stored as whole numbers (e.g., 14 for 14%)
        return value.toFixed(1) + '%';
    }
    if (isPercentage) return (value).toFixed(0) + '%';
    if (property && (property.includes('Income') || property.includes('Value') || property.includes('Rent'))) {
        return '$' + Math.round(value).toLocaleString();
    }
    return Math.round(value).toLocaleString();
}

function initializeScatterPlot() {
    scatterPlot = new ScatterPlot('scatter-plot', demographicsData, currentLayer, currentXAxis);
}

function updateScatterPlot() {
    if (scatterPlot) {
        scatterPlot.updateLayer(currentLayer, currentXAxis);
        const subtitle = document.getElementById('plot-subtitle');
        const xAxisLabel = currentXAxis === 'rank' ? 'Rank' : (layerConfig[currentXAxis]?.label || currentXAxis);
        subtitle.textContent = `${layerConfig[currentLayer]?.label || currentLayer} by ${xAxisLabel}`;
    }
}

class ScatterPlot {
    constructor(containerId, data, layer, xAxis) {
        this.container = d3.select(`#${containerId}`);
        this.data = data;
        this.currentLayer = layer;
        this.currentXAxis = xAxis;
        this.margin = { top: 15, right: 15, bottom: 40, left: 55 };
        this.width = 320 - this.margin.left - this.margin.right;
        this.height = 160 - this.margin.bottom - this.margin.top;
        this.setup();
        this.updateData();
    }
    
    setup() {
        this.container.selectAll('*').remove();
        this.svg = this.container.append('svg')
            .attr('viewBox', `0 0 ${this.width + this.margin.left + this.margin.right} ${this.height + this.margin.top + this.margin.bottom}`)
            .attr('preserveAspectRatio', 'xMidYMid meet');
        this.g = this.svg.append('g').attr('transform', `translate(${this.margin.left},${this.margin.top})`);
        this.xScale = d3.scaleLinear().range([0, this.width]);
        this.yScale = d3.scaleLinear().range([this.height, 0]);
        this.sizeScale = d3.scaleSqrt().range([2, 8]);
        this.trendlineGroup = this.g.append('g').attr('class', 'trendline-group');
        this.xAxis = this.g.append('g').attr('class', 'axis').attr('transform', `translate(0,${this.height})`);
        this.yAxis = this.g.append('g').attr('class', 'axis');
        this.xLabel = this.svg.append('text').attr('class', 'axis-label').attr('text-anchor', 'middle')
            .attr('x', this.margin.left + this.width / 2).attr('y', this.height + this.margin.top + 32).style('font-size', '8px');
        this.yLabel = this.svg.append('text').attr('class', 'axis-label').attr('text-anchor', 'middle')
            .attr('transform', 'rotate(-90)').attr('y', 12).attr('x', -(this.margin.top + this.height / 2)).style('font-size', '8px');
        this.r2Label = this.svg.append('text').attr('class', 'r2-label')
            .attr('x', this.margin.left + 5).attr('y', this.margin.top + 10)
            .style('font-size', '9px').style('font-weight', '600').style('fill', '#1F2052');
    }
    
    calculateLinearRegression(data) {
        const n = data.length;
        let sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0, sumY2 = 0;
        data.forEach(d => {
            sumX += d.xValue;
            sumY += d.yValue;
            sumXY += d.xValue * d.yValue;
            sumX2 += d.xValue * d.xValue;
            sumY2 += d.yValue * d.yValue;
        });
        const slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
        const intercept = (sumY - slope * sumX) / n;
        const yMean = sumY / n;
        let ssTotal = 0, ssResidual = 0;
        data.forEach(d => {
            const yPred = slope * d.xValue + intercept;
            ssTotal += Math.pow(d.yValue - yMean, 2);
            ssResidual += Math.pow(d.yValue - yPred, 2);
        });
        const r2 = 1 - (ssResidual / ssTotal);
        return { slope, intercept, r2 };
    }
    
    updateData() {
        const yProperty = this.currentLayer;
        const xProperty = this.currentXAxis;
        
        let features = this.data.features.map(f => {
            let yValue = f.properties[yProperty];
            let xValue = f.properties[xProperty];
            if (typeof yValue === 'string' && yValue.includes('%')) yValue = parseFloat(yValue.replace('%', '')) / 100;
            if (typeof xValue === 'string' && xValue.includes('%')) xValue = parseFloat(xValue.replace('%', '')) / 100;
            return {
                ...f.properties,
                yValue: yValue || 0,
                xValue: xProperty === 'rank' ? 0 : (xValue || 0),
                population: f.properties.Total_Population || 0
            };
        });
        
        if (xProperty === 'rank') {
            features = features.sort((a, b) => b.yValue - a.yValue).map((d, i) => ({ ...d, xValue: i + 1 }));
        }
        
        features.sort((a, b) => a.yValue - b.yValue);
        const xExtent = d3.extent(features, d => d.xValue);
        const yExtent = d3.extent(features, d => d.yValue);
        this.xScale.domain(xExtent);
        this.yScale.domain(yExtent);
        this.sizeScale.domain(d3.extent(features, d => d.population));
        
        const regression = this.calculateLinearRegression(features);
        const x1 = xExtent[0], x2 = xExtent[1];
        const y1 = regression.slope * x1 + regression.intercept;
        const y2 = regression.slope * x2 + regression.intercept;
        
        this.trendlineGroup.selectAll('*').remove();
        this.trendlineGroup.append('line')
            .attr('x1', this.xScale(x1)).attr('y1', this.yScale(y1))
            .attr('x2', this.xScale(x2)).attr('y2', this.yScale(y2))
            .attr('stroke', '#1F2052').attr('stroke-width', 2)
            .attr('stroke-dasharray', '5,5').attr('opacity', 0.6);
        
        this.r2Label.text(`R² = ${regression.r2.toFixed(3)}`);
        
        const xFormat = xProperty === 'rank' ? d3.format('d') : 
                       xProperty.includes('Percent') ? d3.format('.0%') : 
                       xProperty.includes('Income') ? d => '$' + d3.format(',')(d) : d3.format(',');
        this.xAxis.transition().duration(500).call(d3.axisBottom(this.xScale).tickFormat(xFormat).ticks(4))
            .selectAll('text').style('font-size', '7px');
        
        const yFormat = yProperty.includes('Percent') ? d3.format('.0%') : 
                       yProperty.includes('Income') ? d => '$' + d3.format(',')(d) : d3.format(',');
        this.yAxis.transition().duration(500).call(d3.axisLeft(this.yScale).tickFormat(yFormat).ticks(4))
            .selectAll('text').style('font-size', '7px');
        
        const xAxisLabel = xProperty === 'rank' ? 'Rank (Highest to Lowest)' : (layerConfig[xProperty]?.label || xProperty);
        this.xLabel.text(xAxisLabel);
        this.yLabel.text(layerConfig[yProperty]?.label || yProperty);
        
        const circles = this.g.selectAll('.scatter-circle').data(features, d => d.GEOID);
        circles.exit().remove();
        const circlesEnter = circles.enter().append('circle').attr('class', 'scatter-circle')
            .on('mouseover', (event, d) => this.handleBubbleHover(d))
            .on('mouseout', () => this.handleBubbleLeave())
            .on('click', (event, d) => this.handleBubbleClick(d));
        circles.merge(circlesEnter).transition().duration(500)
            .attr('cx', d => this.xScale(d.xValue))
            .attr('cy', d => this.yScale(d.yValue))
            .attr('r', d => this.sizeScale(d.population))
            .attr('fill', d => getColorForValue(d.yValue, yProperty))
            .attr('opacity', 0.7);
    }
    
    updateLayer(newLayer, newXAxis) {
        this.currentLayer = newLayer;
        this.currentXAxis = newXAxis;
        this.updateData();
    }
    
    handleBubbleClick(data) {
        if (isFrozen && data.GEOID === currentHoveredFeature) {
            unfreeze();
        } else {
            const feature = demographicsData.features.find(f => f.properties.GEOID === data.GEOID);
            if (feature) {
                freeze(data);
                zoomToTract(feature);
            }
        }
    }
    
    handleBubbleHover(data) {
        if (isFrozen) return;
        this.g.selectAll('.scatter-circle').classed('highlighted', false);
        this.g.selectAll('.scatter-circle').filter(d => d.GEOID === data.GEOID)
            .classed('highlighted', true).raise();
        updateTractDetails(data);
        currentHoveredFeature = data.GEOID;
        highlightMapFeature(data.GEOID);
    }
    
    handleBubbleLeave() {
        if (isFrozen) return;
        this.clearHighlight();
        showParishTotals();
        clearMapHighlight();
        currentHoveredFeature = null;
        this.reorderBubbles();
    }
    
    highlightBubble(geoid) {
        this.g.selectAll('.scatter-circle').classed('highlighted', false);
        this.g.selectAll('.scatter-circle').filter(d => d.GEOID === geoid)
            .classed('highlighted', true).raise();
    }
    
    clearHighlight() {
        this.g.selectAll('.scatter-circle').classed('highlighted', false);
    }
    
    reorderBubbles() {
        this.g.selectAll('.scatter-circle').sort((a, b) => a.yValue - b.yValue);
    }
    
    resize() {
        const containerRect = this.container.node().getBoundingClientRect();
        this.width = Math.max(250, containerRect.width - this.margin.left - this.margin.right - 20);
        this.height = Math.max(120, containerRect.height - this.margin.top - this.margin.bottom - 20);
        this.xScale.range([0, this.width]);
        this.yScale.range([this.height, 0]);
        this.svg.attr('viewBox', `0 0 ${this.width + this.margin.left + this.margin.right} ${this.height + this.margin.top + this.margin.bottom}`);
        this.xAxis.attr('transform', `translate(0,${this.height})`);
        this.xLabel.attr('x', this.margin.left + this.width / 2).attr('y', this.height + this.margin.top + 32);
        this.yLabel.attr('x', -(this.margin.top + this.height / 2));
        this.updateData();
    }
}

function showError(message) {
    const errorDiv = document.createElement('div');
    errorDiv.className = 'alert alert-danger';
    errorDiv.style.position = 'fixed';
    errorDiv.style.top = '20px';
    errorDiv.style.left = '50%';
    errorDiv.style.transform = 'translateX(-50%)';
    errorDiv.style.zIndex = '10000';
    errorDiv.textContent = message;
    document.body.appendChild(errorDiv);
    setTimeout(() => {
        if (document.body.contains(errorDiv)) document.body.removeChild(errorDiv);
    }, 5000);
}