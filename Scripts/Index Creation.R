################################################################################
# COOK COUNTY COMPOSITE INDICES ANALYSIS
# 
# This script creates three composite indices:
# 1. Housing Instability Index
# 2. Veteran Healthcare Desert Index
# 3. Family Housing-Opportunity Index
#
# Author: Generated for Cook County Housing Analysis
# Date: 2025-10-31
################################################################################

# Load Required Libraries ------------------------------------------------------
library(tidyverse)      # Data manipulation and visualization
library(sf)             # Spatial data handling
library(scales)         # Number formatting
library(corrplot)       # Correlation visualization
library(psych)          # Factor analysis and PCA
library(ggplot2)        # Advanced plotting
library(viridis)        # Color scales
library(patchwork)      # Combining plots

# Set options
options(scipen = 999)  # Disable scientific notation

# Load Data --------------------------------------------------------------------
cat("Loading Cook County ACS data...\n")

# Define data directory (adjust if needed)
data_dir <- "C:/Users/RichardCarder/Documents/dev/Cook-County-Veterans/Output Data"

# Load CSV data
acs_data <- read_csv(file.path(data_dir, "Cook_County_Housing_Veterans_Tract_2023.csv"))

# Load spatial data
acs_spatial <- st_read(file.path(data_dir, "Cook_County_Housing_Veterans_Tract_2023.geojson"), 
                       quiet = TRUE)

cat(sprintf("Loaded %d census tracts\n", nrow(acs_data)))
cat(sprintf("Variables available: %d\n", ncol(acs_data)))

# Data Overview ----------------------------------------------------------------
cat("\n=== DATA STRUCTURE ===\n")
str(acs_data, list.len = 10)

