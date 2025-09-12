# Baton Rouge Multi-Dataset Collection and Spatial Analysis
# This script pulls blight and building permit data from BR Open Data Portal

# Load required libraries
library(readr)
library(dplyr)
library(httr)
library(sf)
library(tigris)
library(stringr)
library(tidyr)

# Set tigris cache option
options(tigris_use_cache = TRUE)

# =============================================================================
# STEP 1: DEFINE API ENDPOINTS AND PARAMETERS
# =============================================================================

# API endpoints
blight_url <- "https://data.brla.gov/resource/7ixm-mnvx.csv"
permits_url <- "https://data.brla.gov/resource/7fq7-8j7r.csv"  # Replace with actual URL
crime_url<-"https://data.brla.gov/resource/6zc2-imdr.csv"

# Data collection parameters
max_rows <- 50000
batch_limit <- 1000

# =============================================================================
# STEP 2: GENERIC API DATA COLLECTION FUNCTION
# =============================================================================

collect_api_data <- function(base_url, max_rows = 50000, dataset_name = "dataset") {
  cat("Collecting", dataset_name, "data from API...\n")
  
  # Initialize variables
  offset <- 0
  limit <- batch_limit
  all_data <- NULL
  more_data <- TRUE
  total_rows <- 0
  
  # Get first row to determine column types
  first_url <- paste0(base_url, "?$limit=1")
  first_response <- GET(first_url)
  
  if (status_code(first_response) != 200) {
    stop("Failed to download initial ", dataset_name, " data. Status code: ", status_code(first_response))
  }
  
  # Write first response to temp file and read to get column specs
  temp_file <- tempfile(fileext = ".csv")
  writeBin(content(first_response, "raw"), temp_file)
  first_data <- read_csv(temp_file, n_max = 1)
  col_types <- spec(first_data)
  unlink(temp_file)
  
  # Download data in batches
  while(more_data && total_rows < max_rows) {
    # Calculate batch size for this iteration
    batch_size <- min(limit, max_rows - total_rows)
    if (batch_size <= 0) break
    
    # Construct URL with pagination
    url <- paste0(base_url, "?$limit=", batch_size, "&$offset=", offset)
    
    # Make API request
    response <- GET(url)
    
    if (status_code(response) == 200) {
      # Save response to temp file
      temp_file <- tempfile(fileext = ".csv")
      writeBin(content(response, "raw"), temp_file)
      
      # Read CSV with consistent column types
      data <- read_csv(temp_file, col_types = col_types)
      unlink(temp_file)
      
      # Append to main dataset
      if (nrow(data) > 0) {
        if (is.null(all_data)) {
          all_data <- data
        } else {
          all_data <- bind_rows(all_data, data)
        }
        
        total_rows <- nrow(all_data)
        offset <- offset + batch_size
        
        # Check if we've reached end of dataset
        if (nrow(data) < batch_size) {
          more_data <- FALSE
        }
      } else {
        more_data <- FALSE
      }
    } else {
      stop("Failed to download ", dataset_name, " data. Status code: ", status_code(response))
    }
    
    # Rate limiting
    Sys.sleep(0.5)
    
    # Progress update
    if (total_rows %% 5000 == 0) {
      cat("Downloaded", total_rows, dataset_name, "rows\n")
    }
  }
  
  cat("Completed", dataset_name, "collection:", total_rows, "rows\n")
  return(all_data)
}

# =============================================================================
# STEP 3: COLLECT DATA FROM BOTH APIs
# =============================================================================

# Collect blight data
br_311_data <- collect_api_data(blight_url, max_rows, "blight/311")

# Collect building permits data
br_permits_data <- collect_api_data(permits_url, max_rows, "building permits")

# Collect building permits data
br_crime_data <- collect_api_data(crime_url, max_rows, "crime data")

# =============================================================================
# STEP 4: FILTER AND CLEAN DATASETS
# =============================================================================

# Filter and clean blight data
blight <- br_311_data %>%
  filter(parenttype == "BLIGHTED PROPERTIES")

blight_data_clean <- blight %>%
  filter(!is.na(longitude) & !is.na(latitude)) %>%
  mutate(dataset_type = "blight")

# Filter and clean permits data
# TODO: Add specific permit filtering criteria here
# Examples of potential filters:
# - Filter by permit type
# - Filter by date range
# - Filter by permit status
# - Filter by construction value thresholds

permits_data_clean <- br_permits_data %>%
  # PLACEHOLDER: Add your permit filtering criteria here
  # Example filters (uncomment and modify as needed):
  # filter(permit_type %in% c("NEW CONSTRUCTION", "RENOVATION", "DEMOLITION")) %>%
  # filter(issue_date >= as.Date("2020-01-01")) %>%
  # filter(status == "ISSUED") %>%
  filter(!is.na(longitude) & !is.na(latitude)) %>%
  mutate(dataset_type = "permits")

