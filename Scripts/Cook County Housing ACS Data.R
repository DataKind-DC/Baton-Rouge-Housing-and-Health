## Housing and Veterans ACS Data Pull for Cook County, IL

# Load required libraries
library(tidyverse)
library(tidycensus)
library(sf)
library(purrr)

# Set working directory (update this path to your preferred location)
setwd("C:/Users/RichardCarder/Documents/dev/Cook-County-Veterans/Output Data")


# Set up Census API
API_Key <- Sys.getenv("CENSUS_API_KEY")
#census_api_key(API_Key, install = TRUE, overwrite = TRUE)

# Test API connectivity
cat("Testing Census API connectivity...\n")
tryCatch({
  test_data <- get_acs(geography = "state", variables = "B01003_001", year = 2023, survey = "acs5")
  cat("API connection successful!\n")
}, error = function(e) {
  cat("Warning: API connection issue. Error:", e$message, "\n")
  cat("You may need to check your API key or try again later.\n")
})

# Load variables for reference
variables <- load_variables(2023, "acs5", cache = TRUE)

# Define geography - Cook County, IL
state <- "17"  # Illinois state FIPS code
county <- "031"  # Cook County FIPS code

# ==============================================================================
# HOUSING TABLES
# ==============================================================================

# Define housing and demographic tables to pull
housing_tables <- c(
  "DP04",    # Selected Housing Characteristics (Data Profile)
  "B25001",  # Housing Units
  "B25002",  # Occupancy Status
  "B25003",  # Tenure (Owner/Renter)
  "B25007",  # Tenure by Age of Householder
  "B25014",  # Tenure by Occupants Per Room (overcrowding)
  "B25077",  # Median Value (Owner-Occupied)
  "B25064",  # Median Gross Rent
  "B25024",  # Units in Structure
  "B25034",  # Year Structure Built
  "B25041",  # Bedrooms
  "B25053",  # Selected Monthly Owner Costs
  "B25070",  # Gross Rent as Percentage of Income (renters)
  "B25091",  # Mortgage Status and Selected Monthly Owner Costs as Percentage of Income
  "B25106",  # Tenure by Housing Costs as Percentage of Income
  "S2503",   # Financial Characteristics (costs, burdens, value, rent)
  "S2504"   # Physical Housing Characteristics (structure, rooms, facilities)
)

# Define demographic tables for context
demographic_tables <- c(
  "B01003",  # Total Population
  "B02001",  # Race
  "B03003"   # Hispanic/Latino Origin
)

# Define income and economic tables
income_tables <- c(
  "B19013",  # Median Household Income
  "B19001",  # Household Income Distribution
  "B19101",  # Family Income Distribution  
  "B17001",  # Poverty Status by Sex and Age
  "B17017",  # Poverty Status by Household Type
  "B25119",  # Median Household Income by Tenure
  "DP03"     # Selected Economic Characteristics (Data Profile)
)

# Define household and family composition tables
household_tables <- c(
  "B11001",  # Household Type
  "B11005",  # Households by Presence of People Under 18 Years
  "B11013",  # Subfamily Type by Presence of Own Children
  "B09001",  # Population Under 18 Years by Age
  "B09002",  # Own Children Under 18 Years by Family Type
  "B25115",  # Tenure by Household Size
  "B08301",  # Means of Transportation to Work (for worker households)
  "B11017",  # Multigenerational Households
  "B10001"   # Grandparents Living with Own Grandchildren
)

# ==============================================================================
# ADDITIONAL ENRICHMENT TABLES
# ==============================================================================

# Disability tables
disability_tables <- c(
  "B18101",  # Sex by Age by Disability Status
  "C21100"   # Service-Connected Disability Rating Status for Veterans
)

# Education tables
education_tables <- c(
  "B15003",  # Educational Attainment for Population 25 Years and Over
  "B21003"   # Educational Attainment by Veteran Status (already in veteran_tables, included here for clarity)
)

# Health insurance tables
# NOTE: People can have MULTIPLE types of insurance (e.g., Medicare + employer),
# so the sum of insurance types will exceed the total insured population.
# Percentages are calculated as % of total population, not % of insured.
# 
# Insurance Types:
# - Private: Employer-based + Direct-purchase
# - Public: Medicare + Medicaid + TRICARE + VA + other government programs
# - Direct-purchase: ACA Marketplace + other privately purchased plans
health_insurance_tables <- c(
  "B27001",  # Health Insurance Coverage Status by Sex by Age (Overall: with/without)
  "B27002",  # Private Health Insurance Status by Sex by Age
  "B27003",  # Public Health Insurance Status by Sex by Age
  "C27004",  # Employer-Based Health Insurance by Sex by Age (Collapsed table - B27004 discontinued)
  "C27005",  # Direct-Purchase Health Insurance by Sex by Age (Collapsed table - B27005 discontinued)
  "C27006",  # Medicare Coverage by Sex by Age (Collapsed table - B27006 discontinued)
  "C27007",  # Medicaid/Means-Tested Public Coverage by Sex by Age (Collapsed table - B27007 discontinued)
  "C27008",  # TRICARE/Military Health Coverage by Sex by Age (Collapsed table - B27008 discontinued)
  "C27009",  # VA Health Care by Sex by Age (Collapsed table - B27009 discontinued)
  "B27011"   # Health Insurance Coverage Status by Employment Status (NOTE: NOT by Veteran Status!)
)

# Internet and computer access tables
digital_access_tables <- c(
  "B28002",  # Presence and Types of Internet Subscriptions in Household
  "B28003"   # Presence of Computer and Internet Subscription by Age
)

# Transportation tables
transportation_tables <- c(
  "B08303",  # Travel Time to Work
  "B25044",  # Tenure by Vehicles Available
  "B08141"   # Means of Transportation to Work by Poverty Status
)

# Housing stability and mobility tables
mobility_tables <- c(
  "B25026",  # Total Population in Occupied Housing Units by Tenure by Year Householder Moved Into Unit
  "B07003"   # Geographical Mobility in the Past Year by Tenure
)

# Economic hardship tables
hardship_tables <- c(
  "B22001",  # Receipt of Food Stamps/SNAP by Age 60+
  "B22002",  # Receipt of Food Stamps/SNAP by Presence of Children
  "B22003",  # Receipt of Food Stamps/SNAP by Poverty Status
  "B19055",  # Social Security Income for Households
  "B19056",  # Supplemental Security Income (SSI) for Households
  "B19057",  # Public Assistance Income for Households
  "B19058"   # Public Assistance or SNAP Combined for Households
)

# ==============================================================================
# VETERANS TABLES
# ==============================================================================

# Define comprehensive veteran tables
veteran_tables <- c(
  "B21001",  # Sex by Age by Veteran Status (Total Population)
  "C21001A", # Sex by Age by Veteran Status (White Alone)
  "C21001B", # Sex by Age by Veteran Status (Black or African American Alone)
  "C21001C", # Sex by Age by Veteran Status (American Indian and Alaska Native Alone)
  "C21001D", # Sex by Age by Veteran Status (Asian Alone)
  "C21001E", # Sex by Age by Veteran Status (Native Hawaiian and Other Pacific Islander Alone)
  "C21001F", # Sex by Age by Veteran Status (Some Other Race Alone)
  "C21001G", # Sex by Age by Veteran Status (Two or More Races)
  "C21001H", # Sex by Age by Veteran Status (White Alone, Not Hispanic or Latino)
  "C21001I", # Sex by Age by Veteran Status (Hispanic or Latino)
  "B21002",  # Period of Military Service for Civilian Veterans 18 Years and Over
  "B21003",  # Veteran Status by Educational Attainment for Population 25 Years and Over
  "B21004",  # Median Income by Sex by Veteran Status
  "B21005",  # Age by Veteran Status by Employment Status (will aggregate across ages)
  # Note: C21005 not available at tract level, using B21005 instead and aggregating
  "B21007",  # Age by Veteran Status by Poverty Status by Disability Status (18+)
  "C21007",  # Age by Veteran Status by Poverty Status by Disability Status (simplified)
  "B21100",  # Service-Connected Disability Rating Status and Ratings for Veterans 18+
  "C21100"   # Service-Connected Disability Rating Status for Veterans (simplified)
  # Note: Will use whichever is available at tract level
)

# ==============================================================================
# DATA PULL - HOUSING
# ==============================================================================

# Fetch housing data for all tables with error handling
cat("Fetching housing data...\n")
housing_data <- purrr::map_df(housing_tables, ~ {
  cat("Pulling table:", .x, "\n")
  tryCatch({
    Sys.sleep(1)  # Add delay to avoid API rate limits
    get_acs(
      geography = "tract",
      table = .x,
      state = state,
      county = county,
      year = 2023,
      survey = "acs5"
    )
  }, error = function(e) {
    cat("Warning: Could not fetch table", .x, "- Error:", e$message, "\n")
    return(data.frame())
  })
})

# Fetch demographic data with error handling
cat("Fetching demographic data...\n")
demographic_data <- purrr::map_df(demographic_tables, ~ {
  cat("Pulling table:", .x, "\n")
  tryCatch({
    Sys.sleep(1)
    get_acs(
      geography = "tract",
      table = .x,
      state = state,
      county = county,
      year = 2023,
      survey = "acs5"
    )
  }, error = function(e) {
    cat("Warning: Could not fetch table", .x, "- Error:", e$message, "\n")
    return(data.frame())
  })
})

# Fetch income and economic data with error handling
cat("Fetching income and economic data...\n")
income_data <- purrr::map_df(income_tables, ~ {
  cat("Pulling table:", .x, "\n")
  tryCatch({
    Sys.sleep(1)
    get_acs(
      geography = "tract",
      table = .x,
      state = state,
      county = county,
      year = 2023,
      survey = "acs5"
    )
  }, error = function(e) {
    cat("Warning: Could not fetch table", .x, "- Error:", e$message, "\n")
    return(data.frame())
  })
})

# Fetch household and family composition data with error handling
cat("Fetching household and family composition data...\n")
household_data <- purrr::map_df(household_tables, ~ {
  cat("Pulling table:", .x, "\n")
  tryCatch({
    Sys.sleep(1)
    get_acs(
      geography = "tract",
      table = .x,
      state = state,
      county = county,
      year = 2023,
      survey = "acs5"
    )
  }, error = function(e) {
    cat("Warning: Could not fetch table", .x, "- Error:", e$message, "\n")
    return(data.frame())
  })
})

# ==============================================================================
# DATA PULL - ENRICHMENT TABLES
# ==============================================================================

cat("Fetching disability data...\n")
disability_data <- purrr::map_df(disability_tables, ~ {
  cat("Pulling table:", .x, "\n")
  tryCatch({
    Sys.sleep(1)
    get_acs(
      geography = "tract",
      table = .x,
      state = state,
      county = county,
      year = 2023,
      survey = "acs5"
    )
  }, error = function(e) {
    cat("Warning: Could not fetch table", .x, "- Error:", e$message, "\n")
    return(data.frame())
  })
})

cat("Fetching education data...\n")
education_data <- purrr::map_df(education_tables, ~ {
  cat("Pulling table:", .x, "\n")
  tryCatch({
    Sys.sleep(1)
    get_acs(
      geography = "tract",
      table = .x,
      state = state,
      county = county,
      year = 2023,
      survey = "acs5"
    )
  }, error = function(e) {
    cat("Warning: Could not fetch table", .x, "- Error:", e$message, "\n")
    return(data.frame())
  })
})

cat("Fetching health insurance data...\n")
health_insurance_data <- purrr::map_df(health_insurance_tables, ~ {
  cat("Pulling table:", .x, "\n")
  tryCatch({
    Sys.sleep(1)
    get_acs(
      geography = "tract",
      table = .x,
      state = state,
      county = county,
      year = 2023,
      survey = "acs5"
    )
  }, error = function(e) {
    cat("Warning: Could not fetch table", .x, "- Error:", e$message, "\n")
    return(data.frame())
  })
})

cat("Fetching digital access data...\n")
digital_access_data <- purrr::map_df(digital_access_tables, ~ {
  cat("Pulling table:", .x, "\n")
  tryCatch({
    Sys.sleep(1)
    get_acs(
      geography = "tract",
      table = .x,
      state = state,
      county = county,
      year = 2023,
      survey = "acs5"
    )
  }, error = function(e) {
    cat("Warning: Could not fetch table", .x, "- Error:", e$message, "\n")
    return(data.frame())
  })
})

cat("Fetching transportation data...\n")
transportation_data <- purrr::map_df(transportation_tables, ~ {
  cat("Pulling table:", .x, "\n")
  tryCatch({
    Sys.sleep(1)
    get_acs(
      geography = "tract",
      table = .x,
      state = state,
      county = county,
      year = 2023,
      survey = "acs5"
    )
  }, error = function(e) {
    cat("Warning: Could not fetch table", .x, "- Error:", e$message, "\n")
    return(data.frame())
  })
})

cat("Fetching housing mobility data...\n")
mobility_data <- purrr::map_df(mobility_tables, ~ {
  cat("Pulling table:", .x, "\n")
  tryCatch({
    Sys.sleep(1)
    get_acs(
      geography = "tract",
      table = .x,
      state = state,
      county = county,
      year = 2023,
      survey = "acs5"
    )
  }, error = function(e) {
    cat("Warning: Could not fetch table", .x, "- Error:", e$message, "\n")
    return(data.frame())
  })
})

cat("Fetching economic hardship data...\n")
hardship_data <- purrr::map_df(hardship_tables, ~ {
  cat("Pulling table:", .x, "\n")
  tryCatch({
    Sys.sleep(1)
    get_acs(
      geography = "tract",
      table = .x,
      state = state,
      county = county,
      year = 2023,
      survey = "acs5"
    )
  }, error = function(e) {
    cat("Warning: Could not fetch table", .x, "- Error:", e$message, "\n")
    return(data.frame())
  })
})

# ==============================================================================
# DATA PULL - VETERANS
# ==============================================================================

cat("Fetching veteran data...\n")
veteran_data <- purrr::map_df(veteran_tables, ~ {
  cat("Pulling table:", .x, "\n")
  tryCatch({
    Sys.sleep(1)
    get_acs(
      geography = "tract",
      table = .x,
      state = state,
      county = county,
      year = 2023,
      survey = "acs5"
    )
  }, error = function(e) {
    cat("Warning: Could not fetch table", .x, "- Error:", e$message, "\n")
    return(data.frame())
  })
})

# ==============================================================================
# DATA COMBINATION
# ==============================================================================

# Filter out empty data frames and combine all data
all_data_list <- list(
  housing_data, demographic_data, income_data, household_data, veteran_data,
  disability_data, education_data, health_insurance_data, digital_access_data,
  transportation_data, mobility_data, hardship_data
)
all_data_list <- all_data_list[sapply(all_data_list, nrow) > 0]
all_data <- bind_rows(all_data_list)

# Report successful downloads
cat("\n", paste(rep("=", 70), collapse = ""), "\n")
cat("DATA COLLECTION SUMMARY\n")
cat(paste(rep("=", 70), collapse = ""), "\n")

