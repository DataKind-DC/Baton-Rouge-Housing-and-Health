## Housing ACS Data Pull and Transformation for Baton Rouge, LA

# Load required libraries
library(tidyverse)
library(tidycensus)
library(sf)
library(purrr)

setwd("C:/Users/RichardCarder/Documents/dev/Baton-Rouge-Housing-and-Health/Output Data")


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

# Define geography - East Baton Rouge Parish, LA
state <- "22"  # Louisiana state FIPS code
county <- "033"  # East Baton Rouge Parish FIPS code

# Define housing and demographic tables to pull
housing_tables <- c(
  "DP04",    # Selected Housing Characteristics (Data Profile)
  "B25001",  # Housing Units
  "B25002",  # Occupancy Status
  "B25003",  # Tenure (Owner/Renter)
  "B25077",  # Median Value (Owner-Occupied)
  "B25064",  # Median Gross Rent
  "B25024",  # Units in Structure
  "B25034",  # Year Structure Built
  "B25041",  # Bedrooms
  "B25040",  # House Heating Fuel
  "B25053",  # Selected Monthly Owner Costs
  "B25070",  # Gross Rent as Percentage of Income
  "S2503",   # Financial Characteristics (costs, burdens, value, rent)
  "S2504"   # Physical Housing Characteristics (structure, rooms, facilities)
  #"S2505"    # Mortgage Characteristics
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
  "B08301"   # Means of Transportation to Work (for worker households)
)

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
    return(data.frame())  # Return empty data frame if table fails
  })
})