# Create summaries
blight_summary <- blight_data_clean %>%
  group_by(typename) %>%
  summarise(count = n()) %>%
  arrange(desc(count))

permits_summary <- permits_data_clean %>%
  # Adjust grouping variable based on actual permits data structure
  group_by(permit_type = if("permit_type" %in% names(.)) permit_type else "Unknown") %>%
  summarise(count = n()) %>%
  arrange(desc(count))


unique(br_crime_data$statute_category)

blight <- br_311_data %>%
  filter(parenttype == "BLIGHTED PROPERTIES")



# =============================================================================
# STEP 5: LOAD SPATIAL REFERENCE DATA
# =============================================================================

cat("\nDownloading spatial reference data...\n")

# Download census tract data for East Baton Rouge Parish
# Louisiana FIPS: 22, East Baton Rouge Parish FIPS: 033
census_tracts <- tracts(state = "22", county = "033", cb = TRUE, year = 2020)

# Download ZIP code data for Louisiana
zip_codes <- zctas(state = "22", year = 2010)

# =============================================================================
# STEP 6: PREPARE SPATIAL DATA
# =============================================================================

# Convert both datasets to spatial format
blight_sf <- blight_data_clean %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

permits_sf <- permits_data_clean %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

# Transform reference data to same coordinate system
census_tracts_transformed <- st_transform(census_tracts, crs = 4326)
zip_codes_transformed <- st_transform(zip_codes, crs = 4326)

# Create combined buffer to filter ZIP codes to study area
combined_points <- rbind(
  blight_sf %>% select(dataset_type),
  permits_sf %>% select(dataset_type)
)

study_area_buffer <- st_buffer(st_union(combined_points), dist = 0.1)
zip_codes_br <- zip_codes_transformed[st_intersects(zip_codes_transformed, study_area_buffer, sparse = FALSE), ]

# =============================================================================
# STEP 7: SPATIAL JOINS
# =============================================================================

cat("Performing spatial joins...\n")

# Join blight data with census tracts and ZIP codes
blight_with_tracts <- st_join(blight_sf, census_tracts_transformed)
blight_joined <- st_join(blight_with_tracts, zip_codes_br) %>%
  mutate(
    tract_id = GEOID,
    tract_name = NAMELSAD,
    zip_code = ZCTA5CE10
  )

# Join permits data with census tracts and ZIP codes  
permits_with_tracts <- st_join(permits_sf, census_tracts_transformed)
permits_joined <- st_join(permits_with_tracts, zip_codes_br) %>%
  mutate(
    tract_id = GEOID,
    tract_name = NAMELSAD, 
    zip_code = ZCTA5CE10
  )

# =============================================================================
# STEP 8: CREATE COMBINED SUMMARY TABLES
# =============================================================================

cat("Creating summary tables...\n")

# Create tract-level summaries for each dataset
blight_tract_summary <- blight_joined %>%
  st_drop_geometry() %>%
  group_by(tract_id, tract_name) %>%
  summarise(blight_count = n(), .groups = 'drop')

permits_tract_summary <- permits_joined %>%
  st_drop_geometry() %>%
  group_by(tract_id, tract_name) %>%
  summarise(permits_count = n(), .groups = 'drop')

# Create ZIP-level summaries for each dataset
blight_zip_summary <- blight_joined %>%
  st_drop_geometry() %>%
  filter(!is.na(zip_code)) %>%
  group_by(zip_code) %>%
  summarise(blight_count = n(), .groups = 'drop')

permits_zip_summary <- permits_joined %>%
  st_drop_geometry() %>%
  filter(!is.na(zip_code)) %>%
  group_by(zip_code) %>%
  summarise(permits_count = n(), .groups = 'drop')

# Combine tract summaries
tract_totals <- census_tracts_transformed %>%
  st_drop_geometry() %>%
  select(tract_id = GEOID, tract_name = NAMELSAD) %>%
  left_join(blight_tract_summary, by = c("tract_id", "tract_name")) %>%
  left_join(permits_tract_summary, by = c("tract_id", "tract_name")) %>%
  mutate(
    blight_count = coalesce(blight_count, 0),
    permits_count = coalesce(permits_count, 0),
    total_incidents = blight_count + permits_count
  ) %>%
  arrange(desc(total_incidents))