if(nrow(housing_data) > 0) {
  housing_tables_found <- unique(housing_data$variable) %>% str_extract("^[A-Z0-9]+") %>% unique()
  cat("Housing tables:", paste(housing_tables_found, collapse = ", "), "\n")
}

if(nrow(demographic_data) > 0) {
  demo_tables_found <- unique(demographic_data$variable) %>% str_extract("^[A-Z0-9]+") %>% unique()
  cat("Demographic tables:", paste(demo_tables_found, collapse = ", "), "\n")
}

if(nrow(income_data) > 0) {
  income_tables_found <- unique(income_data$variable) %>% str_extract("^[A-Z0-9]+") %>% unique()
  cat("Income tables:", paste(income_tables_found, collapse = ", "), "\n")
}

if(nrow(household_data) > 0) {
  household_tables_found <- unique(household_data$variable) %>% str_extract("^[A-Z0-9]+") %>% unique()
  cat("Household tables:", paste(household_tables_found, collapse = ", "), "\n")
}

if(nrow(veteran_data) > 0) {
  veteran_tables_found <- unique(veteran_data$variable) %>% str_extract("^[A-Z0-9]+") %>% unique()
  cat("Veteran tables:", paste(veteran_tables_found, collapse = ", "), "\n")
}

if(nrow(disability_data) > 0) {
  disability_tables_found <- unique(disability_data$variable) %>% str_extract("^[A-Z0-9]+") %>% unique()
  cat("Disability tables:", paste(disability_tables_found, collapse = ", "), "\n")
}

if(nrow(education_data) > 0) {
  education_tables_found <- unique(education_data$variable) %>% str_extract("^[A-Z0-9]+") %>% unique()
  cat("Education tables:", paste(education_tables_found, collapse = ", "), "\n")
}

if(nrow(health_insurance_data) > 0) {
  health_tables_found <- unique(health_insurance_data$variable) %>% str_extract("^[A-Z0-9]+") %>% unique()
  cat("Health Insurance tables:", paste(health_tables_found, collapse = ", "), "\n")
}

if(nrow(digital_access_data) > 0) {
  digital_tables_found <- unique(digital_access_data$variable) %>% str_extract("^[A-Z0-9]+") %>% unique()
  cat("Digital Access tables:", paste(digital_tables_found, collapse = ", "), "\n")
}

if(nrow(transportation_data) > 0) {
  transport_tables_found <- unique(transportation_data$variable) %>% str_extract("^[A-Z0-9]+") %>% unique()
  cat("Transportation tables:", paste(transport_tables_found, collapse = ", "), "\n")
}

if(nrow(mobility_data) > 0) {
  mobility_tables_found <- unique(mobility_data$variable) %>% str_extract("^[A-Z0-9]+") %>% unique()
  cat("Mobility tables:", paste(mobility_tables_found, collapse = ", "), "\n")
}

if(nrow(hardship_data) > 0) {
  hardship_tables_found <- unique(hardship_data$variable) %>% str_extract("^[A-Z0-9]+") %>% unique()
  cat("Hardship tables:", paste(hardship_tables_found, collapse = ", "), "\n")
}

cat("Total variables collected:", nrow(all_data), "\n")
cat(paste(rep("=", 70), collapse = ""), "\n\n")

# Check which veteran variables were actually retrieved
if(nrow(veteran_data) > 0) {
  veteran_vars_found <- unique(veteran_data$variable)
  cat("Veteran variables found:\n")
  cat(head(veteran_vars_found, 20), "\n")
  cat("Total veteran variables:", length(veteran_vars_found), "\n\n")
}

# Join with variable labels
combined_data <- all_data %>%
  left_join(variables, by = c("variable" = "name"))

# ==============================================================================
# DATA TRANSFORMATION - HOUSING & DEMOGRAPHICS
# ==============================================================================

cat("Transforming housing and demographic data...\n")

