# SET-UP ------------------------------------------------------------------
setwd("~/general_learning/DKDC/NationalLeagueOfCities/RAQS/") ## CHANGE
libraries_needed<-c("RAQSAPI", "keyring", "stringr", "data.table",
                    "lubridate")
lapply(libraries_needed,require,character.only=T)
rm(libraries_needed)
stopifnot(keyring::has_keyring_support())

readRenviron(".Renviron")
datamartAPI_user <- Sys.getenv("EMAIL")
server <- "AQSDatamart"
aqs_credentials(username = datamartAPI_user,
                key = key_get(service = server,
                              username = datamartAPI_user
                )
)

# EXPLORATORY QUERIES -----------------------------------------------------------------
### 1M rows at a time, 10 requests / min. (sequentially) ###
states<-aqs_states() |> as.data.table()
# arl_va_fips<-get_county_fips("Arlington", "Virginia")
# arl_va_sites<-get_sites_by_county_fips(county_fips = arl_va_fips$county_fips,
#                                        state_fips = arl_va_fips$state_fips,
#                                        checked=T)
# aqs_params<-aqs_parameters_by_class(class="CRITERIA") |> as.data.table()
# pm25_code<-aqs_params[grepl("PM2.5", value_represented),.(code)] |> unlist() |> as.numeric()
# 
# wildfire_arl_va_summary<-aqs_dailysummary_by_county(
#   parameter=pm25_code,
#   bdate=ymd("2023-06-08"),
#   edate=ymd("2023-06-09"),
#   stateFIPS=arl_va_fips$state_fips,
#   countycode=arl_va_fips$county_fips)
# 
# q22023_arl_va_summary<-aqs_quarterlysummary_by_county(
#   parameter=pm25_code,
#   bdate=ymd("2023-04-01"),
#   edate=ymd("2023-07-01"),
#   stateFIPS=arl_va_fips$state_fips,
#   countycode=arl_va_fips$county_fips)

# queens_sites<-get_sites_by_county_name("Queens", "New York")
queens_code<-get_county_fips("Queens", "New York")

# more stations reporting
wildfire_queens_summary<-aqs_dailysummary_by_county(
  parameter=pm25_code,
  bdate=ymd("2023-06-06"),
  edate=ymd("2023-06-07"),
  stateFIPS=queens_code$state_fips,
  countycode=queens_code$county_fips)

# UTIL FUNCTIONS ----------------------------------------------------------
get_county_fips<-function(county, state_name) {
  NON_MATCH<-str_c(county, ", ", state_name, " not found or not supported.")
  state_match<-states[state==state_name,]
  if(nrow(state_match) == 0) return(NON_MATCH) 
  state_fips<-state_match$stateFIPS |> unlist()
  supported_counties<-aqs_counties_by_state(stateFIPS = state_fips) |>
    as.data.table()
  exact_match<-supported_counties[county_name == county,]
  if(nrow(exact_match) > 0) return(list(
    state_fips=state_fips,
    county_fips=exact_match$county_code |> unlist()
  ))
  regex_match<-supported_counties[grepl(county, county_name),]
  if(nrow(regex_match) == 0) return()
  match<-regex_match$county_code
  return(list(
    state_fips=state_fips,
    county_fips=match[0]
  ))
}

get_sites_by_county_fips<-function(county_fips, state_fips, checked=F) {
  if(!checked){
    supported_counties<-aqs_counties_by_state(stateFIPS = state_fips) |>
      as.data.table()
    stopifnot(county_fips %in% supported_counties$county_code)
  }
  return(aqs_sites_by_county(stateFIPS = state_fips,
                             countycode=county_fips) |>
           as.data.table())
}

get_sites_by_county_name<-function(county, state_name) {
  county_fips_match<-get_county_fips(county, state_name)
  if(is.character(county_fips_match) && grepl("not found", county_fips_match))
    return(data.table(site_number=character(),
                      site_name=character()))
  return(get_sites_by_county_fips(county_fips_match$county_fips,
                                  county_fips_match$state_fips,
                                  T))
}

### how to determine closest county for PM 2.5 (and other metrics) if no sites reporting in requested county ###