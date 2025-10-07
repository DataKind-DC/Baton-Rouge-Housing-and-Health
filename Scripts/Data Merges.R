# Baton Rouge Multi-Dataset Collection and Spatial Analysis
# This script joins multiple datasets at the census tract level (GEOID)
# and outputs both CSV (no geometry) and GeoJSON (with geometry) formats

# Load required libraries
library(readr)
library(dplyr)
library(httr)
library(sf)
library(tigris)
library(stringr)
library(tidyr)
library(jsonlite)

# Set tigris cache option
options(tigris_use_cache = TRUE)

# =============================================================================
# STEP 1: LOAD DATA
# =============================================================================

cat("\n=== LOADING INPUT DATASETS ===\n")

# Set working directory for output data
setwd("C:/Users/RichardCarder/Documents/dev/Baton-Rouge-Housing-and-Health/Output Data")
ACS_Housing <- read.csv("housing_data.csv", stringsAsFactors = FALSE)
cat("Loaded ACS Housing data:", nrow(ACS_Housing), "rows\n")

# Set working directory for input data
setwd("C:/Users/RichardCarder/Documents/dev/Baton-Rouge-Housing-and-Health/Input Data")

HQM_Housing <- read.csv("HQM_Housing.csv", stringsAsFactors = FALSE) 
cat("Loaded HQM Housing data:", nrow(HQM_Housing), "rows\n")

CDC_Places <- read.csv("CDC_Places.csv", stringsAsFactors = FALSE)%>%
  dplyr::rename("GEOID" = "CENSUS.TRACT")
cat("Loaded CDC Places data:", nrow(CDC_Places), "rows\n")

OpenBR <- read.csv("OpenBR_Tract_Totals.csv", stringsAsFactors = FALSE)%>%
  dplyr::rename("GEOID" = "tract_id")
cat("Loaded OpenBR data:", nrow(OpenBR), "rows\n")

# =============================================================================
# STEP 2: LOAD SPATIAL REFERENCE DATA
# =============================================================================

cat("\n=== DOWNLOADING SPATIAL REFERENCE DATA ===\n")

# Download census tract data for East Baton Rouge Parish
# Louisiana FIPS: 22, East Baton Rouge Parish FIPS: 033
census_tracts <- tracts(state = "22", county = "033", cb = TRUE, year = 2020)
cat("Downloaded census tracts:", nrow(census_tracts), "tracts\n")

# =============================================================================
# STEP 3: STANDARDIZE GEOID FIELDS
# =============================================================================

cat("\n=== STANDARDIZING GEOID FIELDS ===\n")

# Ensure all datasets have a consistent GEOID field
# Check and standardize GEOID format in each dataset

# ACS Housing - adjust based on your actual column name
if("GEOID" %in% names(ACS_Housing)) {
  ACS_Housing <- ACS_Housing %>%
    mutate(GEOID = as.character(GEOID))
  cat("ACS_Housing: GEOID field found\n")
}

# HQM Housing - adjust based on your actual column name
if("GEOID" %in% names(HQM_Housing)) {
  HQM_Housing <- HQM_Housing %>%
    mutate(GEOID = as.character(GEOID))
  cat("HQM_Housing: GEOID field found\n")
} else if("Tract" %in% names(HQM_Housing)) {
  HQM_Housing <- HQM_Housing %>%
    mutate(GEOID = as.character(Tract))
  cat("HQM_Housing: Created GEOID from Tract field\n")
}

# CDC Places - adjust based on your actual column name
if("LocationID" %in% names(CDC_Places)) {
  CDC_Places <- CDC_Places %>%
    mutate(GEOID = as.character(LocationID))
  cat("CDC_Places: Created GEOID from LocationID\n")
} else if("GEOID" %in% names(CDC_Places)) {
  CDC_Places <- CDC_Places %>%
    mutate(GEOID = as.character(GEOID))
  cat("CDC_Places: GEOID field found\n")
}

