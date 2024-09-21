# SET-UP ------------------------------------------------------------------
setwd("~/general_learning/DKDC/NationalLeagueOfCities/RAQS/") ## CHANGE
libraries_needed<-c("RAQSAPI", "keyring", "stringr", "data.table",
                    "lubridate")
lapply(libraries_needed,require,character.only=T)
rm(libraries_needed)

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
# states[grepl("District", state),.(stateFIPS)] |> unlist()
# va_fips<-states[grepl("^Virginia", state),.(stateFIPS)] |> unlist()
# va_counties<-aqs_counties_by_state(stateFIPS = va_fips) |> as.data.table()
# arl_va_code<-va_counties[grepl("^Arlington", county_name),.(county_code)] |> unlist()
# 
# arl_va_sites<-aqs_sites_by_county(stateFIPS = va_fips, countycode = arl_va_code) |> as.data.table()
# 
# aqs_params<-aqs_parameters_by_class(class="CRITERIA") |> as.data.table()
# pm25_code<-aqs_params[grepl("PM2.5", value_represented),.(code)] |> unlist() |> as.numeric()
# 
# wildfire_arl_va_summary<-aqs_dailysummary_by_county(
#   parameter=pm25_code,
#   bdate=ymd("2023-06-08"),
#   edate=ymd("2023-06-09"),
#   stateFIPS=va_fips,
#   countycode=arl_va_code)
# 
# q22023_arl_va_summary<-aqs_quarterlysummary_by_county(
#   parameter="PM 2.5",
#   bdate=ymd("2023-04-01"),
#   edate=ymd("2023-07-01"),
#   stateFIPS=va_fips,
#   countycode=arl_va_code)


# UTIL FUNCTIONS ----------------------------------------------------------
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
  state_fips<-states[state==state_name,.(stateFIPS)] |> unlist()
  supported_counties<-aqs_counties_by_state(stateFIPS = state_fips) |>
    as.data.table()
  exact_match<-supported_counties[county_name == county,]
  if(exact_match |> nrow() > 0) {
    county_fips<-exact_match[,.(county_code)] |> unlist()
    return(get_sites_by_county_fips(county_fips, state_fips, T))
  }
  regex_match<-supported_counties[grepl(county, county_name),]
  if(regex_match |> nrow() == 0) return(data.table(site_number=character(),
                                                   site_name=character()))
  return(get_sites_by_county_fips(regex_match[,.(county_code)] |>
                                    unlist(),
                                  state_fips, T))
}

# queens_sites<-get_sites_by_county_name("Queens", "New York")