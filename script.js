// Cook County Veterans, Economic Security, and Housing Map Application
mapboxgl.accessToken = 'pk.eyJ1Ijoicm1jYXJkZXIxIiwiYSI6ImNtN2pqOG56cjA3bXMybXE0dnhmMm9xM2wifQ.O2mYeNpbnS7TA-J_0q2wkg';

// Configuration
const CONFIG = {
    map: {
        style: 'mapbox://styles/mapbox/light-v11',
        center: [-87.75, 41.85],
        zoom: 9.5
    },
    colors: {
        counts: ['#f7f4f9', '#e7e1ef', '#d4b9da', '#c994c7', '#df65b0', '#e7298a', '#ce1256', '#91003f'],
        percentages: ['#fff5f0', '#fee0d2', '#fcbba1', '#fc9272', '#fb6a4a', '#ef3b2c', '#cb181d', '#a50f15'],
        veterans: ['#f7fcf5','#e5f5e0','#c7e9c0','#a1d99b','#74c476','#41ab5d','#238b45','#005a32'],
        economic: ['#fff7ec','#fee8c8','#fdd49e','#fdbb84','#fc8d59','#ef6548','#d7301f','#990000'],
        housing: ['#ffffd9','#edf8b1','#c7e9b4','#7fcdbb','#41b6c4','#1d91c0','#225ea8','#0c2c84'],
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
let currentLayer = 'Vet_Total_Veterans';
let currentXAxis = 'rank';
let demographicsData = null;
let currentHoveredFeature = null;
let scatterPlot = null;
let isFrozen = false;
let originalMapView = null;
let countyTotals = null;
let tractRankings = null;
let mapPopup = null;
let gridScatterPlots = [];
let currentScatterCategory = 'veterans';

// Data layer configurations
const layerConfig = {
    // Veterans - Population
    'Vet_Total_Veterans': { label: 'Total Veterans', type: 'count', category: 'veterans' },
    'Pct_Veterans_Of_Adult_Pop': { label: 'Veterans % of Adults', type: 'percentage', category: 'veterans' },
    'veterans_per_1000_pop': { label: 'Veterans per 1,000 Pop', type: 'count', category: 'veterans' },
    // Veterans - Demographics
    'Pct_Veterans_Male': { label: 'Male Veterans %', type: 'percentage', category: 'veterans' },
    'Pct_Veterans_Female': { label: 'Female Veterans %', type: 'percentage', category: 'veterans' },
    // Veterans - Age Groups
    'Pct_Veterans_18_34': { label: 'Veterans 18-34 %', type: 'percentage', category: 'veterans' },
    'Pct_Veterans_35_54': { label: 'Veterans 35-54 %', type: 'percentage', category: 'veterans' },
    'Pct_Veterans_55_64': { label: 'Veterans 55-64 %', type: 'percentage', category: 'veterans' },
    'Pct_Veterans_65_Plus': { label: 'Veterans 65+ %', type: 'percentage', category: 'veterans' },
    // Veterans - Economic Status
    'Pct_Veterans_Employed': { label: 'Veterans Employed %', type: 'percentage', category: 'veterans' },
    'Pct_Veterans_Unemployed': { label: 'Veterans Unemployed %', type: 'percentage', category: 'veterans' },
    'Vet_Median_Income_Veteran_Total': { label: 'Veteran Median Income', type: 'currency', category: 'veterans' },
    // Veterans - Poverty & Disability
    'Pct_Vet_18_64_In_Poverty': { label: 'Veterans 18-64 in Poverty %', type: 'percentage', category: 'veterans' },
    'Pct_Vet_65_Plus_In_Poverty': { label: 'Veterans 65+ in Poverty %', type: 'percentage', category: 'veterans' },
    'Pct_Vet_With_Service_Disability': { label: 'Service-Connected Disability %', type: 'percentage', category: 'veterans' },
    // Veterans - Health Coverage
    'Pct_With_TRICARE': { label: 'TRICARE Coverage %', type: 'percentage', category: 'veterans' },
    'Pct_With_VA_HealthCare': { label: 'VA Health Care %', type: 'percentage', category: 'veterans' },

    // Economic Security - Income & Poverty
    'Median_Household_Income': { label: 'Median Household Income', type: 'currency', category: 'economic' },
    'Pct_Below_Poverty': { label: 'Below Poverty %', type: 'percentage', category: 'economic' },
    'Low_Income_Under_35K': { label: 'Low Income (<$35K)', type: 'count', category: 'economic' },
    'High_Income_100K_Plus': { label: 'High Income ($100K+)', type: 'count', category: 'economic' },
    // Economic Security - Health Insurance
    'Pct_With_Health_Insurance': { label: 'With Health Insurance %', type: 'percentage', category: 'economic' },
    'Pct_No_Health_Insurance': { label: 'Without Health Insurance %', type: 'percentage', category: 'economic' },
    'Pct_Employed_With_Insurance': { label: 'Employed With Insurance %', type: 'percentage', category: 'economic' },
    'Pct_With_Employer_Insurance': { label: 'Employer Insurance %', type: 'percentage', category: 'economic' },
    'Pct_With_Medicare': { label: 'Medicare %', type: 'percentage', category: 'economic' },
    'Pct_With_Medicaid': { label: 'Medicaid %', type: 'percentage', category: 'economic' },
    // Economic Security - Public Assistance
    'Pct_HH_SNAP': { label: 'Households on SNAP %', type: 'percentage', category: 'economic' },
    'Pct_HH_Public_Assistance': { label: 'Public Assistance %', type: 'percentage', category: 'economic' },
    'Pct_HH_With_Social_Security': { label: 'Social Security %', type: 'percentage', category: 'economic' },
    'Pct_HH_With_SSI': { label: 'Supplemental SSI %', type: 'percentage', category: 'economic' },
    // Economic Security - Education
    'Pct_Bachelors_Plus': { label: 'Bachelor\'s Degree+ %', type: 'percentage', category: 'economic' },
    'Pct_Less_Than_HS': { label: 'Less than High School %', type: 'percentage', category: 'economic' },
    // Economic Security - Disability & Digital Access
    'Pct_With_Disability': { label: 'With Disability %', type: 'percentage', category: 'economic' },
    'Pct_HH_With_Broadband': { label: 'Broadband Access %', type: 'percentage', category: 'economic' },
    // Economic Security - Transportation
    'Pct_Commute_60_Plus': { label: 'Commute 60+ Min %', type: 'percentage', category: 'economic' },
    'Pct_Work_At_Home': { label: 'Work from Home %', type: 'percentage', category: 'economic' },
    'Pct_HH_No_Vehicle': { label: 'No Vehicle %', type: 'percentage', category: 'economic' },

    // Housing - Stock
    'Total_Housing_Units': { label: 'Total Housing Units', type: 'count', category: 'housing' },
    'Pct_Single_Family': { label: 'Single-Family %', type: 'percentage', category: 'housing' },
    'Pct_Multi_Family_5_Plus': { label: 'Multi-Family 5+ %', type: 'percentage', category: 'housing' },
    'Pct_Vacant': { label: 'Vacancy Rate %', type: 'percentage', category: 'housing' },
    // Housing - Values & Costs
    'Median_Home_Value': { label: 'Median Home Value', type: 'currency', category: 'housing' },
    'Median_Gross_Rent': { label: 'Median Gross Rent', type: 'currency', category: 'housing' },
    'Rent_Burden_Ratio': { label: 'Rent Burden Ratio', type: 'count', category: 'housing' },
    'Price_To_Income_Ratio': { label: 'Price to Income Ratio', type: 'count', category: 'housing' },
    // Housing - Tenure
    'Pct_Owner_Occupied': { label: 'Owner-Occupied %', type: 'percentage', category: 'housing' },
    'Pct_Renter_Occupied': { label: 'Renter-Occupied %', type: 'percentage', category: 'housing' },
    // Housing - Cost Burden
    'Pct_Renters_Cost_Burdened_30_Plus': { label: 'Rent-Burdened 30%+ %', type: 'percentage', category: 'housing' },
    'Pct_Owners_Cost_Burdened_30_Plus': { label: 'Owner Cost-Burdened 30%+ %', type: 'percentage', category: 'housing' },
    'Pct_All_HH_Cost_Burdened_30_Plus': { label: 'All HH Cost-Burdened 30%+ %', type: 'percentage', category: 'housing' },
    // Housing - Overcrowding
    'Pct_All_HH_Overcrowded': { label: 'Overcrowded Households %', type: 'percentage', category: 'housing' },
    // Housing - Aging in Place
    'Pct_Owners_65_Plus': { label: 'Owners 65+ %', type: 'percentage', category: 'housing' },
    // Housing - Density & Size
    'housing_units_per_sqmi': { label: 'Housing Density (per sq mi)', type: 'count', category: 'housing' },
    'Avg_Household_Size': { label: 'Avg Household Size', type: 'count', category: 'housing' },
    // Housing - Stability
    'Pct_Same_House_1_Year': { label: 'Same House 1 Year %', type: 'percentage', category: 'housing' },

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
        const scatterplotsBtn = document.getElementById('toggle-scatterplots');

        if (layerBtn) {
            layerBtn.addEventListener('click', function(e) {
                e.preventDefault();
                e.stopPropagation();
                const layerPanel = document.getElementById('layer-controls-panel');
                const xAxisPanel = document.getElementById('xaxis-controls-panel');
                xAxisPanel.classList.remove('open');
                // DO NOT close scatterplots panel when layer button is clicked
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
                // DO NOT close scatterplots panel when x-axis button is clicked
                xAxisPanel.classList.toggle('open');
            });
        }

        if (scatterplotsBtn) {
            scatterplotsBtn.addEventListener('click', function(e) {
                e.preventDefault();
                e.stopPropagation();
                const layerPanel = document.getElementById('layer-controls-panel');
                const xAxisPanel = document.getElementById('xaxis-controls-panel');
                const scatterplotsPanel = document.getElementById('scatterplots-panel');
                layerPanel.classList.remove('open');
                xAxisPanel.classList.remove('open');

                const isOpening = !scatterplotsPanel.classList.contains('open');
                scatterplotsPanel.classList.toggle('open');

                // If opening the panel and there's a frozen selection, highlight it in all plots
                if (isOpening && isFrozen && currentHoveredFeature) {
                    setTimeout(() => {
                        highlightBubbleInAllPlots(currentHoveredFeature);
                    }, 100);
                }
            });
        }

        const closeLayerBtn = document.getElementById('close-layer-controls');
        const closeXAxisBtn = document.getElementById('close-xaxis-controls');
        const closeScatterplotsBtn = document.getElementById('close-scatterplots');

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

        if (closeScatterplotsBtn) {
            closeScatterplotsBtn.addEventListener('click', function() {
                document.getElementById('scatterplots-panel').classList.remove('open');
            });
        }
    }, 100);

    document.addEventListener('click', function(e) {
        const layerPanel = document.getElementById('layer-controls-panel');
        const xAxisPanel = document.getElementById('xaxis-controls-panel');
        const scatterplotsPanel = document.getElementById('scatterplots-panel');
        const layerBtn = document.getElementById('toggle-layer-controls');
        const xAxisBtn = document.getElementById('toggle-xaxis-controls');
        const scatterplotsBtn = document.getElementById('toggle-scatterplots');

        // Only close layer and xaxis panels on outside click (not scatterplots panel)
        if (!layerPanel.contains(e.target) && !layerBtn.contains(e.target) &&
            !xAxisPanel.contains(e.target) && !xAxisBtn.contains(e.target) &&
            !scatterplotsPanel.contains(e.target) && !scatterplotsBtn.contains(e.target) &&
            !e.target.closest('.control-btn')) {
            layerPanel.classList.remove('open');
            xAxisPanel.classList.remove('open');
            // Note: scatterplots panel is NOT closed here - only closes with X button
        }
    });
}

