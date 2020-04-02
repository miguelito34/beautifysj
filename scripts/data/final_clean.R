################################################################################
## Author: Michael Spencer, Barbara Cardona, Guillermo Camarillo, Jorge Nam Song
## Project: MS&E 108 - BeautifySJ Analysis
## Script Purpose: Clean the data into tidy format for export and exploratory 
##                 analysis
## Notes: Here we standardize the formatting of a lot of the columns as well as 
##        change the names to an easier format.
################################################################################

################################################################################
################################# SETUP ########################################
################################################################################

### Load Data
source("../scripts/data/join_all_data.R") # Loads joined data

################################################################################
############################## CLEAN DATA ######################################
################################################################################

### Drop and Rename Columns
colnames(data) <- 
	colnames(data) %>% 
	str_to_lower() %>% 
	str_replace_all("\\s", "_") %>% 
	str_replace_all("%", "percent") %>% 
	str_remove_all(",|\\.")

data <-
	data %>%
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
		-subject,
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
		
		## Adds relevant time columns to the data
		date_created = date_created %>% as_datetime(),
		request_creation_year = date_created %>% year(),
		request_creation_month = date_created %>% month(label = TRUE, abbr = TRUE),
		request_creation_weekday = date_created %>% wday(label = TRUE, abbr = TRUE)
	) %>% 
	
	## Clean data for erroneous requests
	filter(
		service_requested != "No Value" # Filter out 2 unknown requests
	)

################################################################################
############################## WRITE DATA ######################################
################################################################################

if (write_my_files == "yes") {
	
	data %>%
		st_write("../data_clean/requests/beautifysj_data_shapefiles.shp", delete_dsn = TRUE, delete_layer = TRUE)
	
	data %>%
		st_drop_geometry() %>%
		write_tsv(path = "../data_clean/requests/beautifysj_data.tsv")
	
}

if (keep_geometry == "no") {
	data <-
		data %>%
		st_drop_geometry()
}

################################################################################
############################## SPLIT DATA ######################################
################################################################################

## Once the data is cleaned, splits the data back into the requests data and the
## descriptive demographic data.

data_requests <-
	data %>% 
	select(
		mysanjose_reference_id,
		service_requested,
		incident_source,
		latitude,
		longitude,
		date_created,
		request_creation_year,
		request_creation_month,
		request_creation_weekday,
		san_jose_council_district,
		census_block_id
	)

data_descriptive <-
	data %>% 
	select(
		everything(),
		-mysanjose_reference_id,
		-service_requested,
		-incident_source,
		-latitude,
		-longitude,
		-date_created,
		-request_creation_year,
		-request_creation_month,
		-request_creation_weekday,
		-san_jose_council_district
	) %>% 
	distinct()

rm(data)