# Transform data to wide format with friendly column names
wide_data <- combined_data %>%
  dplyr::select(-moe) %>%
  mutate(friendly_name = case_when(
    # Population and Demographics
    variable == "B01003_001" ~ "Total_Population",
    variable == "B02001_002" ~ "White_Alone",
    variable == "B02001_003" ~ "Black_Alone",
    variable == "B02001_005" ~ "Asian_Alone",
    variable == "B03003_003" ~ "Hispanic_Latino",
    
    # Housing Units and Tenure
    variable == "B25001_001" ~ "Total_Housing_Units",
    variable == "B25002_002" ~ "Occupied_Units",
    variable == "B25002_003" ~ "Vacant_Units",
    variable == "B25003_002" ~ "Owner_Occupied",
    variable == "B25003_003" ~ "Renter_Occupied",
    
    # Structure Type
    variable == "B25024_002" ~ "Single_Family_Detached",
    variable == "B25024_003" ~ "Single_Family_Attached",
    variable == "B25024_010" ~ "Mobile_Home",
    variable == "B25024_001" ~ "Total_Units_Structure_Type",
    
    # Multi-family housing - individual categories
    variable == "B25024_004" ~ "Multi_Family_2_Units",
    variable == "B25024_005" ~ "Multi_Family_3_4_Units",
    variable == "B25024_006" ~ "Multi_Family_5_9_Units",
    variable == "B25024_007" ~ "Multi_Family_10_19_Units",
    variable == "B25024_008" ~ "Multi_Family_20_49_Units",
    variable == "B25024_009" ~ "Multi_Family_50_Plus_Units",
    
    # Bedrooms (B25041: _002=No bedroom, _003=1BR, _004=2BR, _005=3BR, _006=4BR, _007=5+BR)
    variable == "B25041_002" ~ "No_Bedroom",
    variable == "B25041_003" ~ "One_Bedroom",
    variable == "B25041_004" ~ "Two_Bedrooms",
    variable == "B25041_005" ~ "Three_Bedrooms",
    variable == "B25041_006" ~ "Four_Bedrooms",
    variable == "B25041_007" ~ "Five_Plus_Bedrooms",
    
    # Year Built
    variable == "B25034_002" ~ "Built_2020_or_Later",
    variable == "B25034_003" ~ "Built_2010_2019",
    variable == "B25034_004" ~ "Built_2000_2009",
    variable == "B25034_005" ~ "Built_1990_1999",
    variable == "B25034_006" ~ "Built_1980_1989",
    variable == "B25034_007" ~ "Built_1970_1979",
    variable == "B25034_008" ~ "Built_1960_1969",
    variable == "B25034_009" ~ "Built_1950_1959",
    variable == "B25034_010" ~ "Built_1940_1949",
    variable == "B25034_011" ~ "Built_1939_or_Earlier",
    
    # Housing Values and Costs
    variable == "B25077_001" ~ "Median_Home_Value",
    variable == "B25064_001" ~ "Median_Gross_Rent",
    
    # Rent Burden - Individual Categories (B25070 - Renters)
    variable == "B25070_001" ~ "Total_Renters_Cost_Burden_Universe",
    variable == "B25070_007" ~ "Rent_Burden_30_34_9_Pct",
    variable == "B25070_008" ~ "Rent_Burden_35_39_9_Pct",
    variable == "B25070_009" ~ "Rent_Burden_40_49_9_Pct",
    variable == "B25070_010" ~ "Rent_Burden_50_Plus_Pct",

    # Owner Cost Burden (B25091 - detailed) and B25106 (summary)
    variable == "B25091_008" ~ "Owner_Cost_Burden_30_34_9_Pct",
    variable == "B25091_009" ~ "Owner_Cost_Burden_35_39_9_Pct",
    variable == "B25091_010" ~ "Owner_Cost_Burden_40_49_9_Pct",
    variable == "B25091_011" ~ "Owner_Cost_Burden_50_Plus_Pct",

    # Overall Housing Cost Burden by Tenure (B25106)
    variable == "B25106_006" ~ "Owner_30_34_9_Pct_Income",
    variable == "B25106_010" ~ "Owner_35_39_9_Pct_Income",
    variable == "B25106_014" ~ "Owner_40_49_9_Pct_Income",
    variable == "B25106_018" ~ "Owner_50_Plus_Pct_Income",
    variable == "B25106_028" ~ "Renter_30_34_9_Pct_Income",
    variable == "B25106_032" ~ "Renter_35_39_9_Pct_Income",
    variable == "B25106_036" ~ "Renter_40_49_9_Pct_Income",
    variable == "B25106_040" ~ "Renter_50_Plus_Pct_Income",

    # Age of Householder by Tenure (B25007)
    variable == "B25007_003" ~ "Owner_Householder_15_24",
    variable == "B25007_004" ~ "Owner_Householder_25_34",
    variable == "B25007_005" ~ "Owner_Householder_35_44",
    variable == "B25007_006" ~ "Owner_Householder_45_54",
    variable == "B25007_007" ~ "Owner_Householder_55_59",
    variable == "B25007_008" ~ "Owner_Householder_60_64",
    variable == "B25007_009" ~ "Owner_Householder_65_74",
    variable == "B25007_010" ~ "Owner_Householder_75_84",
    variable == "B25007_011" ~ "Owner_Householder_85_Plus",

    variable == "B25007_013" ~ "Renter_Householder_15_24",
    variable == "B25007_014" ~ "Renter_Householder_25_34",
    variable == "B25007_015" ~ "Renter_Householder_35_44",
    variable == "B25007_016" ~ "Renter_Householder_45_54",
    variable == "B25007_017" ~ "Renter_Householder_55_59",
    variable == "B25007_018" ~ "Renter_Householder_60_64",
    variable == "B25007_019" ~ "Renter_Householder_65_74",
    variable == "B25007_020" ~ "Renter_Householder_75_84",
    variable == "B25007_021" ~ "Renter_Householder_85_Plus",

    # Occupants Per Room - Overcrowding (B25014)
    variable == "B25014_003" ~ "Owner_0_5_Or_Less_Per_Room",
    variable == "B25014_004" ~ "Owner_0_51_To_1_Per_Room",
    variable == "B25014_005" ~ "Owner_1_01_To_1_5_Per_Room",
    variable == "B25014_006" ~ "Owner_1_51_To_2_Per_Room",
    variable == "B25014_007" ~ "Owner_2_Plus_Per_Room",

    variable == "B25014_009" ~ "Renter_0_5_Or_Less_Per_Room",
    variable == "B25014_010" ~ "Renter_0_51_To_1_Per_Room",
    variable == "B25014_011" ~ "Renter_1_01_To_1_5_Per_Room",
    variable == "B25014_012" ~ "Renter_1_51_To_2_Per_Room",
    variable == "B25014_013" ~ "Renter_2_Plus_Per_Room",

    # Household Type
    variable == "B11001_001" ~ "Total_Households",
    variable == "B11001_002" ~ "Family_Households",
    variable == "B11001_007" ~ "Nonfamily_Living_Alone",
    variable == "B11005_002" ~ "Households_With_Children_Under_18",
    
    # Children
    variable == "B09002_001" ~ "Total_Own_Children_Under_18",
    variable == "B09002_002" ~ "Children_In_Married_Couple_Families",
    variable == "B09002_009" ~ "Children_In_Single_Mother_Families",
    
    # Household Size by Tenure
    variable == "B25115_008" ~ "Large_Owner_Households_4_Plus",
    variable == "B25115_017" ~ "Large_Renter_Households_4_Plus",
    
    # Income
    variable == "B19013_001" ~ "Median_Household_Income",
    variable == "B25119_002" ~ "Median_Income_Owner_Occupied",
    variable == "B25119_003" ~ "Median_Income_Renter_Occupied",
    
    # Income Distribution - Individual Categories
    variable == "B19001_002" ~ "Income_Under_10K",
    variable == "B19001_003" ~ "Income_10K_15K",
    variable == "B19001_004" ~ "Income_15K_20K",
    variable == "B19001_005" ~ "Income_20K_25K",
    variable == "B19001_006" ~ "Income_25K_30K",
    variable == "B19001_007" ~ "Income_30K_35K",
    variable == "B19001_008" ~ "Income_35K_40K",
    variable == "B19001_009" ~ "Income_40K_45K",
    variable == "B19001_010" ~ "Income_45K_50K",
    variable == "B19001_011" ~ "Income_50K_60K",
    variable == "B19001_012" ~ "Income_60K_75K",
    variable == "B19001_013" ~ "Income_75K_100K",
    variable == "B19001_014" ~ "Income_100K_125K",
    variable == "B19001_015" ~ "Income_125K_150K",
    variable == "B19001_016" ~ "Income_150K_200K",
    variable == "B19001_017" ~ "Income_200K_Plus",
    
    # Poverty
    variable == "B17001_002" ~ "Below_Poverty_Level",
    variable %in% c("B17001_004", "B17001_018") ~ "Children_Below_Poverty",
    
    # ==============================================================================
    # DISABILITY DATA
    # ==============================================================================

    # Total Disability Status (B18101)
    # Note: B18101 breaks disability by age groups, so we sum all age brackets
    # Male: Under 5 (_004), 5-17 (_007), 18-34 (_010), 35-64 (_013), 65-74 (_016), 75+ (_019)
    # Female: Under 5 (_023), 5-17 (_026), 18-34 (_029), 35-64 (_032), 65-74 (_035), 75+ (_038)
    variable == "B18101_001" ~ "Total_Pop_Disability_Universe",
    variable %in% c("B18101_004", "B18101_007", "B18101_010", "B18101_013", "B18101_016", "B18101_019") ~ "Male_With_Disability",
    variable %in% c("B18101_005", "B18101_008", "B18101_011", "B18101_014", "B18101_017", "B18101_020") ~ "Male_No_Disability",
    variable %in% c("B18101_023", "B18101_026", "B18101_029", "B18101_032", "B18101_035", "B18101_038") ~ "Female_With_Disability",
    variable %in% c("B18101_024", "B18101_027", "B18101_030", "B18101_033", "B18101_036", "B18101_039") ~ "Female_No_Disability",
    
    # ==============================================================================
    # EDUCATION DATA
    # ==============================================================================
    
    # Educational Attainment - Total Population 25+ (B15003)
    variable == "B15003_001" ~ "Total_Pop_25_Plus",
    variable %in% c("B15003_002", "B15003_003", "B15003_004", "B15003_005", 
                    "B15003_006", "B15003_007", "B15003_008", "B15003_009",
                    "B15003_010", "B15003_011", "B15003_012", "B15003_013",
                    "B15003_014", "B15003_015", "B15003_016") ~ "Less_Than_HS",
    variable %in% c("B15003_017", "B15003_018") ~ "HS_Grad_Or_Equivalent",
    variable %in% c("B15003_019", "B15003_020", "B15003_021") ~ "Some_College_Or_Associates",
    variable == "B15003_022" ~ "Bachelors_Degree",
    variable %in% c("B15003_023", "B15003_024", "B15003_025") ~ "Graduate_Or_Professional",
    
    # ==============================================================================
    # HEALTH INSURANCE DATA
    # ==============================================================================
    
    # Health Insurance Coverage (B27001)
    variable == "B27001_001" ~ "Total_Pop_Insurance_Universe",
    variable %in% c("B27001_004", "B27001_007", "B27001_010", "B27001_013",
                    "B27001_016", "B27001_019", "B27001_022", "B27001_025",
                    "B27001_028", "B27001_032", "B27001_035", "B27001_038",
                    "B27001_041", "B27001_044", "B27001_047", "B27001_050",
                    "B27001_053", "B27001_056") ~ "With_Health_Insurance",
    variable %in% c("B27001_005", "B27001_008", "B27001_011", "B27001_014",
                    "B27001_017", "B27001_020", "B27001_023", "B27001_026",
                    "B27001_029", "B27001_033", "B27001_036", "B27001_039",
                    "B27001_042", "B27001_045", "B27001_048", "B27001_051",
                    "B27001_054", "B27001_057") ~ "No_Health_Insurance",

    # Children's Health Insurance (B27001 - Under 18 years: Under 6 + 6 to 18)
    # Male children: 004 (with, under 6), 005 (no, under 6), 007 (with, 6-18), 008 (no, 6-18)
    # Female children: 032 (with, under 6), 033 (no, under 6), 035 (with, 6-18), 036 (no, 6-18)
    variable %in% c("B27001_004", "B27001_007", "B27001_032", "B27001_035") ~ "Children_With_Insurance",
    variable %in% c("B27001_005", "B27001_008", "B27001_033", "B27001_036") ~ "Children_No_Insurance",
    
    # Employment Status (B27011 - Health Insurance by Employment Status)
    variable == "B27011_003" ~ "Employed_Total",
    variable == "B27011_004" ~ "Employed_With_Health_Insurance",
    variable == "B27011_009" ~ "Unemployed_With_Health_Insurance",
    variable == "B27011_010" ~ "Unemployed_With_Private_Insurance",
    
    # ==============================================================================
    # HEALTH INSURANCE BY TYPE
    # ==============================================================================
    
    # PRIVATE HEALTH INSURANCE (B27002)
    variable %in% c(
      # Male - With private insurance (all ages)
      "B27002_004", "B27002_007", "B27002_010", "B27002_013", "B27002_016",
      "B27002_019", "B27002_022", "B27002_025", "B27002_028",
      # Female - With private insurance (all ages)
      "B27002_032", "B27002_035", "B27002_038", "B27002_041", "B27002_044",
      "B27002_047", "B27002_050", "B27002_053", "B27002_056"
    ) ~ "With_Private_Insurance",
    
    # PUBLIC HEALTH INSURANCE (B27003)
    variable %in% c(
      # Male - With public coverage (all ages)
      "B27003_004", "B27003_007", "B27003_010", "B27003_013", "B27003_016",
      "B27003_019", "B27003_022", "B27003_025", "B27003_028",
      # Female - With public coverage (all ages)
      "B27003_032", "B27003_035", "B27003_038", "B27003_041", "B27003_044",
      "B27003_047", "B27003_050", "B27003_053", "B27003_056"
    ) ~ "With_Public_Coverage",
    
    # EMPLOYER-BASED INSURANCE (C27004 - Collapsed table)
    variable %in% c(
      # Male: Under 19, 19-64, 65+
      "C27004_004", "C27004_007", "C27004_010",
      # Female: Under 19, 19-64, 65+
      "C27004_014", "C27004_017", "C27004_020"
    ) ~ "With_Employer_Insurance",
    
    # DIRECT-PURCHASE INSURANCE / MARKETPLACE (C27005 - Collapsed table)
    variable %in% c(
      # Male: Under 19, 19-64, 65+
      "C27005_004", "C27005_007", "C27005_010",
      # Female: Under 19, 19-64, 65+
      "C27005_014", "C27005_017", "C27005_020"
    ) ~ "With_DirectPurchase_Insurance",
    
    # MEDICARE (C27006 - Collapsed table)
    variable %in% c(
      # Male: Under 19, 19-64, 65+
      "C27006_004", "C27006_007", "C27006_010",
      # Female: Under 19, 19-64, 65+
      "C27006_014", "C27006_017", "C27006_020"
    ) ~ "With_Medicare",
    
    # MEDICAID / MEANS-TESTED PUBLIC COVERAGE (C27007 - Collapsed table)
    variable %in% c(
      # Male: Under 19, 19-64, 65+
      "C27007_004", "C27007_007", "C27007_010",
      # Female: Under 19, 19-64, 65+
      "C27007_014", "C27007_017", "C27007_020"
    ) ~ "With_Medicaid",
    
    # TRICARE / MILITARY HEALTH COVERAGE (C27008 - Collapsed table)
    variable %in% c(
      # Male: Under 19, 19-64, 65+
      "C27008_004", "C27008_007", "C27008_010",
      # Female: Under 19, 19-64, 65+
      "C27008_014", "C27008_017", "C27008_020"
    ) ~ "With_TRICARE",
    
    # VA HEALTH CARE (C27009 - Collapsed table)
    variable %in% c(
      # Male: Under 19, 19-64, 65+
      "C27009_004", "C27009_007", "C27009_010",
      # Female: Under 19, 19-64, 65+
      "C27009_014", "C27009_017", "C27009_020"
    ) ~ "With_VA_HealthCare",
    
    # ==============================================================================
    # DIGITAL ACCESS DATA
    # ==============================================================================
    
    # Internet Subscriptions (B28002)
    variable == "B28002_001" ~ "Total_Households_Internet_Universe",
    variable == "B28002_002" ~ "HH_With_Internet",
    variable == "B28002_013" ~ "HH_No_Internet",
    variable == "B28002_004" ~ "HH_Broadband",
    
    # Computer and Internet by Age (B28003)
    variable == "B28003_001" ~ "Total_Pop_Computer_Universe",
    variable %in% c("B28003_003", "B28003_009", "B28003_015") ~ "Has_Computer_And_Internet",
    variable %in% c("B28003_006", "B28003_012", "B28003_018") ~ "No_Computer",
    
    # ==============================================================================
    # TRANSPORTATION DATA
    # ==============================================================================
    
    # Travel Time to Work (B08303)
    variable == "B08303_001" ~ "Total_Workers_Commute_Universe",
    variable == "B08303_002" ~ "Commute_Under_5_Min",
    variable == "B08303_003" ~ "Commute_5_9_Min",
    variable == "B08303_004" ~ "Commute_10_14_Min",
    variable == "B08303_005" ~ "Commute_15_19_Min",
    variable == "B08303_006" ~ "Commute_20_24_Min",
    variable == "B08303_007" ~ "Commute_25_29_Min",
    variable == "B08303_008" ~ "Commute_30_34_Min",
    variable == "B08303_009" ~ "Commute_35_44_Min",
    variable == "B08303_010" ~ "Commute_45_59_Min",
    variable == "B08303_011" ~ "Commute_60_89_Min",
    variable == "B08303_012" ~ "Commute_90_Plus_Min",
    variable == "B08303_013" ~ "Work_At_Home",
    
    # Vehicles Available by Tenure (B25044)
    variable == "B25044_002" ~ "Owner_No_Vehicle",
    variable == "B25044_003" ~ "Owner_1_Vehicle",
    variable == "B25044_004" ~ "Owner_2_Vehicles",
    variable == "B25044_005" ~ "Owner_3_Plus_Vehicles",
    variable == "B25044_009" ~ "Renter_No_Vehicle",
    variable == "B25044_010" ~ "Renter_1_Vehicle",
    variable == "B25044_011" ~ "Renter_2_Vehicles",
    variable == "B25044_012" ~ "Renter_3_Plus_Vehicles",
    
    # ==============================================================================
    # HOUSING MOBILITY DATA
    # ==============================================================================
    
    # Year Householder Moved In (B25026)
    variable %in% c("B25026_003", "B25026_010") ~ "Moved_In_2020_Later",
    variable %in% c("B25026_004", "B25026_011") ~ "Moved_In_2010_2019",
    variable %in% c("B25026_005", "B25026_012") ~ "Moved_In_2000_2009",
    variable %in% c("B25026_006", "B25026_013") ~ "Moved_In_1990_1999",
    variable %in% c("B25026_007", "B25026_014") ~ "Moved_In_Before_1990",
    
    # Geographic Mobility (B07003)
    variable == "B07003_001" ~ "Total_Pop_Mobility_Universe",
    variable == "B07003_004" ~ "Same_House_1_Year_Ago",
    variable == "B07003_007" ~ "Moved_Within_County",
    variable == "B07003_010" ~ "Moved_From_Different_County",
    variable == "B07003_013" ~ "Moved_From_Different_State",
    variable == "B07003_016" ~ "Moved_From_Abroad",
    
    # ==============================================================================
    # ECONOMIC HARDSHIP DATA - SNAP/Food Stamps
    # ==============================================================================

    # Overall SNAP Receipt (B22001 or C22001 - simpler version)
    variable == "B22001_001" ~ "Total_HH_SNAP_Universe",
    variable == "B22001_002" ~ "HH_Received_SNAP",
    variable == "B22001_005" ~ "HH_No_SNAP",

    # SNAP by Presence of Children (B22002)
    variable == "B22002_001" ~ "Total_HH_SNAP_Children_Universe",
    variable %in% c("B22002_004", "B22002_006", "B22002_007") ~ "HH_SNAP_With_Children",
    variable %in% c("B22002_017", "B22002_019", "B22002_020") ~ "HH_No_SNAP_With_Children",

    # SNAP by Poverty Status (B22003)
    variable == "B22003_001" ~ "Total_HH_SNAP_Poverty_Universe",
    variable == "B22003_003" ~ "HH_SNAP_Below_Poverty",
    variable == "B22003_004" ~ "HH_SNAP_At_Above_Poverty",
    variable == "B22003_006" ~ "HH_No_SNAP_Below_Poverty",
    variable == "B22003_007" ~ "HH_No_SNAP_At_Above_Poverty",

    # ==============================================================================
    # ECONOMIC HARDSHIP DATA - SSI and Public Assistance
    # ==============================================================================

    # Social Security Income (B19055)
    variable == "B19055_001" ~ "Total_HH_SSI_Universe",
    variable == "B19055_002" ~ "HH_With_Social_Security",
    variable == "B19055_003" ~ "HH_No_Social_Security",

    # Supplemental Security Income (B19056)
    variable == "B19056_001" ~ "Total_HH_SupplementalSSI_Universe",
    variable == "B19056_002" ~ "HH_With_SSI",
    variable == "B19056_003" ~ "HH_No_SSI",

    # Public Assistance Income (B19057)
    variable == "B19057_001" ~ "Total_HH_PublicAssist_Universe",
    variable == "B19057_002" ~ "HH_With_Public_Assistance",
    variable == "B19057_003" ~ "HH_No_Public_Assistance",

    # Public Assistance OR SNAP Combined (B19058)
    variable == "B19058_001" ~ "Total_HH_PublicAssist_Or_SNAP_Universe",
    variable == "B19058_002" ~ "HH_With_PublicAssist_Or_SNAP",
    variable == "B19058_003" ~ "HH_No_PublicAssist_Or_SNAP",
    
    # ==============================================================================
    # MULTIGENERATIONAL HOUSEHOLDS DATA
    # ==============================================================================
    
    # Multigenerational Households (B11017)
    variable == "B11017_001" ~ "Total_Households_Multigen_Universe",
    variable == "B11017_002" ~ "Multigenerational_Households",
    variable == "B11017_003" ~ "Not_Multigenerational",

    # ==============================================================================
    # VETERANS DATA - B21001 (Sex by Age by Veteran Status)
    # ==============================================================================

    # Total Veteran Status (B21001)
    variable == "B21001_001" ~ "Vet_Total_Pop_18_Plus",
    variable == "B21001_002" ~ "Vet_Total_Veterans",
    variable == "B21001_003" ~ "Vet_Total_Non_Veterans",

    # Veterans by Gender Totals (B21001)
    variable == "B21001_005" ~ "Vet_Male_Veterans",
    variable == "B21001_023" ~ "Vet_Female_Veterans",

    # Male Veterans by Age (B21001)
    variable == "B21001_008" ~ "Vet_Male_18_34",
    variable == "B21001_011" ~ "Vet_Male_35_54",
    variable == "B21001_014" ~ "Vet_Male_55_64",
    variable == "B21001_017" ~ "Vet_Male_65_74",
    variable == "B21001_020" ~ "Vet_Male_75_Plus",

    # Female Veterans by Age (B21001)
    variable == "B21001_026" ~ "Vet_Female_18_34",
    variable == "B21001_029" ~ "Vet_Female_35_54",
    variable == "B21001_032" ~ "Vet_Female_55_64",
    variable == "B21001_035" ~ "Vet_Female_65_74",
    variable == "B21001_038" ~ "Vet_Female_75_Plus",

    # ==============================================================================
    # VETERANS BY RACE/ETHNICITY - C21001 Tables (Age groups: 18-64, 65+)
    # ==============================================================================

    # White Alone (C21001A and C21001H - Non-Hispanic White)
    variable == "C21001A_001" ~ "Vet_White_Alone_Total_Pop",
    variable == "C21001A_004" ~ "Vet_White_Alone_Male_18_64",
    variable == "C21001A_007" ~ "Vet_White_Alone_Male_65_Plus",
    variable == "C21001A_011" ~ "Vet_White_Alone_Female_18_64",
    variable == "C21001A_014" ~ "Vet_White_Alone_Female_65_Plus",

    variable == "C21001H_001" ~ "Vet_White_NH_Total_Pop",
    variable == "C21001H_004" ~ "Vet_White_NH_Male_18_64",
    variable == "C21001H_007" ~ "Vet_White_NH_Male_65_Plus",
    variable == "C21001H_011" ~ "Vet_White_NH_Female_18_64",
    variable == "C21001H_014" ~ "Vet_White_NH_Female_65_Plus",

    # Black or African American Alone (C21001B)
    variable == "C21001B_001" ~ "Vet_Black_Total_Pop",
    variable == "C21001B_004" ~ "Vet_Black_Male_18_64",
    variable == "C21001B_007" ~ "Vet_Black_Male_65_Plus",
    variable == "C21001B_011" ~ "Vet_Black_Female_18_64",
    variable == "C21001B_014" ~ "Vet_Black_Female_65_Plus",

    # American Indian and Alaska Native Alone (C21001C)
    variable == "C21001C_001" ~ "Vet_AIAN_Total_Pop",
    variable == "C21001C_004" ~ "Vet_AIAN_Male_18_64",
    variable == "C21001C_007" ~ "Vet_AIAN_Male_65_Plus",
    variable == "C21001C_011" ~ "Vet_AIAN_Female_18_64",
    variable == "C21001C_014" ~ "Vet_AIAN_Female_65_Plus",

    # Asian Alone (C21001D)
    variable == "C21001D_001" ~ "Vet_Asian_Total_Pop",
    variable == "C21001D_004" ~ "Vet_Asian_Male_18_64",
    variable == "C21001D_007" ~ "Vet_Asian_Male_65_Plus",
    variable == "C21001D_011" ~ "Vet_Asian_Female_18_64",
    variable == "C21001D_014" ~ "Vet_Asian_Female_65_Plus",

    # Native Hawaiian and Other Pacific Islander Alone (C21001E)
    variable == "C21001E_001" ~ "Vet_NHPI_Total_Pop",
    variable == "C21001E_004" ~ "Vet_NHPI_Male_18_64",
    variable == "C21001E_007" ~ "Vet_NHPI_Male_65_Plus",
    variable == "C21001E_011" ~ "Vet_NHPI_Female_18_64",
    variable == "C21001E_014" ~ "Vet_NHPI_Female_65_Plus",

    # Some Other Race Alone (C21001F)
    variable == "C21001F_001" ~ "Vet_Other_Race_Total_Pop",
    variable == "C21001F_004" ~ "Vet_Other_Race_Male_18_64",
    variable == "C21001F_007" ~ "Vet_Other_Race_Male_65_Plus",
    variable == "C21001F_011" ~ "Vet_Other_Race_Female_18_64",
    variable == "C21001F_014" ~ "Vet_Other_Race_Female_65_Plus",

    # Two or More Races (C21001G)
    variable == "C21001G_001" ~ "Vet_Two_Plus_Races_Total_Pop",
    variable == "C21001G_004" ~ "Vet_Two_Plus_Races_Male_18_64",
    variable == "C21001G_007" ~ "Vet_Two_Plus_Races_Male_65_Plus",
    variable == "C21001G_011" ~ "Vet_Two_Plus_Races_Female_18_64",
    variable == "C21001G_014" ~ "Vet_Two_Plus_Races_Female_65_Plus",

    # Hispanic or Latino (C21001I)
    variable == "C21001I_001" ~ "Vet_Latino_Total_Pop",
    variable == "C21001I_004" ~ "Vet_Latino_Male_18_64",
    variable == "C21001I_007" ~ "Vet_Latino_Male_65_Plus",
    variable == "C21001I_011" ~ "Vet_Latino_Female_18_64",
    variable == "C21001I_014" ~ "Vet_Latino_Female_65_Plus",
    
    # ==============================================================================
    # PERIOD OF MILITARY SERVICE (B21002) - Veterans can serve multiple periods
    # ==============================================================================
    variable == "B21002_001" ~ "Vet_Period_Total",
    variable == "B21002_002" ~ "Vet_Gulf_War_Post_9_11_Only",
    variable == "B21002_003" ~ "Vet_Gulf_War_Post_9_11_And_Pre_9_11",
    variable == "B21002_004" ~ "Vet_Gulf_War_Post_9_11_And_Pre_9_11_And_Vietnam",
    variable == "B21002_005" ~ "Vet_Gulf_War_Pre_9_11_Only",
    variable == "B21002_006" ~ "Vet_Gulf_War_Pre_9_11_And_Vietnam",
    variable == "B21002_007" ~ "Vet_Vietnam_Era_Only",
    variable == "B21002_008" ~ "Vet_Vietnam_And_Korean_War",
    variable == "B21002_009" ~ "Vet_Vietnam_And_Korean_And_WWII",
    variable == "B21002_010" ~ "Vet_Korean_War_Only",
    variable == "B21002_011" ~ "Vet_Korean_War_And_WWII",
    variable == "B21002_012" ~ "Vet_WWII_Only",
    variable == "B21002_013" ~ "Vet_Between_Gulf_War_And_Vietnam_Only",
    variable == "B21002_014" ~ "Vet_Between_Vietnam_And_Korean_Only",
    variable == "B21002_015" ~ "Vet_Between_Korean_And_WWII_Only",
    variable == "B21002_016" ~ "Vet_Pre_WWII_Only",

    # ==============================================================================
    # VETERAN EDUCATIONAL ATTAINMENT (B21003) - Population 25 Years and Over
    # ==============================================================================
    variable == "B21003_001" ~ "Vet_Ed_Total_Pop_25_Plus",
    variable == "B21003_002" ~ "Vet_Ed_Veteran_Total",
    variable == "B21003_003" ~ "Vet_Ed_Veteran_Less_Than_HS",
    variable == "B21003_004" ~ "Vet_Ed_Veteran_HS_Grad",
    variable == "B21003_005" ~ "Vet_Ed_Veteran_Some_College_AA",
    variable == "B21003_006" ~ "Vet_Ed_Veteran_Bachelors_Plus",
    variable == "B21003_007" ~ "Vet_Ed_NonVeteran_Total",
    variable == "B21003_008" ~ "Vet_Ed_NonVeteran_Less_Than_HS",
    variable == "B21003_009" ~ "Vet_Ed_NonVeteran_HS_Grad",
    variable == "B21003_010" ~ "Vet_Ed_NonVeteran_Some_College_AA",
    variable == "B21003_011" ~ "Vet_Ed_NonVeteran_Bachelors_Plus",

    # ==============================================================================
    # VETERAN MEDIAN INCOME (B21004)
    # ==============================================================================
    variable == "B21004_001" ~ "Vet_Median_Income_Total",
    variable == "B21004_002" ~ "Vet_Median_Income_Veteran_Total",
    variable == "B21004_003" ~ "Vet_Median_Income_Veteran_Male",
    variable == "B21004_004" ~ "Vet_Median_Income_Veteran_Female",
    variable == "B21004_005" ~ "Vet_Median_Income_NonVeteran_Total",
    variable == "B21004_006" ~ "Vet_Median_Income_NonVeteran_Male",
    variable == "B21004_007" ~ "Vet_Median_Income_NonVeteran_Female",

    # ==============================================================================
    # VETERAN EMPLOYMENT STATUS (B21005) - By Age Group, Will Aggregate
    # ==============================================================================
    # B21005: Age by Veteran Status by Employment Status for Civilian Pop 18-64
    variable == "B21005_001" ~ "Vet_Emp_Total_18_64",

    # 18 to 34 years - Veterans
    variable == "B21005_002" ~ "Vet_Emp_Total_18_34",
    variable == "B21005_003" ~ "Vet_Emp_Veteran_18_34_Total",
    variable == "B21005_004" ~ "Vet_Emp_Veteran_18_34_In_Labor_Force",
    variable == "B21005_005" ~ "Vet_Emp_Veteran_18_34_Employed",
    variable == "B21005_006" ~ "Vet_Emp_Veteran_18_34_Unemployed",
    variable == "B21005_007" ~ "Vet_Emp_Veteran_18_34_Not_In_Labor_Force",
    # 18 to 34 years - Nonveterans
    variable == "B21005_008" ~ "Vet_Emp_NonVet_18_34_Total",
    variable == "B21005_009" ~ "Vet_Emp_NonVet_18_34_In_Labor_Force",
    variable == "B21005_010" ~ "Vet_Emp_NonVet_18_34_Employed",
    variable == "B21005_011" ~ "Vet_Emp_NonVet_18_34_Unemployed",
    variable == "B21005_012" ~ "Vet_Emp_NonVet_18_34_Not_In_Labor_Force",

    # 35 to 54 years - Veterans
    variable == "B21005_013" ~ "Vet_Emp_Total_35_54",
    variable == "B21005_014" ~ "Vet_Emp_Veteran_35_54_Total",
    variable == "B21005_015" ~ "Vet_Emp_Veteran_35_54_In_Labor_Force",
    variable == "B21005_016" ~ "Vet_Emp_Veteran_35_54_Employed",
    variable == "B21005_017" ~ "Vet_Emp_Veteran_35_54_Unemployed",
    variable == "B21005_018" ~ "Vet_Emp_Veteran_35_54_Not_In_Labor_Force",
    # 35 to 54 years - Nonveterans
    variable == "B21005_019" ~ "Vet_Emp_NonVet_35_54_Total",
    variable == "B21005_020" ~ "Vet_Emp_NonVet_35_54_In_Labor_Force",
    variable == "B21005_021" ~ "Vet_Emp_NonVet_35_54_Employed",
    variable == "B21005_022" ~ "Vet_Emp_NonVet_35_54_Unemployed",
    variable == "B21005_023" ~ "Vet_Emp_NonVet_35_54_Not_In_Labor_Force",

    # 55 to 64 years - Veterans
    variable == "B21005_024" ~ "Vet_Emp_Total_55_64",
    variable == "B21005_025" ~ "Vet_Emp_Veteran_55_64_Total",
    variable == "B21005_026" ~ "Vet_Emp_Veteran_55_64_In_Labor_Force",
    variable == "B21005_027" ~ "Vet_Emp_Veteran_55_64_Employed",
    variable == "B21005_028" ~ "Vet_Emp_Veteran_55_64_Unemployed",
    variable == "B21005_029" ~ "Vet_Emp_Veteran_55_64_Not_In_Labor_Force",
    # 55 to 64 years - Nonveterans
    variable == "B21005_030" ~ "Vet_Emp_NonVet_55_64_Total",
    variable == "B21005_031" ~ "Vet_Emp_NonVet_55_64_In_Labor_Force",
    variable == "B21005_032" ~ "Vet_Emp_NonVet_55_64_Employed",
    variable == "B21005_033" ~ "Vet_Emp_NonVet_55_64_Unemployed",
    variable == "B21005_034" ~ "Vet_Emp_NonVet_55_64_Not_In_Labor_Force",

    # ==============================================================================
    # VETERAN POVERTY & DISABILITY STATUS (C21007) - Simplified Age Groups
    # ==============================================================================

    # Veterans 18-64 years
    variable == "C21007_001" ~ "Vet_Pov_Total_Pop_18_Plus",
    variable == "C21007_002" ~ "Vet_Pov_Total_18_64",
    variable == "C21007_003" ~ "Vet_Pov_Veteran_18_64",
    variable == "C21007_004" ~ "Vet_Pov_Veteran_18_64_Below_Poverty",
    variable == "C21007_005" ~ "Vet_Pov_Veteran_18_64_Below_Poverty_With_Disability",
    variable == "C21007_006" ~ "Vet_Pov_Veteran_18_64_Below_Poverty_No_Disability",
    variable == "C21007_007" ~ "Vet_Pov_Veteran_18_64_At_Above_Poverty",
    variable == "C21007_008" ~ "Vet_Pov_Veteran_18_64_At_Above_Poverty_With_Disability",
    variable == "C21007_009" ~ "Vet_Pov_Veteran_18_64_At_Above_Poverty_No_Disability",

    variable == "C21007_010" ~ "Vet_Pov_NonVeteran_18_64",
    variable == "C21007_011" ~ "Vet_Pov_NonVeteran_18_64_Below_Poverty",
    variable == "C21007_012" ~ "Vet_Pov_NonVeteran_18_64_Below_Poverty_With_Disability",
    variable == "C21007_013" ~ "Vet_Pov_NonVeteran_18_64_Below_Poverty_No_Disability",
    variable == "C21007_014" ~ "Vet_Pov_NonVeteran_18_64_At_Above_Poverty",
    variable == "C21007_015" ~ "Vet_Pov_NonVeteran_18_64_At_Above_Poverty_With_Disability",
    variable == "C21007_016" ~ "Vet_Pov_NonVeteran_18_64_At_Above_Poverty_No_Disability",

    # Veterans 65 years and over
    variable == "C21007_017" ~ "Vet_Pov_Total_65_Plus",
    variable == "C21007_018" ~ "Vet_Pov_Veteran_65_Plus",
    variable == "C21007_019" ~ "Vet_Pov_Veteran_65_Plus_Below_Poverty",
    variable == "C21007_020" ~ "Vet_Pov_Veteran_65_Plus_Below_Poverty_With_Disability",
    variable == "C21007_021" ~ "Vet_Pov_Veteran_65_Plus_Below_Poverty_No_Disability",
    variable == "C21007_022" ~ "Vet_Pov_Veteran_65_Plus_At_Above_Poverty",
    variable == "C21007_023" ~ "Vet_Pov_Veteran_65_Plus_At_Above_Poverty_With_Disability",
    variable == "C21007_024" ~ "Vet_Pov_Veteran_65_Plus_At_Above_Poverty_No_Disability",

    variable == "C21007_025" ~ "Vet_Pov_NonVeteran_65_Plus",
    variable == "C21007_026" ~ "Vet_Pov_NonVeteran_65_Plus_Below_Poverty",
    variable == "C21007_027" ~ "Vet_Pov_NonVeteran_65_Plus_Below_Poverty_With_Disability",
    variable == "C21007_028" ~ "Vet_Pov_NonVeteran_65_Plus_Below_Poverty_No_Disability",
    variable == "C21007_029" ~ "Vet_Pov_NonVeteran_65_Plus_At_Above_Poverty",
    variable == "C21007_030" ~ "Vet_Pov_NonVeteran_65_Plus_At_Above_Poverty_With_Disability",
    variable == "C21007_031" ~ "Vet_Pov_NonVeteran_65_Plus_At_Above_Poverty_No_Disability",

    # ==============================================================================
    # SERVICE-CONNECTED DISABILITY RATING (B21100 - Detailed, C21100 - Summary)
    # ==============================================================================

    # B21100 - Detailed Disability Ratings
    variable == "B21100_001" ~ "Vet_Dis_Rating_Total",
    variable == "B21100_002" ~ "Vet_Dis_No_Rating",
    variable == "B21100_003" ~ "Vet_Dis_Has_Rating",
    variable == "B21100_004" ~ "Vet_Dis_Rating_0_Pct",
    variable == "B21100_005" ~ "Vet_Dis_Rating_10_20_Pct",
    variable == "B21100_006" ~ "Vet_Dis_Rating_30_40_Pct",
    variable == "B21100_007" ~ "Vet_Dis_Rating_50_60_Pct",
    variable == "B21100_008" ~ "Vet_Dis_Rating_70_Plus_Pct",
    variable == "B21100_009" ~ "Vet_Dis_Rating_Not_Reported",

    # C21100 - Summary (simpler version)
    variable == "C21100_001" ~ "Vet_Dis_Summary_Total",
    variable == "C21100_002" ~ "Vet_Dis_Summary_No_Rating",
    variable == "C21100_003" ~ "Vet_Dis_Summary_Has_Rating",
    
    TRUE ~ variable
  ))

