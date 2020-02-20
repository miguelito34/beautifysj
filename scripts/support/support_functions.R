################################################################################
## Author: Michael Spencer, Barbara Cardona, Guillermo Camarillo, Jorge Nam Song
## Project: MS&E 108 - BeautifySJ Analysis
## Script Purpose: Load helper functions for analysis
## Notes: 
################################################################################

################################################################################
################################ FUNCTIONS #####################################
################################################################################

## Standardizes a column of data and converts it to showing percents as a decimal
tranform_percent <- function(x) {
	return(x/100)
}

# This function takes the raw tidycensus data and tranforms it into our desirable format.
transform_census_data <- function(data) {
	
	data %>% 
		group_by(NAME) %>%
		spread(key = variable, value = estimate) %>%
		ungroup() %>% 
		transmute(
			geoid = GEOID,
			state = "California",
			county = "Santa Clara County",
			geometry = st_cast(geometry, "MULTIPOLYGON"),
			bg_pop_total = pop_total,
			bg_pop_percent_white = pop_num_white/pop_total,
			bg_pop_percent_black = pop_num_black/pop_total,
			bg_pop_percent_hispanic = pop_num_hisp/pop_total,
			bg_pop_percent_asian = pop_num_asian/pop_total,
			bg_pop_percent_two_or_more_races = pop_two_plus/pop_total,
			bg_pop_percent_other = pop_num_other/pop_total,
			bg_pop_percent_native = pop_num_native/pop_total,
			bg_pop_percent_islander = pop_num_islander/pop_total,
			bg_pop_percent_non_white = 1 - bg_pop_percent_white,
			bg_emp_percent_unemployed = emp_unemp/emp_total,
			bg_emp_percent_employed = 1 - bg_emp_percent_unemployed,
			bg_ed_percent_graduate_degree = (ed_prof + ed_phd + ed_ms)/ed_total,
			bg_ed_percent_bachelors = ed_bs/ed_total,
			bg_ed_percent_associates = ed_as/ed_total,
			bg_ed_percent_high_school = (ed_hs_college_nf + ed_hs_ged + ed_hs_hs + ed_hs_some_college)/ed_total,
			bg_ed_percent_less_than_hs = 
				1 - 
				(bg_ed_percent_graduate_degree + 
				 	bg_ed_percent_bachelors + 
				 	bg_ed_percent_associates + 
				 	bg_ed_percent_high_school),
			bg_med_income = med_income,
			bg_med_age = med_age,
			bg_percent_english_only_speaking_households = english_only/total_households,
			bg_percent_spanish_speaking_households = spanish_speaking/total_households,
			bg_percent_spanish_spk_english_lim = spanish_limited/total_households,
			bg_percent_api_speaking_households = api_speaking/total_households,
			bg_percent_api_spk_english_lim = api_limited/total_households,
			bg_percent_prop_households_owner_occ = hhlds_owner_occ/total_households,
			bg_percent_prop_households_renter_occ = hhlds_renter_occ/total_households
		)
}