async function loadData() {
    try {
        const response = await fetch('Output Data/Cook_County_Housing_Veterans_Tract_2023.geojson');
        demographicsData = await response.json();
        console.log('Data loaded successfully:', demographicsData.features.length, 'features');
        calculateCountyTotals();
        calculateRankings();
        initializeMap();
        initializeScatterPlot();
        initializeScatterplotsPanel();

        // Initialize the tract details with county totals
        // Need to render the DOM first, then populate with data
        updateTractDetails(countyTotals, true);
    } catch (error) {
        console.error('Error loading data:', error);
        showError('Failed to load demographics data. Please check your data file.');
    }
}

function calculateCountyTotals() {
    countyTotals = {
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
        countyTotals.Total_Population += props.Total_Population || 0;
        countyTotals.White_Alone += props.White_Alone || 0;
        countyTotals.Black_Alone += props.Black_Alone || 0;
        countyTotals.Asian_Alone += props.Asian_Alone || 0;
        countyTotals.Hispanic_Latino += props.Hispanic_Latino || 0;
        countyTotals.Below_Poverty_Level += props.Below_Poverty_Level || 0;
        countyTotals.Owner_Occupied += props.Owner_Occupied || 0;
        countyTotals.Renter_Occupied += props.Renter_Occupied || 0;
        countyTotals.Single_Family_Detached += props.Single_Family_Detached || 0;
        countyTotals.Multi_Family_All_Units += props.Multi_Family_All_Units || 0;
        countyTotals.Households_With_Children_Under_18 += props.Households_With_Children_Under_18 || 0;
        countyTotals.Total_Households += props.Total_Households || 0;
        countyTotals.Total_Housing_Units += props.Total_Housing_Units || 0;

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

    countyTotals.Percent_White = countyTotals.White_Alone / countyTotals.Total_Population;
    countyTotals.Percent_Black = countyTotals.Black_Alone / countyTotals.Total_Population;
    countyTotals.Percent_Asian = countyTotals.Asian_Alone / countyTotals.Total_Population;
    countyTotals.Percent_Hispanic = countyTotals.Hispanic_Latino / countyTotals.Total_Population;
    countyTotals.Percent_Below_Poverty = countyTotals.Below_Poverty_Level / countyTotals.Total_Population;
    countyTotals.Median_Household_Income = incomeCount > 0 ? incomeSum / incomeCount : 0;
    countyTotals.Percent_Built_Pre_1980 = housingUnitsCount > 0 ? (pre1980Sum / housingUnitsCount) : 0;
    countyTotals.Percent_Built_2000_Plus = housingUnitsCount > 0 ? (post2000Sum / housingUnitsCount) : 0;
    countyTotals.NAME = 'Cook County, Illinois';

    // Calculate medians for lollipop chart variables
    const lollipopVars = [
        // Veterans
        'Vet_Total_Veterans', 'Pct_Veterans_Of_Adult_Pop', 'veterans_per_1000_pop',
        'Pct_Veterans_Male', 'Pct_Veterans_Female',
        'Pct_Veterans_18_34', 'Pct_Veterans_35_54', 'Pct_Veterans_55_64', 'Pct_Veterans_65_Plus',
        'Pct_Veterans_Employed', 'Pct_Veterans_Unemployed', 'Vet_Median_Income_Veteran_Total',
        'Pct_Vet_18_64_In_Poverty', 'Pct_Vet_65_Plus_In_Poverty', 'Pct_Vet_With_Service_Disability',
        'Pct_With_TRICARE', 'Pct_With_VA_HealthCare',
        // Economic Security
        'Median_Household_Income', 'Pct_Below_Poverty', 'Low_Income_Under_35K', 'High_Income_100K_Plus',
        'Pct_With_Health_Insurance', 'Pct_No_Health_Insurance', 'Pct_Employed_With_Insurance',
        'Pct_With_Employer_Insurance', 'Pct_With_Medicare', 'Pct_With_Medicaid',
        'Pct_HH_SNAP', 'Pct_HH_Public_Assistance', 'Pct_HH_With_Social_Security', 'Pct_HH_With_SSI',
        'Pct_Bachelors_Plus', 'Pct_Less_Than_HS', 'Pct_With_Disability', 'Pct_HH_With_Broadband',
        'Pct_Commute_60_Plus', 'Pct_Work_At_Home', 'Pct_HH_No_Vehicle',
        // Housing
        'Total_Housing_Units', 'Median_Home_Value', 'Median_Gross_Rent',
        'Pct_Owner_Occupied', 'Pct_Renter_Occupied', 'Pct_Vacant',
        'Pct_Single_Family', 'Pct_Multi_Family_5_Plus',
        'Rent_Burden_Ratio', 'Price_To_Income_Ratio',
        'Pct_Renters_Cost_Burdened_30_Plus', 'Pct_Owners_Cost_Burdened_30_Plus', 'Pct_All_HH_Cost_Burdened_30_Plus',
        'Pct_All_HH_Overcrowded', 'Pct_Owners_65_Plus',
        'housing_units_per_sqmi', 'Avg_Household_Size', 'Pct_Same_House_1_Year'
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
            countyTotals[varName] = median;
        } else {
            countyTotals[varName] = 0;
        }
    });
}

