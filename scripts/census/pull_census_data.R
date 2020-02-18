################################################################################
## Author: Michael Spencer, Barbara Cardona, Guillermo Camrillo, Jorge Nam Song
## Project: MS&E 108 - BeautifySJ Analysis
## Script Purpose: Gather census data for relevant block groups in analyzed cities
## Notes: Uses tidycensus package to gather relevant tables on ethnicity/race,
##        education, median household income, employment status
################################################################################

## Setup

### Parameters
source("scripts/census/load_census_query.R")
source("credentials.R")
census_api_key(my_census_api_key)

#===============================================================================

### Functions
# This function takes the raw tidycensus data and tranforms into our desirable format.
transform_census_data <- function(data) {
	
	data %>% 
		group_by(NAME) %>%
		spread(key = variable, value = estimate) %>%
		ungroup() %>% 
		transmute(
			geoid = GEOID,
			detail = NAME,
			# st_fip = str_sub(geoid, 1L, 2L),
			# cty_fip = str_sub(geoid, 3L, 5L),
			# trt_fip = str_sub(geoid, 6L, 11L),
			# bloc_fip = str_sub(geoid, 11L, 12L),
			state = "California",
			county = "Santa Clara County",
			geometry = st_cast(geometry, "MULTIPOLYGON"),
			pop_total = pop_total,
			pop_white = pop_num_white/pop_total,
			pop_black = pop_num_black/pop_total,
			pop_hispanic = pop_num_hisp/pop_total,
			pop_asian = pop_num_asian/pop_total,
			pop_two_or_more = pop_two_plus/pop_total,
			pop_other = pop_num_other/pop_total,
			pop_native = pop_num_native/pop_total,
			pop_islander = pop_num_islander/pop_total,
			pop_non_white = 1 - pop_white,
			emp_unemployed = emp_unemp/emp_total,
			emp_employed = 1 - emp_unemployed,
			ed_graduate_degree = (ed_prof + ed_phd + ed_ms)/ed_total,
			ed_bachelors = ed_bs/ed_total,
			ed_associates = ed_as/ed_total,
			ed_high_school = (ed_hs_college_nf + ed_hs_ged + ed_hs_hs + ed_hs_some_college)/ed_total,
			ed_less_than_hs = 1 - (ed_graduate_degree + ed_bachelors + ed_associates + ed_high_school),
			med_income = med_income,
			med_age,
			english_only_speaking_households = english_only/total_households,
			spanish_speaking_households = spanish_speaking/total_households,
			spanish_spk_english_lim = spanish_limited/total_households,
			api_speaking_households = api_speaking/total_households,
			api_spk_english_lim = api_limited/total_households,
			prop_households_owner_occ = hhlds_owner_occ/total_households,
			prop_households_renter_occ = hhlds_renter_occ/total_households
		)
}

### Get Data
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

### Write Data
if (write_my_files == "yes") {
	
	data_census %>%
		st_write("./data_clean/census/census_data_shapefiles.shp", delete_dsn = TRUE, delete_layer = TRUE)
	
	data_census %>%
		st_drop_geometry() %>%
		write_tsv(path = "./data_clean/census/census_data.tsv")	
	
}

rm(my_census_api_key, table_census_vars, transform_census_data)
