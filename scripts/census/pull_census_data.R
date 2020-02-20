################################################################################
## Author: Michael Spencer, Barbara Cardona, Guillermo Camarillo, Jorge Nam Song
## Project: MS&E 108 - BeautifySJ Analysis
## Script Purpose: Gather census data for relevant block groups in San Jose
## Notes: Uses tidycensus package to gather relevant tables on ethnicity/race,
##        education, median household income, employment status
################################################################################

################################################################################
################################# SETUP ########################################
################################################################################

### Parameters
source("../scripts/census/load_census_query.R")
source("../credentials.R")
census_api_key(my_census_api_key)

################################################################################
############################### GET DATA #######################################
################################################################################
data_census <-
	get_acs(
		geography = "block group",
		variables = table_census_vars,
		state = "California",
		county = "Santa Clara County",
		year = 2018,
		geometry = TRUE
	) %>% 
	select(-moe) %>% 
	transform_census_data() %>% 
	st_sf()

rm(my_census_api_key, table_census_vars, transform_census_data)