# Aggregate data for variables that need summing
aggregated_data <- wide_data %>%
  group_by(GEOID, NAME, friendly_name) %>%
  summarise(estimate = sum(estimate, na.rm = TRUE), .groups = "drop")

# Pivot to wide format
final_wide_data <- aggregated_data %>%
  pivot_wider(
    names_from = friendly_name,
    values_from = estimate
  )

# Calculate aggregated multi-family housing categories
final_wide_data <- final_wide_data %>%
  mutate(
    # Aggregate multi-family categories
    Multi_Family_All_Units = rowSums(
      select(., starts_with("Multi_Family_")), 
      na.rm = TRUE
    ),
    Multi_Family_2_4_Units = rowSums(
      select(., matches("Multi_Family_(2|3_4)_Units")),
      na.rm = TRUE
    ),
    Multi_Family_5_Plus_Units = rowSums(
      select(., matches("Multi_Family_(5_9|10_19|20_49|50_Plus)_Units")),
      na.rm = TRUE
    ),
    Multi_Family_10_Plus_Units = rowSums(
      select(., matches("Multi_Family_(10_19|20_49|50_Plus)_Units")),
      na.rm = TRUE
    ),
    Multi_Family_20_Plus_Units = rowSums(
      select(., matches("Multi_Family_(20_49|50_Plus)_Units")),
      na.rm = TRUE
    ),
    
    # Aggregate bedroom categories
    Two_Plus_Bedroom_Units = rowSums(
      select(., matches("(Two|Three|Four|Five_Plus)_Bedrooms")),
      na.rm = TRUE
    ),
    Three_Plus_Bedroom_Units = rowSums(
      select(., matches("(Three|Four|Five_Plus)_Bedrooms")),
      na.rm = TRUE
    ),
    
    # Aggregate income distribution categories
    Low_Income_Under_35K = rowSums(
      select(., matches("Income_(Under_10K|10K_15K|15K_20K|20K_25K|25K_30K|30K_35K)")),
      na.rm = TRUE
    ),
    Middle_Income_35K_100K = rowSums(
      select(., matches("Income_(35K_40K|40K_45K|45K_50K|50K_60K|60K_75K|75K_100K)")),
      na.rm = TRUE
    ),
    High_Income_100K_Plus = rowSums(
      select(., matches("Income_(100K_125K|125K_150K|150K_200K|200K_Plus)")),
      na.rm = TRUE
    ),
    
    # Aggregate rent burden categories
    High_Rent_Burden_30_Plus_Units = rowSums(
      select(., matches("Rent_Burden_(30_34_9|35_39_9|40_49_9|50_Plus)_Pct")),
      na.rm = TRUE
    ),
    High_Rent_Burden_50_Plus_Units = Rent_Burden_50_Plus_Pct,
    
    # ==============================================================================
    # AGGREGATIONS FOR NEW DATA
    # ==============================================================================
    
    # Total disability counts
    Total_With_Disability = rowSums(
      select(., matches("(Male|Female)_With_Disability")),
      na.rm = TRUE
    ),
    Total_No_Disability = rowSums(
      select(., matches("(Male|Female)_No_Disability")),
      na.rm = TRUE
    ),
    
    # Education aggregations - Total Population
    Total_Bachelors_Plus = rowSums(
      select(., matches("(Bachelors_Degree|Graduate_Or_Professional)")),
      na.rm = TRUE
    ),
    
    # Commute time aggregations
    Commute_Under_30_Min = rowSums(
      select(., matches("Commute_(Under_5|5_9|10_14|15_19|20_24|25_29)_Min")),
      na.rm = TRUE
    ),
    Commute_30_59_Min = rowSums(
      select(., matches("Commute_(30_34|35_44|45_59)_Min")),
      na.rm = TRUE
    ),
    Commute_60_Plus_Min = rowSums(
      select(., matches("Commute_(60_89|90_Plus)_Min")),
      na.rm = TRUE
    ),
    
    # Vehicle availability aggregations
    Total_Owner_No_Vehicle = Owner_No_Vehicle,
    Total_Renter_No_Vehicle = Renter_No_Vehicle,
    Total_No_Vehicle = rowSums(
      select(., matches("(Owner|Renter)_No_Vehicle")),
      na.rm = TRUE
    ),
    Total_With_Vehicle = rowSums(
      select(., matches("(Owner|Renter)_(1|2|3_Plus)_Vehicle")),
      na.rm = TRUE
    ),
    
    # Recent movers
    Total_Moved_Since_2020 = Moved_In_2020_Later,
    Total_Moved_Since_2010 = rowSums(
      select(., matches("Moved_In_(2020_Later|2010_2019)")),
      na.rm = TRUE
    )
  )