# OpenBR - adjust based on your actual column name
if("GEOID" %in% names(OpenBR)) {
  OpenBR <- OpenBR %>%
    mutate(GEOID = as.character(GEOID))
  cat("OpenBR: GEOID field found\n")
}

# Census tracts spatial data
census_tracts <- census_tracts %>%
  mutate(GEOID = as.character(GEOID))

# =============================================================================
# STEP 4: JOIN ALL DATASETS
# =============================================================================

cat("\n=== JOINING DATASETS AT TRACT LEVEL ===\n")

# Start with census tracts as the base (ensures all tracts are included)
combined_data <- census_tracts

# Join ACS Housing
if(exists("ACS_Housing") && "GEOID" %in% names(ACS_Housing)) {
  combined_data <- combined_data %>%
    left_join(ACS_Housing, by = "GEOID", suffix = c("", "_acs"))
  cat("Joined ACS Housing data\n")
}

# Join HQM Housing
if(exists("HQM_Housing") && "GEOID" %in% names(HQM_Housing)) {
  combined_data <- combined_data %>%
    left_join(HQM_Housing, by = "GEOID", suffix = c("", "_hqm"))
  cat("Joined HQM Housing data\n")
}

# Join CDC Places
if(exists("CDC_Places") && "GEOID" %in% names(CDC_Places)) {
  combined_data <- combined_data %>%
    left_join(CDC_Places, by = "GEOID", suffix = c("", "_cdc"))
  cat("Joined CDC Places data\n")
}

# Join OpenBR
if(exists("OpenBR") && "GEOID" %in% names(OpenBR)) {
  combined_data <- combined_data %>%
    left_join(OpenBR, by = "GEOID", suffix = c("", "_openbr"))
  cat("Joined OpenBR data\n")
}

cat("\nFinal combined dataset:", nrow(combined_data), "rows,", ncol(combined_data), "columns\n")

# =============================================================================
# STEP 5: CREATE NON-SPATIAL VERSION (CSV)
# =============================================================================

cat("\n=== CREATING NON-SPATIAL VERSION ===\n")

# Remove geometry for CSV export
combined_data_csv <- combined_data %>%
  st_drop_geometry()

# =============================================================================
# STEP 6: SAVE OUTPUTS
# =============================================================================

cat("\n=== SAVING OUTPUT FILES ===\n")

# Set output directory
setwd("C:/Users/RichardCarder/Documents/dev/Baton-Rouge-Housing-and-Health/Output Data")

# Save CSV (without geometry)
csv_filename <- "BR_Combined_Tract_Data.csv"
write.csv(combined_data_csv, csv_filename, row.names = FALSE)
cat("Saved CSV file:", csv_filename, "\n")
cat("  - Rows:", nrow(combined_data_csv), "\n")
cat("  - Columns:", ncol(combined_data_csv), "\n")

# Save GeoJSON (with geometry)
geojson_filename <- "BR_Combined_Tract_Data.geojson"
st_write(combined_data, geojson_filename, driver = "GeoJSON", delete_dsn = TRUE)
cat("Saved GeoJSON file:", geojson_filename, "\n")
cat("  - Features:", nrow(combined_data), "\n")

# =============================================================================
# STEP 7: SUMMARY STATISTICS
# =============================================================================

cat("\n=== SUMMARY STATISTICS ===\n")
cat("Total census tracts:", nrow(combined_data), "\n")
cat("Column names in final dataset:\n")
print(names(combined_data))

# Check for missing data
cat("\nMissing data summary:\n")
missing_summary <- combined_data_csv %>%
  summarise(across(everything(), ~sum(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "column", values_to = "missing_count") %>%
  filter(missing_count > 0) %>%
  arrange(desc(missing_count))

if(nrow(missing_summary) > 0) {
  print(missing_summary)
} else {
  cat("No missing data found!\n")
}

cat("\n=== ANALYSIS COMPLETE ===\n")
cat("Output files saved to:", getwd(), "\n")