function calculateRankings() {
    tractRankings = {};
    const metrics = ['Total_Population', 'Median_Household_Income', 'Pct_Below_Poverty'];
    
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
                if (!isFrozen) showCountyTotals();
                document.getElementById('layer-controls-panel').classList.remove('open');
            }
        });
    });

    document.querySelectorAll('input[name="xAxisVar"]').forEach(radio => {
        radio.addEventListener('change', function() {
            if (this.checked) {
                currentXAxis = this.value;
                updateScatterPlot();
                updateScatterplotsXAxis(); // Update grid scatterplots x-axis

                // Always close the x-axis panel (scatterplots panel stays open independently)
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
    highlightBubbleInAllPlots(properties.GEOID);
    highlightMapFeature(properties.GEOID);
}

function unfreeze() {
    isFrozen = false;
    currentHoveredFeature = null;
    showCountyTotals();
    clearMapHighlight();
    zoomToOriginalView();
    clearHighlightInAllPlots();
}

function handleMapHover(e) {
    if (isFrozen) return;
    const feature = e.features[0];
    if (feature) {
        if (feature.properties.GEOID !== currentHoveredFeature) {
            currentHoveredFeature = feature.properties.GEOID;
            updateTractDetails(feature.properties);
            highlightBubbleInAllPlots(feature.properties.GEOID);

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
    showCountyTotals();
    clearMapHighlight();
    clearHighlightInAllPlots();
    map.getCanvas().style.cursor = '';

    // Remove popup
    if (mapPopup) {
        mapPopup.remove();
    }
}

function showCountyTotals() {
    updateTractDetails(countyTotals, true);
}

function updateTractDetails(properties, isCountyView = false) {
    const tractInfo = document.getElementById('tract-info');
    const rankings = isCountyView ? {} : (tractRankings[properties.GEOID] || {});
    const totalTracts = demographicsData.features.length;
    const chartsExist = tractInfo.querySelector('#race-chart') !== null;

    // Store current properties for tab switching
    window.currentTractProperties = properties;

    if (!chartsExist) {
        tractInfo.innerHTML = `
            <div class="tract-summary-stats">
                <div class="summary-stat-box">
                    <div class="summary-stat-value" id="total-pop-value">${Number(properties.Total_Population || 0).toLocaleString()} <span class="inline-rank" id="total-pop-rank">${rankings.Total_Population ? `#${rankings.Total_Population}` : ''}</span></div>
                    <div class="summary-stat-label">Total Population</div>
                </div>
                <div class="summary-stat-box">
                    <div class="summary-stat-value" id="vet-total-value">${Number(properties.Vet_Total_Veterans || 0).toLocaleString()} <span class="inline-rank" id="vet-total-rank">${rankings.Vet_Total_Veterans ? `#${rankings.Vet_Total_Veterans}` : ''}</span></div>
                    <div class="summary-stat-label">Total Veterans</div>
                </div>
                <div class="summary-stat-box">
                    <div class="summary-stat-value" id="median-income-value">$${Number(properties.Median_Household_Income || 0).toLocaleString()} <span class="inline-rank" id="median-income-rank">${rankings.Median_Household_Income ? `#${rankings.Median_Household_Income}` : ''}</span></div>
                    <div class="summary-stat-label">Median Income</div>
                </div>
            </div>

            <div class="chart-section race-bar-section">
                <div id="race-chart"></div>
            </div>

            <!-- Tabbed Section -->
            <div class="tabs-container">
                <div class="tabs-header">
                    <button class="tab-btn active" data-tab="veterans">Veterans</button>
                    <button class="tab-btn" data-tab="economic">Economic</button>
                    <button class="tab-btn" data-tab="housing">Housing</button>
                </div>

                <div class="tabs-content">
                    <div class="tab-pane active" id="tab-veterans">
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Total Veterans</div>
                            <div class="chart-container-inline" id="vet-total-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Veterans % of Adults</div>
                            <div class="chart-container-inline" id="vet-pct-adult-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Veterans per 1,000</div>
                            <div class="chart-container-inline" id="vet-per-1000-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Male Veterans %</div>
                            <div class="chart-container-inline" id="vet-male-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Female Veterans %</div>
                            <div class="chart-container-inline" id="vet-female-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Veterans 18-34 %</div>
                            <div class="chart-container-inline" id="vet-18-34-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Veterans 35-54 %</div>
                            <div class="chart-container-inline" id="vet-35-54-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Veterans 55-64 %</div>
                            <div class="chart-container-inline" id="vet-55-64-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Veterans 65+ %</div>
                            <div class="chart-container-inline" id="vet-65-plus-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Veterans Employed %</div>
                            <div class="chart-container-inline" id="vet-employed-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Veteran Median Income</div>
                            <div class="chart-container-inline" id="vet-median-income-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Service-Connected Disability %</div>
                            <div class="chart-container-inline" id="vet-service-disability-chart"></div>
                        </div>
                    </div>

                    <div class="tab-pane" id="tab-economic">
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Median Income</div>
                            <div class="chart-container-inline" id="median-income-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">% Below Poverty</div>
                            <div class="chart-container-inline" id="below-poverty-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Low Income Count</div>
                            <div class="chart-container-inline" id="low-income-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">High Income Count</div>
                            <div class="chart-container-inline" id="high-income-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">With Insurance %</div>
                            <div class="chart-container-inline" id="with-insurance-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Without Insurance %</div>
                            <div class="chart-container-inline" id="no-insurance-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">SNAP %</div>
                            <div class="chart-container-inline" id="snap-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Public Assistance %</div>
                            <div class="chart-container-inline" id="public-assist-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Bachelor's+ %</div>
                            <div class="chart-container-inline" id="bachelors-plus-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Less than HS %</div>
                            <div class="chart-container-inline" id="less-than-hs-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Commute 60+ Min %</div>
                            <div class="chart-container-inline" id="long-commute-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">No Vehicle %</div>
                            <div class="chart-container-inline" id="no-vehicle-chart"></div>
                        </div>
                    </div>

                    <div class="tab-pane" id="tab-housing">
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Total Housing Units</div>
                            <div class="chart-container-inline" id="housing-units-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Median Home Value</div>
                            <div class="chart-container-inline" id="median-home-value-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Median Gross Rent</div>
                            <div class="chart-container-inline" id="median-rent-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">% Owner Occupied</div>
                            <div class="chart-container-inline" id="owner-pct-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">% Renter Occupied</div>
                            <div class="chart-container-inline" id="renter-pct-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Vacancy Rate %</div>
                            <div class="chart-container-inline" id="vacancy-rate-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">% Single Family</div>
                            <div class="chart-container-inline" id="single-family-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">% Multi-Family 5+</div>
                            <div class="chart-container-inline" id="multi-family-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Rent Burden Ratio</div>
                            <div class="chart-container-inline" id="rent-burden-ratio-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Price/Income Ratio</div>
                            <div class="chart-container-inline" id="price-income-ratio-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Housing Density</div>
                            <div class="chart-container-inline" id="density-chart"></div>
                        </div>
                        <div class="chart-section inline-chart">
                            <div class="chart-title-inline">Avg Household Size</div>
                            <div class="chart-container-inline" id="household-size-chart"></div>
                        </div>
                    </div>
                </div>
            </div>
        `;

        // Setup tab switching
        setupTabs();

        // Create charts for Veterans tab (default)
        createRaceChart(properties);
        createVetTotalChart(properties);
        createVetPctAdultChart(properties);
        createVetPer1000Chart(properties);
        createVetMaleChart(properties);
        createVetFemaleChart(properties);
        createVet18_34Chart(properties);
        createVet35_54Chart(properties);
        createVet55_64Chart(properties);
        createVet65PlusChart(properties);
        createVetEmployedChart(properties);
        createVetMedianIncomeChart(properties);
        createVetServiceDisabilityChart(properties);

        // Create charts for Economic tab
        createMedianIncomeChart(properties);
        createBelowPovertyChart(properties);
        createLowIncomeChart(properties);
        createHighIncomeChart(properties);
        createWithInsuranceChart(properties);
        createNoInsuranceChart(properties);
        createSNAPChart(properties);
        createPublicAssistChart(properties);
        createBachelorsPlusChart(properties);
        createLessThanHSChart(properties);
        createLongCommuteChart(properties);
        createNoVehicleChart(properties);

        // Create charts for Housing tab
        createHousingUnitsChart(properties);
        createMedianHomeValueChart(properties);
        createMedianRentChart(properties);
        createOwnerPctChart(properties);
        createRenterPctChart(properties);
        createVacancyRateChart(properties);
        createSingleFamilyPctChart(properties);
        createMultiFamilyChart(properties);
        createRentBurdenRatioChart(properties);
        createPriceIncomeRatioChart(properties);
        createDensityChart(properties);
        createHouseholdSizeChart(properties);
    } else {
        document.getElementById('total-pop-value').innerHTML = `${Number(properties.Total_Population || 0).toLocaleString()} <span class="inline-rank" id="total-pop-rank">${rankings.Total_Population ? `#${rankings.Total_Population}` : ''}</span>`;
        document.getElementById('vet-total-value').innerHTML = `${Number(properties.Vet_Total_Veterans || 0).toLocaleString()} <span class="inline-rank" id="vet-total-rank">${rankings.Vet_Total_Veterans ? `#${rankings.Vet_Total_Veterans}` : ''}</span>`;
        document.getElementById('median-income-value').innerHTML = `$${Number(properties.Median_Household_Income || 0).toLocaleString()} <span class="inline-rank" id="median-income-rank">${rankings.Median_Household_Income ? `#${rankings.Median_Household_Income}` : ''}</span>`;
        createRaceChart(properties);
        createVetTotalChart(properties);
        createVetPctAdultChart(properties);
        createVetPer1000Chart(properties);
        createVetMaleChart(properties);
        createVetFemaleChart(properties);
        createVet18_34Chart(properties);
        createVet35_54Chart(properties);
        createVet55_64Chart(properties);
        createVet65PlusChart(properties);
        createVetEmployedChart(properties);
        createVetMedianIncomeChart(properties);
        createVetServiceDisabilityChart(properties);
        createMedianIncomeChart(properties);
        createBelowPovertyChart(properties);
        createLowIncomeChart(properties);
        createHighIncomeChart(properties);
        createWithInsuranceChart(properties);
        createNoInsuranceChart(properties);
        createSNAPChart(properties);
        createPublicAssistChart(properties);
        createBachelorsPlusChart(properties);
        createLessThanHSChart(properties);
        createLongCommuteChart(properties);
        createNoVehicleChart(properties);
        createHousingUnitsChart(properties);
        createMedianHomeValueChart(properties);
        createMedianRentChart(properties);
        createOwnerPctChart(properties);
        createRenterPctChart(properties);
        createVacancyRateChart(properties);
        createSingleFamilyPctChart(properties);
        createMultiFamilyChart(properties);
        createRentBurdenRatioChart(properties);
        createPriceIncomeRatioChart(properties);
        createDensityChart(properties);
        createHouseholdSizeChart(properties);
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

            // Sync with scatterplots panel tabs
            currentScatterCategory = targetTab;
            const scatterTabButtons = document.querySelectorAll('.scatterplots-tab-btn');
            scatterTabButtons.forEach(btn => {
                if (btn.getAttribute('data-scatter-category') === targetTab) {
                    btn.classList.add('active');
                } else {
                    btn.classList.remove('active');
                }
            });
            showScatterplotsForCategory(targetTab);

            // Re-render veterans charts when veterans tab is activated
            if (targetTab === 'veterans') {
                const currentProperties = window.currentTractProperties || countyTotals;
                createVetTotalChart(currentProperties);
                createVetPctAdultChart(currentProperties);
                createVetPer1000Chart(currentProperties);
                createVetMaleChart(currentProperties);
                createVetFemaleChart(currentProperties);
                createVet18_34Chart(currentProperties);
                createVet35_54Chart(currentProperties);
                createVet55_64Chart(currentProperties);
                createVet65PlusChart(currentProperties);
                createVetEmployedChart(currentProperties);
                createVetMedianIncomeChart(currentProperties);
                createVetServiceDisabilityChart(currentProperties);
            }

            // Re-render economic charts when economic tab is activated
            if (targetTab === 'economic') {
                const currentProperties = window.currentTractProperties || countyTotals;
                createMedianIncomeChart(currentProperties);
                createBelowPovertyChart(currentProperties);
                createLowIncomeChart(currentProperties);
                createHighIncomeChart(currentProperties);
                createWithInsuranceChart(currentProperties);
                createNoInsuranceChart(currentProperties);
                createSNAPChart(currentProperties);
                createPublicAssistChart(currentProperties);
                createBachelorsPlusChart(currentProperties);
                createLessThanHSChart(currentProperties);
                createLongCommuteChart(currentProperties);
                createNoVehicleChart(currentProperties);
            }

            // Re-render housing charts when housing tab is activated
            if (targetTab === 'housing') {
                const currentProperties = window.currentTractProperties || countyTotals;
                createHousingUnitsChart(currentProperties);
                createMedianHomeValueChart(currentProperties);
                createMedianRentChart(currentProperties);
                createOwnerPctChart(currentProperties);
                createRenterPctChart(currentProperties);
                createVacancyRateChart(currentProperties);
                createSingleFamilyPctChart(currentProperties);
                createMultiFamilyChart(currentProperties);
                createRentBurdenRatioChart(currentProperties);
                createPriceIncomeRatioChart(currentProperties);
                createDensityChart(currentProperties);
                createHouseholdSizeChart(currentProperties);
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
    const isCurrencyVariable = property === 'Median_Household_Income' || property === 'Median_Home_Value' || property === 'Median_Gross_Rent' || property === 'Vet_Median_Income_Veteran_Total';
    const isCountVariable = property === 'Vet_Total_Veterans' || property === 'veterans_per_1000_pop' || property === 'Low_Income_Under_35K' || property === 'High_Income_100K_Plus' || property === 'Total_Housing_Units' || property === 'housing_units_per_sqmi' || isCurrencyVariable;

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
    if (chartType === 'veterans') {
        colors = CONFIG.colors.veterans;
    } else if (chartType === 'economic') {
        colors = CONFIG.colors.economic;
    } else if (chartType === 'housing') {
        colors = CONFIG.colors.housing;
    } else if (chartType === 'demographics') {
        colors = CONFIG.colors.economic; // fallback to economic for old demographics
    } else if (chartType === 'health') {
        colors = CONFIG.colors.economic; // fallback to economic for old health
    } else {
        colors = CONFIG.colors.housing; // default
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
    const container = d3.select('#renter-pct-chart');
    const renterPct = properties.Pct_Renter_Occupied || 0;
    createLollipopChart(container, renterPct, 'Pct_Renter_Occupied', 'housing');
}

function createSingleFamilyPctChart(properties) {
    const container = d3.select('#single-family-chart');
    const singlePct = properties.Pct_Single_Family || 0;
    createLollipopChart(container, singlePct, 'Pct_Single_Family', 'housing');
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
    createLollipopChart(container, value, 'Median_Household_Income', 'economic');
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
    const value = parseFloat(properties.Low_Income_Under_35K) || 0;
    createLollipopChart(container, value, 'Low_Income_Under_35K', 'economic');
}

function createHighIncomeChart(properties) {
    const container = d3.select('#high-income-chart');
    const value = parseFloat(properties.High_Income_100K_Plus) || 0;
    createLollipopChart(container, value, 'High_Income_100K_Plus', 'economic');
}

function createBelowPovertyChart(properties) {
    const container = d3.select('#below-poverty-chart');
    const value = parseFloat(properties.Pct_Below_Poverty) || 0;
    createLollipopChart(container, value, 'Pct_Below_Poverty', 'economic');
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
    const isPercentage = config?.type === 'percentage' || config?.type === 'health_percentage';

    // Use category-based colors to match the map
    let colors;
    if (config?.category === 'demographics') {
        colors = CONFIG.colors.demographics;
    } else if (config?.category === 'housing') {
        colors = CONFIG.colors.housing;
    } else if (config?.category === 'health' || config?.type === 'health_percentage') {
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
    if (config?.type === 'health_percentage') {
        // Health values are stored as whole numbers (e.g., 14 for 14%)
        return value.toFixed(0) + '%';
    }
    if (isPercentage) return (value).toFixed(0) + '%';
    if (config?.type === 'currency') {
        return '$' + Math.round(value).toLocaleString();
    }
    if (property && (property.includes('Income') || property.includes('Value') || property.includes('Rent'))) {
        return '$' + Math.round(value).toLocaleString();
    }
    return Math.round(value).toLocaleString();
}

function initializeScatterPlot() {
    scatterPlot = new ScatterPlot('scatter-plot', demographicsData, currentLayer, currentXAxis);

    // Add click handler to sidebar scatter plot for unfreezing when clicking outside bubbles
    setTimeout(() => {
        const sidebarPlotContainer = document.getElementById('scatter-plot');
        if (sidebarPlotContainer) {
            sidebarPlotContainer.addEventListener('click', function(e) {
                // If clicked directly on the container (not on a bubble), unfreeze
                if (e.target === this || e.target.tagName === 'svg') {
                    if (isFrozen) {
                        unfreeze();
                    }
                }
            });
        }
    }, 150);
}

function updateScatterPlot() {
    if (scatterPlot) {
        scatterPlot.updateLayer(currentLayer, currentXAxis);
        const subtitle = document.getElementById('plot-subtitle');
        const xAxisLabel = currentXAxis === 'rank' ? 'Rank' : (layerConfig[currentXAxis]?.label || currentXAxis);
        subtitle.textContent = `${layerConfig[currentLayer]?.label || currentLayer} by ${xAxisLabel}`;
    }
}

function highlightBubbleInAllPlots(geoid) {
    if (!geoid) return;

    // Highlight in sidebar plot
    if (scatterPlot && scatterPlot.highlightBubble) {
        try {
            scatterPlot.highlightBubble(geoid);
        } catch (e) {
            console.warn('Error highlighting in sidebar plot:', e);
        }
    }

    // Highlight in all grid plots
    if (Array.isArray(gridScatterPlots)) {
        gridScatterPlots.forEach(plot => {
            if (plot && plot.highlightBubble) {
                try {
                    plot.highlightBubble(geoid);
                } catch (e) {
                    console.warn('Error highlighting in grid plot:', e);
                }
            }
        });
    }
}

function clearHighlightInAllPlots() {
    // Clear in sidebar plot
    if (scatterPlot && scatterPlot.clearHighlight) {
        try {
            scatterPlot.clearHighlight();
            if (scatterPlot.reorderBubbles) {
                scatterPlot.reorderBubbles();
            }
        } catch (e) {
            console.warn('Error clearing highlight in sidebar plot:', e);
        }
    }

    // Clear in all grid plots
    if (Array.isArray(gridScatterPlots)) {
        gridScatterPlots.forEach(plot => {
            if (plot && plot.clearHighlight) {
                try {
                    plot.clearHighlight();
                    if (plot.reorderBubbles) {
                        plot.reorderBubbles();
                    }
                } catch (e) {
                    console.warn('Error clearing highlight in grid plot:', e);
                }
            }
        });
    }
}

function initializeScatterplotsPanel() {
    // Create all plots once at initialization
    createAllScatterplots();

    // Setup tab switching
    const tabButtons = document.querySelectorAll('.scatterplots-tab-btn');
    tabButtons.forEach(button => {
        button.addEventListener('click', () => {
            const category = button.getAttribute('data-scatter-category');

            // Update active tab in scatterplots panel
            tabButtons.forEach(btn => btn.classList.remove('active'));
            button.classList.add('active');

            // Sync with sidebar tabs
            currentScatterCategory = category;
            const sidebarTabButtons = document.querySelectorAll('.tab-btn');
            const tabPanes = document.querySelectorAll('.tab-pane');

            sidebarTabButtons.forEach(btn => {
                if (btn.getAttribute('data-tab') === category) {
                    btn.classList.add('active');
                } else {
                    btn.classList.remove('active');
                }
            });

            tabPanes.forEach(pane => {
                if (pane.id === `tab-${category}`) {
                    pane.classList.add('active');
                } else {
                    pane.classList.remove('active');
                }
            });

            // Re-render sidebar charts for the selected category
            const currentProperties = window.currentTractProperties || countyTotals;
            if (category === 'veterans') {
                createVetTotalChart(currentProperties);
                createVetPctAdultChart(currentProperties);
                createVetPer1000Chart(currentProperties);
                createVetMaleChart(currentProperties);
                createVetFemaleChart(currentProperties);
                createVet18_34Chart(currentProperties);
                createVet35_54Chart(currentProperties);
                createVet55_64Chart(currentProperties);
                createVet65PlusChart(currentProperties);
                createVetEmployedChart(currentProperties);
                createVetMedianIncomeChart(currentProperties);
                createVetServiceDisabilityChart(currentProperties);
            } else if (category === 'economic') {
                createMedianIncomeChart(currentProperties);
                createBelowPovertyChart(currentProperties);
                createLowIncomeChart(currentProperties);
                createHighIncomeChart(currentProperties);
                createWithInsuranceChart(currentProperties);
                createNoInsuranceChart(currentProperties);
                createSNAPChart(currentProperties);
                createPublicAssistChart(currentProperties);
                createBachelorsPlusChart(currentProperties);
                createLessThanHSChart(currentProperties);
                createLongCommuteChart(currentProperties);
                createNoVehicleChart(currentProperties);
            } else if (category === 'housing') {
                createHousingUnitsChart(currentProperties);
                createMedianHomeValueChart(currentProperties);
                createMedianRentChart(currentProperties);
                createOwnerPctChart(currentProperties);
                createRenterPctChart(currentProperties);
                createVacancyRateChart(currentProperties);
                createSingleFamilyPctChart(currentProperties);
                createMultiFamilyChart(currentProperties);
                createRentBurdenRatioChart(currentProperties);
                createPriceIncomeRatioChart(currentProperties);
                createDensityChart(currentProperties);
                createHouseholdSizeChart(currentProperties);
            }

            // Show/hide scatterplots based on category
            showScatterplotsForCategory(category);
        });
    });

    // Initial visibility
    showScatterplotsForCategory(currentScatterCategory);
}

function createAllScatterplots() {
    const grid = document.querySelector('.scatterplots-grid');
    if (!grid) return;

    // Define variables by category
    const variablesByCategory = {
        veterans: [
            { var: 'Vet_Total_Veterans', label: 'Total Veterans', category: 'veterans' },
            { var: 'Pct_Veterans_Of_Adult_Pop', label: 'Veterans % of Adults', category: 'veterans' },
            { var: 'veterans_per_1000_pop', label: 'Veterans per 1,000 Pop', category: 'veterans' },
            { var: 'Pct_Veterans_Male', label: 'Male Veterans %', category: 'veterans' },
            { var: 'Pct_Veterans_Female', label: 'Female Veterans %', category: 'veterans' },
            { var: 'Pct_Veterans_18_34', label: 'Veterans 18-34 %', category: 'veterans' },
            { var: 'Pct_Veterans_35_54', label: 'Veterans 35-54 %', category: 'veterans' },
            { var: 'Pct_Veterans_55_64', label: 'Veterans 55-64 %', category: 'veterans' },
            { var: 'Pct_Veterans_65_Plus', label: 'Veterans 65+ %', category: 'veterans' },
            { var: 'Pct_Veterans_Employed', label: 'Veterans Employed %', category: 'veterans' },
            { var: 'Vet_Median_Income_Veteran_Total', label: 'Veteran Median Income', category: 'veterans' },
            { var: 'Pct_Vet_With_Service_Disability', label: 'Service-Connected Disability %', category: 'veterans' }
        ],
        economic: [
            { var: 'Median_Household_Income', label: 'Median Household Income', category: 'economic' },
            { var: 'Pct_Below_Poverty', label: 'Below Poverty %', category: 'economic' },
            { var: 'Low_Income_Under_35K', label: 'Low Income (<$35K)', category: 'economic' },
            { var: 'High_Income_100K_Plus', label: 'High Income ($100K+)', category: 'economic' },
            { var: 'Pct_With_Health_Insurance', label: 'With Health Insurance %', category: 'economic' },
            { var: 'Pct_No_Health_Insurance', label: 'Without Health Insurance %', category: 'economic' },
            { var: 'Pct_HH_SNAP', label: 'Households on SNAP %', category: 'economic' },
            { var: 'Pct_HH_Public_Assistance', label: 'Public Assistance %', category: 'economic' },
            { var: 'Pct_Bachelors_Plus', label: 'Bachelor\'s Degree+ %', category: 'economic' },
            { var: 'Pct_Less_Than_HS', label: 'Less than High School %', category: 'economic' },
            { var: 'Pct_With_Disability', label: 'With Disability %', category: 'economic' },
            { var: 'Pct_HH_No_Vehicle', label: 'No Vehicle %', category: 'economic' }
        ],
        housing: [
            { var: 'Total_Housing_Units', label: 'Total Housing Units', category: 'housing' },
            { var: 'Median_Home_Value', label: 'Median Home Value', category: 'housing' },
            { var: 'Median_Gross_Rent', label: 'Median Gross Rent', category: 'housing' },
            { var: 'Pct_Owner_Occupied', label: 'Owner-Occupied %', category: 'housing' },
            { var: 'Pct_Renter_Occupied', label: 'Renter-Occupied %', category: 'housing' },
            { var: 'Pct_Vacant', label: 'Vacancy Rate %', category: 'housing' },
            { var: 'Pct_Single_Family', label: 'Single-Family %', category: 'housing' },
            { var: 'Pct_Multi_Family_5_Plus', label: 'Multi-Family 5+ %', category: 'housing' },
            { var: 'Pct_All_HH_Cost_Burdened_30_Plus', label: 'Cost-Burdened 30%+ %', category: 'housing' },
            { var: 'Pct_All_HH_Overcrowded', label: 'Overcrowded %', category: 'housing' },
            { var: 'housing_units_per_sqmi', label: 'Housing Density (per sq mi)', category: 'housing' },
            { var: 'Avg_Household_Size', label: 'Avg Household Size', category: 'housing' }
        ]
    };

    // Clear existing content and plots
    grid.innerHTML = '';
    gridScatterPlots = [];

    // Get x-axis label
    const xAxisLabel = currentXAxis === 'rank' ? 'Rank' : (layerConfig[currentXAxis]?.label || currentXAxis);

    // Create ALL scatterplots from all categories
    let plotIndex = 0;
    Object.keys(variablesByCategory).forEach(category => {
        variablesByCategory[category].forEach((varConfig) => {
            const item = document.createElement('div');
            item.className = 'scatterplot-item';
            item.setAttribute('data-category', varConfig.category);

            const title = document.createElement('div');
            title.className = 'scatterplot-item-title';
            title.textContent = `${varConfig.label} vs ${xAxisLabel}`;

            const container = document.createElement('div');
            container.className = 'scatterplot-item-container';
            container.id = `scatterplot-grid-${plotIndex}`;

            item.appendChild(title);
            item.appendChild(container);
            grid.appendChild(item);

            // Create the scatter plot instance and store it with category info
            const plot = new ScatterPlot(`scatterplot-grid-${plotIndex}`, demographicsData, varConfig.var, currentXAxis);
            plot.category = varConfig.category;
            plot.varConfig = varConfig;
            plot.titleElement = title;
            gridScatterPlots.push(plot);

            // Add click handler for unfreezing when clicking outside bubbles
            container.addEventListener('click', function(e) {
                if (e.target === this || e.target.tagName === 'svg') {
                    if (isFrozen) {
                        unfreeze();
                    }
                }
            });

            plotIndex++;
        });
    });

    // If there's a frozen selection, restore it in all plots
    if (isFrozen && currentHoveredFeature) {
        setTimeout(() => {
            highlightBubbleInAllPlots(currentHoveredFeature);
        }, 100);
    }
}

function showScatterplotsForCategory(category) {
    const items = document.querySelectorAll('.scatterplot-item');
    items.forEach(item => {
        if (item.getAttribute('data-category') === category) {
            item.style.display = 'flex';
        } else {
            item.style.display = 'none';
        }
    });
}

function updateScatterplotsXAxis() {
    // Get x-axis label
    const xAxisLabel = currentXAxis === 'rank' ? 'Rank' : (layerConfig[currentXAxis]?.label || currentXAxis);

    // Update all plots with new x-axis
    gridScatterPlots.forEach(plot => {
        if (plot && plot.updateLayer) {
            plot.updateLayer(plot.currentLayer, currentXAxis);
            // Update title
            if (plot.titleElement && plot.varConfig) {
                plot.titleElement.textContent = `${plot.varConfig.label} vs ${xAxisLabel}`;
            }
        }
    });

    // If there's a frozen selection, restore it
    if (isFrozen && currentHoveredFeature) {
        setTimeout(() => {
            highlightBubbleInAllPlots(currentHoveredFeature);
        }, 100);
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
        
        // Get the proper formatting based on variable type
        const xConfig = layerConfig[xProperty];
        let xFormat;
        if (xProperty === 'rank') {
            xFormat = d3.format('d');
        } else if (xConfig?.type === 'percentage' || xConfig?.type === 'health_percentage') {
            // Data is already in 0-100 format, just add %
            xFormat = d => d3.format('.0f')(d) + '%';
        } else if (xConfig?.type === 'currency') {
            xFormat = d => '$' + d3.format(',.0f')(d);
        } else {
            xFormat = d3.format(',');
        }
        this.xAxis.transition().duration(500).call(d3.axisBottom(this.xScale).tickFormat(xFormat).ticks(4))
            .selectAll('text').style('font-size', '7px');

        const yConfig = layerConfig[yProperty];
        let yFormat;
        if (yConfig?.type === 'percentage' || yConfig?.type === 'health_percentage') {
            // Data is already in 0-100 format, just add %
            yFormat = d => d3.format('.0f')(d) + '%';
        } else if (yConfig?.type === 'currency') {
            yFormat = d => '$' + d3.format(',.0f')(d);
        } else {
            yFormat = d3.format(',');
        }
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
            // Clicking the same frozen bubble unfreezes
            unfreeze();
        } else {
            // Clicking a different bubble (whether frozen or not)
            const feature = demographicsData.features.find(f => f.properties.GEOID === data.GEOID);
            if (feature) {
                // If already frozen on another bubble, clear all highlights first
                if (isFrozen) {
                    clearHighlightInAllPlots();
                    clearMapHighlight();
                    isFrozen = false;
                    currentHoveredFeature = null;
                }
                // Then freeze on the new bubble
                freeze(data);
                zoomToTract(feature);
                // Ensure highlights are applied to all plots
                setTimeout(() => {
                    highlightBubbleInAllPlots(data.GEOID);
                }, 50);
            }
        }
    }
    
    handleBubbleHover(data) {
        if (isFrozen) return;
        // Highlight in this plot
        this.g.selectAll('.scatter-circle').classed('highlighted', false);
        this.g.selectAll('.scatter-circle').filter(d => d.GEOID === data.GEOID)
            .classed('highlighted', true).raise();

        // Highlight in all other plots
        highlightBubbleInAllPlots(data.GEOID);

        updateTractDetails(data);
        currentHoveredFeature = data.GEOID;
        highlightMapFeature(data.GEOID);
    }

    handleBubbleLeave() {
        if (isFrozen) return;
        this.clearHighlight();
        clearHighlightInAllPlots();
        showCountyTotals();
        clearMapHighlight();
        currentHoveredFeature = null;
        this.reorderBubbles();
    }
    
    highlightBubble(geoid) {
        if (!this.g || !geoid) return;
        try {
            this.g.selectAll('.scatter-circle').classed('highlighted', false);
            this.g.selectAll('.scatter-circle').filter(d => d && d.GEOID === geoid)
                .classed('highlighted', true).raise();
        } catch (e) {
            console.warn('Error in highlightBubble:', e);
        }
    }

    clearHighlight() {
        if (!this.g) return;
        try {
            this.g.selectAll('.scatter-circle').classed('highlighted', false);
        } catch (e) {
            console.warn('Error in clearHighlight:', e);
        }
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

// Veterans charts
function createVetTotalChart(properties) {
    const container = d3.select('#vet-total-chart');
    const value = parseFloat(properties.Vet_Total_Veterans) || 0;
    createLollipopChart(container, value, 'Vet_Total_Veterans', 'veterans');
}

function createVetPctAdultChart(properties) {
    const container = d3.select('#vet-pct-adult-chart');
    const value = parseFloat(properties.Pct_Veterans_Of_Adult_Pop) || 0;
    createLollipopChart(container, value, 'Pct_Veterans_Of_Adult_Pop', 'veterans');
}

function createVetPer1000Chart(properties) {
    const container = d3.select('#vet-per-1000-chart');
    const value = parseFloat(properties.veterans_per_1000_pop) || 0;
    createLollipopChart(container, value, 'veterans_per_1000_pop', 'veterans');
}

function createVetMaleChart(properties) {
    const container = d3.select('#vet-male-chart');
    const value = parseFloat(properties.Pct_Veterans_Male) || 0;
    createLollipopChart(container, value, 'Pct_Veterans_Male', 'veterans');
}

function createVetFemaleChart(properties) {
    const container = d3.select('#vet-female-chart');
    const value = parseFloat(properties.Pct_Veterans_Female) || 0;
    createLollipopChart(container, value, 'Pct_Veterans_Female', 'veterans');
}

function createVet18_34Chart(properties) {
    const container = d3.select('#vet-18-34-chart');
    const value = parseFloat(properties.Pct_Veterans_18_34) || 0;
    createLollipopChart(container, value, 'Pct_Veterans_18_34', 'veterans');
}

function createVet35_54Chart(properties) {
    const container = d3.select('#vet-35-54-chart');
    const value = parseFloat(properties.Pct_Veterans_35_54) || 0;
    createLollipopChart(container, value, 'Pct_Veterans_35_54', 'veterans');
}

function createVet55_64Chart(properties) {
    const container = d3.select('#vet-55-64-chart');
    const value = parseFloat(properties.Pct_Veterans_55_64) || 0;
    createLollipopChart(container, value, 'Pct_Veterans_55_64', 'veterans');
}

function createVet65PlusChart(properties) {
    const container = d3.select('#vet-65-plus-chart');
    const value = parseFloat(properties.Pct_Veterans_65_Plus) || 0;
    createLollipopChart(container, value, 'Pct_Veterans_65_Plus', 'veterans');
}

function createVetEmployedChart(properties) {
    const container = d3.select('#vet-employed-chart');
    const value = parseFloat(properties.Pct_Veterans_Employed) || 0;
    createLollipopChart(container, value, 'Pct_Veterans_Employed', 'veterans');
}

function createVetUnemployedChart(properties) {
    const container = d3.select('#vet-unemployed-chart');
    const value = parseFloat(properties.Pct_Veterans_Unemployed) || 0;
    createLollipopChart(container, value, 'Pct_Veterans_Unemployed', 'veterans');
}

function createVetMedianIncomeChart(properties) {
    const container = d3.select('#vet-median-income-chart');
    const value = parseFloat(properties.Vet_Median_Income_Veteran_Total) || 0;
    createLollipopChart(container, value, 'Vet_Median_Income_Veteran_Total', 'veterans');
}

function createVetServiceDisabilityChart(properties) {
    const container = d3.select('#vet-service-disability-chart');
    const value = parseFloat(properties.Pct_Vet_With_Service_Disability) || 0;
    createLollipopChart(container, value, 'Pct_Vet_With_Service_Disability', 'veterans');
}

// Economic Security charts
function createWithInsuranceChart(properties) {
    const container = d3.select('#with-insurance-chart');
    const value = parseFloat(properties.Pct_With_Health_Insurance) || 0;
    createLollipopChart(container, value, 'Pct_With_Health_Insurance', 'economic');
}

function createNoInsuranceChart(properties) {
    const container = d3.select('#no-insurance-chart');
    const value = parseFloat(properties.Pct_No_Health_Insurance) || 0;
    createLollipopChart(container, value, 'Pct_No_Health_Insurance', 'economic');
}

function createSNAPChart(properties) {
    const container = d3.select('#snap-chart');
    const value = parseFloat(properties.Pct_HH_SNAP) || 0;
    createLollipopChart(container, value, 'Pct_HH_SNAP', 'economic');
}

function createPublicAssistChart(properties) {
    const container = d3.select('#public-assist-chart');
    const value = parseFloat(properties.Pct_HH_Public_Assistance) || 0;
    createLollipopChart(container, value, 'Pct_HH_Public_Assistance', 'economic');
}

function createBachelorsPlusChart(properties) {
    const container = d3.select('#bachelors-plus-chart');
    const value = parseFloat(properties.Pct_Bachelors_Plus) || 0;
    createLollipopChart(container, value, 'Pct_Bachelors_Plus', 'economic');
}

function createLessThanHSChart(properties) {
    const container = d3.select('#less-than-hs-chart');
    const value = parseFloat(properties.Pct_Less_Than_HS) || 0;
    createLollipopChart(container, value, 'Pct_Less_Than_HS', 'economic');
}

function createLongCommuteChart(properties) {
    const container = d3.select('#long-commute-chart');
    const value = parseFloat(properties.Pct_Commute_60_Plus) || 0;
    createLollipopChart(container, value, 'Pct_Commute_60_Plus', 'economic');
}

function createNoVehicleChart(properties) {
    const container = d3.select('#no-vehicle-chart');
    const value = parseFloat(properties.Pct_HH_No_Vehicle) || 0;
    createLollipopChart(container, value, 'Pct_HH_No_Vehicle', 'economic');
}

// Housing charts
function createHousingUnitsChart(properties) {
    const container = d3.select('#housing-units-chart');
    const value = parseFloat(properties.Total_Housing_Units) || 0;
    createLollipopChart(container, value, 'Total_Housing_Units', 'housing');
}

function createOwnerPctChart(properties) {
    const container = d3.select('#owner-pct-chart');
    const value = parseFloat(properties.Pct_Owner_Occupied) || 0;
    createLollipopChart(container, value, 'Pct_Owner_Occupied', 'housing');
}

function createVacancyRateChart(properties) {
    const container = d3.select('#vacancy-rate-chart');
    const value = parseFloat(properties.Pct_Vacant) || 0;
    createLollipopChart(container, value, 'Pct_Vacant', 'housing');
}

function createMultiFamilyChart(properties) {
    const container = d3.select('#multi-family-chart');
    const value = parseFloat(properties.Pct_Multi_Family_5_Plus) || 0;
    createLollipopChart(container, value, 'Pct_Multi_Family_5_Plus', 'housing');
}

function createRentBurdenRatioChart(properties) {
    const container = d3.select('#rent-burden-ratio-chart');
    const value = parseFloat(properties.Rent_Burden_Ratio) || 0;
    createLollipopChart(container, value, 'Rent_Burden_Ratio', 'housing');
}

function createPriceIncomeRatioChart(properties) {
    const container = d3.select('#price-income-ratio-chart');
    const value = parseFloat(properties.Price_To_Income_Ratio) || 0;
    createLollipopChart(container, value, 'Price_To_Income_Ratio', 'housing');
}

function createDensityChart(properties) {
    const container = d3.select('#density-chart');
    const value = parseFloat(properties.housing_units_per_sqmi) || 0;
    createLollipopChart(container, value, 'housing_units_per_sqmi', 'housing');
}

function createHouseholdSizeChart(properties) {
    const container = d3.select('#household-size-chart');
    const value = parseFloat(properties.Avg_Household_Size) || 0;
    createLollipopChart(container, value, 'Avg_Household_Size', 'housing');
}