# ==============================================================================
# CALCULATE DERIVED VARIABLES
# ==============================================================================

cat("Calculating derived variables...\n")

final_wide_data <- final_wide_data %>%
  mutate(
    # Housing Percentages
    Pct_Vacant = (Vacant_Units / Total_Housing_Units) * 100,
    Pct_Owner_Occupied = (Owner_Occupied / Occupied_Units) * 100,
    Pct_Renter_Occupied = (Renter_Occupied / Occupied_Units) * 100,
    Pct_Single_Family = (Single_Family_Detached / Total_Housing_Units) * 100,
    Pct_Multi_Family_5_Plus = (Multi_Family_5_Plus_Units / Total_Housing_Units) * 100,
    
    # Demographics
    Pct_Below_Poverty = (Below_Poverty_Level / Total_Population) * 100,
    Pct_Black = (Black_Alone / Total_Population) * 100,
    Pct_White = (White_Alone / Total_Population) * 100,
    Pct_Asian = (Asian_Alone / Total_Population) * 100,
    Pct_Hispanic = (Hispanic_Latino / Total_Population) * 100,
    Pct_Households_With_Children = (Households_With_Children_Under_18 / Total_Households) * 100,
    
    # Housing Characteristics
    Occupancy_Rate = (Occupied_Units / Total_Housing_Units) * 100,
    Avg_Household_Size = Total_Population / Occupied_Units,
    
    # Affordability - Standard Metrics
    Rent_Burden_Ratio = (Median_Gross_Rent / Median_Household_Income) * 100,
    Price_To_Income_Ratio = Median_Home_Value / Median_Income_Owner_Occupied,
    
    # ==============================================================================
    # PERCENTAGES FOR NEW DATA (with existence checks)
    # ==============================================================================
    
    # Elderly Living Alone (calculated from existing data)
    # Population 65+ who are nonfamily living alone
    Elderly_Living_Alone = NA_real_,  # Will calculate if age data available
    Pct_Elderly_Living_Alone = NA_real_
  )

# Note: Veteran disability percentages are now calculated in the main veteran calculations section

# Add remaining enrichment percentages
final_wide_data <- final_wide_data %>%
  mutate(
    # Disability Percentages (general population)
    Pct_With_Disability = if("Total_With_Disability" %in% names(.)) {
      (Total_With_Disability / Total_Pop_Disability_Universe) * 100
    } else NA_real_,
    
    # Education Percentages - Total Population
    Pct_Less_Than_HS = if("Less_Than_HS" %in% names(.)) {
      (Less_Than_HS / Total_Pop_25_Plus) * 100
    } else NA_real_,
    Pct_HS_Grad = if("HS_Grad_Or_Equivalent" %in% names(.)) {
      (HS_Grad_Or_Equivalent / Total_Pop_25_Plus) * 100
    } else NA_real_,
    Pct_Some_College = if("Some_College_Or_Associates" %in% names(.)) {
      (Some_College_Or_Associates / Total_Pop_25_Plus) * 100
    } else NA_real_,
    Pct_Bachelors = if("Bachelors_Degree" %in% names(.)) {
      (Bachelors_Degree / Total_Pop_25_Plus) * 100
    } else NA_real_,
    Pct_Graduate = if("Graduate_Or_Professional" %in% names(.)) {
      (Graduate_Or_Professional / Total_Pop_25_Plus) * 100
    } else NA_real_,
    Pct_Bachelors_Plus = if("Total_Bachelors_Plus" %in% names(.)) {
      (Total_Bachelors_Plus / Total_Pop_25_Plus) * 100
    } else NA_real_,
    
    # Health Insurance Percentages
    Pct_With_Health_Insurance = if("With_Health_Insurance" %in% names(.)) {
      (With_Health_Insurance / Total_Pop_Insurance_Universe) * 100
    } else NA_real_,
    Pct_No_Health_Insurance = if("No_Health_Insurance" %in% names(.)) {
      (No_Health_Insurance / Total_Pop_Insurance_Universe) * 100
    } else NA_real_,
    Pct_Employed_With_Insurance = if(all(c("Employed_Total", "Employed_With_Health_Insurance") %in% names(.))) {
      (Employed_With_Health_Insurance / Employed_Total) * 100
    } else NA_real_,

    # Children's Insurance Percentages (Ages 0-18)
    Total_Children_Under_18 = if(all(c("Children_With_Insurance", "Children_No_Insurance") %in% names(.))) {
      Children_With_Insurance + Children_No_Insurance
    } else NA_real_,
    Pct_Children_With_Insurance = if(all(c("Children_With_Insurance", "Total_Children_Under_18") %in% names(.))) {
      (Children_With_Insurance / Total_Children_Under_18) * 100
    } else NA_real_,
    Pct_Children_No_Insurance = if(all(c("Children_No_Insurance", "Total_Children_Under_18") %in% names(.))) {
      (Children_No_Insurance / Total_Children_Under_18) * 100
    } else NA_real_,
    
    # Health Insurance by Type Percentages (% of total population)
    Pct_With_Private_Insurance = if("With_Private_Insurance" %in% names(.)) {
      (With_Private_Insurance / Total_Pop_Insurance_Universe) * 100
    } else NA_real_,
    Pct_With_Public_Coverage = if("With_Public_Coverage" %in% names(.)) {
      (With_Public_Coverage / Total_Pop_Insurance_Universe) * 100
    } else NA_real_,
    Pct_With_Employer_Insurance = if("With_Employer_Insurance" %in% names(.)) {
      (With_Employer_Insurance / Total_Pop_Insurance_Universe) * 100
    } else NA_real_,
    Pct_With_DirectPurchase_Insurance = if("With_DirectPurchase_Insurance" %in% names(.)) {
      (With_DirectPurchase_Insurance / Total_Pop_Insurance_Universe) * 100
    } else NA_real_,
    Pct_With_Medicare = if("With_Medicare" %in% names(.)) {
      (With_Medicare / Total_Pop_Insurance_Universe) * 100
    } else NA_real_,
    Pct_With_Medicaid = if("With_Medicaid" %in% names(.)) {
      (With_Medicaid / Total_Pop_Insurance_Universe) * 100
    } else NA_real_,
    Pct_With_TRICARE = if("With_TRICARE" %in% names(.)) {
      (With_TRICARE / Total_Pop_Insurance_Universe) * 100
    } else NA_real_,
    Pct_With_VA_HealthCare = if("With_VA_HealthCare" %in% names(.)) {
      (With_VA_HealthCare / Total_Pop_Insurance_Universe) * 100
    } else NA_real_,
    
    # Digital Access Percentages
    Pct_HH_With_Internet = if("HH_With_Internet" %in% names(.)) {
      (HH_With_Internet / Total_Households_Internet_Universe) * 100
    } else NA_real_,
    Pct_HH_With_Broadband = if("HH_Broadband" %in% names(.)) {
      (HH_Broadband / Total_Households_Internet_Universe) * 100
    } else NA_real_,
    Pct_HH_No_Computer = if("No_Computer" %in% names(.)) {
      (No_Computer / Total_Pop_Computer_Universe) * 100
    } else NA_real_,
    
    # Transportation Percentages
    Pct_Commute_Under_30 = if("Commute_Under_30_Min" %in% names(.)) {
      (Commute_Under_30_Min / Total_Workers_Commute_Universe) * 100
    } else NA_real_,
    Pct_Commute_30_59 = if("Commute_30_59_Min" %in% names(.)) {
      (Commute_30_59_Min / Total_Workers_Commute_Universe) * 100
    } else NA_real_,
    Pct_Commute_60_Plus = if("Commute_60_Plus_Min" %in% names(.)) {
      (Commute_60_Plus_Min / Total_Workers_Commute_Universe) * 100
    } else NA_real_,
    Pct_Work_At_Home = if("Work_At_Home" %in% names(.)) {
      (Work_At_Home / Total_Workers_Commute_Universe) * 100
    } else NA_real_,
    Pct_HH_No_Vehicle = if(all(c("Total_No_Vehicle", "Total_With_Vehicle") %in% names(.))) {
      (Total_No_Vehicle / (Total_No_Vehicle + Total_With_Vehicle)) * 100
    } else NA_real_,
    Pct_Owner_No_Vehicle = if(all(c("Owner_No_Vehicle", "Owner_1_Vehicle", "Owner_2_Vehicles", "Owner_3_Plus_Vehicles") %in% names(.))) {
      (Owner_No_Vehicle / (Owner_No_Vehicle + Owner_1_Vehicle + Owner_2_Vehicles + Owner_3_Plus_Vehicles)) * 100
    } else NA_real_,
    Pct_Renter_No_Vehicle = if(all(c("Renter_No_Vehicle", "Renter_1_Vehicle", "Renter_2_Vehicles", "Renter_3_Plus_Vehicles") %in% names(.))) {
      (Renter_No_Vehicle / (Renter_No_Vehicle + Renter_1_Vehicle + Renter_2_Vehicles + Renter_3_Plus_Vehicles)) * 100
    } else NA_real_,
    
    # Housing Stability Percentages
    Pct_Same_House_1_Year = if("Same_House_1_Year_Ago" %in% names(.)) {
      (Same_House_1_Year_Ago / Total_Pop_Mobility_Universe) * 100
    } else NA_real_,
    Pct_Moved_Within_County = if("Moved_Within_County" %in% names(.)) {
      (Moved_Within_County / Total_Pop_Mobility_Universe) * 100
    } else NA_real_,
    Pct_Moved_Since_2020 = if(all(c("Total_Moved_Since_2020", "Moved_In_2010_2019", "Moved_In_2000_2009", "Moved_In_1990_1999", "Moved_In_Before_1990") %in% names(.))) {
      (Total_Moved_Since_2020 / (Moved_In_2020_Later + Moved_In_2010_2019 + Moved_In_2000_2009 + Moved_In_1990_1999 + Moved_In_Before_1990)) * 100
    } else NA_real_,
    Pct_Moved_Since_2010 = if(all(c("Total_Moved_Since_2010", "Moved_In_2000_2009", "Moved_In_1990_1999", "Moved_In_Before_1990") %in% names(.))) {
      (Total_Moved_Since_2010 / (Moved_In_2020_Later + Moved_In_2010_2019 + Moved_In_2000_2009 + Moved_In_1990_1999 + Moved_In_Before_1990)) * 100
    } else NA_real_,
    
    # Economic Hardship Percentages - SNAP
    Pct_HH_SNAP = if("HH_Received_SNAP" %in% names(.)) {
      (HH_Received_SNAP / Total_HH_SNAP_Universe) * 100
    } else NA_real_,
    Pct_HH_No_SNAP = if("HH_No_SNAP" %in% names(.)) {
      (HH_No_SNAP / Total_HH_SNAP_Universe) * 100
    } else NA_real_,

    # SNAP - Families with Children
    Total_HH_With_Children = if(all(c("HH_SNAP_With_Children", "HH_No_SNAP_With_Children") %in% names(.))) {
      HH_SNAP_With_Children + HH_No_SNAP_With_Children
    } else NA_real_,
    Pct_HH_With_Children_On_SNAP = if(all(c("HH_SNAP_With_Children", "Total_HH_With_Children") %in% names(.))) {
      (HH_SNAP_With_Children / Total_HH_With_Children) * 100
    } else NA_real_,

    # SNAP - By Poverty Status
    Pct_HH_SNAP_Below_Poverty = if(all(c("HH_SNAP_Below_Poverty", "HH_No_SNAP_Below_Poverty") %in% names(.))) {
      (HH_SNAP_Below_Poverty / (HH_SNAP_Below_Poverty + HH_No_SNAP_Below_Poverty)) * 100
    } else NA_real_,
    Pct_HH_SNAP_At_Above_Poverty = if(all(c("HH_SNAP_At_Above_Poverty", "HH_No_SNAP_At_Above_Poverty") %in% names(.))) {
      (HH_SNAP_At_Above_Poverty / (HH_SNAP_At_Above_Poverty + HH_No_SNAP_At_Above_Poverty)) * 100
    } else NA_real_,

    # SSI and Public Assistance Percentages
    Pct_HH_With_Social_Security = if("HH_With_Social_Security" %in% names(.)) {
      (HH_With_Social_Security / Total_HH_SSI_Universe) * 100
    } else NA_real_,
    Pct_HH_With_SSI = if("HH_With_SSI" %in% names(.)) {
      (HH_With_SSI / Total_HH_SupplementalSSI_Universe) * 100
    } else NA_real_,
    Pct_HH_Public_Assistance = if("HH_With_Public_Assistance" %in% names(.)) {
      (HH_With_Public_Assistance / Total_HH_PublicAssist_Universe) * 100
    } else NA_real_,
    Pct_HH_PublicAssist_Or_SNAP = if("HH_With_PublicAssist_Or_SNAP" %in% names(.)) {
      (HH_With_PublicAssist_Or_SNAP / Total_HH_PublicAssist_Or_SNAP_Universe) * 100
    } else NA_real_,
    
    # Multigenerational Household Percentages
    Pct_Multigenerational = if("Multigenerational_Households" %in% names(.)) {
      (Multigenerational_Households / Total_Households_Multigen_Universe) * 100
    } else NA_real_,
    Pct_Grandparents_Caring = if("Grandparents_Responsible_For_Grandchildren" %in% names(.)) {
      (Grandparents_Responsible_For_Grandchildren / Total_Grandparents_Universe) * 100
    } else NA_real_,

    # ==============================================================================
    # HOUSING VULNERABILITY METRICS
    # ==============================================================================

    # Elderly Homeowners - Aging in Place Vulnerability
    Owner_Householder_65_Plus = if(all(c("Owner_Householder_65_74", "Owner_Householder_75_84", "Owner_Householder_85_Plus") %in% names(.))) {
      Owner_Householder_65_74 + Owner_Householder_75_84 + Owner_Householder_85_Plus
    } else NA_real_,
    Owner_Householder_75_Plus = if(all(c("Owner_Householder_75_84", "Owner_Householder_85_Plus") %in% names(.))) {
      Owner_Householder_75_84 + Owner_Householder_85_Plus
    } else NA_real_,
    Pct_Owners_65_Plus = if(all(c("Owner_Householder_65_Plus", "Owner_Occupied") %in% names(.))) {
      (Owner_Householder_65_Plus / Owner_Occupied) * 100
    } else NA_real_,
    Pct_Owners_75_Plus = if(all(c("Owner_Householder_75_Plus", "Owner_Occupied") %in% names(.))) {
      (Owner_Householder_75_Plus / Owner_Occupied) * 100
    } else NA_real_,
    Pct_Owners_85_Plus = if(all(c("Owner_Householder_85_Plus", "Owner_Occupied") %in% names(.))) {
      (Owner_Householder_85_Plus / Owner_Occupied) * 100
    } else NA_real_,

    # Overcrowding Metrics (>1.0 occupants per room)
    Owner_Overcrowded = if(all(c("Owner_1_01_To_1_5_Per_Room", "Owner_1_51_To_2_Per_Room", "Owner_2_Plus_Per_Room") %in% names(.))) {
      Owner_1_01_To_1_5_Per_Room + Owner_1_51_To_2_Per_Room + Owner_2_Plus_Per_Room
    } else NA_real_,
    Renter_Overcrowded = if(all(c("Renter_1_01_To_1_5_Per_Room", "Renter_1_51_To_2_Per_Room", "Renter_2_Plus_Per_Room") %in% names(.))) {
      Renter_1_01_To_1_5_Per_Room + Renter_1_51_To_2_Per_Room + Renter_2_Plus_Per_Room
    } else NA_real_,
    Total_Overcrowded = if(all(c("Owner_Overcrowded", "Renter_Overcrowded") %in% names(.))) {
      Owner_Overcrowded + Renter_Overcrowded
    } else NA_real_,
    Pct_Owner_Overcrowded = if(all(c("Owner_Overcrowded", "Owner_Occupied") %in% names(.))) {
      (Owner_Overcrowded / Owner_Occupied) * 100
    } else NA_real_,
    Pct_Renter_Overcrowded = if(all(c("Renter_Overcrowded", "Renter_Occupied") %in% names(.))) {
      (Renter_Overcrowded / Renter_Occupied) * 100
    } else NA_real_,
    Pct_All_HH_Overcrowded = if(all(c("Total_Overcrowded", "Occupied_Units") %in% names(.))) {
      (Total_Overcrowded / Occupied_Units) * 100
    } else NA_real_,

    # Housing Cost Burden - Owners (30%+ of income on housing)
    Owner_Cost_Burden_30_Plus = if(all(c("Owner_Cost_Burden_30_34_9_Pct", "Owner_Cost_Burden_35_39_9_Pct", "Owner_Cost_Burden_40_49_9_Pct", "Owner_Cost_Burden_50_Plus_Pct") %in% names(.))) {
      Owner_Cost_Burden_30_34_9_Pct + Owner_Cost_Burden_35_39_9_Pct + Owner_Cost_Burden_40_49_9_Pct + Owner_Cost_Burden_50_Plus_Pct
    } else NA_real_,
    Owner_Cost_Burden_50_Plus = if("Owner_Cost_Burden_50_Plus_Pct" %in% names(.)) {
      Owner_Cost_Burden_50_Plus_Pct
    } else NA_real_,
    Pct_Owners_Cost_Burdened_30_Plus = if(all(c("Owner_Cost_Burden_30_Plus", "Owner_Occupied") %in% names(.))) {
      (Owner_Cost_Burden_30_Plus / Owner_Occupied) * 100
    } else NA_real_,
    Pct_Owners_Cost_Burdened_50_Plus = if(all(c("Owner_Cost_Burden_50_Plus", "Owner_Occupied") %in% names(.))) {
      (Owner_Cost_Burden_50_Plus / Owner_Occupied) * 100
    } else NA_real_,

    # Housing Cost Burden - Renters (30%+ of income on rent)
    Renter_Cost_Burden_30_Plus = if(all(c("Rent_Burden_30_34_9_Pct", "Rent_Burden_35_39_9_Pct", "Rent_Burden_40_49_9_Pct", "Rent_Burden_50_Plus_Pct") %in% names(.))) {
      Rent_Burden_30_34_9_Pct + Rent_Burden_35_39_9_Pct + Rent_Burden_40_49_9_Pct + Rent_Burden_50_Plus_Pct
    } else NA_real_,
    Renter_Cost_Burden_50_Plus = if("Rent_Burden_50_Plus_Pct" %in% names(.)) {
      Rent_Burden_50_Plus_Pct
    } else NA_real_,
    Pct_Renters_Cost_Burdened_30_Plus = if(all(c("Renter_Cost_Burden_30_Plus", "Total_Renters_Cost_Burden_Universe") %in% names(.))) {
      (Renter_Cost_Burden_30_Plus / Total_Renters_Cost_Burden_Universe) * 100
    } else NA_real_,
    Pct_Renters_Cost_Burdened_50_Plus = if(all(c("Renter_Cost_Burden_50_Plus", "Total_Renters_Cost_Burden_Universe") %in% names(.))) {
      (Renter_Cost_Burden_50_Plus / Total_Renters_Cost_Burden_Universe) * 100
    } else NA_real_,

    # Combined Housing Cost Burden (both owners and renters)
    Total_Cost_Burdened_30_Plus = if(all(c("Owner_Cost_Burden_30_Plus", "Renter_Cost_Burden_30_Plus") %in% names(.))) {
      Owner_Cost_Burden_30_Plus + Renter_Cost_Burden_30_Plus
    } else NA_real_,
    Total_Cost_Burdened_50_Plus = if(all(c("Owner_Cost_Burden_50_Plus", "Renter_Cost_Burden_50_Plus") %in% names(.))) {
      Owner_Cost_Burden_50_Plus + Renter_Cost_Burden_50_Plus
    } else NA_real_,
    Pct_All_HH_Cost_Burdened_30_Plus = if(all(c("Total_Cost_Burdened_30_Plus", "Occupied_Units") %in% names(.))) {
      (Total_Cost_Burdened_30_Plus / Occupied_Units) * 100
    } else NA_real_,
    Pct_All_HH_Cost_Burdened_50_Plus = if(all(c("Total_Cost_Burdened_50_Plus", "Occupied_Units") %in% names(.))) {
      (Total_Cost_Burdened_50_Plus / Occupied_Units) * 100
    } else NA_real_
  )