# Check for missing values
missing_summary <- acs_data %>%
  summarise(across(everything(), ~sum(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "missing_count") %>%
  filter(missing_count > 0) %>%
  arrange(desc(missing_count))

if(nrow(missing_summary) > 0) {
  cat("\nVariables with missing values:\n")
  print(missing_summary, n = 20)
}


################################################################################
# INDEX 1: HOUSING INSTABILITY INDEX
################################################################################

cat("\n\n=== BUILDING HOUSING INSTABILITY INDEX ===\n")

# This index measures housing insecurity through three dimensions:
# 1. Affordability Crisis - how much of income goes to housing
# 2. Residential Instability - turnover and tenure patterns
# 3. Economic Vulnerability - poverty and economic stress

housing_instability <- acs_data %>%
  mutate(
    # -------------------------------------------------------------------------
    # DIMENSION 1: AFFORDABILITY CRISIS
    # -------------------------------------------------------------------------
    
    # Rent burden (primary indicator)
    rent_burden_severe = High_Rent_Burden_50_Plus_Units,
    
    # Rent-to-income ratio (contextualize rent levels)
    rent_income_ratio = ifelse(Median_Household_Income > 0,
                               (Median_Gross_Rent * 12) / Median_Household_Income,
                               NA),
    
    # SNAP usage (economic desperation)
    snap_rate = Pct_HH_SNAP,
    
    # Create normalized affordability score (0-100, higher = worse)
    affordability_score = (
      0.4 * percent_rank(rent_burden_severe) * 100 +
        0.3 * percent_rank(rent_income_ratio) * 100 +
        0.3 * percent_rank(snap_rate) * 100
    ),
    
    # -------------------------------------------------------------------------
    # DIMENSION 2: RESIDENTIAL INSTABILITY  
    # -------------------------------------------------------------------------
    
    # Recent moves (proxy for instability)
    recent_move_rate = Moved_In_2020_Later / Total_Occupied_Units * 100,
    
    # Renter concentration (renters more vulnerable to displacement)
    renter_rate = Pct_Renter_Occupied,
    
    # Create normalized instability score (0-100, higher = worse)
    instability_score = (
      0.5 * percent_rank(recent_move_rate) * 100 +
        0.5 * percent_rank(renter_rate) * 100
    ),
    
    # -------------------------------------------------------------------------
    # DIMENSION 3: ECONOMIC VULNERABILITY
    # -------------------------------------------------------------------------
    
    # Overall poverty rate
    poverty_rate = Pct_Below_Poverty,
    
    # Child poverty (children especially vulnerable)
    child_poverty_rate = ifelse(Children_Total > 0,
                                Children_Below_Poverty / Children_Total * 100,
                                NA),
    
    # Single mother families (highest risk of housing instability)
    single_mother_rate = ifelse(Family_Households > 0,
                                Children_In_Single_Mother_Families / Family_Households * 100,
                                NA),
    
    # Create normalized vulnerability score (0-100, higher = worse)
    vulnerability_score = (
      0.4 * percent_rank(poverty_rate) * 100 +
        0.3 * percent_rank(child_poverty_rate) * 100 +
        0.3 * percent_rank(single_mother_rate) * 100
    ),
    
    # -------------------------------------------------------------------------
    # COMPOSITE HOUSING INSTABILITY INDEX
    # -------------------------------------------------------------------------
    
    # Equal weighting of three dimensions (can adjust based on priorities)
    housing_instability_index = (
      affordability_score + 
        instability_score + 
        vulnerability_score
    ) / 3,
    
    # Create risk categories
    instability_category = case_when(
      housing_instability_index >= 75 ~ "Very High Risk",
      housing_instability_index >= 50 ~ "High Risk",
      housing_instability_index >= 25 ~ "Moderate Risk",
      TRUE ~ "Lower Risk"
    )
  )




# Summary Statistics
cat("\nHousing Instability Index Summary:\n")
summary(housing_instability$housing_instability_index)

cat("\nRisk Category Distribution:\n")
table(housing_instability$instability_category)

# Correlation between dimensions
cat("\nCorrelation between index dimensions:\n")
dimension_cors <- housing_instability %>%
  select(affordability_score, instability_score, vulnerability_score) %>%
  cor(use = "complete.obs")
print(round(dimension_cors, 3))

# *** DATA ENHANCEMENT OPPORTUNITY #1: EVICTION DATA ***
cat("\n*** DATA ENHANCEMENT OPPORTUNITY #1 ***")
cat("\nEVICTION DATA would dramatically improve this index:")
cat("\n  - Source: Princeton Eviction Lab (https://evictionlab.org/get-the-data/)")
cat("\n  - Variables: Eviction filing rate, eviction judgment rate")
cat("\n  - Geographic level: Census tract")
cat("\n  - How to add: Download tract-level data, join by GEOID")
cat("\n  - Impact: Direct measure of housing instability vs. proxies")
cat("\n\n  Implementation:")
cat("\n  eviction_data <- read_csv('eviction_lab_cook_county.csv')")
cat("\n  housing_instability <- left_join(housing_instability, eviction_data, by = 'GEOID')")
cat("\n  # Add eviction rate to instability_score with 0.4 weight\n\n")


################################################################################
# INDEX 2: VETERAN HEALTHCARE DESERT INDEX  
################################################################################

cat("\n\n=== BUILDING VETERAN HEALTHCARE DESERT INDEX ===\n")

veteran_healthcare <- acs_data %>%
  mutate(
    # -------------------------------------------------------------------------
    # DIMENSION 1: VETERAN POPULATION & NEEDS
    # -------------------------------------------------------------------------
    
    # Veteran concentration
    veteran_density = Vet_Total_Veterans / Total_Population * 100,
    
    # Veterans with disabilities (higher healthcare needs)
    veteran_disability_rate = Pct_Veterans_With_Service_Disability,
    
    # Veteran unemployment (correlates with healthcare access issues)
    veteran_unemployment_rate = Pct_Veterans_Unemployed,
    
    # Create normalized needs score (0-100, higher = more need)
    veteran_needs_score = (
      0.4 * percent_rank(veteran_density) * 100 +
        0.3 * percent_rank(veteran_disability_rate) * 100 +
        0.3 * percent_rank(veteran_unemployment_rate) * 100
    ),
    
    # -------------------------------------------------------------------------
    # DIMENSION 2: VA HEALTHCARE COVERAGE GAP
    # -------------------------------------------------------------------------
    
    # Gap between veterans and VA coverage
    va_coverage_gap = ifelse(veteran_density > 0,
                             100 - Pct_With_VA_HealthCare - Pct_With_TRICARE,
                             NA),
    
    # General uninsured rate (context)
    uninsured_rate = Pct_No_Health_Insurance,
    
    # Create normalized coverage gap score (0-100, higher = bigger gap)
    coverage_gap_score = (
      0.6 * percent_rank(va_coverage_gap) * 100 +
        0.4 * percent_rank(uninsured_rate) * 100
    ),
    
    # -------------------------------------------------------------------------
    # DIMENSION 3: TRANSPORTATION BARRIERS
    # -------------------------------------------------------------------------
    
    # Households without vehicles
    no_vehicle_rate = Pct_HH_No_Vehicle,
    
    # Long commute as proxy for distance from services
    long_commute_rate = Pct_Commute_60_Plus,
    
    # Low income (can't afford transportation)
    low_income_indicator = ifelse(Median_Household_Income < median(Median_Household_Income, na.rm = TRUE),
                                  100, 0),
    
    # Create normalized transportation barrier score (0-100, higher = worse)
    transport_barrier_score = (
      0.4 * percent_rank(no_vehicle_rate) * 100 +
        0.3 * percent_rank(long_commute_rate) * 100 +
        0.3 * low_income_indicator
    ),
    
    # -------------------------------------------------------------------------
    # COMPOSITE VETERAN HEALTHCARE DESERT INDEX
    # -------------------------------------------------------------------------
    
    # Weighted combination (only where veterans exist)
    veteran_healthcare_desert_index = ifelse(
      Vet_Total_Veterans > 10,  # Only calculate for tracts with meaningful veteran population
      (
        0.3 * veteran_needs_score +
          0.4 * coverage_gap_score +
          0.3 * transport_barrier_score
      ),
      NA
    ),
    
    # Create risk categories
    veteran_desert_category = case_when(
      is.na(veteran_healthcare_desert_index) ~ "Insufficient Veterans",
      veteran_healthcare_desert_index >= 75 ~ "Critical Desert",
      veteran_healthcare_desert_index >= 50 ~ "Healthcare Desert",
      veteran_healthcare_desert_index >= 25 ~ "Moderate Access",
      TRUE ~ "Good Access"
    )
  )

# Summary Statistics
cat("\nVeteran Healthcare Desert Index Summary:\n")
cat(sprintf("Tracts with sufficient veteran population: %d\n", 
            sum(!is.na(veteran_healthcare$veteran_healthcare_desert_index))))
summary(veteran_healthcare$veteran_healthcare_desert_index)

cat("\nAccess Category Distribution:\n")
table(veteran_healthcare$veteran_desert_category)

# *** DATA ENHANCEMENT OPPORTUNITY #2: VA FACILITY LOCATIONS ***
cat("\n*** DATA ENHANCEMENT OPPORTUNITY #2 ***")
cat("\nVA FACILITY LOCATION DATA would complete this index:")
cat("\n  - Source: VA Facility Locator API (https://developer.va.gov/)")
cat("\n  - Or: VA.gov facility directory download")
cat("\n  - Variables needed: Facility locations, types (Medical Center vs CBOC)")
cat("\n  - Processing: Calculate network distance from each tract centroid")
cat("\n\n  Implementation using VA API:")
cat("\n  library(httr)")
cat("\n  va_facilities <- GET('https://api.va.gov/services/va_facilities/v0/facilities/all')")
cat("\n  va_data <- content(va_facilities) %>% filter(state == 'IL')")
cat("\n  # Calculate distances using osrm or r5r package")
cat("\n\n  Or manual download:")
cat("\n  1. Visit: https://www.va.gov/find-locations/")
cat("\n  2. Export facilities in Illinois")
cat("\n  3. Geocode addresses if needed")
cat("\n  4. Calculate distance using sf::st_distance()\n")

cat("\n*** DATA ENHANCEMENT OPPORTUNITY #3: TRANSIT DATA ***")
cat("\nTRANSIT ACCESSIBILITY DATA would improve transportation dimension:")
cat("\n  - Source: Chicago Transit Authority GTFS (https://www.transitchicago.com/developers/gtfs/)")
cat("\n  - Also: Metra and Pace GTFS feeds")
cat("\n  - Processing: Calculate service frequency, stops per area, coverage")
cat("\n  - Package: Use 'tidytransit' R package to process GTFS")
cat("\n\n  Implementation:")
cat("\n  library(tidytransit)")
cat("\n  cta_gtfs <- read_gtfs('google_transit.zip')")
cat("\n  # Calculate stops per square mile, frequency, service hours per tract\n\n")


################################################################################
# INDEX 3: FAMILY HOUSING-OPPORTUNITY INDEX
################################################################################

cat("\n\n=== BUILDING FAMILY HOUSING-OPPORTUNITY INDEX ===\n")

family_opportunity <- acs_data %>%
  mutate(
    # -------------------------------------------------------------------------
    # DIMENSION 1: FAMILY-SIZED HOUSING AVAILABILITY
    # -------------------------------------------------------------------------
    
    # 3+ bedroom units
    large_unit_rate = Three_Plus_Bedroom_Units / Total_Housing_Units * 100,
    
    # Owner-occupied (stability for families)
    owner_rate = Pct_Owner_Occupied,
    
    # Affordable large units (rent for 3BR relative to income)
    # Note: This is approximate since we don't have 3BR-specific rent
    housing_affordability = ifelse(Median_Household_Income > 0,
                                   100 - ((Median_Gross_Rent * 12) / Median_Household_Income * 100),
                                   NA),
    
    # Create normalized housing supply score (0-100, higher = better)
    housing_supply_score = (
      0.4 * percent_rank(large_unit_rate) * 100 +
        0.3 * percent_rank(owner_rate) * 100 +
        0.3 * percent_rank(housing_affordability) * 100
    ),
    
    # -------------------------------------------------------------------------
    # DIMENSION 2: ECONOMIC OPPORTUNITY ACCESS
    # -------------------------------------------------------------------------
    
    # Short commutes (proxy for job proximity)
    short_commute_rate = 100 - Pct_Commute_60_Plus,
    
    # Work from home capability (flexibility)
    wfh_rate = Pct_Work_At_Home,
    
    # Income level (proxy for job quality)
    income_percentile = percent_rank(Median_Household_Income) * 100,
    
    # Create normalized opportunity access score (0-100, higher = better)
    opportunity_access_score = (
      0.4 * percent_rank(short_commute_rate) * 100 +
        0.3 * percent_rank(wfh_rate) * 100 +
        0.3 * income_percentile
    ),
    
    # -------------------------------------------------------------------------
    # DIMENSION 3: FAMILY WELLBEING INDICATORS
    # -------------------------------------------------------------------------
    
    # Education levels (proxy for good schools/educated neighbors)
    education_rate = Pct_Bachelors_Plus,
    
    # Low child poverty
    low_child_poverty = ifelse(Children_Total > 0,
                               100 - (Children_Below_Poverty / Children_Total * 100),
                               NA),
    
    # Health insurance for children
    insured_rate = 100 - Pct_No_Health_Insurance,
    
    # Create normalized wellbeing score (0-100, higher = better)
    wellbeing_score = (
      0.4 * percent_rank(education_rate) * 100 +
        0.3 * percent_rank(low_child_poverty) * 100 +
        0.3 * percent_rank(insured_rate) * 100
    ),
    
    # -------------------------------------------------------------------------
    # COMPOSITE FAMILY HOUSING-OPPORTUNITY INDEX
    # -------------------------------------------------------------------------
    
    # Higher scores = better places for families
    family_opportunity_index = (
      0.35 * housing_supply_score +
        0.35 * opportunity_access_score +
        0.30 * wellbeing_score
    ),
    
    # Identify mismatches: lots of family housing but low opportunity
    housing_opportunity_mismatch = case_when(
      large_unit_rate >= median(large_unit_rate, na.rm = TRUE) & 
        opportunity_access_score < 40 ~ "High Housing, Low Opportunity",
      large_unit_rate < median(large_unit_rate, na.rm = TRUE) & 
        opportunity_access_score >= 60 ~ "Low Housing, High Opportunity",
      TRUE ~ "Matched"
    ),
    
    # Create quintile categories
    family_opportunity_quintile = ntile(family_opportunity_index, 5),
    family_opportunity_category = case_when(
      family_opportunity_quintile == 5 ~ "Excellent",
      family_opportunity_quintile == 4 ~ "Good",
      family_opportunity_quintile == 3 ~ "Moderate",
      family_opportunity_quintile == 2 ~ "Limited",
      family_opportunity_quintile == 1 ~ "Poor",
      TRUE ~ NA_character_
    )
  )

# Summary Statistics
cat("\nFamily Housing-Opportunity Index Summary:\n")
summary(family_opportunity$family_opportunity_index)

cat("\nOpportunity Category Distribution:\n")
table(family_opportunity$family_opportunity_category)

cat("\nHousing-Opportunity Mismatch:\n")
table(family_opportunity$housing_opportunity_mismatch)

# *** DATA ENHANCEMENT OPPORTUNITY #4: JOB LOCATION DATA ***
cat("\n*** DATA ENHANCEMENT OPPORTUNITY #4 ***")
cat("\nJOB LOCATION DATA would transform opportunity measurement:")
cat("\n  - Source: LEHD LODES (Longitudinal Employer-Household Dynamics)")
cat("\n  - URL: https://lehd.ces.census.gov/data/")
cat("\n  - Files needed: WAC (Workplace Area Characteristics) for Cook County")
cat("\n  - Variables: Job counts by census block, wage levels, industry")
cat("\n\n  Implementation:")
cat("\n  # Download from https://lehd.ces.census.gov/data/lodes/LODES7/")
cat("\n  lodes <- read_csv('il_wac_S000_JT00_2021.csv.gz')")
cat("\n  # Aggregate blocks to tracts, calculate job density")
cat("\n  # Use gravity model to calculate job accessibility\n")

cat("\n*** DATA ENHANCEMENT OPPORTUNITY #5: SCHOOL QUALITY DATA ***")
cat("\nSCHOOL QUALITY DATA would improve family wellbeing dimension:")
cat("\n  - Source: Great Schools API or Illinois Report Card")
cat("\n  - URL: https://www.greatschools.org/api/ or https://www.illinoisreportcard.com/")
cat("\n  - Variables: Test scores, ratings, graduation rates")
cat("\n  - Processing: Geocode schools, assign to census tracts")
cat("\n\n  Implementation:")
cat("\n  library(httr)")
cat("\n  # GreatSchools API requires key")
cat("\n  schools <- GET('https://api.greatschools.org/schools/IL/Chicago')")
cat("\n  # Or scrape Illinois Report Card")
cat("\n  # Spatial join schools to tracts\n\n")


################################################################################
# COMBINE ALL INDICES
################################################################################

cat("\n\n=== CREATING MASTER DATASET ===\n")

# Combine all indices
master_indices <- housing_instability %>%
  select(GEOID, NAME, 
         # Housing Instability components
         affordability_score, instability_score, vulnerability_score,
         housing_instability_index, instability_category,
         # Raw variables for reference
         rent_burden_severe, recent_move_rate, poverty_rate) %>%
  left_join(
    veteran_healthcare %>%
      select(GEOID,
             veteran_needs_score, coverage_gap_score, transport_barrier_score,
             veteran_healthcare_desert_index, veteran_desert_category,
             veteran_density, Vet_Total_Veterans),
    by = "GEOID"
  ) %>%
  left_join(
    family_opportunity %>%
      select(GEOID,
             housing_supply_score, opportunity_access_score, wellbeing_score,
             family_opportunity_index, family_opportunity_category,
             housing_opportunity_mismatch, large_unit_rate),
    by = "GEOID"
  )

cat(sprintf("Master index dataset created with %d tracts\n", nrow(master_indices)))


################################################################################
# VALIDATION & DIAGNOSTICS
################################################################################

cat("\n\n=== INDEX VALIDATION ===\n")

# 1. Check index distributions
cat("\n1. Index Distribution Statistics:\n")
index_vars <- c("housing_instability_index", 
                "veteran_healthcare_desert_index", 
                "family_opportunity_index")

for(idx in index_vars) {
  cat(sprintf("\n%s:\n", idx))
  print(summary(master_indices[[idx]]))
}

# 2. Check for extreme outliers
cat("\n2. Extreme Values (top/bottom 5):\n")
cat("\nMost Housing Unstable Tracts:\n")
master_indices %>%
  arrange(desc(housing_instability_index)) %>%
  select(NAME, housing_instability_index, poverty_rate, rent_burden_severe) %>%
  head(5) %>%
  print()

cat("\nMost Severe Veteran Healthcare Deserts:\n")
master_indices %>%
  filter(!is.na(veteran_healthcare_desert_index)) %>%
  arrange(desc(veteran_healthcare_desert_index)) %>%
  select(NAME, veteran_healthcare_desert_index, veteran_density, Vet_Total_Veterans) %>%
  head(5) %>%
  print()

cat("\nBest Family Opportunity Areas:\n")
master_indices %>%
  arrange(desc(family_opportunity_index)) %>%
  select(NAME, family_opportunity_index, family_opportunity_category) %>%
  head(5) %>%
  print()

# 3. Correlation matrix of main indices
cat("\n3. Correlation Between Indices:\n")
index_correlations <- master_indices %>%
  select(housing_instability_index, 
         veteran_healthcare_desert_index, 
         family_opportunity_index) %>%
  cor(use = "complete.obs")
print(round(index_correlations, 3))


################################################################################
# VISUALIZATIONS
################################################################################

cat("\n\n=== CREATING VISUALIZATIONS ===\n")

# Create output directory
dir.create("outputs/indices", recursive = TRUE, showWarnings = FALSE)

# 1. Housing Instability Distribution
p1 <- ggplot(master_indices, aes(x = housing_instability_index)) +
  geom_histogram(bins = 30, fill = "steelblue", alpha = 0.7) +
  geom_vline(xintercept = c(25, 50, 75), linetype = "dashed", color = "red") +
  labs(title = "Distribution of Housing Instability Index",
       subtitle = "Cook County Census Tracts",
       x = "Housing Instability Index (0-100)",
       y = "Number of Tracts") +
  theme_minimal()

ggsave("outputs/indices/housing_instability_distribution.png", p1, 
       width = 10, height = 6, dpi = 300)
cat("Saved: housing_instability_distribution.png\n")

# 2. Veteran Healthcare Desert (only tracts with veterans)
p2 <- master_indices %>%
  filter(!is.na(veteran_healthcare_desert_index)) %>%
  ggplot(aes(x = veteran_healthcare_desert_index)) +
  geom_histogram(bins = 30, fill = "darkred", alpha = 0.7) +
  geom_vline(xintercept = c(25, 50, 75), linetype = "dashed", color = "black") +
  labs(title = "Distribution of Veteran Healthcare Desert Index",
       subtitle = sprintf("Cook County Tracts with 10+ Veterans (n=%d)", 
                          sum(!is.na(master_indices$veteran_healthcare_desert_index))),
       x = "Healthcare Desert Index (0-100)",
       y = "Number of Tracts") +
  theme_minimal()

ggsave("outputs/indices/veteran_healthcare_distribution.png", p2, 
       width = 10, height = 6, dpi = 300)
cat("Saved: veteran_healthcare_distribution.png\n")

# 3. Family Opportunity Index
p3 <- ggplot(master_indices, aes(x = family_opportunity_index)) +
  geom_histogram(bins = 30, fill = "darkgreen", alpha = 0.7) +
  geom_vline(xintercept = median(master_indices$family_opportunity_index, na.rm = TRUE), 
             linetype = "dashed", color = "red") +
  labs(title = "Distribution of Family Housing-Opportunity Index",
       subtitle = "Cook County Census Tracts (higher = better)",
       x = "Family Opportunity Index (0-100)",
       y = "Number of Tracts") +
  theme_minimal()

ggsave("outputs/indices/family_opportunity_distribution.png", p3, 
       width = 10, height = 6, dpi = 300)
cat("Saved: family_opportunity_distribution.png\n")

# 4. Scatterplot: Housing vs Opportunity
p4 <- ggplot(master_indices, 
             aes(x = housing_instability_index, y = family_opportunity_index)) +
  geom_point(alpha = 0.5, color = "steelblue") +
  geom_smooth(method = "lm", color = "red", se = TRUE) +
  labs(title = "Housing Instability vs Family Opportunity",
       subtitle = "Cook County Census Tracts",
       x = "Housing Instability (higher = worse)",
       y = "Family Opportunity (higher = better)") +
  theme_minimal()

ggsave("outputs/indices/instability_vs_opportunity.png", p4, 
       width = 10, height = 8, dpi = 300)
cat("Saved: instability_vs_opportunity.png\n")

# 5. Category bar charts
p5 <- master_indices %>%
  count(instability_category) %>%
  mutate(instability_category = factor(instability_category, 
                                       levels = c("Lower Risk", "Moderate Risk", 
                                                  "High Risk", "Very High Risk"))) %>%
  ggplot(aes(x = instability_category, y = n, fill = instability_category)) +
  geom_col() +
  geom_text(aes(label = n), vjust = -0.5) +
  scale_fill_manual(values = c("Lower Risk" = "#2ecc71",
                               "Moderate Risk" = "#f39c12",
                               "High Risk" = "#e67e22",
                               "Very High Risk" = "#e74c3c")) +
  labs(title = "Housing Instability Risk Categories",
       subtitle = "Cook County Census Tracts",
       x = "", y = "Number of Tracts") +
  theme_minimal() +
  theme(legend.position = "none")

ggsave("outputs/indices/instability_categories.png", p5, 
       width = 10, height = 6, dpi = 300)
cat("Saved: instability_categories.png\n")

# 6. Correlation heatmap of all components
component_data <- master_indices %>%
  select(affordability_score, instability_score, vulnerability_score,
         veteran_needs_score, coverage_gap_score, transport_barrier_score,
         housing_supply_score, opportunity_access_score, wellbeing_score) %>%
  cor(use = "complete.obs")

png("outputs/indices/component_correlations.png", width = 10, height = 10, 
    units = "in", res = 300)
corrplot(component_data, method = "color", type = "upper", 
         tl.col = "black", tl.srt = 45,
         title = "Correlation Between Index Components",
         mar = c(0,0,2,0))
dev.off()
cat("Saved: component_correlations.png\n")


################################################################################
# SPATIAL MAPS
################################################################################

cat("\n\n=== CREATING SPATIAL MAPS ===\n")

# Join indices to spatial data
spatial_indices <- acs_spatial %>%
  left_join(master_indices, by = "GEOID")

# 1. Housing Instability Map
map1 <- ggplot(spatial_indices) +
  geom_sf(aes(fill = housing_instability_index), color = NA) +
  scale_fill_viridis_c(option = "magma", direction = -1,
                       name = "Instability\nIndex",
                       na.value = "grey90") +
  labs(title = "Housing Instability Index",
       subtitle = "Cook County, Illinois",
       caption = "Higher values indicate greater housing instability") +
  theme_void() +
  theme(legend.position = "right")

ggsave("outputs/indices/map_housing_instability.png", map1, 
       width = 12, height = 10, dpi = 300)
cat("Saved: map_housing_instability.png\n")

# 2. Veteran Healthcare Desert Map
map2 <- ggplot(spatial_indices) +
  geom_sf(aes(fill = veteran_healthcare_desert_index), color = NA) +
  scale_fill_viridis_c(option = "plasma", direction = -1,
                       name = "Desert\nIndex",
                       na.value = "grey90") +
  labs(title = "Veteran Healthcare Desert Index",
       subtitle = "Cook County, Illinois (Tracts with 10+ Veterans)",
       caption = "Higher values indicate worse healthcare access for veterans") +
  theme_void() +
  theme(legend.position = "right")

ggsave("outputs/indices/map_veteran_healthcare.png", map2, 
       width = 12, height = 10, dpi = 300)
cat("Saved: map_veteran_healthcare.png\n")

# 3. Family Opportunity Map
map3 <- ggplot(spatial_indices) +
  geom_sf(aes(fill = family_opportunity_index), color = NA) +
  scale_fill_viridis_c(option = "viridis", 
                       name = "Opportunity\nIndex",
                       na.value = "grey90") +
  labs(title = "Family Housing-Opportunity Index",
       subtitle = "Cook County, Illinois",
       caption = "Higher values indicate better opportunities for families") +
  theme_void() +
  theme(legend.position = "right")

ggsave("outputs/indices/map_family_opportunity.png", map3, 
       width = 12, height = 10, dpi = 300)
cat("Saved: map_family_opportunity.png\n")

# 4. Combined facet map
map4 <- spatial_indices %>%
  select(GEOID, geometry, 
         housing_instability_index, 
         veteran_healthcare_desert_index, 
         family_opportunity_index) %>%
  pivot_longer(cols = ends_with("_index"), 
               names_to = "Index", 
               values_to = "Value") %>%
  mutate(Index = case_when(
    Index == "housing_instability_index" ~ "Housing Instability",
    Index == "veteran_healthcare_desert_index" ~ "Veteran Healthcare Desert",
    Index == "family_opportunity_index" ~ "Family Opportunity"
  )) %>%
  ggplot() +
  geom_sf(aes(fill = Value), color = NA) +
  scale_fill_viridis_c(na.value = "grey90", name = "Index\nValue") +
  facet_wrap(~Index, ncol = 1) +
  labs(title = "Composite Indices: Cook County, Illinois",
       caption = "Source: American Community Survey 5-Year Estimates") +
  theme_void() +
  theme(legend.position = "right",
        strip.text = element_text(size = 12, face = "bold"))

ggsave("outputs/indices/map_all_indices_facet.png", map4, 
       width = 10, height = 14, dpi = 300)
cat("Saved: map_all_indices_facet.png\n")


################################################################################
# EXPORT RESULTS
################################################################################

cat("\n\n=== EXPORTING RESULTS ===\n")

# 1. Export CSV with all indices
write_csv(master_indices, "outputs/indices/cook_county_composite_indices.csv")
cat("Saved: cook_county_composite_indices.csv\n")

# 2. Export GeoJSON with spatial data
st_write(spatial_indices, "outputs/indices/cook_county_composite_indices.geojson",
         delete_dsn = TRUE, quiet = TRUE)
cat("Saved: cook_county_composite_indices.geojson\n")

# 3. Export summary statistics
sink("outputs/indices/index_summary_statistics.txt")
cat("COOK COUNTY COMPOSITE INDICES - SUMMARY STATISTICS\n")
cat("Generated:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
cat(rep("=", 80), "\n\n")

cat("HOUSING INSTABILITY INDEX\n")
cat(rep("-", 80), "\n")
print(summary(master_indices$housing_instability_index))
cat("\nCategory Distribution:\n")
print(table(master_indices$instability_category))

cat("\n\nVETERAN HEALTHCARE DESERT INDEX\n")
cat(rep("-", 80), "\n")
print(summary(master_indices$veteran_healthcare_desert_index))
cat("\nCategory Distribution:\n")
print(table(master_indices$veteran_desert_category))

cat("\n\nFAMILY OPPORTUNITY INDEX\n")
cat(rep("-", 80), "\n")
print(summary(master_indices$family_opportunity_index))
cat("\nCategory Distribution:\n")
print(table(master_indices$family_opportunity_category))

cat("\n\nINDEX CORRELATIONS\n")
cat(rep("-", 80), "\n")
print(round(index_correlations, 3))

sink()
cat("Saved: index_summary_statistics.txt\n")

# 4. Create a data dictionary
data_dictionary <- tribble(
  ~Variable, ~Description, ~Range, ~Interpretation,
  "housing_instability_index", "Composite measure of housing instability risk", "0-100", "Higher = worse instability",
  "affordability_score", "Rent burden and housing cost pressure", "0-100", "Higher = less affordable",
  "instability_score", "Residential turnover and tenure instability", "0-100", "Higher = more unstable",
  "vulnerability_score", "Economic vulnerability and poverty", "0-100", "Higher = more vulnerable",
  "veteran_healthcare_desert_index", "Healthcare access challenges for veterans", "0-100", "Higher = worse access",
  "veteran_needs_score", "Concentration and needs of veteran population", "0-100", "Higher = more needs",
  "coverage_gap_score", "Gap in VA healthcare coverage", "0-100", "Higher = bigger gap",
  "transport_barrier_score", "Transportation barriers to healthcare", "0-100", "Higher = worse barriers",
  "family_opportunity_index", "Overall opportunity for families with children", "0-100", "Higher = better opportunity",
  "housing_supply_score", "Availability of family-sized housing", "0-100", "Higher = better supply",
  "opportunity_access_score", "Access to jobs and economic opportunity", "0-100", "Higher = better access",
  "wellbeing_score", "Family wellbeing indicators", "0-100", "Higher = better outcomes"
)

write_csv(data_dictionary, "outputs/indices/data_dictionary.csv")
cat("Saved: data_dictionary.csv\n")


################################################################################
# SUMMARY AND NEXT STEPS
################################################################################

cat("\n\n")
cat(rep("=", 80), "\n")
cat("ANALYSIS COMPLETE!\n")
cat(rep("=", 80), "\n\n")

cat("FILES CREATED:\n")
cat("  - cook_county_composite_indices.csv (main data file)\n")
cat("  - cook_county_composite_indices.geojson (spatial data)\n")
cat("  - data_dictionary.csv (variable descriptions)\n")
cat("  - index_summary_statistics.txt (summary report)\n")
cat("  - Multiple visualization PNG files\n\n")

cat("KEY FINDINGS:\n")
cat(sprintf("  - %d tracts analyzed\n", nrow(master_indices)))
cat(sprintf("  - %.1f%% in High/Very High housing instability risk\n",
            sum(master_indices$instability_category %in% c("High Risk", "Very High Risk")) / 
              nrow(master_indices) * 100))
cat(sprintf("  - %d tracts with sufficient veteran population for analysis\n",
            sum(!is.na(master_indices$veteran_healthcare_desert_index))))
cat(sprintf("  - Housing instability and family opportunity correlation: %.3f\n",
            cor(master_indices$housing_instability_index, 
                master_indices$family_opportunity_index, 
                use = "complete.obs")))

cat("\n\nDATA ENHANCEMENT PRIORITIES:\n")
cat("  1. EVICTION DATA - Direct measure of housing instability\n")
cat("  2. VA FACILITY LOCATIONS - Spatial distance calculations\n")
cat("  3. TRANSIT DATA (GTFS) - Accurate transportation access\n")
cat("  4. JOB LOCATIONS (LODES) - True opportunity measurement\n")
cat("  5. SCHOOL QUALITY - Family wellbeing dimension\n\n")

cat("NEXT STEPS:\n")
cat("  1. Review maps and identify specific neighborhoods of concern\n")
cat("  2. Validate indices with local knowledge/stakeholders\n")
cat("  3. Download priority enhancement datasets (see comments above)\n")
cat("  4. Adjust weights if needed based on policy priorities\n")
cat("  5. Create targeted interventions for high-risk areas\n\n")

cat(rep("=", 80), "\n\n")