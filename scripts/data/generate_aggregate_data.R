################################################################################
## Author: Michael Spencer, Barbara Cardona, Guillermo Camarillo, Jorge Nam Song
## Project: MS&E 108 - BeautifySJ Analysis
## Script Purpose: Produce summarized data by block group for use in Tableau
## Notes:
################################################################################

################################################################################
################################# SETUP ########################################
################################################################################

source("../scripts/support/support_functions.R")
source("../scripts/data/final_clean.R")

################################################################################
########################### WRITE CENSUS DATA ##################################
################################################################################

data_census %>% 
	select(census_block_id = geoid, geometry) %>% 
	st_write(
		"../data_clean/census/census_bg_shapefiles.shp", 
		delete_dsn = TRUE, 
		delete_layer = TRUE
	)

################################################################################
######################## WRITE AGGREGATED DATA #################################
################################################################################

data_tableau <-
	data_requests %>% 
	count(census_block_id, incident_source) %>% 
	group_by(census_block_id) %>% 
	mutate(
		prop = n/sum(n)
	) %>% 
	select(-n) %>% 
	spread(incident_source, prop) %>% 
	left_join(
		data_requests %>% count(census_block_id), 
		by = "census_block_id"
	) %>% 
	left_join(
		data_requests %>% 
			count(census_block_id, service_requested) %>% 
			group_by(census_block_id) %>% 
			mutate(
				prop = n/sum(n)
			) %>% 
			select(-n) %>% 
			spread(service_requested, prop),
		by = "census_block_id"
	) %>%
	left_join(
		data_requests %>% 
			distinct(census_block_id, san_jose_council_district) %>% 
			group_by(census_block_id) %>% 
			mutate(rn = row_number()) %>% 
			filter(rn == 1) %>% 
			select(-rn),
		by = "census_block_id"
	) %>% 
	rename(
		prop_requests_agent_desktop = "Agent desktop",
		prop_requests_mobile = Mobile,
		prop_requests_web = Web,
		prop_requests_abandoned_vehicle = "Abandoned Vehicle",
		prop_requests_general_requests = "General Request",
		prop_requests_graffiti = "Graffiti",
		prop_requests_illegal_dumping = "Illegal Dumping",
		prop_requests_pothole = "Pothole",
		prop_requests_streetlight_outage = "Streetlight Outage",
		total_num_requests = "n"
	) %>% 
	left_join(data_census, by = c("census_block_id" = "geoid")) %>% 
	mutate(
		st_fip   = str_sub(census_block_id, 1L, 2L),
		cty_fip  = str_sub(census_block_id, 3L, 5L),
		trt_fip  = str_sub(census_block_id, 6L, 11L),
		bloc_fip = str_sub(census_block_id, 12L, 12L)
	) %>% 
	left_join(data_spi, by = c('st_fip', 'cty_fip', 'trt_fip')) %>% 
	ungroup()

colnames(data_tableau) <- 
	colnames(data_tableau) %>% 
	str_to_lower() %>% 
	str_replace_all("\\s", "_") %>% 
	str_replace_all("%", "percent") %>% 
	str_remove_all(",|\\.")

data_tableau <-
	data_tableau %>%
	mutate(
		## Keeps block group median incomes, replacing NA's with the median incomes 
		## of the 2017 census tract from which a block group belongs. These should be good proxy's
		## as they're only a year off.
		bg_med_income = 
			ifelse(
				is.na(bg_med_income), 
				`median_household_income_(2017)`, 
				bg_med_income
			) 
	) %>% 
	
	## Divides Social Progress Index % columns by 100 so they are easier to work with.
	mutate_at(vars(contains("(percent_")), tranform_percent) %>% 
	
	## Selects out needless colums and renames for clarity.
	select(
		everything(),
		-tract_fips_code,
		-`median_household_income_(2017)`,
		tract_population_total = `tract_population_(2017)`,
		-`7`,
		housing_and_homelessness = `housing_/_homelessness`,
		crashes_resulting_in_injury_death_rate = `crashes_resulting_in_injury_or_death_(per_1000_pop)`,
		property_crime_rate = `property_crime_rate_(per_100000_pop)`,
		violent_crime_rate = `violent_crime_rate_(per_100000_pop)`
	) %>% 
	
	## Converts crime and vehicle injury rates into percentages for easier interpretation and comparison.
	mutate(
		crashes_resulting_in_injury_death_rate = crashes_resulting_in_injury_death_rate/1000,
		property_crime_rate = property_crime_rate/100000,
		violent_crime_rate = violent_crime_rate/100000,
		requests_per_person = total_num_requests/bg_pop_total
	)

data_tableau %>% 
	select(-geometry) %>% 
	write_tsv(path = "../data_clean/requests/beautifysj_tableau_data.tsv")