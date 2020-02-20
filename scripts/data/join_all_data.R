################################################################################
## Author: Michael Spencer, Barbara Cardona, Guillermo Camarillo, Jorge Nam Song
## Project: MS&E 108 - BeautifySJ Analysis
## Script Purpose: Prep the three data files and join them together
## Notes:
################################################################################

################################################################################
################################# SETUP ########################################
################################################################################

### Parameters
filepath_raw_requests <- "../data_raw/MySanJose Public Requests 18_19 FY through Q1 19_20 FY_Stanford MS&E.xlsx"
filepath_spi <- "../data_raw/San Jose Social Progress Index Data.xlsx"

### Load Data
source("../scripts/census/pull_census_data.R") # Loads Census data

data_requests <- 
	filepath_raw_requests %>% 
	readxl::read_xlsx(sheet = "MySanJose Requests", col_names = TRUE)

data_spi <- 
	filepath_spi %>% 
	readxl::read_xlsx(
		sheet = "2019 - Census Tract", 
		col_names = TRUE,
		range = "A1:BM214"
	)

################################################################################
########################## PREP DATA FOR JOINING ###############################
################################################################################

### Manage Social Prgress Index Data
data_spi <-
	data_spi %>% 
	# Appends leading 0 to match other datasets and parses into individual FIPS
	mutate(
		`Tract FIPS Code` = paste0('0', (`Tract FIPS Code` %>% as.character())),
		st_fip   = str_sub(`Tract FIPS Code`, 1L, 2L),
		cty_fip  = str_sub(`Tract FIPS Code`, 3L, 5L),
		trt_fip  = str_sub(`Tract FIPS Code`, 6L, 11L)
	)

### Manage requests data
data_requests <-
	data_requests %>% 
	# Removes misc '.' character separating tract and block, allowing for later joining
	mutate(
		`Census Block ID` = `Census Block ID` %>% str_remove('\\.'),
		st_fip   = str_sub(`Census Block ID`, 1L, 2L),
		cty_fip  = str_sub(`Census Block ID`, 3L, 5L),
		trt_fip  = str_sub(`Census Block ID`, 6L, 11L),
		bloc_fip = str_sub(`Census Block ID`, 12L, 12L)
	)

### Join all data
data <-
	data_requests %>% 
	left_join(data_census, by = c(`Census Block ID` = "geoid")) %>% 
	left_join(data_spi, by = c('st_fip', 'cty_fip', 'trt_fip')) %>% 
	st_sf()

rm(data_census, data_requests, data_spi)
