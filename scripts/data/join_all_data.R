################################################################################
## Author: Michael Spencer, Barbara Cardona, Guillermo Camrillo, Jorge Nam Song
## Project: MS&E 108 - BeautifySJ Analysis
## Script Purpose: Gather census data for relevant block groups in analyzed cities
## Notes: Uses tidycensus package to gather relevant tables on ethnicity/race,
##        education, median household income, employment status
################################################################################

## Setup

### Libraries
if (!require(tidycensus)) install.packages("tidycensus")
library(tidycensus)

if (!require(sf)) install.packages("sf")
library(sf)

if (!require(tidyverse)) install.packages("tidyverse")
library(tidyverse)

### Parameters
write_my_files <- "yes" # Change this if you would like fresh census files downloaded
filepath_raw_requests <- "data_raw/MySanJose Public Requests 18_19 FY through Q1 19_20 FY_Stanford MS&E.xlsx"
filepath_spi <- "data_raw/San Jose Social Progress Index Data.xlsx"

### Load Data
source("scripts/census/pull_census_data.R") # Loads Census data

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

### Clean Data
data_spi <-
	data_spi %>% 
	# Appends leading 0 to match other datasets and parses into individual FIPS
	mutate(
		`Tract FIPS Code` = paste0('0', (`Tract FIPS Code` %>% as.character())),
		st_fip   = str_sub(`Tract FIPS Code`, 1L, 2L),
		cty_fip  = str_sub(`Tract FIPS Code`, 3L, 5L),
		trt_fip  = str_sub(`Tract FIPS Code`, 6L, 11L)
	)

data_requests <-
	data_requests %>% 
	# Removes misc '.' character separating tract and block, allowing for later joining
	mutate(
		`Census Block ID` = `Census Block ID` %>% str_remove('\\.'),
		st_fip   = str_sub(`Census Block ID`, 1L, 2L),
		cty_fip  = str_sub(`Census Block ID`, 3L, 5L),
		trt_fip  = str_sub(`Census Block ID`, 6L, 11L),
		bloc_fip = str_sub(`Census Block ID`, 11L, 12L)
	)

data <-
	data_requests %>% 
	left_join(data_census, by = c(`Census Block ID` = "geoid")) %>% 
	left_join(data_spi, by = c('st_fip', 'cty_fip', 'trt_fip')) %>% 
	st_sf()

### Write Data
if (write_my_files == "yes") {
	
	data %>%
		st_write("./data_clean/requests/beautifysj_data_shapefiles.shp", delete_dsn = TRUE, delete_layer = TRUE)
	
	data %>%
		st_drop_geometry() %>%
		write_tsv(path = "./data_clean/requests/beautifysj_data.tsv")
	
}