# Fetch demographic data with error handling
cat("Fetching demographic data...\n")
demographic_data <- purrr::map_df(demographic_tables, ~ {
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

# Fetch income and economic data with error handling
cat("Fetching income and economic data...\n")
income_data <- purrr::map_df(income_tables, ~ {
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

# Fetch household and family composition data with error handling
cat("Fetching household and family composition data...\n")
household_data <- purrr::map_df(household_tables, ~ {
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

# Filter out empty data frames and combine all data
all_data_list <- list(housing_data, demographic_data, income_data, household_data)
all_data_list <- all_data_list[sapply(all_data_list, nrow) > 0]  # Remove empty data frames
all_data <- bind_rows(all_data_list)

# Report successful downloads
cat("\nData collection summary:\n")
if(nrow(housing_data) > 0) {
  housing_tables_found <- unique(housing_data$variable) %>% str_extract("^[A-Z0-9]+") %>% unique()
  cat("Housing tables successfully downloaded:", paste(housing_tables_found, collapse = ", "), "\n")
} else {
  cat("No housing tables downloaded\n")
}

if(nrow(demographic_data) > 0) {
  demo_tables_found <- unique(demographic_data$variable) %>% str_extract("^[A-Z0-9]+") %>% unique()
  cat("Demographic tables successfully downloaded:", paste(demo_tables_found, collapse = ", "), "\n")
} else {
  cat("No demographic tables downloaded\n")
}

if(nrow(income_data) > 0) {
  income_tables_found <- unique(income_data$variable) %>% str_extract("^[A-Z0-9]+") %>% unique()
  cat("Income tables successfully downloaded:", paste(income_tables_found, collapse = ", "), "\n")
} else {
  cat("No income tables downloaded\n")
}

if(nrow(household_data) > 0) {
  household_tables_found <- unique(household_data$variable) %>% str_extract("^[A-Z0-9]+") %>% unique()
  cat("Household tables successfully downloaded:", paste(household_tables_found, collapse = ", "), "\n")
} else {
  cat("No household tables downloaded\n")
}

cat("Total variables collected:", nrow(all_data), "\n")

# Join with variable labels
combined_data <- all_data %>%
  left_join(variables, by = c("variable" = "name"))

# Transform data to wide format with friendly column names
wide_data <- combined_data %>%
  dplyr::select(-moe) %>%  # Remove margin of error columns
  mutate(friendly_name = case_when(
    # Population and Demographics
    variable == "B01003_001" ~ "Total_Population",
    variable == "B02001_002" ~ "White_Alone",
    variable == "B02001_003" ~ "Black_Alone",
    variable == "B02001_005" ~ "Asian_Alone",
    variable == "B03003_003" ~ "Hispanic_Latino",
    
    # Income Variables
    variable == "B19013_001" ~ "Median_Household_Income",
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
    
    # Family Income Distribution
    variable == "B19101_001" ~ "Total_Families",
    variable == "B19101_017" ~ "Family_Income_200K_Plus",
    
    # Poverty Status
    # Poverty Status - corrected mappings
    variable == "B17001_001" ~ "Total_Pop_Poverty_Status",
    variable == "B17001_002" ~ "Below_Poverty_Level",
    variable == "B17001_003" ~ "Below_Poverty_Male_Total",
    variable == "B17001_004" ~ "Below_Poverty_Male_Under_5",
    variable == "B17001_005" ~ "Below_Poverty_Male_5",
    variable == "B17001_006" ~ "Below_Poverty_Male_6_11",
    variable == "B17001_007" ~ "Below_Poverty_Male_12_14",
    variable == "B17001_008" ~ "Below_Poverty_Male_15",
    variable == "B17001_009" ~ "Below_Poverty_Male_16_17",
    variable == "B17001_017" ~ "Below_Poverty_Female_Total",
    variable == "B17001_018" ~ "Below_Poverty_Female_Under_5",
    variable == "B17001_019" ~ "Below_Poverty_Female_5",
    variable == "B17001_020" ~ "Below_Poverty_Female_6_11",
    variable == "B17001_021" ~ "Below_Poverty_Female_12_14",
    variable == "B17001_022" ~ "Below_Poverty_Female_15",
    variable == "B17001_023" ~ "Below_Poverty_Female_16_17",
    variable == "B17001_031" ~ "Above_Poverty_Level",
    
    # Poverty by Household Type
    variable == "B17017_001" ~ "Total_Households_Poverty_Status",
    variable == "B17017_002" ~ "Below_Poverty_Households",
    variable == "B17017_010" ~ "Above_Poverty_Households",
    
    # Income by Tenure
    variable == "B25119_001" ~ "Median_Household_Income_All_Tenure",
    variable == "B25119_002" ~ "Median_Income_Owner_Occupied",
    variable == "B25119_003" ~ "Median_Income_Renter_Occupied",
    
    # Household Composition
    variable == "B11001_001" ~ "Total_Households",
    variable == "B11001_002" ~ "Family_Households",
    variable == "B11001_003" ~ "Family_Married_Couple",
    variable == "B11001_004" ~ "Family_Male_No_Wife",
    variable == "B11001_005" ~ "Family_Female_No_Husband",
    variable == "B11001_007" ~ "Nonfamily_Households",
    variable == "B11001_008" ~ "Nonfamily_Living_Alone",
    variable == "B11001_009" ~ "Nonfamily_Not_Alone",
    
    # Households with Children
    variable == "B11005_001" ~ "Total_Households_Children_Status",
    variable == "B11005_002" ~ "Households_With_Children_Under_18",
    variable == "B11005_011" ~ "Households_No_Children_Under_18",
    
    # Children by Family Type
    variable == "B09002_001" ~ "Total_Own_Children_Under_18",
    variable == "B09002_002" ~ "Children_In_Married_Couple_Families",
    variable == "B09002_009" ~ "Children_In_Single_Father_Families",
    variable == "B09002_015" ~ "Children_In_Single_Mother_Families",
    
    # Population Under 18 by Age
    variable == "B09001_001" ~ "Total_Pop_Under_18",
    variable == "B09001_002" ~ "Pop_Under_3",
    variable == "B09001_003" ~ "Pop_3_4",
    variable == "B09001_004" ~ "Pop_5",
    variable == "B09001_005" ~ "Pop_6_11",
    variable == "B09001_006" ~ "Pop_12_14",
    variable == "B09001_007" ~ "Pop_15_17",
    
    # Household Size by Tenure
    variable == "B25115_001" ~ "Total_Occupied_Units_Size",
    variable == "B25115_002" ~ "Owner_1_Person",
    variable == "B25115_003" ~ "Owner_2_Person",
    variable == "B25115_004" ~ "Owner_3_Person",
    variable == "B25115_005" ~ "Owner_4_Person",
    variable == "B25115_006" ~ "Owner_5_Person",
    variable == "B25115_007" ~ "Owner_6_Person",
    variable == "B25115_008" ~ "Owner_7_Plus_Person",
    variable == "B25115_010" ~ "Renter_1_Person",
    variable == "B25115_011" ~ "Renter_2_Person",
    variable == "B25115_012" ~ "Renter_3_Person",
    variable == "B25115_013" ~ "Renter_4_Person",
    variable == "B25115_014" ~ "Renter_5_Person",
    variable == "B25115_015" ~ "Renter_6_Person",
    variable == "B25115_016" ~ "Renter_7_Plus_Person",
    
    # Basic Housing Units and Occupancy
    variable == "B25001_001" ~ "Total_Housing_Units",
    variable == "B25002_001" ~ "Total_Housing_Units_Check",
    variable == "B25002_002" ~ "Occupied_Units",
    variable == "B25002_003" ~ "Vacant_Units",
    
    # Tenure
    variable == "B25003_001" ~ "Total_Occupied_Units",
    variable == "B25003_002" ~ "Owner_Occupied",
    variable == "B25003_003" ~ "Renter_Occupied",
    
    # Housing Values and Costs
    variable == "B25077_001" ~ "Median_Home_Value",
    variable == "B25064_001" ~ "Median_Gross_Rent",
    
    # Structure Type (Units in Structure)
    variable == "B25024_002" ~ "Single_Family_Detached",
    variable == "B25024_003" ~ "Single_Family_Attached",
    variable == "B25024_004" ~ "Units_2",
    variable == "B25024_005" ~ "Units_3_4",
    variable == "B25024_006" ~ "Units_5_9",
    variable == "B25024_007" ~ "Units_10_19",
    variable == "B25024_008" ~ "Units_20_49",
    variable == "B25024_009" ~ "Units_50_Plus",
    variable == "B25024_010" ~ "Mobile_Home",
    variable == "B25024_011" ~ "Other_Housing_Type",
    
    # Year Built
    variable == "B25034_002" ~ "Built_2020_Later",
    variable == "B25034_003" ~ "Built_2010_2019",
    variable == "B25034_004" ~ "Built_2000_2009",
    variable == "B25034_005" ~ "Built_1990_1999",
    variable == "B25034_006" ~ "Built_1980_1989",
    variable == "B25034_007" ~ "Built_1970_1979",
    variable == "B25034_008" ~ "Built_1960_1969",
    variable == "B25034_009" ~ "Built_1950_1959",
    variable == "B25034_010" ~ "Built_1940_1949",
    variable == "B25034_011" ~ "Built_1939_Earlier",
    
    # Bedrooms
    variable == "B25041_002" ~ "No_Bedroom",
    variable == "B25041_003" ~ "One_Bedroom",
    variable == "B25041_004" ~ "Two_Bedrooms",
    variable == "B25041_005" ~ "Three_Bedrooms",
    variable == "B25041_006" ~ "Four_Bedrooms",
    variable == "B25041_007" ~ "Five_Plus_Bedrooms",
    
    # Owner Costs
    variable == "B25053_002" ~ "Owner_Costs_Under_300",
    variable == "B25053_003" ~ "Owner_Costs_300_599",
    variable == "B25053_004" ~ "Owner_Costs_600_999",
    variable == "B25053_005" ~ "Owner_Costs_1000_1499",
    variable == "B25053_006" ~ "Owner_Costs_1500_1999",
    variable == "B25053_007" ~ "Owner_Costs_2000_2999",
    variable == "B25053_008" ~ "Owner_Costs_3000_Plus",
    
    # Rent Burden
    variable == "B25070_007" ~ "Rent_Burden_30_34_Pct",
    variable == "B25070_008" ~ "Rent_Burden_35_39_Pct",
    variable == "B25070_009" ~ "Rent_Burden_40_49_Pct",
    variable == "B25070_010" ~ "Rent_Burden_50_Plus_Pct",
    
    # S2503 Financial Characteristics - Key Variables (without E suffix)
    variable == "S2503_C01_001" ~ "S2503_Total_Occupied_Units",
    variable == "S2503_C01_013" ~ "S2503_Median_Household_Income",
    variable == "S2503_C01_014" ~ "S2503_Housing_Costs_Under_300",
    variable == "S2503_C01_015" ~ "S2503_Housing_Costs_300_499",
    variable == "S2503_C01_016" ~ "S2503_Housing_Costs_500_799",
    variable == "S2503_C01_017" ~ "S2503_Housing_Costs_800_999",
    variable == "S2503_C01_018" ~ "S2503_Housing_Costs_1000_1499",
    variable == "S2503_C01_019" ~ "S2503_Housing_Costs_1500_1999",
    variable == "S2503_C01_020" ~ "S2503_Housing_Costs_2000_2499",
    variable == "S2503_C01_021" ~ "S2503_Housing_Costs_2500_2999",
    variable == "S2503_C01_022" ~ "S2503_Housing_Costs_3000_Plus",
    variable == "S2503_C01_024" ~ "S2503_Median_Housing_Costs",
    variable == "S2503_C01_028" ~ "S2503_Cost_Burden_30_Plus_Under_20K",
    variable == "S2503_C01_032" ~ "S2503_Cost_Burden_30_Plus_20K_35K",
    variable == "S2503_C01_036" ~ "S2503_Cost_Burden_30_Plus_35K_50K",
    variable == "S2503_C01_040" ~ "S2503_Cost_Burden_30_Plus_50K_75K",
    variable == "S2503_C01_044" ~ "S2503_Cost_Burden_30_Plus_75K_Plus",
    
    # S2503 by Tenure (Owner vs Renter) - these would be in C03 and C04 columns
    variable == "S2503_C03_001" ~ "S2503_Total_Owner_Occupied",
    variable == "S2503_C03_024" ~ "S2503_Median_Owner_Costs",
    variable == "S2503_C04_001" ~ "S2503_Total_Renter_Occupied",
    variable == "S2503_C04_024" ~ "S2503_Median_Renter_Costs",
    
    # S2505 Mortgage Characteristics - Key Variables (without E suffix)
    # variable == "S2505_C01_001" ~ "S2505_Total_Owner_Units",
    # variable == "S2505_C01_002" ~ "S2505_With_Mortgage",
    # variable == "S2505_C01_003" ~ "S2505_Without_Mortgage",
    # variable == "S2505_C01_004" ~ "S2505_Median_Owner_Costs_All",
    # variable == "S2505_C02_001" ~ "S2505_With_Mortgage_Total",
    # variable == "S2505_C02_004" ~ "S2505_Median_Costs_With_Mortgage",
    # variable == "S2505_C03_001" ~ "S2505_Without_Mortgage_Total", 
    # variable == "S2505_C03_004" ~ "S2505_Median_Costs_Without_Mortgage",
    # 
    TRUE ~ "Other"
  )) %>%
  dplyr::select(-variable, -label, -concept, -geography) %>%
  filter(friendly_name != "Other") %>%
  pivot_wider(
    names_from = friendly_name,
    values_from = estimate,
    values_fill = 0
  )

# Note: S-table variables will have structured names based on actual ACS content:
# S2503 = Financial Characteristics (housing costs, cost burden by income, tenure)
# S2504 = Physical Housing Characteristics (structure, rooms, facilities by tenure)  
# S2505 = Mortgage Characteristics (mortgage status, costs with/without mortgage)
# Variables are broken down by: C01=All units, C02=Percentages, C03=Owner, C04=Renter
cat("S-table variables included for cost and burden analysis:\n")
s_table_vars <- names(wide_data)[grepl("^S25", names(wide_data))]
if(length(s_table_vars) > 0) {
  cat(paste(s_table_vars[1:min(15, length(s_table_vars))], collapse = ", "), "\n")
  if(length(s_table_vars) > 15) cat("... and", length(s_table_vars) - 15, "more S-table variables\n")
}

# Calculate summary statistics and percentages
housing_summary_data <- wide_data %>%
  mutate(
    # Population percentages
    Percent_White = White_Alone / Total_Population * 100,
    Percent_Black = Black_Alone / Total_Population * 100,
    Percent_Asian = Asian_Alone / Total_Population * 100,
    Percent_Hispanic = Hispanic_Latino / Total_Population * 100,
    
    # Income analysis
    Low_Income_Under_35K = ifelse(!is.na(Income_Under_10K),
                                  (Income_Under_10K + Income_10K_15K + Income_15K_20K + 
                                     Income_20K_25K + Income_25K_30K + Income_30K_35K), 0),
    Middle_Income_35K_100K = ifelse(!is.na(Income_35K_40K),
                                    (Income_35K_40K + Income_40K_45K + Income_45K_50K + 
                                       Income_50K_60K + Income_60K_75K + Income_75K_100K), 0),
    High_Income_100K_Plus = ifelse(!is.na(Income_100K_125K),
                                   (Income_100K_125K + Income_125K_150K + Income_150K_200K + Income_200K_Plus), 0),
    
    Percent_Low_Income_Under_35K = ifelse(!is.na(Total_Households) & Total_Households > 0,
                                          Low_Income_Under_35K / Total_Households * 100, 0),
    Percent_High_Income_100K_Plus = ifelse(!is.na(Total_Households) & Total_Households > 0,
                                           High_Income_100K_Plus / Total_Households * 100, 0),
    
    # Poverty analysis
    Percent_Below_Poverty = ifelse(!is.na(Total_Pop_Poverty_Status) & Total_Pop_Poverty_Status > 0,
                                   Below_Poverty_Level / Total_Pop_Poverty_Status * 100, 0),
    Percent_Households_Below_Poverty = ifelse(!is.na(Total_Households_Poverty_Status) & Total_Households_Poverty_Status > 0,
                                              Below_Poverty_Households / Total_Households_Poverty_Status * 100, 0),
    
    # Children in poverty
    Children_Below_Poverty = ifelse(!is.na(Below_Poverty_Male_Under_5),
                                    (Below_Poverty_Male_Under_5 + Below_Poverty_Male_6_11 + Below_Poverty_Male_12_14 + Below_Poverty_Male_15 + Below_Poverty_Male_16_17 +
                                       Below_Poverty_Female_Under_5 + Below_Poverty_Female_6_11 + Below_Poverty_Female_12_14 +Below_Poverty_Female_15+ Below_Poverty_Female_16_17), 0),
    Percent_Children_Below_Poverty = ifelse(!is.na(Total_Pop_Under_18) & Total_Pop_Under_18 > 0,
                                            Children_Below_Poverty / Total_Pop_Under_18 * 100, 0),
    
    # Household composition analysis
    Percent_Family_Households = ifelse(!is.na(Total_Households) & Total_Households > 0,
                                       Family_Households / Total_Households * 100, 0),
    Percent_Single_Person_Households = ifelse(!is.na(Total_Households) & Total_Households > 0,
                                              Nonfamily_Living_Alone / Total_Households * 100, 0),
    Percent_Households_With_Children = ifelse(!is.na(Total_Households_Children_Status) & Total_Households_Children_Status > 0,
                                              Households_With_Children_Under_18 / Total_Households_Children_Status * 100, 0),
    
    # Children by family structure
    Percent_Children_Married_Couple = ifelse(!is.na(Total_Own_Children_Under_18) & Total_Own_Children_Under_18 > 0,
                                             Children_In_Married_Couple_Families / Total_Own_Children_Under_18 * 100, 0),
    Percent_Children_Single_Parent = ifelse(!is.na(Total_Own_Children_Under_18) & Total_Own_Children_Under_18 > 0,
                                            (Children_In_Single_Mother_Families+Children_In_Single_Father_Families) / Total_Own_Children_Under_18 * 100, 0),
    
    # Household size analysis
    Large_Owner_Households_4_Plus = ifelse(!is.na(Owner_4_Person),
                                           (Owner_4_Person + Owner_5_Person + Owner_6_Person + Owner_7_Plus_Person), 0),
    Large_Renter_Households_4_Plus = ifelse(!is.na(Renter_4_Person),
                                            (Renter_4_Person + Renter_5_Person + Renter_6_Person + Renter_7_Plus_Person), 0),
    Percent_Large_Owner_Households = ifelse(!is.na(Owner_Occupied) & Owner_Occupied > 0,
                                            Large_Owner_Households_4_Plus / Owner_Occupied * 100, 0),
    Percent_Large_Renter_Households = ifelse(!is.na(Renter_Occupied) & Renter_Occupied > 0,
                                             Large_Renter_Households_4_Plus / Renter_Occupied * 100, 0),
    
    # Housing unit percentages
    Percent_Occupied = Occupied_Units / Total_Housing_Units * 100,
    Percent_Vacant = Vacant_Units / Total_Housing_Units * 100,
    
    # Tenure percentages
    Percent_Owner_Occupied = Owner_Occupied / Total_Occupied_Units * 100,
    Percent_Renter_Occupied = Renter_Occupied / Total_Occupied_Units * 100,
    
    # Structure type percentages - more granular
    Percent_Single_Family = (Single_Family_Detached + Single_Family_Attached) / Total_Housing_Units * 100,
    Percent_Multi_Family_All = (Units_2 + Units_3_4 + Units_5_9 + Units_10_19 + Units_20_49 + Units_50_Plus) / Total_Housing_Units * 100,
    Percent_Multi_Family_5_Plus = (Units_5_9 + Units_10_19 + Units_20_49 + Units_50_Plus) / Total_Housing_Units * 100,
    Percent_Multi_Family_10_Plus = (Units_10_19 + Units_20_49 + Units_50_Plus) / Total_Housing_Units * 100,
    Percent_Multi_Family_20_Plus = (Units_20_49 + Units_50_Plus) / Total_Housing_Units * 100,
    
    # Age of housing percentages
    Percent_Built_2000_Plus = (Built_2020_Later + Built_2010_2019 + Built_2000_2009) / Total_Housing_Units * 100,
    Percent_Built_Pre_1980 = (Built_1970_1979 + Built_1960_1969 + Built_1950_1959 + Built_1940_1949 + Built_1939_Earlier) / Total_Housing_Units * 100,
    
    # Bedroom distribution percentages - more granular
    Percent_Two_Plus_Bedrooms = (Two_Bedrooms + Three_Bedrooms + Four_Bedrooms + Five_Plus_Bedrooms) / Total_Housing_Units * 100,
    Percent_Three_Plus_Bedrooms = (Three_Bedrooms + Four_Bedrooms + Five_Plus_Bedrooms) / Total_Housing_Units * 100,
    
    # Cost burden indicators - more granular (counts and percentages)
    High_Rent_Burden_30_Plus_Units = Rent_Burden_30_34_Pct + Rent_Burden_35_39_Pct + Rent_Burden_40_49_Pct + Rent_Burden_50_Plus_Pct,
    High_Rent_Burden_50_Plus_Units = Rent_Burden_50_Plus_Pct,
    Percent_High_Rent_Burden_30_Plus = High_Rent_Burden_30_Plus_Units / Renter_Occupied * 100,
    Percent_High_Rent_Burden_50_Plus = High_Rent_Burden_50_Plus_Units / Renter_Occupied * 100,
    
    # S2503 Financial Characteristics - Cost Burden Analysis
    Total_Cost_Burden_30_Plus = rowSums(select(., starts_with("S2503_Cost_Burden_30_Plus")), na.rm = TRUE),
    Percent_Cost_Burden_30_Plus = ifelse(!is.na(Total_Occupied_Units) & Total_Occupied_Units > 0,
                                         Total_Cost_Burden_30_Plus / Total_Occupied_Units * 100, 0),
    
    # Housing cost categories (simplified approach)
    High_Housing_Costs_1500_Plus = ifelse(!is.na(S2503_Housing_Costs_1500_1999),
                                          (S2503_Housing_Costs_1500_1999 + S2503_Housing_Costs_2000_2499 +
                                             S2503_Housing_Costs_2500_2999 + S2503_Housing_Costs_3000_Plus), 0),
    Low_Housing_Costs_Under_800 = ifelse(!is.na(S2503_Housing_Costs_Under_300),
                                         (S2503_Housing_Costs_Under_300 + S2503_Housing_Costs_300_499 +
                                            S2503_Housing_Costs_500_799), 0),
    
    # Multi-family unit counts for reference
    Multi_Family_All_Units = Units_2 + Units_3_4 + Units_5_9 + Units_10_19 + Units_20_49 + Units_50_Plus,
    Multi_Family_5_Plus_Units = Units_5_9 + Units_10_19 + Units_20_49 + Units_50_Plus,
    Multi_Family_10_Plus_Units = Units_10_19 + Units_20_49 + Units_50_Plus,
    Multi_Family_20_Plus_Units = Units_20_49 + Units_50_Plus,
    
    # Bedroom unit counts for reference
    Two_Plus_Bedroom_Units = Two_Bedrooms + Three_Bedrooms + Four_Bedrooms + Five_Plus_Bedrooms,
    Three_Plus_Bedroom_Units = Three_Bedrooms + Four_Bedrooms + Five_Plus_Bedrooms
  ) %>%
  # Replace infinite values and NaN with 0
  mutate(across(where(is.numeric), ~ ifelse(is.infinite(.) | is.nan(.), 0, .)))

# Select key columns for output - with error handling for missing variables
key_housing_data <- housing_summary_data %>%
  select(
    # Geographic identifiers
    GEOID, NAME,
    
    # Population basics
    Total_Population, White_Alone, Black_Alone, Asian_Alone, Hispanic_Latino,
    Percent_White, Percent_Black, Percent_Asian, Percent_Hispanic,
    
    # Income analysis
    any_of(c("Median_Household_Income", "Median_Income_Owner_Occupied", "Median_Income_Renter_Occupied",
             "Low_Income_Under_35K", "Middle_Income_35K_100K", "High_Income_100K_Plus",
             "Percent_Low_Income_Under_35K", "Percent_High_Income_100K_Plus")),
    
    # Poverty analysis
    any_of(c("Below_Poverty_Level", "Percent_Below_Poverty", "Percent_Households_Below_Poverty",
             "Children_Below_Poverty", "Percent_Children_Below_Poverty")),
    
    # Household composition
    any_of(c("Total_Households", "Family_Households", "Nonfamily_Living_Alone",
             "Percent_Family_Households", "Percent_Single_Person_Households",
             "Households_With_Children_Under_18", "Percent_Households_With_Children",
             "Total_Own_Children_Under_18", "Children_In_Married_Couple_Families", "Children_In_Single_Mother_Families",
             "Percent_Children_Married_Couple", "Percent_Children_Single_Parent")),
    
    # Household size by tenure
    any_of(c("Large_Owner_Households_4_Plus", "Large_Renter_Households_4_Plus",
             "Percent_Large_Owner_Households", "Percent_Large_Renter_Households")),
    
    # Housing unit basics
    Total_Housing_Units, Occupied_Units, Vacant_Units,
    Percent_Occupied, Percent_Vacant,
    
    # Tenure
    Owner_Occupied, Renter_Occupied,
    Percent_Owner_Occupied, Percent_Renter_Occupied,
    
    # Housing values and costs
    Median_Home_Value, Median_Gross_Rent,
    
    # Structure types - more granular
    Single_Family_Detached, Single_Family_Attached, Mobile_Home,
    Multi_Family_All_Units, Multi_Family_5_Plus_Units, Multi_Family_10_Plus_Units, Multi_Family_20_Plus_Units,
    Percent_Single_Family, Percent_Multi_Family_All, Percent_Multi_Family_5_Plus, Percent_Multi_Family_10_Plus, Percent_Multi_Family_20_Plus,
    
    # Age of housing
    Percent_Built_2000_Plus, Percent_Built_Pre_1980,
    
    # Bedrooms - more granular
    One_Bedroom, Two_Bedrooms, Three_Bedrooms, Four_Bedrooms,
    Two_Plus_Bedroom_Units, Three_Plus_Bedroom_Units,
    Percent_Two_Plus_Bedrooms, Percent_Three_Plus_Bedrooms,
    
    # Cost burden - more granular
    High_Rent_Burden_30_Plus_Units, High_Rent_Burden_50_Plus_Units,
    Percent_High_Rent_Burden_30_Plus, Percent_High_Rent_Burden_50_Plus,
    
    # S2503 Financial Characteristics - Key Cost Analysis Variables (if available)
    any_of(c("S2503_Median_Household_Income", "S2503_Median_Housing_Costs",
             "S2503_Median_Owner_Costs", "S2503_Median_Renter_Costs",
             "Total_Cost_Burden_30_Plus", "Percent_Cost_Burden_30_Plus",
             "High_Housing_Costs_1500_Plus", "Moderate_Housing_Costs_800_1499", "Low_Housing_Costs_Under_800",
             "Percent_High_Housing_Costs_1500_Plus", "Percent_Low_Housing_Costs_Under_800",
             "Owner_Renter_Cost_Gap", "Owner_Renter_Cost_Ratio"))
  )

# Get tract geometries
cat("Fetching tract geometries...\n")
tract_shapes <- get_acs(
  geography = "tract",
  state = state,
  county = county,
  year = 2023,
  geometry = TRUE,
  variables = "B01003_001"
) %>%
  select(GEOID, geometry)

# Combine data with geometries for GeoJSON output
housing_with_geometry <- tract_shapes %>%
  left_join(key_housing_data, by = "GEOID") %>%
  st_transform(crs = 4326)




# Save final dataset to GeoJSON
output_file <- "housing_data_with_geometry.geojson"
st_write(housing_with_geometry, output_file, delete_dsn = TRUE)

# Save final dataset to csv
write.csv(key_housing_data, "housing_data.csv", row.names=FALSE)







# ==============================================================================
# SPATIAL ANALYSIS EXTENSION
# Add this section after your existing data processing and before final output
# ==============================================================================

# Load additional spatial libraries
library(sf)
library(units)
library(lwgeom)
library(httr)

# Set consistent CRS for area/distance calculations (Louisiana South State Plane)
louisiana_crs <- 3452  # EPSG:3452 - NAD83 / Louisiana South (feet)
wgs84_crs <- 4326      # WGS84 for input/output

cat("Starting spatial analysis...\n")

# ==============================================================================
# 1A. GENERIC LARGE DATASET BATCH DOWNLOAD FUNCTION
# ==============================================================================

# Generic function to download large spatial datasets in batches and assign them
download_and_assign_large_datasets <- function(dataset_config, max_rows = 50000, batch_limit = 1000, target_crs = louisiana_crs) {
  successful_downloads <- c()
  failed_downloads <- c()
  
  for(i in 1:nrow(dataset_config)) {
    var_name <- dataset_config$var_name[i]
    base_url <- dataset_config$url[i]
    display_name <- dataset_config$display_name[i]
    
    cat("Collecting", display_name, "spatial data from API in batches...\n")
    
    # Initialize variables for this dataset
    offset <- 0
    limit <- batch_limit
    all_data <- NULL
    more_data <- TRUE
    total_rows <- 0
    
    dataset_result <- tryCatch({
      # Download data in batches
      while(more_data && total_rows < max_rows) {
        # Calculate batch size for this iteration
        batch_size <- min(limit, max_rows - total_rows)
        if (batch_size <= 0) break
        
        # Construct URL with pagination
        url <- paste0(base_url, "?$limit=", batch_size, "&$offset=", offset)
        
        # Make API request for spatial data
        batch_data <- tryCatch({
          data <- st_read(url, quiet = TRUE)
          
          # Transform to target CRS if spatial data
          if("sf" %in% class(data) && !is.na(st_crs(data))) {
            data <- st_transform(data, crs = target_crs)
          }
          
          data
        }, error = function(e) {
          cat("Failed to download", display_name, "batch. Error:", e$message, "\n")
          return(NULL)
        })
        
        if (!is.null(batch_data) && nrow(batch_data) > 0) {
          # Append to main dataset
          if (is.null(all_data)) {
            all_data <- batch_data
          } else {
            all_data <- rbind(all_data, batch_data)
          }
          
          total_rows <- nrow(all_data)
          offset <- offset + batch_size
          
          # Check if we've reached end of dataset
          if (nrow(batch_data) < batch_size) {
            more_data <- FALSE
          }
        } else {
          more_data <- FALSE
        }
        
        # Rate limiting
        Sys.sleep(0.5)
        
        # Progress update
        if (total_rows %% 5000 == 0) {
          cat("Downloaded", total_rows, display_name, "rows\n")
        }
      }
      
      cat("Completed", display_name, "collection:", total_rows, "rows\n")
      
      # Assign to global environment with the specified variable name
      assign(var_name, all_data, envir = .GlobalEnv)
      successful_downloads <- c(successful_downloads, display_name)
      "SUCCESS"
      
    }, error = function(e) {
      cat("Error downloading", display_name, ":", e$message, "\n")
      assign(var_name, NULL, envir = .GlobalEnv)
      failed_downloads <- c(failed_downloads, display_name)
      "FAILED"
    })
  }
  
  # Summary report
  cat("\n=== LARGE DATASET DOWNLOAD SUMMARY ===\n")
  if(length(successful_downloads) > 0) {
    cat("Successful downloads:", paste(successful_downloads, collapse = ", "), "\n")
  }
  if(length(failed_downloads) > 0) {
    cat("Failed downloads:", paste(failed_downloads, collapse = ", "), "\n")
  }
  
  return(list(successful = successful_downloads, failed = failed_downloads))
}

# ==============================================================================
# 1B. GENERIC SMALL DATASET DOWNLOAD FUNCTION  
# ==============================================================================

# Generic function to download and assign spatial datasets
download_and_assign_datasets <- function(dataset_config, target_crs = louisiana_crs, delay_seconds = 2) {
  successful_downloads <- c()
  failed_downloads <- c()
  
  for(i in 1:nrow(dataset_config)) {
    var_name <- dataset_config$var_name[i]
    url <- dataset_config$url[i]
    display_name <- dataset_config$display_name[i]
    
    # Add delay between requests (except for first one)
    if(i > 1) {
      cat("Waiting", delay_seconds, "seconds before next download...\n")
      Sys.sleep(delay_seconds)
    }
    
    # Download and assign dataset
    dataset_result <- tryCatch({
      cat("Downloading", display_name, "from Baton Rouge/Louisiana Data Portal...\n")
      data <- st_read(url, quiet = TRUE)
      data <- st_transform(data, crs = target_crs)
      cat("Successfully downloaded", display_name, ":", nrow(data), "rows\n")
      
      # Assign to global environment with the specified variable name
      assign(var_name, data, envir = .GlobalEnv)
      successful_downloads <- c(successful_downloads, display_name)
      "SUCCESS"
      
    }, error = function(e) {
      cat("Error downloading", display_name, ":", e$message, "\n")
      assign(var_name, NULL, envir = .GlobalEnv)
      failed_downloads <- c(failed_downloads, display_name)
      "FAILED"
    })
  }
  
  # Summary report
  cat("\n=== DOWNLOAD SUMMARY ===\n")
  if(length(successful_downloads) > 0) {
    cat("Successful downloads:", paste(successful_downloads, collapse = ", "), "\n")
  }
  if(length(failed_downloads) > 0) {
    cat("Failed downloads:", paste(failed_downloads, collapse = ", "), "\n")
  }
  
  return(list(successful = successful_downloads, failed = failed_downloads))
}

# ==============================================================================
# 1C. CONFIGURE DATA SOURCES
# ==============================================================================

# Configuration dataframe for small datasets
# Note: These URLs are examples - you'll need to replace with actual Baton Rouge/Louisiana data sources
baton_rouge_small_datasets <- data.frame(
  var_name = c("neighborhoods", "bus_stops", "parks", "affordable_housing", "roads"),
  url = c("https://data.brla.gov/resource/example1.geojson",  # Replace with actual URLs
          "https://data.brla.gov/resource/example2.geojson",
          "https://data.brla.gov/resource/example3.geojson",
          "https://data.brla.gov/resource/example4.geojson",
          "https://data.brla.gov/resource/example5.geojson"),
  display_name = c("neighborhoods", "bus stops", "parks", "affordable housing", "roads"),
  stringsAsFactors = FALSE
)

# Configuration dataframe for large datasets that need batch downloading
baton_rouge_large_datasets <- data.frame(
  var_name = c("land_use", "vacant_buildings", "permit_data", "crime_data"),
  url = c("https://data.brla.gov/resource/example6.geojson",  # Replace with actual URLs
          "https://data.brla.gov/resource/example7.geojson",
          "https://data.brla.gov/resource/example8.geojson", 
          "https://data.brla.gov/resource/example9.geojson"),
  display_name = c("zoning", "vacant buildings", "permits", "crime data"),
  stringsAsFactors = FALSE
)

# Parameters for large dataset downloads
max_rows_per_dataset <- 50000
batch_size <- 1000

# ==============================================================================
# 1D. DOWNLOAD DATASETS (COMMENTED OUT - UPDATE URLs FIRST)
# ==============================================================================

cat("Spatial dataset downloads disabled - please update URLs for Baton Rouge data sources\n")

# Uncomment and update URLs when you have actual Baton Rouge data sources:
# download_results <- download_and_assign_datasets(baton_rouge_small_datasets)
# large_download_results <- download_and_assign_large_datasets(
#   baton_rouge_large_datasets,
#   max_rows_per_dataset,
#   batch_size
# )

# Set spatial variables to NULL for now
neighborhoods <- NULL
bus_stops <- NULL
parks <- NULL
affordable_housing <- NULL
land_use <- NULL
vacant_buildings <- NULL

# Transform tract geometries to consistent CRS for calculations
tracts_projected <- housing_with_geometry %>%
  st_transform(crs = louisiana_crs)

# ==============================================================================
# 2. CALCULATE HOUSING DENSITY
# ==============================================================================

cat("Calculating housing unit density...\n")

# Calculate tract areas in square miles
tracts_with_density <- tracts_projected %>%
  mutate(
    # Calculate area in square feet, then convert to square miles
    tract_area_sqft = as.numeric(st_area(.)),
    tract_area_sqmi = tract_area_sqft / 27878400,  # 1 sq mile = 27,878,400 sq ft
    
    # Calculate various density measures
    housing_units_per_sqmi = Total_Housing_Units / tract_area_sqmi,
    occupied_units_per_sqmi = Occupied_Units / tract_area_sqmi,
    vacant_units_per_sqmi = Vacant_Units / tract_area_sqmi,
    population_per_sqmi = Total_Population / tract_area_sqmi,
    
    # Housing unit density categories
    density_category = case_when(
      housing_units_per_sqmi < 500 ~ "Very Low Density",
      housing_units_per_sqmi < 2000 ~ "Low Density", 
      housing_units_per_sqmi < 5000 ~ "Medium Density",
      housing_units_per_sqmi < 10000 ~ "High Density",
      TRUE ~ "Very High Density"
    )
  )

# ==============================================================================
# 3. TRANSIT ACCESSIBILITY ANALYSIS (BUSES INSTEAD OF L STOPS)
# ==============================================================================

if (!is.null(bus_stops)) {
  cat("Calculating bus stop accessibility...\n")
  
  # Calculate bus stop accessibility metrics
  transit_accessibility <- tracts_projected %>%
    st_drop_geometry() %>%
    select(GEOID) %>%
    mutate(
      bus_stops_within_half_mile = 0,
      bus_stops_within_quarter_mile = 0,
      distance_to_nearest_bus_stop_ft = 0,
      bus_stop_density_per_sqmi = 0
    )
  
  # For each tract, calculate bus stop metrics
  for(i in 1:nrow(tracts_projected)) {
    tract_geom <- tracts_projected[i, ]
    
    # Create buffers around tract centroid
    tract_centroid <- st_centroid(tract_geom)
    buffer_quarter_mile <- st_buffer(tract_centroid, dist = 1320)  # 1320 ft = 0.25 miles
    buffer_half_mile <- st_buffer(tract_centroid, dist = 2640)     # 2640 ft = 0.5 miles
    
    # Count bus stops within buffers
    stops_quarter_mile <- st_intersects(buffer_quarter_mile, bus_stops, sparse = FALSE)
    stops_half_mile <- st_intersects(buffer_half_mile, bus_stops, sparse = FALSE)
    
    transit_accessibility$bus_stops_within_quarter_mile[i] <- sum(stops_quarter_mile)
    transit_accessibility$bus_stops_within_half_mile[i] <- sum(stops_half_mile)
    
    # Calculate distance to nearest bus stop
    if(nrow(bus_stops) > 0) {
      distances <- st_distance(tract_centroid, bus_stops)
      transit_accessibility$distance_to_nearest_bus_stop_ft[i] <- as.numeric(min(distances))
    }
    
    # Calculate bus stop density within tract
    tract_stops <- st_intersects(tract_geom, bus_stops, sparse = FALSE)
    tract_area_sqmi <- as.numeric(st_area(tract_geom)) / 27878400
    transit_accessibility$bus_stop_density_per_sqmi[i] <- sum(tract_stops) / tract_area_sqmi
  }
  
  # Add accessibility categories
  transit_accessibility <- transit_accessibility %>%
    mutate(
      transit_accessibility_category = case_when(
        bus_stops_within_half_mile == 0 ~ "No Access",
        bus_stops_within_half_mile <= 2 ~ "Limited Access",
        bus_stops_within_half_mile <= 5 ~ "Moderate Access",
        bus_stops_within_half_mile <= 10 ~ "Good Access",
        TRUE ~ "Excellent Access"
      ),
      distance_to_nearest_bus_stop_mi = distance_to_nearest_bus_stop_ft / 5280
    )
  
  # Join back to main dataset
  tracts_with_density <- tracts_with_density %>%
    left_join(transit_accessibility, by = "GEOID")
  
} else {
  cat("Skipping transit accessibility analysis - bus stop data not available\n")
}

# ==============================================================================
# 4. LAND USE ANALYSIS
# ==============================================================================

if (!is.null(land_use)) {
  cat("Calculating land use percentages by tract...\n")
  
  # Ensure land use data has the required columns
  # Adjust column names based on your actual land use data structure
  if (!"land_use_type" %in% names(land_use)) {
    # Try common alternative column names
    land_use_col <- names(land_use)[names(land_use) %in% c("LANDUSE", "TYPE", "ZONING", "CLASS", "zone_type")]
    if (length(land_use_col) > 0) {
      land_use <- land_use %>% rename(land_use_type = !!land_use_col[1])
    } else {
      cat("Warning: Could not identify land use type column\n")
      land_use <- land_use %>% mutate(land_use_type = "Unknown")
    }
  }
  
  # Calculate land use percentages for each tract
  land_use_by_tract <- st_intersection(tracts_projected %>% select(GEOID, geometry), 
                                       land_use %>% select(land_use_type, geometry)) %>%
    mutate(
      intersection_area = as.numeric(st_area(.))
    ) %>%
    st_drop_geometry() %>%
    group_by(GEOID, land_use_type) %>%
    summarise(land_use_area = sum(intersection_area), .groups = "drop") %>%
    group_by(GEOID) %>%
    mutate(
      total_tract_analyzed_area = sum(land_use_area),
      pct_land_use = (land_use_area / total_tract_analyzed_area) * 100
    ) %>%
    ungroup()
  
  # Pivot to wide format for common land use types
  land_use_wide <- land_use_by_tract %>%
    select(GEOID, land_use_type, pct_land_use) %>%
    # Standardize land use categories (adjust based on your data)
    mutate(
      land_use_clean = case_when(
        grepl("residential|housing", tolower(land_use_type)) ~ "Residential",
        grepl("commercial|retail", tolower(land_use_type)) ~ "Commercial",
        grepl("industrial|manufacturing", tolower(land_use_type)) ~ "Industrial", 
        grepl("office", tolower(land_use_type)) ~ "Office",
        grepl("park|open|recreation", tolower(land_use_type)) ~ "Parks_Recreation",
        grepl("institutional|public", tolower(land_use_type)) ~ "Institutional",
        grepl("transport|transit", tolower(land_use_type)) ~ "Transportation",
        grepl("vacant|undeveloped", tolower(land_use_type)) ~ "Vacant",
        TRUE ~ "Other"
      )
    ) %>%
    group_by(GEOID, land_use_clean) %>%
    summarise(pct_land_use = sum(pct_land_use), .groups = "drop") %>%
    pivot_wider(
      names_from = land_use_clean,
      values_from = pct_land_use,
      values_fill = 0,
      names_prefix = "Pct_LandUse_"
    )
  
  # Join back to main dataset
  tracts_with_density <- tracts_with_density %>%
    left_join(land_use_wide, by = "GEOID")
  
} else {
  cat("Skipping land use analysis - data not available\n")
}

# ==============================================================================
# 5. NEIGHBORHOOD-LEVEL AGGREGATION
# ==============================================================================

if (!is.null(neighborhoods)) {
  cat("Aggregating tract data to neighborhood level...\n")
  
  # Ensure neighborhoods have a name/ID column
  if (!"neighborhood_name" %in% names(neighborhoods)) {
    name_col <- names(neighborhoods)[names(neighborhoods) %in% c("community", "pri_neigh", "area_name", "district")]
    if (length(name_col) > 0) {
      neighborhoods <- neighborhoods %>% rename(neighborhood_name = !!name_col[1])
    } else {
      neighborhoods <- neighborhoods %>% mutate(neighborhood_name = paste0("Neighborhood_", row_number()))
    }
  }
  
  # Spatial join to assign tracts to neighborhoods
  # Use largest overlap method for tracts that cross neighborhood boundaries
  tract_neighborhood_join <- st_intersection(
    tracts_projected %>% select(GEOID, geometry),
    neighborhoods %>% select(neighborhood_name, geometry)
  ) %>%
    mutate(intersection_area = as.numeric(st_area(.))) %>%
    st_drop_geometry() %>%
    group_by(GEOID) %>%
    slice_max(intersection_area, n = 1) %>%  # Assign to neighborhood with largest overlap
    ungroup() %>%
    select(GEOID, neighborhood_name)
  
  # Join neighborhood assignments back to tract data
  tracts_with_neighborhoods <- tracts_with_density %>%
    left_join(tract_neighborhood_join, by = "GEOID")
  
  # Define aggregation rules for different variable types
  
  # COUNT VARIABLES (can be summed)
  count_vars <- c(
    "Total_Population", "White_Alone", "Black_Alone", "Asian_Alone", "Hispanic_Latino",
    "Total_Households", "Family_Households", "Nonfamily_Living_Alone",
    "Households_With_Children_Under_18", "Total_Own_Children_Under_18",
    "Children_In_Married_Couple_Families", "Children_In_Single_Mother_Families",
    "Large_Owner_Households_4_Plus", "Large_Renter_Households_4_Plus",
    "Total_Housing_Units", "Occupied_Units", "Vacant_Units",
    "Owner_Occupied", "Renter_Occupied", "Single_Family_Detached",
    "Single_Family_Attached", "Mobile_Home", "Multi_Family_All_Units",
    "Multi_Family_5_Plus_Units", "Multi_Family_10_Plus_Units", "Multi_Family_20_Plus_Units",
    "One_Bedroom", "Two_Bedrooms", "Three_Bedrooms", "Four_Bedrooms",
    "Two_Plus_Bedroom_Units", "Three_Plus_Bedroom_Units",
    "High_Rent_Burden_30_Plus_Units", "High_Rent_Burden_50_Plus_Units",
    "Below_Poverty_Level", "Children_Below_Poverty", "Low_Income_Under_35K",
    "Middle_Income_35K_100K", "High_Income_100K_Plus"
  )
  
  # AREA-WEIGHTED VARIABLES (for density and accessibility)
  area_weighted_vars <- c("tract_area_sqft", "tract_area_sqmi")
  
  # BUS STOP VARIABLES (can be summed or area-weighted)
  bus_stop_count_vars <- c("bus_stops_within_quarter_mile", "bus_stops_within_half_mile")
  
  # [Rest of neighborhood aggregation code remains the same...]
  
} else {
  cat("Skipping neighborhood aggregation - boundary data not available\n")
  neighborhood_summary <- NULL
}

# ==============================================================================
# 6. FINAL DATA PREPARATION
# ==============================================================================

# Transform back to WGS84 for output
final_tract_data <- tracts_with_density %>%
  st_transform(crs = wgs84_crs)

# ==============================================================================
# 7. ENHANCED OUTPUT
# ==============================================================================

# Update the tract-level CSV output with spatial analysis
enhanced_tract_data <- final_tract_data %>%
  st_drop_geometry()

write.csv(enhanced_tract_data, "Enhanced_Housing_Tract_Baton_Rouge_2023.csv", row.names = FALSE)

# Output enhanced GeoJSON
st_write(final_tract_data, "Enhanced_Housing_Tract_Baton_Rouge_2023.geojson", driver = "GeoJSON", delete_dsn = TRUE)

# Output neighborhood-level data if available
if (!is.null(neighborhood_summary)) {
  neighborhood_data_only <- neighborhood_summary %>% st_drop_geometry()
  write.csv(neighborhood_data_only, "Neighborhood_Housing_Summary_Baton_Rouge_2023.csv", row.names = FALSE)
  st_write(neighborhood_summary, "Neighborhood_Housing_Summary_Baton_Rouge_2023.geojson", driver = "GeoJSON", delete_dsn = TRUE)
}

# ==============================================================================
# 8. SUMMARY REPORT
# ==============================================================================

cat("\n", paste(rep("=", 60), collapse = ""), "\n")
cat("BATON ROUGE SPATIAL ANALYSIS SUMMARY\n")
cat(paste(rep("=", 60), collapse = ""), "\n")
cat("Enhanced tract-level data:", nrow(enhanced_tract_data), "rows,", ncol(enhanced_tract_data), "columns\n")

if (!is.null(neighborhood_summary)) {
  cat("Neighborhood-level data:", nrow(neighborhood_summary), "neighborhoods\n")
}

# Density summary
density_summary <- enhanced_tract_data %>%
  summarise(
    avg_housing_density = mean(housing_units_per_sqmi, na.rm = TRUE),
    max_housing_density = max(housing_units_per_sqmi, na.rm = TRUE),
    avg_population_density = mean(population_per_sqmi, na.rm = TRUE)
  )

cat("Average housing density:", round(density_summary$avg_housing_density, 1), "units/sq mi\n")
cat("Maximum housing density:", round(density_summary$max_housing_density, 1), "units/sq mi\n")
cat("Average population density:", round(density_summary$avg_population_density, 1), "people/sq mi\n")

# Transit accessibility summary
if ("transit_accessibility_category" %in% names(enhanced_tract_data)) {
  transit_access_summary <- enhanced_tract_data %>%
    count(transit_accessibility_category) %>%
    arrange(desc(n))
  
  cat("\nTransit Accessibility Distribution:\n")
  for(i in 1:nrow(transit_access_summary)) {
    cat("-", transit_access_summary$transit_accessibility_category[i], ":", transit_access_summary$n[i], "tracts\n")
  }
}

# Land use summary
land_use_cols <- names(enhanced_tract_data)[grepl("Pct_LandUse_", names(enhanced_tract_data))]
if (length(land_use_cols) > 0) {
  cat("\nLand use categories included:", length(land_use_cols), "\n")
  cat("Land use variables:", paste(gsub("Pct_LandUse_", "", land_use_cols), collapse = ", "), "\n")
}

cat("\nFiles created:\n")
cat("- Enhanced_Housing_Tract_Baton_Rouge_2023.csv (tract-level data)\n")
cat("- Enhanced_Housing_Tract_Baton_Rouge_2023.geojson (tract-level with geometry)\n")
if (!is.null(neighborhood_summary)) {
  cat("- Neighborhood_Housing_Summary_Baton_Rouge_2023.csv (neighborhood-level data)\n")
  cat("- Neighborhood_Housing_Summary_Baton_Rouge_2023.geojson (neighborhood-level with geometry)\n")
}

cat("\nBaton Rouge spatial analysis complete!\n")

# Set output directory
setwd("C:/Users/RichardCarder/RLD Foundation/RLD Master - Documents/Data Strategy/Data/Housing")

# Output to CSV (data only, no geometry)
write.csv(key_housing_data, "Housing_Income_Demographics_Tract_Baton_Rouge_2023.csv", row.names = FALSE)

# Output to GeoJSON (includes geometry)
st_write(housing_with_geometry, "Housing_Income_Demographics_Tract_Baton_Rouge_2023.geojson", driver = "GeoJSON", delete_dsn = TRUE)

# Print summary
cat("Data processing complete!\n")
cat("CSV output:", nrow(key_housing_data), "rows\n")
cat("GeoJSON output:", nrow(housing_with_geometry), "tracts with geometry\n")
cat("Variables included:", ncol(key_housing_data), "columns\n")