# ==============================================================================
# VETERANS CALCULATIONS
# ==============================================================================

final_wide_data <- final_wide_data %>%
  mutate(
    # Calculate veteran totals by race
    Vet_Total_White = rowSums(
      select(., matches("Vet_White_(Male|Female)")), 
      na.rm = TRUE
    ),
    Vet_Total_Black = rowSums(
      select(., matches("Vet_Black_(Male|Female)")), 
      na.rm = TRUE
    ),
    Vet_Total_Asian = rowSums(
      select(., matches("Vet_Asian_(Male|Female)")), 
      na.rm = TRUE
    ),
    Vet_Total_Latino = rowSums(
      select(., matches("Vet_Latino_(Male|Female)")), 
      na.rm = TRUE
    ),
    
    # Calculate veteran age groups
    Vet_Total_18_34 = rowSums(
      select(., matches("Vet_(Male|Female)_18_34")),
      na.rm = TRUE
    ),
    Vet_Total_35_54 = rowSums(
      select(., matches("Vet_(Male|Female)_35_54")),
      na.rm = TRUE
    ),
    Vet_Total_55_64 = rowSums(
      select(., matches("Vet_(Male|Female)_55_64")),
      na.rm = TRUE
    ),
    Vet_Total_65_74 = rowSums(
      select(., matches("Vet_(Male|Female)_65_74")),
      na.rm = TRUE
    ),
    Vet_Total_75_Plus = rowSums(
      select(., matches("Vet_(Male|Female)_75_Plus")),
      na.rm = TRUE
    ),
    
    # Veteran Percentages
    Pct_Veterans_Of_Adult_Pop = (Vet_Total_Veterans / Vet_Total_Pop_18_Plus) * 100,
    Pct_Veterans_Male = (Vet_Male_Veterans / Vet_Total_Veterans) * 100,
    Pct_Veterans_Female = (Vet_Female_Veterans / Vet_Total_Veterans) * 100,
    
    # Veteran Race Percentages (of total veterans)
    Pct_Veterans_White = (Vet_Total_White / Vet_Total_Veterans) * 100,
    Pct_Veterans_Black = (Vet_Total_Black / Vet_Total_Veterans) * 100,
    Pct_Veterans_Asian = (Vet_Total_Asian / Vet_Total_Veterans) * 100,
    Pct_Veterans_Latino = (Vet_Total_Latino / Vet_Total_Veterans) * 100,
    
    # Veteran Age Percentages (of total veterans)
    Pct_Veterans_18_34 = (Vet_Total_18_34 / Vet_Total_Veterans) * 100,
    Pct_Veterans_35_54 = (Vet_Total_35_54 / Vet_Total_Veterans) * 100,
    Pct_Veterans_55_64 = (Vet_Total_55_64 / Vet_Total_Veterans) * 100,
    Pct_Veterans_65_Plus = ((Vet_Total_65_74 + Vet_Total_75_Plus) / Vet_Total_Veterans) * 100
  )

# ==============================================================================
# ADDITIONAL VETERAN CALCULATIONS - NEW DATA CATEGORIES
# ==============================================================================

final_wide_data <- final_wide_data %>%
  mutate(
    # Period of Service Aggregations (note: veterans can serve multiple periods)
    Vet_Any_Post_9_11 = rowSums(
      select(., matches("Vet_Gulf_War_Post_9_11")),
      na.rm = TRUE
    ),
    Vet_Any_Gulf_War = rowSums(
      select(., matches("Vet_Gulf_War")),
      na.rm = TRUE
    ),
    Vet_Any_Vietnam = rowSums(
      select(., matches("Vet_Vietnam")),
      na.rm = TRUE
    ),

    # Veteran Education Percentages
    Pct_Vet_Ed_Less_Than_HS = if("Vet_Ed_Veteran_Less_Than_HS" %in% names(.)) {
      (Vet_Ed_Veteran_Less_Than_HS / Vet_Ed_Veteran_Total) * 100
    } else NA_real_,
    Pct_Vet_Ed_HS_Grad = if("Vet_Ed_Veteran_HS_Grad" %in% names(.)) {
      (Vet_Ed_Veteran_HS_Grad / Vet_Ed_Veteran_Total) * 100
    } else NA_real_,
    Pct_Vet_Ed_Some_College = if("Vet_Ed_Veteran_Some_College_AA" %in% names(.)) {
      (Vet_Ed_Veteran_Some_College_AA / Vet_Ed_Veteran_Total) * 100
    } else NA_real_,
    Pct_Vet_Ed_Bachelors_Plus = if("Vet_Ed_Veteran_Bachelors_Plus" %in% names(.)) {
      (Vet_Ed_Veteran_Bachelors_Plus / Vet_Ed_Veteran_Total) * 100
    } else NA_real_,

    # Veteran Poverty Rates (18-64)
    Pct_Vet_18_64_In_Poverty = if("Vet_Pov_Veteran_18_64_Below_Poverty" %in% names(.)) {
      (Vet_Pov_Veteran_18_64_Below_Poverty / Vet_Pov_Veteran_18_64) * 100
    } else NA_real_,

    # Veteran Poverty Rates (65+)
    Pct_Vet_65_Plus_In_Poverty = if("Vet_Pov_Veteran_65_Plus_Below_Poverty" %in% names(.)) {
      (Vet_Pov_Veteran_65_Plus_Below_Poverty / Vet_Pov_Veteran_65_Plus) * 100
    } else NA_real_,

    # Veteran Disability Rates (among those in poverty)
    Pct_Vet_18_64_Poverty_With_Disability = if(all(c("Vet_Pov_Veteran_18_64_Below_Poverty_With_Disability", "Vet_Pov_Veteran_18_64_Below_Poverty") %in% names(.))) {
      (Vet_Pov_Veteran_18_64_Below_Poverty_With_Disability / Vet_Pov_Veteran_18_64_Below_Poverty) * 100
    } else NA_real_,

    Pct_Vet_65_Plus_Poverty_With_Disability = if(all(c("Vet_Pov_Veteran_65_Plus_Below_Poverty_With_Disability", "Vet_Pov_Veteran_65_Plus_Below_Poverty") %in% names(.))) {
      (Vet_Pov_Veteran_65_Plus_Below_Poverty_With_Disability / Vet_Pov_Veteran_65_Plus_Below_Poverty) * 100
    } else NA_real_,

    # Veteran Disability Rates (overall, among all veterans)
    Pct_Vet_18_64_With_Disability = if(all(c("Vet_Pov_Veteran_18_64_Below_Poverty_With_Disability", "Vet_Pov_Veteran_18_64_At_Above_Poverty_With_Disability", "Vet_Pov_Veteran_18_64") %in% names(.))) {
      ((Vet_Pov_Veteran_18_64_Below_Poverty_With_Disability + Vet_Pov_Veteran_18_64_At_Above_Poverty_With_Disability) / Vet_Pov_Veteran_18_64) * 100
    } else NA_real_,

    Pct_Vet_65_Plus_With_Disability = if(all(c("Vet_Pov_Veteran_65_Plus_Below_Poverty_With_Disability", "Vet_Pov_Veteran_65_Plus_At_Above_Poverty_With_Disability", "Vet_Pov_Veteran_65_Plus") %in% names(.))) {
      ((Vet_Pov_Veteran_65_Plus_Below_Poverty_With_Disability + Vet_Pov_Veteran_65_Plus_At_Above_Poverty_With_Disability) / Vet_Pov_Veteran_65_Plus) * 100
    } else NA_real_,

    # Service-Connected Disability Rating Percentages
    Pct_Vet_With_Service_Disability = if("Vet_Dis_Has_Rating" %in% names(.)) {
      (Vet_Dis_Has_Rating / Vet_Dis_Rating_Total) * 100
    } else NA_real_,

    Pct_Vet_Disability_70_Plus = if("Vet_Dis_Rating_70_Plus_Pct" %in% names(.)) {
      (Vet_Dis_Rating_70_Plus_Pct / Vet_Dis_Has_Rating) * 100
    } else NA_real_
  )

