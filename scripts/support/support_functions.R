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

## This function takes the raw tidycensus data and tranforms it into our desirable format.
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
			bg_ed_percent_college_educated = bg_ed_percent_associates + bg_ed_percent_bachelors + bg_ed_percent_graduate_degree,
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
			bg_percent_prop_households_renter_occ = hhlds_renter_occ/total_households,
			bg_med_home_value = med_home_value
		)
}

## Gathers the data and determines the proportion, for a given census block group,
## of either all requests or a given request that stems from a given source.
gather_data <- function(data, request_type = "all", request_source = "all") {
	if (request_source == "all") {
		## What percent of all requests come from BSJ mobile and web sources?
		if (request_type == "all") {
			data %>% 
				mutate(msj = ifelse(incident_source %in% c("Mobile", "Web"), "yes", "no")) %>% 
				group_by(census_block_id, msj) %>% 
				summarise(n = n()) %>% 
				mutate(percent_from_source = (n/sum(n)) %>% round(digits = 4)) %>% 
				filter(msj == "yes") %>% 
				ungroup() %>% 
				arrange(desc(percent_from_source)) %>% 
				#filter(n > 20) %>% 
				left_join(data_descriptive, by = "census_block_id")
		} else {
			## What percent of request_type come from BSJ mobile and web sources?
			data %>% 
				mutate(msj = ifelse(incident_source %in% c("Mobile", "Web"), "yes", "no")) %>%
				filter(service_requested == request_type) %>% 
				group_by(census_block_id, msj) %>%  
				summarise(n = n()) %>% 
				mutate(percent_from_source = (n/sum(n)) %>% round(digits = 4)) %>% 
				filter(msj == "yes") %>% 
				ungroup() %>% 
				arrange(desc(percent_from_source)) %>% 
				#filter(n > 20) %>% 
				left_join(data_descriptive, by = "census_block_id")
		}
	} else {
		## What percent of all requests come from this specific BSJ source?
		if (request_type == "all") {
			data %>% 
				group_by(census_block_id, incident_source) %>% 
				summarise(n = n()) %>% 
				mutate(percent_from_source = (n/sum(n)) %>% round(digits = 4)) %>% 
				filter(incident_source == request_source) %>% 
				ungroup() %>% 
				arrange(desc(percent_from_source)) %>% 
				#filter(n > 20) %>% 
				left_join(data_descriptive, by = "census_block_id")
		} else {
			## What percent of request_type come from this specific BSJ source?
			data %>% 
				filter(service_requested == request_type) %>% 
				group_by(census_block_id, incident_source) %>% 
				summarise(n = n()) %>% 
				mutate(percent_from_source = (n/sum(n)) %>% round(digits = 4)) %>% 
				filter(incident_source == request_source) %>% 
				ungroup() %>% 
				arrange(desc(percent_from_source)) %>% 
				#filter(n > 20) %>% 
				left_join(data_descriptive, by = "census_block_id")
		}
	}
}

find_demographic_descriptors <- function(data) {
	data %>% 
		mutate(
			quantile = case_when(
				percent_from_source > .8 ~ "80%-100%",
				percent_from_source > .6 ~ "60%-80%",
				percent_from_source > .4 ~ "40%-60%",
				percent_from_source > .2 ~ "20%-40%",
				percent_from_source > 0 ~ "0%-20%",
				TRUE ~ NA_character_
			)
		) %>%
		group_by(quantile) %>% 
		mutate(total_census_blocks = n()) %>% 
		group_by(quantile, total_census_blocks) %>% 
		summarize_at(vars_of_interest, median, na.rm = TRUE) %>% 
		gather(key = "var", value = "val", -quantile) %>% 
		mutate(val = val %>% format(scientific = FALSE, digits = 3)) %>%  
		spread(quantile, val) %>% 
		arrange(desc(var))
}

find_demographic_descriptors_var <- function(data) {
	data %>% 
		mutate(
			quantile = case_when(
				percent_from_source > .8 ~ "80%-100%",
				percent_from_source > .6 ~ "60%-80%",
				percent_from_source > .4 ~ "40%-60%",
				percent_from_source > .2 ~ "20%-40%",
				percent_from_source > 0 ~ "0%-20%",
				TRUE ~ NA_character_
			)
		) %>%
		group_by(quantile) %>% 
		mutate(total_census_blocks = n()) %>% 
		group_by(quantile, total_census_blocks) %>% 
		summarize_at(
			vars_of_interest, 
			list(
				xthirtieth_percentile = ~quantile(., .3, na.rm = TRUE),
				xmedian = median,
				xseventieth_percentile = ~quantile(., .7, na.rm = TRUE)
			), 
			na.rm = TRUE
		) %>% 
		gather(key = "var", value = "val", -quantile) %>% 
		mutate(val = val %>% format(scientific = FALSE, digits = 3)) %>%
		separate(var, into = c("var", "percentile"), sep = "_x") %>%
		spread(percentile, val) %>%
		ungroup() %>% 
		transmute(
			quantile,
			var,
			val = ifelse(
				var != "total_census_blocks", 
				str_c(thirtieth_percentile, seventieth_percentile, sep = "-"),
				`<NA>`
			)
		) %>% 
		group_by(quantile) %>% 
		spread(quantile, val) %>% 
		arrange(desc(var))
}

## Creates a scatter plot of a given metric and its relationship to the proportion 
## of requests being made from a given source.
plot_metric <- function(data, metric, flip = FALSE) {
	metric <- enquo(metric)
	
	if (flip == FALSE) {
		data %>% 
			select(percent_from_source, !!metric) %>% 
			ggplot(aes(x = !!metric, y = percent_from_source)) +
			geom_point(alpha = .4) +
			geom_smooth(color = "maroon") +
			scale_y_continuous(labels = scales::percent_format()) +
			theme_minimal() +
			labs(caption = "Source: City of San Jose")
	} else {
		data %>% 
			select(percent_from_source, !!metric) %>% 
			ggplot(aes(y = !!metric, x = percent_from_source)) +
			geom_point(alpha = .4) +
			geom_smooth(color = "maroon") +
			scale_x_continuous(labels = scales::percent_format()) +
			theme_minimal() +
			labs(caption = "Source: City of San Jose")
	}
}

plot_metric_distribution <- function(data, metric) {
	metric <- enquo(metric)
	
	data %>% 
		ggplot(aes(x = !!metric)) +
		geom_histogram(bins = 30, color = "black", fill = "white") +
		theme_minimal() +
		labs(caption = "Source: City of San Jose")
}