# Combine ZIP summaries
zip_totals <- zip_codes_br %>%
  st_drop_geometry() %>%
  select(zip_code = ZCTA5CE10) %>%
  left_join(blight_zip_summary, by = "zip_code") %>%
  left_join(permits_zip_summary, by = "zip_code") %>%
  mutate(
    blight_count = coalesce(blight_count, 0),
    permits_count = coalesce(permits_count, 0),
    total_incidents = blight_count + permits_count
  ) %>%
  arrange(desc(total_incidents))

# Detailed breakdowns by type
tract_type_summary_blight <- blight_joined %>%
  st_drop_geometry() %>%
  group_by(tract_id, tract_name, typename) %>%
  summarise(count = n(), .groups = 'drop') %>%
  mutate(dataset = "blight") %>%
  arrange(tract_id, desc(count))

tract_type_summary_permits <- permits_joined %>%
  st_drop_geometry() %>%
  group_by(tract_id, tract_name, 
           type_name = if("permit_type" %in% names(.)) permit_type else "Unknown") %>%
  summarise(count = n(), .groups = 'drop') %>%
  mutate(dataset = "permits") %>%
  rename(typename = type_name) %>%
  arrange(tract_id, desc(count))

# Combine detailed summaries
tract_type_summary_combined <- bind_rows(
  tract_type_summary_blight,
  tract_type_summary_permits
)

# Similar for ZIP codes
zip_type_summary_blight <- blight_joined %>%
  st_drop_geometry() %>%
  filter(!is.na(zip_code)) %>%
  group_by(zip_code, typename) %>%
  summarise(count = n(), .groups = 'drop') %>%
  mutate(dataset = "blight")

zip_type_summary_permits <- permits_joined %>%
  st_drop_geometry() %>%
  filter(!is.na(zip_code)) %>%
  group_by(zip_code, 
           type_name = if("permit_type" %in% names(.)) permit_type else "Unknown") %>%
  summarise(count = n(), .groups = 'drop') %>%
  mutate(dataset = "permits") %>%
  rename(typename = type_name)

zip_type_summary_combined <- bind_rows(
  zip_type_summary_blight,
  zip_type_summary_permits
)

# =============================================================================
# STEP 9: SAVE RESULTS
# =============================================================================

cat("Saving results...\n")

# Save main summary tables with both datasets
write.csv(tract_totals, "tract_totals_combined.csv", row.names = FALSE)
write.csv(zip_totals, "zip_totals_combined.csv", row.names = FALSE)

# Save detailed breakdowns
write.csv(tract_type_summary_combined, "tract_type_summary_combined.csv", row.names = FALSE)
write.csv(zip_type_summary_combined, "zip_type_summary_combined.csv", row.names = FALSE)

# Save individual dataset summaries (for reference)
write.csv(tract_type_summary_blight, "tract_type_summary_blight.csv", row.names = FALSE)
write.csv(tract_type_summary_permits, "tract_type_summary_permits.csv", row.names = FALSE)

# Save the main datasets with spatial joins (optional - can be large)
# write.csv(st_drop_geometry(blight_joined), "blight_with_spatial_joins.csv", row.names = FALSE)
# write.csv(st_drop_geometry(permits_joined), "permits_with_spatial_joins.csv", row.names = FALSE)

# =============================================================================
# STEP 10: SUMMARY OUTPUT
# =============================================================================

cat("\n=== PROCESSING COMPLETE ===\n")
cat("Total blight incidents processed:", nrow(blight_joined), "\n")
cat("Total building permits processed:", nrow(permits_joined), "\n")
cat("Unique census tracts with data:", n_distinct(c(blight_joined$tract_id, permits_joined$tract_id)), "\n")
cat("Unique ZIP codes with data:", n_distinct(c(blight_joined$zip_code, permits_joined$zip_code), na.rm = TRUE), "\n")

cat("\nTop 5 census tracts by combined incident count:\n")
print(head(tract_totals, 5))

cat("\nTop 5 ZIP codes by combined incident count:\n")
print(head(zip_totals, 5))

cat("\nFiles saved:\n")
cat("- tract_totals_combined.csv (main tract summary with blight + permits)\n")
cat("- zip_totals_combined.csv (main ZIP summary with blight + permits)\n")
cat("- tract_type_summary_combined.csv (detailed breakdown by tract and type)\n")
cat("- zip_type_summary_combined.csv (detailed breakdown by ZIP and type)\n")
cat("- tract_type_summary_blight.csv (blight only)\n")
cat("- tract_type_summary_permits.csv (permits only)\n")

cat("\nReady for ACS integration and additional analysis!\n")

# Clean up temporary objects
rm(temp_file, first_response, response, data, first_data)
if(exists("study_area_buffer")) rm(study_area_buffer)
if(exists("combined_points")) rm(combined_points)