# Add employment percentages - aggregate B21005 age groups (18-34, 35-54, 55-64)
# Check if B21005 age-grouped variables exist
emp_vars_exist <- all(c(
  "Vet_Emp_Veteran_18_34_Total", "Vet_Emp_Veteran_35_54_Total", "Vet_Emp_Veteran_55_64_Total",
  "Vet_Emp_Veteran_18_34_In_Labor_Force", "Vet_Emp_Veteran_35_54_In_Labor_Force", "Vet_Emp_Veteran_55_64_In_Labor_Force",
  "Vet_Emp_Veteran_18_34_Employed", "Vet_Emp_Veteran_35_54_Employed", "Vet_Emp_Veteran_55_64_Employed",
  "Vet_Emp_Veteran_18_34_Unemployed", "Vet_Emp_Veteran_35_54_Unemployed", "Vet_Emp_Veteran_55_64_Unemployed"
) %in% names(final_wide_data))

if (emp_vars_exist) {
  final_wide_data <- final_wide_data %>%
    mutate(
      # Aggregate across age groups (18-64)
      Vet_Emp_Veteran_Total = Vet_Emp_Veteran_18_34_Total +
                               Vet_Emp_Veteran_35_54_Total +
                               Vet_Emp_Veteran_55_64_Total,
      Vet_Emp_Veteran_In_Labor_Force = Vet_Emp_Veteran_18_34_In_Labor_Force +
                                        Vet_Emp_Veteran_35_54_In_Labor_Force +
                                        Vet_Emp_Veteran_55_64_In_Labor_Force,
      Vet_Emp_Veteran_Employed = Vet_Emp_Veteran_18_34_Employed +
                                  Vet_Emp_Veteran_35_54_Employed +
                                  Vet_Emp_Veteran_55_64_Employed,
      Vet_Emp_Veteran_Unemployed = Vet_Emp_Veteran_18_34_Unemployed +
                                    Vet_Emp_Veteran_35_54_Unemployed +
                                    Vet_Emp_Veteran_55_64_Unemployed,
      # Calculate percentages
      Pct_Veterans_Employed = (Vet_Emp_Veteran_Employed / Vet_Emp_Veteran_In_Labor_Force) * 100,
      Pct_Veterans_Unemployed = (Vet_Emp_Veteran_Unemployed / Vet_Emp_Veteran_In_Labor_Force) * 100,
      Pct_Veterans_In_Labor_Force = (Vet_Emp_Veteran_In_Labor_Force / Vet_Emp_Veteran_Total) * 100
    )
  cat("Employment data aggregated across age groups (18-34, 35-54, 55-64)\n")
} else {
  cat("Warning: Employment data not available - skipping employment percentage calculations\n")
  final_wide_data <- final_wide_data %>%
    mutate(
      Pct_Veterans_Employed = NA_real_,
      Pct_Veterans_Unemployed = NA_real_,
      Pct_Veterans_In_Labor_Force = NA_real_
    )
}

# ==============================================================================
# SELECT KEY VARIABLES FOR OUTPUT
# ==============================================================================

cat("Selecting key variables for output...\n")

key_combined_data <- final_wide_data %>%
  select(
    # Geography
    GEOID, NAME,
    
    # Population
    Total_Population, White_Alone, Black_Alone, Asian_Alone, Hispanic_Latino,
    Pct_White, Pct_Black, Pct_Asian, Pct_Hispanic,
    
    # Housing Supply
    Total_Housing_Units, Occupied_Units, Vacant_Units, Pct_Vacant, Occupancy_Rate,
    Owner_Occupied, Renter_Occupied, Pct_Owner_Occupied, Pct_Renter_Occupied,
    
    # Structure Types
    Single_Family_Detached, Single_Family_Attached, Multi_Family_All_Units,
    Multi_Family_2_4_Units, Multi_Family_5_Plus_Units, 
    Multi_Family_10_Plus_Units, Multi_Family_20_Plus_Units,
    Mobile_Home, Pct_Single_Family, Pct_Multi_Family_5_Plus,
    
    # Unit Size
    No_Bedroom, One_Bedroom, Two_Bedrooms, Three_Bedrooms, Four_Bedrooms, Five_Plus_Bedrooms,
    Two_Plus_Bedroom_Units, Three_Plus_Bedroom_Units,
    
    # Year Built
    starts_with("Built_"),
    
    # Households
    Total_Households, Family_Households, Nonfamily_Living_Alone,
    Households_With_Children_Under_18, Pct_Households_With_Children,
    Total_Own_Children_Under_18, Children_In_Married_Couple_Families, 
    Children_In_Single_Mother_Families,
    Large_Owner_Households_4_Plus, Large_Renter_Households_4_Plus,
    Avg_Household_Size,
    
    # Financial
    Median_Home_Value, Median_Gross_Rent, Median_Household_Income,
    Median_Income_Owner_Occupied, Median_Income_Renter_Occupied,
    
    # Income Distribution - Individual Brackets
    starts_with("Income_"),
    
    # Income Distribution - Aggregated
    Low_Income_Under_35K, Middle_Income_35K_100K, High_Income_100K_Plus,
    
    # Poverty
    Below_Poverty_Level, Children_Below_Poverty, Pct_Below_Poverty,
    
    # Affordability
    Rent_Burden_Ratio, Price_To_Income_Ratio,
    
    # Rent Burden
    High_Rent_Burden_30_Plus_Units, High_Rent_Burden_50_Plus_Units,

    # ==============================================================================
    # HOUSING VULNERABILITY METRICS
    # ==============================================================================

    # Age of Householder - Aging in Place (B25007)
    any_of(c("Owner_Householder_15_24", "Owner_Householder_25_34", "Owner_Householder_35_44",
             "Owner_Householder_45_54", "Owner_Householder_55_59", "Owner_Householder_60_64",
             "Owner_Householder_65_74", "Owner_Householder_75_84", "Owner_Householder_85_Plus",
             "Renter_Householder_15_24", "Renter_Householder_25_34", "Renter_Householder_35_44",
             "Renter_Householder_45_54", "Renter_Householder_55_59", "Renter_Householder_60_64",
             "Renter_Householder_65_74", "Renter_Householder_75_84", "Renter_Householder_85_Plus",
             "Owner_Householder_65_Plus", "Owner_Householder_75_Plus",
             "Pct_Owners_65_Plus", "Pct_Owners_75_Plus", "Pct_Owners_85_Plus")),

    # Occupants Per Room - Overcrowding (B25014)
    any_of(c("Owner_0_5_Or_Less_Per_Room", "Owner_0_51_To_1_Per_Room",
             "Owner_1_01_To_1_5_Per_Room", "Owner_1_51_To_2_Per_Room", "Owner_2_Plus_Per_Room",
             "Renter_0_5_Or_Less_Per_Room", "Renter_0_51_To_1_Per_Room",
             "Renter_1_01_To_1_5_Per_Room", "Renter_1_51_To_2_Per_Room", "Renter_2_Plus_Per_Room",
             "Owner_Overcrowded", "Renter_Overcrowded", "Total_Overcrowded",
             "Pct_Owner_Overcrowded", "Pct_Renter_Overcrowded", "Pct_All_HH_Overcrowded")),

    # Housing Cost Burden - Owners (B25091, B25106)
    any_of(c("Owner_Cost_Burden_Less_20_Pct", "Owner_Cost_Burden_20_24_9_Pct", "Owner_Cost_Burden_25_29_9_Pct",
             "Owner_Cost_Burden_30_34_9_Pct", "Owner_Cost_Burden_35_39_9_Pct",
             "Owner_Cost_Burden_40_49_9_Pct", "Owner_Cost_Burden_50_Plus_Pct",
             "Owner_Cost_Burden_30_Plus", "Owner_Cost_Burden_50_Plus",
             "Pct_Owners_Cost_Burdened_30_Plus", "Pct_Owners_Cost_Burdened_50_Plus")),

    # Housing Cost Burden - Renters (B25070, B25106)
    any_of(c("Total_Renters_Cost_Burden_Universe",
             "Rent_Burden_Less_20_Pct", "Rent_Burden_20_24_9_Pct", "Rent_Burden_25_29_9_Pct",
             "Rent_Burden_30_34_9_Pct", "Rent_Burden_35_39_9_Pct",
             "Rent_Burden_40_49_9_Pct", "Rent_Burden_50_Plus_Pct",
             "Renter_Cost_Burden_30_Plus", "Renter_Cost_Burden_50_Plus",
             "Pct_Renters_Cost_Burdened_30_Plus", "Pct_Renters_Cost_Burdened_50_Plus")),

    # Combined Cost Burden (All Households)
    any_of(c("Total_Cost_Burdened_30_Plus", "Total_Cost_Burdened_50_Plus",
             "Pct_All_HH_Cost_Burdened_30_Plus", "Pct_All_HH_Cost_Burdened_50_Plus")),

    # ==============================================================================
    # DISABILITY DATA
    # ==============================================================================

    any_of(c("Total_With_Disability", "Total_No_Disability", "Pct_With_Disability")),
    
    # ==============================================================================
    # EDUCATION DATA
    # ==============================================================================
    
    # Total Population Education
    any_of(c("Total_Pop_25_Plus", "Less_Than_HS", "HS_Grad_Or_Equivalent", "Some_College_Or_Associates",
             "Bachelors_Degree", "Graduate_Or_Professional", "Total_Bachelors_Plus",
             "Pct_Less_Than_HS", "Pct_HS_Grad", "Pct_Some_College", "Pct_Bachelors", "Pct_Graduate", "Pct_Bachelors_Plus")),
    
    # Veteran vs Non-Veteran Education
    any_of(c("Vet_Education_Less_Than_HS", "Vet_Education_HS_Grad", "Vet_Education_Some_College", "Vet_Education_Bachelors_Plus",
             "NonVet_Education_Less_Than_HS", "NonVet_Education_HS_Grad", "NonVet_Education_Some_College", "NonVet_Education_Bachelors_Plus")),
    
    # ==============================================================================
    # HEALTH INSURANCE DATA
    # ==============================================================================
    
    # Overall Coverage Status
    any_of(c("Total_Pop_Insurance_Universe",
             "With_Health_Insurance", "No_Health_Insurance",
             "Pct_With_Health_Insurance", "Pct_No_Health_Insurance")),

    # Children's Insurance Coverage (Ages 0-18)
    any_of(c("Total_Children_Under_18",
             "Children_With_Insurance", "Children_No_Insurance",
             "Pct_Children_With_Insurance", "Pct_Children_No_Insurance")),
    
    # Insurance by Type (Counts)
    any_of(c("With_Private_Insurance", "With_Public_Coverage",
             "With_Employer_Insurance", "With_DirectPurchase_Insurance",
             "With_Medicare", "With_Medicaid", "With_TRICARE", "With_VA_HealthCare")),
    
    # Insurance by Type (Percentages)
    any_of(c("Pct_With_Private_Insurance", "Pct_With_Public_Coverage",
             "Pct_With_Employer_Insurance", "Pct_With_DirectPurchase_Insurance",
             "Pct_With_Medicare", "Pct_With_Medicaid", "Pct_With_TRICARE", "Pct_With_VA_HealthCare")),
    
    # Employment Status and Health Insurance
    any_of(c("Employed_Total", "Employed_With_Health_Insurance", "Pct_Employed_With_Insurance",
             "Unemployed_With_Health_Insurance", "Unemployed_With_Private_Insurance")),
    
    # ==============================================================================
    # DIGITAL ACCESS DATA
    # ==============================================================================
    
    any_of(c("HH_With_Internet", "HH_No_Internet", "HH_Broadband", "Pct_HH_With_Internet", "Pct_HH_With_Broadband",
             "Has_Computer_And_Internet", "No_Computer", "Pct_HH_No_Computer")),
    
    # ==============================================================================
    # TRANSPORTATION DATA
    # ==============================================================================
    
    # Commute Times
    any_of(c("Total_Workers_Commute_Universe", "Commute_Under_30_Min", "Commute_30_59_Min", "Commute_60_Plus_Min", "Work_At_Home",
             "Pct_Commute_Under_30", "Pct_Commute_30_59", "Pct_Commute_60_Plus", "Pct_Work_At_Home")),
    
    # Vehicle Availability
    any_of(c("Owner_No_Vehicle", "Owner_1_Vehicle", "Owner_2_Vehicles", "Owner_3_Plus_Vehicles",
             "Renter_No_Vehicle", "Renter_1_Vehicle", "Renter_2_Vehicles", "Renter_3_Plus_Vehicles",
             "Total_No_Vehicle", "Total_With_Vehicle", "Pct_HH_No_Vehicle", "Pct_Owner_No_Vehicle", "Pct_Renter_No_Vehicle")),
    
    # ==============================================================================
    # HOUSING MOBILITY & STABILITY DATA
    # ==============================================================================
    
    # Year Moved In
    any_of(c("Moved_In_2020_Later", "Moved_In_2010_2019", "Moved_In_2000_2009", "Moved_In_1990_1999", "Moved_In_Before_1990",
             "Total_Moved_Since_2020", "Total_Moved_Since_2010", "Pct_Moved_Since_2020", "Pct_Moved_Since_2010")),
    
    # Geographic Mobility
    any_of(c("Same_House_1_Year_Ago", "Moved_Within_County", "Moved_From_Different_County", 
             "Moved_From_Different_State", "Moved_From_Abroad",
             "Pct_Same_House_1_Year", "Pct_Moved_Within_County")),
    
    # ==============================================================================
    # ECONOMIC HARDSHIP DATA
    # ==============================================================================

    # Overall SNAP Receipt
    any_of(c("Total_HH_SNAP_Universe",
             "HH_Received_SNAP", "HH_No_SNAP",
             "Pct_HH_SNAP", "Pct_HH_No_SNAP")),

    # SNAP by Families with Children
    any_of(c("Total_HH_With_Children",
             "HH_SNAP_With_Children", "HH_No_SNAP_With_Children",
             "Pct_HH_With_Children_On_SNAP")),

    # SNAP by Poverty Status
    any_of(c("HH_SNAP_Below_Poverty", "HH_SNAP_At_Above_Poverty",
             "HH_No_SNAP_Below_Poverty", "HH_No_SNAP_At_Above_Poverty",
             "Pct_HH_SNAP_Below_Poverty", "Pct_HH_SNAP_At_Above_Poverty")),

    # Social Security, SSI, and Public Assistance
    any_of(c("HH_With_Social_Security", "HH_No_Social_Security", "Pct_HH_With_Social_Security",
             "HH_With_SSI", "HH_No_SSI", "Pct_HH_With_SSI",
             "HH_With_Public_Assistance", "HH_No_Public_Assistance", "Pct_HH_Public_Assistance",
             "HH_With_PublicAssist_Or_SNAP", "HH_No_PublicAssist_Or_SNAP", "Pct_HH_PublicAssist_Or_SNAP")),
    
    # ==============================================================================
    # MULTIGENERATIONAL & COMPLEX HOUSEHOLDS
    # ==============================================================================
    
    any_of(c("Multigenerational_Households", "Not_Multigenerational", "Pct_Multigenerational",
             "Grandparents_Responsible_For_Grandchildren", "Pct_Grandparents_Caring")),
    
    # Elderly Living Alone
    any_of(c("Elderly_Living_Alone", "Pct_Elderly_Living_Alone")),
    
    # ==============================================================================
    # VETERANS DATA
    # ==============================================================================

    # Total Veterans
    Vet_Total_Pop_18_Plus, Vet_Total_Veterans, Vet_Total_Non_Veterans,
    Pct_Veterans_Of_Adult_Pop,

    # Veterans by Gender
    Vet_Male_Veterans, Vet_Female_Veterans,
    Pct_Veterans_Male, Pct_Veterans_Female,

    # Veterans by Age Group (from B21001)
    Vet_Total_18_34, Vet_Total_35_54, Vet_Total_55_64,
    Vet_Total_65_74, Vet_Total_75_Plus,
    Pct_Veterans_18_34, Pct_Veterans_35_54, Pct_Veterans_55_64, Pct_Veterans_65_Plus,

    # Veterans by Race/Ethnicity (Aggregated Totals)
    Vet_Total_White, Vet_Total_Black, Vet_Total_Asian, Vet_Total_Latino,
    Pct_Veterans_White, Pct_Veterans_Black, Pct_Veterans_Asian, Pct_Veterans_Latino,

    # Period of Service (B21002 - Veterans can serve multiple periods, totals may not sum)
    any_of(c("Vet_Period_Total", "Vet_Any_Post_9_11", "Vet_Any_Gulf_War", "Vet_Any_Vietnam")),
    starts_with("Vet_Gulf_War"), starts_with("Vet_Vietnam"),
    starts_with("Vet_Korean"), starts_with("Vet_WWII"), starts_with("Vet_Between"),
    any_of(c("Vet_Pre_WWII_Only")),

    # Veteran Educational Attainment (B21003)
    any_of(c("Vet_Ed_Total_Pop_25_Plus", "Vet_Ed_Veteran_Total",
             "Vet_Ed_Veteran_Less_Than_HS", "Vet_Ed_Veteran_HS_Grad",
             "Vet_Ed_Veteran_Some_College_AA", "Vet_Ed_Veteran_Bachelors_Plus",
             "Pct_Vet_Ed_Less_Than_HS", "Pct_Vet_Ed_HS_Grad",
             "Pct_Vet_Ed_Some_College", "Pct_Vet_Ed_Bachelors_Plus")),

    # Veteran Income (B21004)
    any_of(c("Vet_Median_Income_Total", "Vet_Median_Income_Veteran_Total",
             "Vet_Median_Income_Veteran_Male", "Vet_Median_Income_Veteran_Female",
             "Vet_Median_Income_NonVeteran_Total", "Vet_Median_Income_NonVeteran_Male",
             "Vet_Median_Income_NonVeteran_Female")),

    # Veteran Employment (B21005 - Aggregated across age groups 18-64)
    any_of(c("Vet_Emp_Total_18_64", "Vet_Emp_Veteran_Total",
             "Vet_Emp_Veteran_In_Labor_Force", "Vet_Emp_Veteran_Employed",
             "Vet_Emp_Veteran_Unemployed",
             "Pct_Veterans_Employed", "Pct_Veterans_Unemployed",
             "Pct_Veterans_In_Labor_Force")),

    # Veteran Poverty Status (C21007)
    any_of(c("Vet_Pov_Veteran_18_64", "Vet_Pov_Veteran_18_64_Below_Poverty",
             "Vet_Pov_Veteran_65_Plus", "Vet_Pov_Veteran_65_Plus_Below_Poverty",
             "Pct_Vet_18_64_In_Poverty", "Pct_Vet_65_Plus_In_Poverty")),

    # Veteran Disability Status from Poverty Table (C21007)
    any_of(c("Vet_Pov_Veteran_18_64_Below_Poverty_With_Disability",
             "Vet_Pov_Veteran_18_64_At_Above_Poverty_With_Disability",
             "Vet_Pov_Veteran_65_Plus_Below_Poverty_With_Disability",
             "Vet_Pov_Veteran_65_Plus_At_Above_Poverty_With_Disability",
             "Pct_Vet_18_64_With_Disability", "Pct_Vet_65_Plus_With_Disability",
             "Pct_Vet_18_64_Poverty_With_Disability", "Pct_Vet_65_Plus_Poverty_With_Disability")),

    # Service-Connected Disability Ratings (B21100/C21100)
    any_of(c("Vet_Dis_Rating_Total", "Vet_Dis_No_Rating", "Vet_Dis_Has_Rating",
             "Vet_Dis_Rating_0_Pct", "Vet_Dis_Rating_10_20_Pct",
             "Vet_Dis_Rating_30_40_Pct", "Vet_Dis_Rating_50_60_Pct",
             "Vet_Dis_Rating_70_Plus_Pct",
             "Pct_Vet_With_Service_Disability", "Pct_Vet_Disability_70_Plus"))
  )

