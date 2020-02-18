################################################################################
## Author: Michael Spencer, Barbara Cardona, Guillermo Camrillo, Jorge Nam Song
## Project: MS&E 108 - BeautifySJ Analysis
## Script Purpose: Customize query for census data pull
## Notes: Specify variables to gather
################################################################################

# Relevant variables we'd like to pull from the census
table_census_vars <- 
	c(
		pop_total          = "B03002_001",
		pop_num_white      = "B03002_003",
		pop_num_black      = "B03002_004",
		pop_num_native     = "B03002_005",
		pop_num_asian      = "B03002_006",
		pop_num_islander   = "B03002_007",
		pop_num_other      = "B03002_008",
		pop_two_plus       = "B03002_009",
		pop_num_hisp       = "B03002_012",
		med_income         = "B19013_001",
		ed_total           = "B15003_001",
		ed_less_hs_none    = "B15003_002",
		ed_less_hs_nurse   = "B15003_003",
		ed_less_hs_kind    = "B15003_004",
		ed_less_hs_one     = "B15003_005",
		ed_less_hs_two     = "B15003_006",
		ed_less_hs_three   = "B15003_007",
		ed_less_hs_four    = "B15003_008",
		ed_less_hs_five    = "B15003_009",
		ed_less_hs_six     = "B15003_010",
		ed_less_hs_seven   = "B15003_011",
		ed_less_hs_eight   = "B15003_012",
		ed_less_hs_nine    = "B15003_013",
		ed_less_hs_ten     = "B15003_014",
		ed_less_hs_eleven  = "B15003_015",
		ed_less_hs_twelve  = "B15003_016",
		ed_hs_hs           = "B15003_017",
		ed_hs_ged          = "B15003_018",
		ed_hs_some_college = "B15003_019",
		ed_hs_college_nf   = "B15003_020",
		ed_as              = "B15003_021",
		ed_bs              = "B15003_022",
		ed_ms              = "B15003_023",
		ed_prof            = "B15003_024",
		ed_phd             = "B15003_025",
		emp_total          = "B23025_002",
		emp_unemp          = "B23025_005",
		med_age            = "B01002_001",
		total_households   = "C16002_001",
		english_only       = "C16002_002",
		spanish_speaking   = "C16002_003",
		spanish_limited    = "C16002_004",
		api_speaking       = "C16002_009",
		api_limited        = "C16002_010",
		hhlds_owner_occ    = "B25003_002",
		hhlds_renter_occ   = "B25003_003"
	)