# ==============================================================================
# SPATIAL ANALYSIS
# ==============================================================================

cat("Fetching tract geometries for spatial analysis...\n")
tracts_geometry <- tryCatch({
  get_acs(
    geography = "tract",
    variables = "B01003_001",
    state = state,
    county = county,
    year = 2023,
    survey = "acs5",
    geometry = TRUE
  )
}, error = function(e) {
  cat("Warning: Could not fetch tract geometries\n")
  NULL
})

# Join housing data with geometries
if (!is.null(tracts_geometry)) {
  housing_with_geometry <- tracts_geometry %>%
    select(GEOID, geometry) %>%
    left_join(key_combined_data, by = "GEOID")
  
  cat("Successfully joined data with tract geometries\n")
  
  # Set up coordinate reference systems
  wgs84_crs <- 4326
  projected_crs <- 32616  # UTM Zone 16N for Cook County
  
  # Transform to projected CRS for area calculations
  tracts_projected <- housing_with_geometry %>%
    st_transform(crs = projected_crs)
  
  # Calculate spatial metrics
  tracts_with_density <- tracts_projected %>%
    mutate(
      tract_area_sqft = as.numeric(st_area(.)),
      tract_area_sqmi = tract_area_sqft / 27878400,
      tract_area_acres = tract_area_sqft / 43560,
      
      # Density calculations
      housing_units_per_sqmi = Total_Housing_Units / tract_area_sqmi,
      housing_units_per_acre = Total_Housing_Units / tract_area_acres,
      population_per_sqmi = Total_Population / tract_area_sqmi,
      population_per_acre = Total_Population / tract_area_acres,
      
      # Veteran density
      veterans_per_sqmi = Vet_Total_Veterans / tract_area_sqmi,
      veterans_per_1000_pop = (Vet_Total_Veterans / Total_Population) * 1000,
      
      # Gross and net housing density
      gross_housing_density_per_sqmi = housing_units_per_sqmi,
      net_housing_density_per_sqmi = Occupied_Units / tract_area_sqmi
    )
  
  # Transform back to WGS84 for output
  final_tract_data <- tracts_with_density %>%
    st_transform(crs = wgs84_crs)
  
  cat("Spatial calculations complete\n")
} else {
  cat("Skipping spatial calculations - geometry not available\n")
  final_tract_data <- key_combined_data
}

# ==============================================================================
# OUTPUT FILES
# ==============================================================================

cat("\n", paste(rep("=", 70), collapse = ""), "\n")
cat("CREATING OUTPUT FILES\n")
cat(paste(rep("=", 70), collapse = ""), "\n")

# Output tract-level data (CSV - no geometry)
if (!is.null(final_tract_data)) {
  enhanced_tract_data <- final_tract_data
  if ("geometry" %in% names(enhanced_tract_data)) {
    enhanced_tract_data <- st_drop_geometry(enhanced_tract_data)
  }
  
  write.csv(enhanced_tract_data, "Cook_County_Housing_Veterans_Tract_2023.csv", row.names = FALSE)
  cat("✓ Created: Cook_County_Housing_Veterans_Tract_2023.csv\n")
}

# Output tract-level data with geometry (GeoJSON)
if (!is.null(final_tract_data) && "geometry" %in% names(final_tract_data)) {
  st_write(final_tract_data, "Cook_County_Housing_Veterans_Tract_2023.geojson", 
           driver = "GeoJSON", delete_dsn = TRUE)
  cat("✓ Created: Cook_County_Housing_Veterans_Tract_2023.geojson\n")
}

# ==============================================================================
# SUMMARY REPORT
# ==============================================================================

cat("\n", paste(rep("=", 70), collapse = ""), "\n")
cat("COOK COUNTY HOUSING & VETERANS DATA SUMMARY\n")
cat(paste(rep("=", 70), collapse = ""), "\n\n")

if (exists("enhanced_tract_data")) {
  cat("Census Tracts:", nrow(enhanced_tract_data), "\n")
  cat("Total Variables:", ncol(enhanced_tract_data), "\n\n")
  
  # Housing Summary
  housing_summary <- enhanced_tract_data %>%
    summarise(
      total_housing_units = sum(Total_Housing_Units, na.rm = TRUE),
      total_population = sum(Total_Population, na.rm = TRUE),
      avg_median_home_value = mean(Median_Home_Value, na.rm = TRUE),
      avg_median_rent = mean(Median_Gross_Rent, na.rm = TRUE)
    )
  
  cat("HOUSING OVERVIEW:\n")
  cat("  Total Housing Units:", format(housing_summary$total_housing_units, big.mark = ","), "\n")
  cat("  Total Population:", format(housing_summary$total_population, big.mark = ","), "\n")
  cat("  Avg Median Home Value: $", format(round(housing_summary$avg_median_home_value), big.mark = ","), "\n", sep = "")
  cat("  Avg Median Rent: $", format(round(housing_summary$avg_median_rent), big.mark = ","), "\n\n", sep = "")
  
  # Veterans Summary
  veteran_summary <- enhanced_tract_data %>%
    summarise(
      total_veterans = sum(Vet_Total_Veterans, na.rm = TRUE),
      total_adult_pop = sum(Vet_Total_Pop_18_Plus, na.rm = TRUE),
      pct_veterans = mean(Pct_Veterans_Of_Adult_Pop, na.rm = TRUE),
      male_veterans = sum(Vet_Male_Veterans, na.rm = TRUE),
      female_veterans = sum(Vet_Female_Veterans, na.rm = TRUE),
      white_veterans = sum(Vet_Total_White, na.rm = TRUE),
      black_veterans = sum(Vet_Total_Black, na.rm = TRUE),
      asian_veterans = sum(Vet_Total_Asian, na.rm = TRUE),
      latino_veterans = sum(Vet_Total_Latino, na.rm = TRUE)
    )
  
  cat("VETERANS OVERVIEW:\n")
  cat("  Total Veterans:", format(veteran_summary$total_veterans, big.mark = ","), "\n")
  cat("  Adult Population (18+):", format(veteran_summary$total_adult_pop, big.mark = ","), "\n")
  cat("  Avg % Veterans:", round(veteran_summary$pct_veterans, 2), "%\n\n")
  
  cat("  By Gender:\n")
  cat("    Male:", format(veteran_summary$male_veterans, big.mark = ","), 
      "(", round(veteran_summary$male_veterans / veteran_summary$total_veterans * 100, 1), "%)\n", sep = "")
  cat("    Female:", format(veteran_summary$female_veterans, big.mark = ","),
      "(", round(veteran_summary$female_veterans / veteran_summary$total_veterans * 100, 1), "%)\n\n", sep = "")
  
  cat("  By Race/Ethnicity:\n")
  cat("    White:", format(veteran_summary$white_veterans, big.mark = ","),
      "(", round(veteran_summary$white_veterans / veteran_summary$total_veterans * 100, 1), "%)\n", sep = "")
  cat("    Black:", format(veteran_summary$black_veterans, big.mark = ","),
      "(", round(veteran_summary$black_veterans / veteran_summary$total_veterans * 100, 1), "%)\n", sep = "")
  cat("    Asian:", format(veteran_summary$asian_veterans, big.mark = ","),
      "(", round(veteran_summary$asian_veterans / veteran_summary$total_veterans * 100, 1), "%)\n", sep = "")
  cat("    Latino:", format(veteran_summary$latino_veterans, big.mark = ","),
      "(", round(veteran_summary$latino_veterans / veteran_summary$total_veterans * 100, 1), "%)\n\n", sep = "")
  
  # Density summary (if spatial data available)
  if ("housing_units_per_sqmi" %in% names(enhanced_tract_data)) {
    density_summary <- enhanced_tract_data %>%
      summarise(
        avg_housing_density = mean(housing_units_per_sqmi, na.rm = TRUE),
        max_housing_density = max(housing_units_per_sqmi, na.rm = TRUE),
        avg_population_density = mean(population_per_sqmi, na.rm = TRUE),
        avg_veteran_density = mean(veterans_per_sqmi, na.rm = TRUE)
      )
    
    cat("DENSITY METRICS:\n")
    cat("  Avg Housing Density:", round(density_summary$avg_housing_density, 1), "units/sq mi\n")
    cat("  Max Housing Density:", round(density_summary$max_housing_density, 1), "units/sq mi\n")
    cat("  Avg Population Density:", round(density_summary$avg_population_density, 1), "people/sq mi\n")
    cat("  Avg Veteran Density:", round(density_summary$avg_veteran_density, 2), "veterans/sq mi\n\n")
  }
}

cat(paste(rep("=", 70), collapse = ""), "\n")
cat("DATA PULL COMPLETE!\n")
cat(paste(rep("=", 70), collapse = ""), "\n")