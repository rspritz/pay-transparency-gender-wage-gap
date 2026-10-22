**********************************************************************************
* Author: Rebecca Spritzer
* Project: MSc Dissertation
**********************************************************************************

clear all

global project_data "/Users/rebeccaspritzer/Desktop/Files/Ireland/Trinity/MSc/Thesis/MSc Dissertation Data and Do File_Rebecca Spritzer"
global project_tables "/Users/rebeccaspritzer/Desktop/Files/Ireland/Trinity/MSc/Thesis/MSc Dissertation Data and Do File_Rebecca Spritzer"
global project_graphs "/Users/rebeccaspritzer/Desktop/Files/Ireland/Trinity/MSc/Thesis/MSc Dissertation Data and Do File_Rebecca Spritzer"
global project_sumstats "/Users/rebeccaspritzer/Desktop/Files/Ireland/Trinity/MSc/Thesis/MSc Dissertation Data and Do File_Rebecca Spritzer"


cd "$project_data"

use MSc_Dissertation_Clean_Data.dta, replace

*-----------------------------------------------------------------------------------------------*
************************************************************************************************
*********************************** SECTION 1: FORMAT ******************************************
************************************************************************************************
 gen nyc = 1 if county == 36047|county == 36061|county == 36081|county == 36005|county == 36085
 gen cleveland = 1 if county == 39035
 *-----------------------------------------------------------------------------------------------*
 
 *Indicate if law is in effect / signed
gen date = mdy(month, 1, year)
format date %td
*Signed - use the month rather than exact date 
gen signed_m = .

replace signed_m = ym(2022,9) if statefip == 6 // California
replace signed_m = ym(2019,5) if statefip == 8 // Colorado
replace signed_m =ym(2024, 5) if statefip == 27 // Minnesota
replace signed_m =ym(2024, 3) if statefip == 11 // DC 
replace signed_m = ym(2023, 7) if statefip == 15 // Hawaii
replace signed_m = ym(2023, 8) if statefip == 17 // Illinois
replace signed_m = ym(2024, 4) if statefip == 24 // Maryland
replace signed_m = ym(2024, 7) if statefip == 25 // Massachusetts
replace signed_m = ym(2024, 11) if statefip == 34 & county != 34017 // New Jersey
replace signed_m = ym(2022, 12) if statefip == 36 & nyc != 1 & county != 36119 // New York
replace signed_m = ym(2024, 6) if statefip == 50 // Vermont
replace signed_m = ym(2022, 3) if statefip == 53 // Washington
replace signed_m = ym(2022, 4) if county == 36119 // Westchester County
replace signed_m = ym(2022, 5) if nyc == 1 // NYC
replace signed_m = ym(2025, 4) if cleveland == 1 // Cleveland
replace signed_m = ym(2022, 3) if county == 34017 // Jersey City

format signed_m %tm
gen treated = signed_m != .

*Effective day
gen effective_m = .

replace effective_m = ym(2023,1) if statefip == 6 // California
replace effective_m = ym(2021,1) if statefip == 8 // Colorado
replace effective_m =ym(2025, 1) if statefip == 27 // Minnesota
replace effective_m =ym(2024, 6) if statefip == 11 // DC 
replace effective_m = ym(2024, 1) if statefip == 15 // Hawaii
replace effective_m = ym(2025, 1) if statefip == 17 // Illinois
replace effective_m = ym(2024, 10) if statefip == 24 // Maryland
replace effective_m = ym(2025, 10) if statefip == 25 // Massachusetts
replace effective_m = ym(2025, 6) if statefip == 34 & county != 34017 // New Jersey
replace effective_m = ym(2023, 9) if statefip == 36 & nyc != 1 & county != 36119 // New York
replace effective_m = ym(2025, 7) if statefip == 50 // Vermont
replace effective_m = ym(2023, 1) if statefip == 53 // Washington
replace effective_m = ym(2022, 11) if county == 36119 // Westchester County
replace effective_m = ym(2022, 11) if nyc == 1 // NYC
replace effective_m = ym(2025, 10) if cleveland == 1 // Cleveland
replace effective_m = ym(2022, 4) if county == 34017 // Jersey City

format effective_m %tm

// gen log wages
gen ln_hourwage2 = ln(hourwage2)

// gen post variable, this is the baseline DID estimator - effective x treated
gen mdate = ym(year, month)
format mdate %tm

* Event-time relative to law effective month
gen diff = mdate - effective_m  // months since effective date
gen post = diff >= 0
replace post = 0 if treated==0

*gen effective - to indicate period when state has enacted a law
gen effected = (mdate >= effective_m)

* Limit window for event study
gen posdiff = diff
replace posdiff = . if diff < -12 | diff > 12
replace posdiff = 100 if treated==0   // control group coded separately

//gen education years
gen educ_years = .
replace educ_years = 0 if educ == 2 // none or just preschool / kindergarten
replace educ_years = 4 if educ == 10 // 1st, 2nd, 3rd, or 4th grade
replace educ_years = 6 if educ == 20 // 5th or 6th grade
replace educ_years = 8 if educ == 30 // 7th or 8th grade
replace educ_years = 9 if educ == 40 // 9th grade
replace educ_years = 10 if educ == 50 // 10th grade
replace educ_years = 11 if educ == 60 // 11th grade
replace educ_years = 12 if educ >= 70 & educ <= 73 // high school
replace educ_years = 14 if educ == 81 | educ == 91 | educ == 92 // some college or associates degree
replace educ_years = 16 if educ == 111 // bachelors degree
replace educ_years = 18 if educ == 123 | educ == 124 // masters or professional degree
replace educ_years = 22 if educ == 125 // PHD

// gen experience
gen exp = age - educ_years - 6
gen exp2 = exp*exp

// gen marital status 
gen married = 0
replace married = 1 if marst == 1 | marst == 2

// gen dummy to indicate that has a child under 5
gen childunder5 = 0
replace childunder5 = 1 if nchlt5 > 0


//female
gen female = 0
replace female = 1 if sex == 2

// create occupation groups so not as many categories
gen occ_group = .

replace occ_group = 1 if occ >= 1 & occ <= 0960 // Management, Business, Finance
replace occ_group = 2 if occ >= 1000 & occ <= 2180 // Professional (Engineers, Scientists, Lawyers, )
replace occ_group = 3 if occ >= 2200 & occ <= 2555 // Education
replace occ_group = 4 if occ >= 2600 & occ <= 2960 // Arts
replace occ_group = 5 if occ >= 3000 & occ <= 3655 // Healthcare
replace occ_group = 6 if occ >= 3700 & occ <= 3960 // Protective Support Workers
replace occ_group = 7 if occ >= 4000 & occ <= 4655 // Hospitality, Cleaning, Personal Care
replace occ_group = 8 if occ >= 4700 & occ <= 4965 // Retail and Sales
replace occ_group = 9 if occ >= 5000 & occ <= 5940 // Admin, Office Support
replace occ_group = 10 if occ >= 6000 & occ <= 6130 // Natural Resources
replace occ_group = 11 if occ >= 6200 & occ <= 8990 // Manufacturing, Trades, Construction
replace occ_group = 12 if occ >= 9000 & occ <= 9760 // Transportation
replace occ_group = 13 if occ >= 9840 // Military

label define occ13_lbl 1 "Management/Finance" 2 "Professional" 3 "Education" 4 "Arts" 5 "Healthcare" 6 "Protective Services" 7 "Hospitality" 8 "Sales" 9 "Administration" 10 "Farming" 11 "Manufacturing, Construction, Trades" 12 "Transportation" 13 "Military" // Add labels for occupation groups
label values occ_group occ13_lbl

tab occ_group, gen(d13_occ) // gen dummies for occ groups

gen female_post = female * post // variable identify interaction

bysort statefip county: egen gvar_raw = min(effective_m) if treated == 1 // generate group variable
	replace gvar_raw = 0 if gvar_raw == . // never treated variables = 0
	bysort statefip county: egen gvar = max(gvar_raw) // ensure same for each county
	
gen never_treated = (gvar == 0) // gen never treated indicator

*gen race dummy variables
gen race_cat = .
replace race_cat = 1 if race == 100 // White
replace race_cat = 2 if race == 200 // Black
replace race_cat = 3 if race == 300 // Native American
replace race_cat = 4 if race >= 650 & race <= 652 // Asian / Pacific Islander
replace race_cat = 5 if race_cat == . | race >= 700 // Other / Mixed
label define race_cat_lbl 1 "White" 2 "Black" 3 "Native American" 4 "Asian" 5 "Other"
label values race_cat race_cat_lbl

tab race_cat, gen(race_)
label variable race_1 "White"
label variable race_2 "Black"
label variable race_3 "Native American"
label variable race_4 "Asian / Pacific Islander"
label variable race_5 "Other / Mixed"

*-----------------------------------------------------------------------------------------------* 
************************************************************************************************
*************************** SECTION 2: SUMMARY STATS *******************************************
************************************************************************************************
cd "$project_sumstats"

*1. Mean Wages by Gender - Pre Treatment
preserve
drop if year >= 2021 // pre period
estpost ttest hourwage2, by(female)
esttab using "wage_means_gender.tex", replace ///
	cells("mu_1(label(Male) fmt(2)) mu_2(label(Female) fmt(2)) b(label(Difference) star fmt(2))") ///
	label booktabs nonum noobs
restore

*2. Oaxaca Blinder Decomp Pre-2021
preserve
drop if year >= 2021 // pre period

oaxaca ln_hourwage2 educ_years exp exp2 married childunder5 race_2 race_3 race_4 race_5 (Occupation: d13_occ*), ///
by(female) pooled relax // perform decomposition using pooled model, not including occupation

estimates store oaxaca_pre1 // store estimates
esttab oaxaca_pre1 using "oaxaca_decomp_1.tex", replace /// export decomposition
	cells("b(fmt(3)) se(fmt(3))") ///
	label booktabs nonum

*3. Comparison of Labour Markets
* First, I look at overall average wages and years of education for each state.
tabstat hourwage2 educ_years, ///
    by(statefip) ///
    statistics(mean) 

restore

*4. Balance Tables

 preserve
    * Use baseline data only (Pre-2021)
    keep if year < 2021
	
	* gender wage gap
	gen male_wage = hourwage2 if female == 0
	gen female_wage = hourwage2 if female == 1
	
	bysort county mdate: egen avg_male_wage = mean(male_wage)
	bysort county mdate: egen avg_female_wage = mean(female_wage)
	gen wage_gap = avg_female_wage - avg_male_wage
	
	local occ_dummies d13_occ1 d13_occ2 d13_occ3 d13_occ4 d13_occ5 d13_occ6 ///
                      d13_occ7 d13_occ8 d13_occ9 d13_occ10 d13_occ11 d13_occ12
	
    label variable d13_occ1  "Management/Finance"
    label variable d13_occ2  "Professional"
    label variable d13_occ3  "Education"
    label variable d13_occ4  "Arts"
    label variable d13_occ5  "Healthcare"
    label variable d13_occ6  "Protective Services"
    label variable d13_occ7  "Hospitality"
    label variable d13_occ8  "Sales"
    label variable d13_occ9  "Administration"
    label variable d13_occ10 "Farming/Natural Res"
    label variable d13_occ11 "Manuf/Const/Trades"
    label variable d13_occ12 "Transportation"
	
	local race_dummies race_1 race_2 race_3 race_4 race_5

    *Define the full set of variables for the balance check
    local balance_vars wage_gap hourwage2 educ_years age married childunder5 female `occ_dummies' `race_dummies' 

    * Run t-Tests
    est clear
    estpost ttest `balance_vars', by(treated)

    *Export the final table
    esttab using "full_balance_table.tex", replace ///
        cells("mu_1(label(Control) fmt(2)) mu_2(label(Treated) fmt(2)) b(label(Diff.) star fmt(2))") ///
        label booktabs nonum noobs ///
        title("Baseline Balance Check: Demographic and Occupational Characteristics (Pre-2021)") ///
        addnotes("Note: Occupation and race values are percentages. Group 13 (Military) omitted due to zero observations. * p < 0.05, ** p < 0.01, *** p < 0.001")
restore

cd "$project_data"
save data_for_regressions.dta, replace

************** Baseline occupation differences in gender wage gap ****************
preserve
keep if year < 2021

* results matrix
matrix results = J(12, 4, .)
local row = 0

levelsof occ_group, local(occs)

foreach o of local occs {
    if `o' == 13 continue  // skip military since no observations here
    local row = `row' + 1
    
    * Mean wages by gender
    quietly summarize hourwage2 if occ_group == `o' & female == 0
    local male_mean = r(mean)
    
    quietly summarize hourwage2 if occ_group == `o' & female == 1
    local female_mean = r(mean)
    
    * t test
    quietly ttest ln_hourwage2 if occ_group == `o', by(female)
    local diff = r(mu_2) - r(mu_1)   // raw gap
    local pval = r(p)
    local pct = (exp(`diff') - 1) * 100  // % gap
    
	* store in results matrix
    matrix results[`row', 1] = `male_mean'
    matrix results[`row', 2] = `female_mean'
    matrix results[`row', 3] = `diff'
    matrix results[`row', 4] = `pct'
}

* row names as occupation categories
matrix rownames results = "Management/Finance" "Professional" "Education" ///
    "Arts" "Healthcare" "Protective Services" "Hospitality" ///
    "Sales" "Administration" "Farming" "Manufacturing/Trade" "Transport"
	
matrix colnames results = "Male" "Female" "Gap" "Gap (\%)"

matrix list results

esttab matrix(results, fmt(3 3 3 1 3)) using "baseline_gap.tex", replace booktabs 

restore

************** Oaxaca by Occupation ****************
preserve
keep if year < 2021

levelsof occ_group, local(occs)

* results matrix
matrix results = J(12, 8, .)
local row = 0

* loop to run decomp over each occupation group
foreach o of local occs {
    if `o' == 13 continue  // skip military since no observations
    local row = `row' + 1
    
    quietly oaxaca ln_hourwage2 educ_years exp exp2 married childunder5 race_2 race_3 race_4 race_5 ///
        if occ_group == `o', by(female) swap relax pooled
		
	local raw = _b[difference]
    local explained = _b[explained]
    local unexplained = _b[unexplained]
	
	local raw_se = _se[difference]
    local explained_se = _se[explained]
    local unexplained_se = _se[unexplained]
    
    matrix results[`row', 1] = `raw'
	matrix results[`row', 2] = `raw_se'
	matrix results[`row', 3] = `explained'
	matrix results[`row', 4] = `explained_se'
	matrix results[`row', 5] = `unexplained'
	matrix results[`row',6] = `unexplained_se'
    matrix results[`row', 7] = (`explained' / -`raw') * 100
    matrix results[`row', 8] = (`unexplained' / -`raw') * 100
}

* row names as occupation categories
matrix rownames results = "Management/Finance" "Professional" "Education" ///
    "Arts" "Healthcare" "Protective Services" "Hospitality" ///
    "Sales" "Administration" "Farming" "Manufacturing/Trade" "Transport"
	
matrix colnames results = "Raw Gap (\$)" "Std.Err." "Explained (\$)" "Std.Err." "Unexplained(\$)" "Std.Err." "Explained (\%)" "Unexplained (\%)"

esttab matrix(results, fmt(2)) using "oaxaca_by_occ.tex", replace booktabs

matrix list results
restore

* Raw gender wage gap 
preserve 

* results matrix
matrix results = J(12, 4, .)
local row = 0


levelsof year, local(years)

foreach y of local years {
    local row = `row' + 1
    
    * Mean wages by gender
    quietly summarize hourwage2 if year == `y' & female == 0
    local male_mean = r(mean)
    
    quietly summarize hourwage2 if year == `y' & female == 1
	local female_mean = r(mean)
	
	quietly ttest ln_hourwage2 if year == `y', by(female)
    local diff = r(mu_2) - r(mu_1)
    local pct = (exp(`diff') - 1) * 100  // % gap
    
	* store in results matrix
    matrix results[`row', 1] = `male_mean'
    matrix results[`row', 2] = `female_mean'
    matrix results[`row', 3] = `diff'
    matrix results[`row', 4] = `pct'
}

matrix rownames results = "2015" "2016" "2017" "2018" "2019" "2020" "2021" "2022" "2023" "2024" "2025" "2026"
	
matrix colnames results = "Male" "Female" "Gap" "Gap (\%)"

matrix list results
restore

*-----------------------------------------------------------------------------------------------*
*************************************************************************************************
************************** SECTION 3:PARALLEL TRENDS ********************************************
*************************************************************************************************


*1. Plot treated v control

****************************Gender Wage Gap*******************************************
set scheme s1mono

* YEARLY
preserve
drop if year > 2021
* Calculate mean log wages by gender
collapse (mean) ln_hourwage2, by(treated year female)
* Compute gap
reshape wide ln_hourwage2, i(treated year) j(female)
* male wages (female==0); female wages (female==1)
gen wagegap = ln_hourwage20 - ln_hourwage21

twoway ///
(line wagegap year if treated == 1, sort lcolor(black) lpattern(solid)) ///
(line wagegap year if treated == 0, sort lcolor(black) lpattern(dash)), ///
    legend(label(1 "PTDH Law") label(2 "No PTDH Law") position(6) ring(0) size(tiny) cols(1) region(lstyle(none))) ///
    xtitle("") ///
    ytitle("Log Wage Gap (Male - Female)") ///
    xscale(range(2015 2020) noextend) ///
    xlabel(2016 2018 2020) ///
    title("A. Yearly", size(medium)) ///
    graphregion(color(white)) ///
    name(yearlyPT, replace)
restore

* MONTHLY
preserve
drop if mdate > `=tm(2020m12)'
* Calculate mean log wages by gender
collapse (mean) ln_hourwage2, by(treated mdate female)
* Compute gap
reshape wide ln_hourwage2, i(treated mdate) j(female)
* male wages (female==0); female wages (female==1)
gen wagegap = ln_hourwage20 - ln_hourwage21

twoway ///
(line wagegap mdate if treated == 1, sort lcolor(black) lpattern(solid)) ///
(line wagegap mdate if treated == 0, sort lcolor(black) lpattern(dash)), ///
    legend(off) ///
    xtitle("") ///
    ytitle("Log Wage Gap (Male - Female)") ///
    xscale(range(`=tm(2015m1)' `=tm(2020m12)') noextend) ///
    xlabel(`=tm(2015m1)' "Jan '15" `=tm(2016m7)' "Jul '16" `=tm(2018m1)' "Jan '18" `=tm(2019m7)' "Jul '19"`=tm(2020m12)' "Dec '20") ///
    title("B. Monthly", size(medium)) ///
    graphregion(color(white)) ///
    name(monthlyPT, replace)
restore

graph combine yearlyPT monthlyPT, ///
	xsize(10) ysize(10) ///
	rows(2) ///
	name(combined, replace)

cd "$project_graphs"
graph export "parralell_trends_graph.png", width(2000) replace


************* Event Study TWFE - Quarterly Basis *************************
* Given CPS data is very noisy, I restrict monthly data to quarterly for cleaner assessment of pre trends.

preserve

*Generate Quarters
gen qdate      = qofd(dofm(mdate))         // calendar quarter for each obs
gen effective_q = qofd(dofm(effective_m))  // quarter of law effective date
format qdate %tq
format effective_q %tq

* Collapse to quarterly data
collapse (mean) ln_hourwage2 educ_years exp exp2 married childunder5 ///
         (firstnm) never_treated effective_q treated           ///
         [pweight = earnwt],                                    ///
         by(county qdate female statefip race_cat occ_group)

* Saturated DDD Fixed Effects
capture drop female_county_es female_time_es county_time_es
egen female_county_es = group(female county)   // alpha_s: Female x jurisdiction
egen female_time_es   = group(female qdate)    // tau_t:   Female x time
egen county_time_es   = group(county qdate)    // eta_st:  Jurisdiction x time

* Event Time Dummies
capture drop k_q lead_q* lag_q*
gen k_q = qdate - effective_q if treated == 1

* bin periods not included
replace k_q = -6 if k_q < -6 & !missing(k_q)
replace k_q = 4  if k_q > 4  & !missing(k_q)

* Pre-period dummies, omitting k_q = -1
forvalues i = 2/6 {
    gen lead_q`i' = (k_q == -`i') if treated == 1
    replace lead_q`i' = 0 if never_treated == 1
}

* Post-period dummies
forvalues i = 0/4 {
    gen lag_q`i' = (k_q == `i') if treated == 1
    replace lag_q`i' = 0 if never_treated == 1
}

* Female x event-quarter interactions
foreach var of varlist lead_q* lag_q* {
    gen `var'_female = `var' * female
}

* Macro lists

local leads_q lead_q6 lead_q5 lead_q4 lead_q3 lead_q2
local lags_q lag_q0 lag_q1 lag_q2 lag_q3 lag_q4
local leads_q_fem lead_q6_female lead_q5_female lead_q4_female lead_q3_female lead_q2_female
local lags_q_fem lag_q0_female lag_q1_female lag_q2_female lag_q3_female lag_q4_female

* TWFE regression
* No Occupation Fixed Effects
reghdfe ln_hourwage2 `leads_q' `lags_q' `leads_q_fem' `lags_q_fem' ///
    educ_years exp exp2 married childunder5 i.race_cat, ///
    absorb(female_county_es female_time_es county_time_es) ///
    vce(cluster statefip)

* Joint pre-trend test
testparm `leads_q_fem'

* Plot
coefplot, keep(`leads_q_fem' `lags_q_fem') ///
    vertical ///
    yline(0, lpattern(dash) lcolor(gs8)) ///
    xline(5.5, lpattern(solid) lcolor(cranberry)) ///
    recast(line) lcolor(black) lwidth(medium) ///
    ciopts(recast(rcap) lcolor(blue%40) lwidth(thin)) ///
    title("Overall Gender Wage Gap: Quarterly Event Study", ///
          size(medium)) ///
    xtitle("Quarters Relative to Law Effective Date", size(small)) ///
    ytitle("Female Event-Time Coefficient (95% CI)", size(small)) ///
    graphregion(color(white)) ///
    xlabel(, labels angle(45) labsize(small)) ///
    coeflabels(lead_q6_female = "-6" lead_q5_female = "-5" lead_q4_female = "-4"  lead_q3_female = "-3" lead_q2_female = "-2" lag_q0_female  = "0" lag_q1_female  = "1" lag_q2_female  = "2" lag_q3_female  = "3" lag_q4_female  = "4") ///
	name(event_plot_q1, replace)
	
* TWFE regression
* Occupation Fixed Effects
reghdfe ln_hourwage2 `leads_q' `lags_q' `leads_q_fem' `lags_q_fem' ///
    educ_years exp exp2 married childunder5 i.race_cat, ///
    absorb(female_county_es female_time_es county_time_es occ_group) ///
    vce(cluster statefip)

* Joint pre-trend test
testparm `leads_q_fem'

* Plot
coefplot, keep(`leads_q_fem' `lags_q_fem') ///
    vertical ///
    yline(0, lpattern(dash) lcolor(gs8)) ///
    xline(5.5, lpattern(solid) lcolor(cranberry)) ///
    recast(line) lcolor(black) lwidth(medium) ///
    ciopts(recast(rcap) lcolor(blue%40) lwidth(thin)) ///
    title("Within Occupation Gender Wage Gap: Quarterly Event Study", ///
          size(medium)) ///
    xtitle("Quarters Relative to Law Effective Date", size(small)) ///
    ytitle("Female Event-Time Coefficient (95% CI)", size(small)) ///
    graphregion(color(white)) ///
    xlabel(, labels angle(45) labsize(small)) ///
    coeflabels(lead_q6_female = "-6" lead_q5_female = "-5" lead_q4_female = "-4"  lead_q3_female = "-3" lead_q2_female = "-2" lag_q0_female  = "0" lag_q1_female  = "1" lag_q2_female  = "2" lag_q3_female  = "3" lag_q4_female  = "4") ///
	name(event_plot_q2, replace)

graph combine event_plot_q1 event_plot_q2, ///
	xsize(12) ysize(10) ///
	rows(2) ///
	name(event_plot, replace)

cd "$project_graphs"
graph export "event_study_twfe.png", width(2000) replace

************* Event Study S&A - Quarterly Basis *************************
* This approach implements eventstudyinteract following Sun & Abraham (2021) for a more robust check of the common trends assumption.

* Macro lists
local leads_q lead_q6 lead_q5 lead_q4 lead_q3 lead_q2
local lags_q lag_q0 lag_q1 lag_q2 lag_q3 lag_q4
local leads_q_fem lead_q6_female lead_q5_female lead_q4_female lead_q3_female lead_q2_female
local lags_q_fem lag_q0_female lag_q1_female lag_q2_female lag_q3_female lag_q4_female

* No Occupation Fixed Effects
eventstudyinteract ln_hourwage2  `leads_q' `lags_q' `leads_q_fem' `lags_q_fem', ///
    cohort(effective_q) /// 
    control_cohort(never_treated) /// identifies the clean baseline comparison pool
    absorb(female_county_es female_time_es county_time_es) /// fixed effects
	covariates(educ_years exp exp2 married childunder5 i.race_cat) ///
    vce(cluster statefip) 

* Extract the coefficients matrix from memory
matrix C = e(b_iw)
matrix V = e(V_iw)

* Coefficients row and the standard errors row together vertically
mata st_matrix("A", sqrt(diagonal(st_matrix("e(V_iw)")))')
matrix C = C \ A

* Plot
coefplot matrix(C[1]), se(C[2])  ///
	keep(`leads_q_fem' `lags_q_fem') ///
    vertical ///
    yline(0, lpattern(dash) lcolor(gs8)) ///
    xline(5.5, lpattern(solid) lcolor(cranberry)) ///
    recast(line) lcolor(black) lwidth(medium) ///
    ciopts(recast(rcap) lcolor(blue%40) lwidth(thin)) ///
    title("Overall Gender Wage Gap: Quarterly Event Study", ///
          size(medium)) ///
    xtitle("Quarters Relative to Law Effective Date", size(small)) ///
    ytitle("Female Event-Time Coefficient (95% CI)", size(small)) ///
    graphregion(color(white)) ///
    xlabel(, labels angle(45) labsize(small)) ///
    coeflabels(lead_q6_female = "-6" lead_q5_female = "-5" lead_q4_female = "-4"  lead_q3_female = "-3" lead_q2_female = "-2" lag_q0_female  = "0" lag_q1_female  = "1" lag_q2_female  = "2" lag_q3_female  = "3" lag_q4_female  = "4") ///
	name(event_plot_q3, replace)
	
* Extract the coefficients matrix from memory
matrix C = e(b_iw)
matrix V = e(V_iw)

*joint significance test
ereturn post C V

test (lead_q6_female=0) (lead_q5_female=0) (lead_q4_female=0) (lead_q3_female=0) (lead_q2_female=0)

* Occupation Fixed Effects
eventstudyinteract ln_hourwage2  `leads_q' `lags_q' `leads_q_fem' `lags_q_fem', ///
    cohort(effective_q) /// 
    control_cohort(never_treated) /// identifies the clean baseline comparison pool
    absorb(female_county_es female_time_es county_time_es occ_group) /// fixed effects
	covariates(educ_years exp exp2 married childunder5 i.race_cat) ///
    vce(cluster statefip) 

* Extract the coefficients matrix from memory
matrix C = e(b_iw)
matrix V = e(V_iw)

* Coefficients row and the standard errors row together vertically
mata st_matrix("A", sqrt(diagonal(st_matrix("e(V_iw)")))')
matrix C = C \ A

* Plot
coefplot matrix(C[1]), se(C[2])  ///
	keep(`leads_q_fem' `lags_q_fem') ///
    vertical ///
    yline(0, lpattern(dash) lcolor(gs8)) ///
    xline(5.5, lpattern(solid) lcolor(cranberry)) ///
    recast(line) lcolor(black) lwidth(medium) ///
    ciopts(recast(rcap) lcolor(blue%40) lwidth(thin)) ///
    title("Within Occupation Gender Wage Gap: Quarterly Event Study", ///
          size(medium)) ///
    xtitle("Quarters Relative to Law Effective Date", size(small)) ///
    ytitle("Female Event-Time Coefficient (95% CI)", size(small)) ///
    graphregion(color(white)) ///
    xlabel(, labels angle(45) labsize(small)) ///
    coeflabels(lead_q6_female = "-6" lead_q5_female = "-5" lead_q4_female = "-4"  lead_q3_female = "-3" lead_q2_female = "-2" lag_q0_female  = "0" lag_q1_female  = "1" lag_q2_female  = "2" lag_q3_female  = "3" lag_q4_female  = "4") ///
	name(event_plot_q4, replace)
	
* Extract the coefficients matrix from memory
matrix C = e(b_iw)
matrix V = e(V_iw)

*joint significance test
ereturn post C V

test (lead_q6_female=0) (lead_q5_female=0) (lead_q4_female=0) (lead_q3_female=0) (lead_q2_female=0)

graph combine event_plot_q3 event_plot_q4, ///
	xsize(12) ysize(10) ///
	rows(2) ///
	name(event_plot2, replace)

cd "$project_graphs"
graph export "event_study_AS.png", width(2000) replace

restore

*-----------------------------------------------------------------------------------------------*
*************************************************************************************************
*************************** SECTION 5: REGRESSIONS **********************************************
*************************************************************************************************
cd "$project_data"
use data_for_regressions.dta, clear // reset data

***************************TWO WAY FIXED EFFECTS*************************************************
** std errors clustered at state level
egen female_county_fe = group(female county)   // alpha_s: Female x jurisdiction
egen female_time_fe   = group(female mdate)    // tau_t:   Female x time
egen county_time_fe   = group(county mdate)    // eta_st:  Jurisdiction x time

save data_for_regressions.dta, replace // save with fixed effects

reghdfe ln_hourwage2 female_post ///
	educ_years exp exp2 married childunder5 i.race_cat ///
	[pweight = earnwt], ///
	absorb(female_county_fe female_time_fe county_time_fe) ///
	vce(cluster statefip)
	
cd "$project_tables"
outreg2 using mainregression.tex, drop (educ_years exp exp2 married childunder5 i.race_cat) replace bdec(3) sdec(4)

*Include Occupation fixed effects
reghdfe ln_hourwage2 female_post ///
	educ_years exp exp2 married childunder5 i.race_cat ///
	[pweight = earnwt], ///
	absorb(female_county_fe female_time_fe county_time_fe occ_group) ///
	vce(cluster statefip)

cd "$project_tables"
outreg2 using mainregression.tex, drop (educ_years exp exp2 married childunder5 i.race_cat) append bdec(3) sdec(4)

***************************STACKED DID *************************************************
*ssc install stackedev

* recreate saturated fixed effects with group variable 

* No occupation fixed effects
stackedev ln_hourwage2 female_post, ///
    cohort(gvar) ///
    time(mdate) ///
    never_treat(never_treated) ///
    unit_fe(county) ///
    clust_unit(statefip) ///
    covariates(educ_years exp exp2 married childunder5 i.race_cat) ///
	other_fe(female_county_fe female_time_fe county_time_fe)

outreg2 using mainregression.tex, ///
    drop(educ_years exp exp2 married childunder5 i.race_cat) ///
    append bdec(3) sdec(4)

*reset data 
cd "$project_data"
use data_for_regressions.dta, clear

* Include occupation fixed effects
stackedev ln_hourwage2 female_post, ///
    cohort(gvar) ///
    time(mdate) ///
    never_treat(never_treated) ///
    unit_fe(county) ///
    clust_unit(statefip) ///
    covariates(educ_years exp exp2 married childunder5 i.race_cat) ///
	other_fe(female_county_fe female_time_fe county_time_fe occ_group)
	
cd "$project_tables"

outreg2 using mainregression.tex, ///
    drop(educ_years exp exp2 married childunder5 i.race_cat) ///
    append bdec(3) sdec(4)

cd "$project_data"
use data_for_regressions.dta, clear // reset data

*** Alternative clustering
*1. County clustering
* recreate saturated fixed effects with group variable capture drop female_county_fe female_time_fe county_time_fe

preserve
stackedev ln_hourwage2 female_post, ///
    cohort(gvar) ///
    time(mdate) ///
    never_treat(never_treated) ///
    unit_fe(county) ///
    clust_unit(county) ///
    covariates(educ_years exp exp2 married childunder5 i.race_cat) ///
	other_fe(female_county_fe female_time_fe county_time_fe)

cd "$project_tables"

outreg2 using mainregression.tex, ///
    drop(educ_years exp exp2 married childunder5 i.race_cat) ///
    append bdec(3) sdec(4)
restore

preserve
stackedev ln_hourwage2 female_post, ///
    cohort(gvar) ///
    time(mdate) ///
    never_treat(never_treated) ///
    unit_fe(county) ///
    clust_unit(county) ///
    covariates(educ_years exp exp2 married childunder5 i.race_cat) ///
	other_fe(female_county_fe female_time_fe county_time_fe occ_group)

cd "$project_tables"

outreg2 using mainregression.tex, ///
    drop(educ_years exp exp2 married childunder5 i.race_cat) ///
    append bdec(3) sdec(4)
restore

*2. Wild cluster bootstrap 
* In order to use boot command with stackedev, I need to manually construct the stackedev package. Code for building and appending stacks sourced from stackedev.ado and modified for to keep appropriate form for wild cluster bootstrap.

cd "$project_data"
use data_for_regressions.dta, clear

********************************************************************************
//Creating stacks for each treated cohort of units
qui levelsof gvar
        local t_val=r(levels)
foreach i of local t_val{
preserve
di "**** Building Stack `i' ****"

qui gen stack_keep=0
qui replace stack_keep=1 if gvar ==`i'
qui replace stack_keep=1 if never_treated==1
qui keep if stack_keep==1
qui drop stack_keep
qui gen stack=`i'
qui tempfile stack`i'
qui save "`stack`i''"
restore
}
********************************************************************************
//Appending together each stack
qui sum gvar
local stackmin=r(min)

qui levelsof gvar if gvar!=`stackmin'
        local t_val2=r(levels)
        
qui use "`stack`stackmin''", clear

qui tempfile all_stacks
qui save `all_stacks', emptyok

di "**** Appending Stacks ****"
foreach j of local t_val2{
    qui append using "`stack`j''"
    qui save `"`all_stacks'"', replace
}

********************************************************************************
//Creating variable to estimate unit by stack variances
qui gen unit_stack=stack*statefip
local clust_var unit_stack

********************************************************************************
//Estimating model with reghdfe
* No occupation fixed effects
di "**** Estimating Model with reghdfe ****"
reghdfe ln_hourwage2 educ_years exp exp2 married childunder5 i.race_cat, absorb(i.county##i.stack i.mdate##i.stack female_county_fe female_time_fe county_time_fe) cluster(`clust_var') residuals(y_residuals)

reghdfe female_post educ_years exp exp2 married childunder5 i.race_cat, absorb(i.county##i.stack i.mdate##i.stack female_county_fe female_time_fe county_time_fe) cluster(`clust_var') residuals(d_residuals)

* run simplified regression
reg y_residuals d_residuals, cluster(`clust_var')

* wild cluster bootstrap
boottest d_residuals, ///
    cluster(statefip) ///
    reps(999) ///
    seed(12345)
	
//Estimating model with reghdfe
* Occupation fixed effects
//Creating variable to estimate unit by stack variances
local clust_var unit_stack

di "**** Estimating Model with reghdfe ****"
reghdfe ln_hourwage2 educ_years exp exp2 married childunder5 i.race_cat, absorb(i.county##i.stack i.mdate##i.stack female_county_fe female_time_fe county_time_fe occ_group) cluster(`clust_var') residuals(y_residuals2)

reghdfe female_post educ_years exp exp2 married childunder5 i.race_cat, absorb(i.county##i.stack i.mdate##i.stack female_county_fe female_time_fe county_time_fe occ_group) cluster(`clust_var') residuals(d_residuals2)

* run simplified regression
reg y_residuals2 d_residuals2, cluster(`clust_var')

* wild cluster bootstrap
boottest d_residuals2, ///
    cluster(statefip) ///
    reps(999) ///
    seed(12345)
	
******************************* Difference in Decomposition ***********************************
******* Overall Decomp of DiD -- keep only periods when no jurisdctions have adopted and when all jurisdcitions have adopted ********
* Start of Data end of Data
cd "$project_data"
use data_for_regressions.dta, clear // reset data

capture program drop staggered_oaxaca
program define staggered_oaxaca, rclass

local controls educ_years exp exp2 married childunder5 race_2 race_3 race_4 race_5 d13_occ2 d13_occ3 d13_occ4 d13_occ5 d13_occ6 d13_occ7 d13_occ8 d13_occ9 d13_occ10 d13_occ11 d13_occ12

	* treated pre
	capture oaxaca ln_hourwage2 `controls' ///
			if mdate <= ym(2021,1) & treated == 1, by(female) pooled swap relax
	capture matrix b_T_pre = e(b)
			
            
	* treated post
	capture oaxaca ln_hourwage2 `controls' ///
			if mdate >= ym(2025,11) & treated == 1, by(female) pooled swap relax
	capture matrix b_C_post = e(b)
     
	 * control pre
	quietly capture oaxaca ln_hourwage2 `controls' ///
			if mdate <= ym(2021,1) & treated == 0, by(female) pooled swap relax
	capture matrix b_C_pre = e(b)
			
            
	* treated post
	quietly capture oaxaca ln_hourwage2 `controls' ///
			if mdate >= ym(2025,11) & treated == 0, by(female) pooled swap relax
	capture matrix b_T_post = e(b)	
	
	* Compute DiD
	capture matrix did = (b_T_post - b_T_pre) - (b_C_post - b_C_pre) // calculated based on four oaxaca components
	
	matrix list did
	
	return scalar male_wage    = did[1,1]
	return scalar female_wage  = did[1,2]
	return scalar raw_gap      = did[1,3]
	return scalar explained    = did[1,4]
	return scalar unexplained  = did[1,5]
end
	
* Run bootstrap with state-level clustering
bootstrap male_wage=r(male_wage) ///
    female_wage=r(female_wage) ///
    raw_gap=r(raw_gap) ///
    explained=r(explained) ///
    unexplained=r(unexplained), ///
    reps(200) cluster(statefip) idcluster(new_statefip) seed(1234): staggered_oaxaca

cd "$project_tables"
esttab using "DID_oaxaca.tex", replace booktabs b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    title("Difference-in-Decomposition") plain nonum

	
* Drop jurisdictions that adopted in 2025 
cd "$project_data"
use data_for_regressions.dta, clear // reset data

drop if effective_m > ym(2025,1) & treated == 1
capture program drop staggered_oaxaca
program define staggered_oaxaca, rclass

local controls educ_years exp exp2 married childunder5 race_2 race_3 race_4 race_5 d13_occ2 d13_occ3 d13_occ4 d13_occ5 d13_occ6 d13_occ7 d13_occ8 d13_occ9 d13_occ10 d13_occ11 d13_occ12

	* treated pre
	capture oaxaca ln_hourwage2 `controls' ///
			if mdate <= ym(2021,1) & treated == 1, by(female) pooled swap relax
	capture matrix b_T_pre = e(b)
			
            
	* treated post
	capture oaxaca ln_hourwage2 `controls' ///
			if mdate >= ym(2025,1) & treated == 1, by(female) pooled swap relax
	capture matrix b_C_post = e(b)
     
	 * control pre
	quietly capture oaxaca ln_hourwage2 `controls' ///
			if mdate <= ym(2021,1) & treated == 0, by(female) pooled swap relax
	capture matrix b_C_pre = e(b)
			
            
	* treated post
	quietly capture oaxaca ln_hourwage2 `controls' ///
			if mdate >= ym(2025,1) & treated == 0, by(female) pooled swap relax
	capture matrix b_T_post = e(b)	
	
	* Compute DiD
	capture matrix did = (b_T_post - b_T_pre) - (b_C_post - b_C_pre) // calculated based on four oaxaca components
	
	matrix list did
	
	return scalar male_wage    = did[1,1]
	return scalar female_wage  = did[1,2]
	return scalar raw_gap      = did[1,3]
	return scalar explained    = did[1,4]
	return scalar unexplained  = did[1,5]
end
	
* Run bootstrap with state-level clustering
bootstrap male_wage=r(male_wage) ///
    female_wage=r(female_wage) ///
    raw_gap=r(raw_gap) ///
    explained=r(explained) ///
    unexplained=r(unexplained), ///
    reps(200) cluster(statefip) idcluster(new_statefip) seed(1234): staggered_oaxaca

cd "$project_tables"
esttab using "DID_oaxaca.tex", append booktabs b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    title("Difference-in-Decomposition") plain nonum
	
*  Drop jurisdictions that adopted in 2024, 2025 
cd "$project_data"
use data_for_regressions.dta, clear // reset data

drop if effective_m > ym(2024,1) & treated == 1
capture program drop staggered_oaxaca
program define staggered_oaxaca, rclass

local controls educ_years exp exp2 married childunder5 race_2 race_3 race_4 race_5 d13_occ2 d13_occ3 d13_occ4 d13_occ5 d13_occ6 d13_occ7 d13_occ8 d13_occ9 d13_occ10 d13_occ11 d13_occ12

	* treated pre
	capture oaxaca ln_hourwage2 `controls' ///
			if mdate <= ym(2021,1) & treated == 1, by(female) pooled swap relax
	capture matrix b_T_pre = e(b)
			
            
	* treated post
	capture oaxaca ln_hourwage2 `controls' ///
			if mdate >= ym(2024,1) & treated == 1, by(female) pooled swap relax
	capture matrix b_C_post = e(b)
     
	 * control pre
	quietly capture oaxaca ln_hourwage2 `controls' ///
			if mdate <= ym(2021,1) & treated == 0, by(female) pooled swap relax
	capture matrix b_C_pre = e(b)
			
            
	* treated post
	quietly capture oaxaca ln_hourwage2 `controls' ///
			if mdate >= ym(2024,1) & treated == 0, by(female) pooled swap relax
	capture matrix b_T_post = e(b)	
	
	* Compute DiD
	capture matrix did = (b_T_post - b_T_pre) - (b_C_post - b_C_pre) // calculated based on four oaxaca components
	
	matrix list did
	
	return scalar male_wage    = did[1,1]
	return scalar female_wage  = did[1,2]
	return scalar raw_gap      = did[1,3]
	return scalar explained    = did[1,4]
	return scalar unexplained  = did[1,5]
end
	
* Run bootstrap with state-level clustering
bootstrap male_wage=r(male_wage) ///
    female_wage=r(female_wage) ///
    raw_gap=r(raw_gap) ///
    explained=r(explained) ///
    unexplained=r(unexplained), ///
    reps(200) cluster(statefip) idcluster(new_statefip) seed(1234): staggered_oaxaca

cd "$project_tables"
esttab using "DID_oaxaca.tex", append booktabs b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    title("Difference-in-Decomposition") plain nonum
	
**** Staggered Cohort Based Difference-in-Decomposition ********
* 12 Month Window
cd "$project_data"
use data_for_regressions.dta, clear // reset data

capture program drop staggered_oaxaca

* drop cohorts with too short of a post window - PTDH during 2025
drop if effective_m > ym(2025,1) & treated == 1
tab statefip if treated == 1

* Set up program to construct decomposition
program define staggered_oaxaca, rclass
    
	* starting variables
    levelsof gvar if gvar > 0 & gvar != ., local(cohorts) // identify cohorts
    matrix total_diff_in_diff = J(1, 5, 0) // total matrix
    scalar total_obs = 0 // observations used
	scalar cohorts_used = 0 // cohorts used - since some will not work with oaxaca + bootstrapping
	
	local controls educ_years exp exp2 married childunder5 race_2 race_3 race_4 race_5 // controls for oaxaca, occupations excluded 
    
	* set event window and calculate for each cohort
    foreach c of local cohorts {
        scalar c_skip = 0
		capture matrix drop b_T_pre b_T_post b_C_pre b_C_post cohort_did cohort_summary
		
        preserve
            keep if gvar == `c' | never_treated == 1
			keep if mdate >= `c' - 12 & mdate <= `c' + 12 // 12 months before and after PTDH adoption
			
            gen c_post = (mdate >= `c')
            gen c_treat = (gvar == `c')
			
			* check cell sizes for to make sure bootstrap iteration will execute
			foreach comp in "c_treat == 1 & c_post == 0" "c_treat == 1 & c_post == 1" "c_treat == 0 & c_post == 0" "c_treat == 0 & c_post == 1" {
				foreach gender in 0 1{
					count if `comp' & female == `gender'
					if r(N) < 20 scalar c_skip = 1 // skip if will cause bootstrap to fail
				}
			}
            
            count if c_treat == 1
            scalar c_obs = r(N)
            
			* treated pre
			if c_skip == 0{ 
				quietly capture oaxaca ln_hourwage2 `controls' ///
					if c_treat==1 & c_post==0, by(female) pooled swap relax
				local rc1 = _rc
				// check that calculation worked
				if `rc1' != 0{
					scalar c_skip = 1
				}
				else{
					capture matrix b_T_pre = e(b)
					local mrc1 = _rc
					if `mrc1' != 0 scalar c_skip = 1
				}
			}
            
			* treated post
            if c_skip == 0{
				quietly capture oaxaca ln_hourwage2 `controls' ///
					if c_treat==1 & c_post==1, by(female) pooled swap relax
				local rc2 = _rc
				// check that calculation worked
				if `rc2' != 0{
					scalar c_skip = 1
				}
				else{
					capture matrix b_T_post = e(b)
					local mrc2 = _rc
					if `mrc2' != 0 scalar c_skip = 1
				}
			}
            
			* control pre
            if c_skip == 0{
				quietly capture oaxaca ln_hourwage2 `controls' ///
					if c_treat==0 & c_post==0, by(female) pooled swap relax
				local rc3 = _rc
				// check that calculation worked
				if `rc3' != 0{
					scalar c_skip = 1
				}
				else{
					capture matrix b_C_pre = e(b)
					local mrc3 = _rc
					if `mrc3' != 0 scalar c_skip = 1
				}
			}
            
			* control post
            if c_skip == 0{
				quietly capture oaxaca ln_hourwage2 `controls' ///
					if c_treat==0 & c_post==1, by(female) pooled swap relax
				local rc4 = _rc
				// check that calculation worked
				if `rc4' != 0{
					scalar c_skip = 1
				}
				else{
					capture matrix b_C_post = e(b)
					local mrc4 = _rc
					if `mrc4' != 0 scalar c_skip = 1
				}
			}
			
			* Compute DiD for cohort
			if c_skip == 0{
				capture matrix cohort_did = (b_T_post - b_T_pre) - (b_C_post - b_C_pre) // calculated based on four oaxaca components calculated above
				local rc5 = _rc
				if `rc5' != 0 scalar c_skip = 1
			}
			
			* accumulate cohort results into main matrix 
			if c_skip == 0 {
				matrix cohort_summary = J(1, 5, 0)
				matrix cohort_summary[1,1] = cohort_did[1, "overall:group_1"]
				matrix cohort_summary[1,2] = cohort_did[1, "overall:group_2"]
				matrix cohort_summary[1,3] = cohort_did[1, "overall:difference"]
				matrix cohort_summary[1,4] = cohort_did[1, "overall:explained"]
				matrix cohort_summary[1,5] = cohort_did[1, "overall:unexplained"]
			
				
			
				matrix total_diff_in_diff = total_diff_in_diff + (cohort_summary)
				scalar total_obs = total_obs + scalar(c_obs) // adjust total observations based on number of observations used for cohort
				scalar cohorts_used = cohorts_used + 1 // update to add that cohort was used
			}
		restore
	}
        
	
	// exit if not enough cohorts return results
	if total_obs == 0 | cohorts_used < 3 { 
		
		exit 2000
	}
	
	matrix final_did = total_diff_in_diff / scalar(cohorts_used) // final matrix for results
	
	return scalar male_wage=final_did[1,1] // effect on male wages
	return scalar female_wage=final_did[1,2] // effect on female wages
	return scalar raw_gap=final_did[1,3] // overall gender wage gap
	return scalar explained=final_did[1,4] // explained portion
	return scalar unexplained=final_did[1,5] // unexplained portion
	return scalar no_cohorts_used = cohorts_used // how many cohorts actually used
end

* Run bootstrap with state-level clustering
bootstrap male_wage=r(male_wage) ///
    female_wage=r(female_wage) ///
    raw_gap=r(raw_gap) ///
    explained=r(explained) ///
    unexplained=r(unexplained) ///
	n_cohorts=r(no_cohorts_used), ///
    reps(200) cluster(statefip) idcluster(new_statefip) seed(1234): staggered_oaxaca

estout

cd "$project_tables"
esttab using "staggered_oaxaca.tex", replace booktabs b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    title("Difference-in-Decomposition") plain nonum
	
************* 24 Month Window ***********************
cd "$project_data"
use data_for_regressions.dta, clear // reset data

* drop jurisdictions where not enough data after adoption for 24 month window
drop if effective_m > ym(2024,1) & treated == 1
tab statefip if treated == 1

capture program drop staggered_oaxaca

* Set up program to construct decomposition
program define staggered_oaxaca, rclass
    
	* starting variables
    levelsof gvar if gvar > 0 & gvar != ., local(cohorts) // identify cohorts
    matrix total_diff_in_diff = J(1, 5, 0) // total matrix
    scalar total_obs = 0 // observations used
	scalar cohorts_used = 0 // cohorts used - since some will not work with oaxaca + bootstrapping
	
	local controls educ_years exp exp2 married childunder5 race_2 race_3 race_4 race_5 // controls for oaxaca, occupations excluded 
    
	* set event window and calculate for each cohort
    foreach c of local cohorts {
        scalar c_skip = 0
		capture matrix drop b_T_pre b_T_post b_C_pre b_C_post cohort_did cohort_summary
		
        preserve
            keep if gvar == `c' | never_treated == 1
			keep if mdate >= `c' - 12 & mdate <= `c' + 24 // 12 months before and 24 months after PTDH adoption
			
            gen c_post = (mdate >= `c')
            gen c_treat = (gvar == `c')
			
			* check cell sizes for to make sure bootstrap iteration will execute
			foreach comp in "c_treat == 1 & c_post == 0" "c_treat == 1 & c_post == 1" "c_treat == 0 & c_post == 0" "c_treat == 0 & c_post == 1" {
				foreach gender in 0 1{
					count if `comp' & female == `gender'
					if r(N) < 20 scalar c_skip = 1 // skip if will cause bootstrap to fail
				}
			}
            
            count if c_treat == 1
            scalar c_obs = r(N)
            
			* treated pre
			if c_skip == 0{ 
				quietly capture oaxaca ln_hourwage2 `controls' ///
					if c_treat==1 & c_post==0, by(female) pooled swap relax
				local rc1 = _rc
				// check that calculation worked
				if `rc1' != 0{
					scalar c_skip = 1
				}
				else{
					capture matrix b_T_pre = e(b)
					local mrc1 = _rc
					if `mrc1' != 0 scalar c_skip = 1
				}
			}
            
			* treated post
            if c_skip == 0{
				quietly capture oaxaca ln_hourwage2 `controls' ///
					if c_treat==1 & c_post==1, by(female) pooled swap relax
				local rc2 = _rc
				// check that calculation worked
				if `rc2' != 0{
					scalar c_skip = 1
				}
				else{
					capture matrix b_T_post = e(b)
					local mrc2 = _rc
					if `mrc2' != 0 scalar c_skip = 1
				}
			}
            
			* control pre
            if c_skip == 0{
				quietly capture oaxaca ln_hourwage2 `controls' ///
					if c_treat==0 & c_post==0, by(female) pooled swap relax
				local rc3 = _rc
				// check that calculation worked
				if `rc3' != 0{
					scalar c_skip = 1
				}
				else{
					capture matrix b_C_pre = e(b)
					local mrc3 = _rc
					if `mrc3' != 0 scalar c_skip = 1
				}
			}
            
			* control post
            if c_skip == 0{
				quietly capture oaxaca ln_hourwage2 `controls' ///
					if c_treat==0 & c_post==1, by(female) pooled swap relax
				local rc4 = _rc
				// check that calculation worked
				if `rc4' != 0{
					scalar c_skip = 1
				}
				else{
					capture matrix b_C_post = e(b)
					local mrc4 = _rc
					if `mrc4' != 0 scalar c_skip = 1
				}
			}
			
			* Compute DiD for cohort
			if c_skip == 0{
				capture matrix cohort_did = (b_T_post - b_T_pre) - (b_C_post - b_C_pre) // calculated based on four oaxaca components calculated above
				local rc5 = _rc
				if `rc5' != 0 scalar c_skip = 1
			}
			
			* accumulate cohort results into main matrix 
			if c_skip == 0 {
				matrix cohort_summary = J(1, 5, 0)
				matrix cohort_summary[1,1] = cohort_did[1, "overall:group_1"]
				matrix cohort_summary[1,2] = cohort_did[1, "overall:group_2"]
				matrix cohort_summary[1,3] = cohort_did[1, "overall:difference"]
				matrix cohort_summary[1,4] = cohort_did[1, "overall:explained"]
				matrix cohort_summary[1,5] = cohort_did[1, "overall:unexplained"]
			
				
			
				matrix total_diff_in_diff = total_diff_in_diff + (cohort_summary)
				scalar total_obs = total_obs + scalar(c_obs) // adjust total observations based on number of observations used for cohort
				scalar cohorts_used = cohorts_used + 1 // update to add that cohort was used
			}
		restore
	}
        
	
	// exit if not enough cohorts return results
	if total_obs == 0 | cohorts_used < 3 { 
		
		exit 2000
	}
	
	matrix final_did = total_diff_in_diff / scalar(cohorts_used) // final matrix for results
	
	return scalar male_wage=final_did[1,1] // effect on male wages
	return scalar female_wage=final_did[1,2] // effect on female wages
	return scalar raw_gap=final_did[1,3] // overall gender wage gap
	return scalar explained=final_did[1,4] // explained portion
	return scalar unexplained=final_did[1,5] // unexplained portion
	return scalar no_cohorts_used = cohorts_used // how many cohorts actually used
end

* Run bootstrap with state-level clustering
bootstrap male_wage=r(male_wage) ///
    female_wage=r(female_wage) ///
    raw_gap=r(raw_gap) ///
    explained=r(explained) ///
    unexplained=r(unexplained) ///
	n_cohorts=r(no_cohorts_used), ///
    reps(200) cluster(statefip) idcluster(new_statefip) seed(1234): staggered_oaxaca

estout 

cd "$project_tables"
esttab using "staggered_oaxaca.tex", append booktabs b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    title("Difference-in-Decomposition") plain nonum
	
*-----------------------------------------------------------------------------------------------*
*************************************************************************************************
*************************** SECTION 6: ROBUSTNESS & MECHANISMS **********************************
*************************************************************************************************

******************************* Drop States with Late Treatment ***********************************
* Given PTDH is correlated with changing jobs, effects may take time. Thus, I drop jurisdiction that were treated in 2025 and then drop those treated in 2024 and 2025. 

cd "$project_data"
use data_for_regressions.dta, clear // reset data

drop if effective_m >= ym(2025,1) & treated == 1
tab statefip if treated == 1

preserve
* No occupation fixed effects
stackedev ln_hourwage2 female_post, ///
    cohort(gvar) ///
    time(mdate) ///
    never_treat(never_treated) ///
    unit_fe(county) ///
    clust_unit(statefip) ///
    covariates(educ_years exp exp2 married childunder5 i.race_cat) ///
	other_fe(female_county_fe female_time_fe county_time_fe)
	
cd "$project_tables"

outreg2 using mainregression2.tex, ///
    drop(educ_years exp exp2 married childunder5 i.race_cat) ///
    replace bdec(3) sdec(4)
restore

preserve
* No occupation fixed effects
stackedev ln_hourwage2 female_post, ///
    cohort(gvar) ///
    time(mdate) ///
    never_treat(never_treated) ///
    unit_fe(county) ///
    clust_unit(statefip) ///
    covariates(educ_years exp exp2 married childunder5 i.race_cat) ///
	other_fe(female_county_fe female_time_fe county_time_fe occ_group)
	
cd "$project_tables"

outreg2 using mainregression2.tex, ///
    drop(educ_years exp exp2 married childunder5 i.race_cat) ///
    append bdec(3) sdec(4)
restore

drop if effective_m >= ym(2024,1) & treated == 1
tab statefip if treated == 1

preserve
* No occupation fixed effects
stackedev ln_hourwage2 female_post, ///
    cohort(gvar) ///
    time(mdate) ///
    never_treat(never_treated) ///
    unit_fe(county) ///
    clust_unit(statefip) ///
    covariates(educ_years exp exp2 married childunder5 i.race_cat) ///
	other_fe(female_county_fe female_time_fe county_time_fe)
	
cd "$project_tables"

outreg2 using mainregression2.tex, ///
    drop(educ_years exp exp2 married childunder5 i.race_cat) ///
    append bdec(3) sdec(4)
restore

preserve
* No occupation fixed effects
stackedev ln_hourwage2 female_post, ///
    cohort(gvar) ///
    time(mdate) ///
    never_treat(never_treated) ///
    unit_fe(county) ///
    clust_unit(statefip) ///
    covariates(educ_years exp exp2 married childunder5 i.race_cat) ///
	other_fe(female_county_fe female_time_fe county_time_fe occ_group)
	
cd "$project_tables"

outreg2 using mainregression2.tex, ///
    drop(educ_years exp exp2 married childunder5 i.race_cat) ///
    append bdec(3) sdec(4)
restore

******************************* Anticipation Effects ***********************************
* I use the saturated DDD model here and use signing date of the legislation in contrast to effective date of the legislation.
cd "$project_data"
use data_for_regressions.dta, clear // reset data

* reset gvar, never treated
drop gvar gvar_raw never_treated

bysort statefip county: egen gvar_raw = min(signed_m) if treated == 1 // generate group variable
	replace gvar_raw = 0 if gvar_raw == . // never treated variables = 0
	bysort statefip county: egen gvar = max(gvar_raw) // ensure same for each county
	
gen never_treated = (gvar == 0) // gen never treated indicator

* reassign post based on signing date
* Event-time relative to law effective month
drop post diff female_post

gen diff = mdate - signed_m  // months since signing date
gen post = diff >= 0
replace post = 0 if treated==0
gen female_post = female * post // variable identify interaction

preserve
* No occupation fixed effects
stackedev ln_hourwage2 female_post, ///
    cohort(gvar) ///
    time(mdate) ///
    never_treat(never_treated) ///
    unit_fe(county) ///
    clust_unit(statefip) ///
    covariates(educ_years exp exp2 married childunder5 i.race_cat) ///
	other_fe(female_county_fe female_time_fe county_time_fe)

cd "$project_tables"

outreg2 using mainregression3.tex, ///
    drop(educ_years exp exp2 married childunder5 i.race_cat) ///
    replace bdec(3) sdec(4)

restore

preserve
* Occupation fixed effects
stackedev ln_hourwage2 female_post, ///
    cohort(gvar) ///
    time(mdate) ///
    never_treat(never_treated) ///
    unit_fe(county) ///
    clust_unit(statefip) ///
    covariates(educ_years exp exp2 married childunder5 i.race_cat) ///
	other_fe(occ_group female_county_fe female_time_fe county_time_fe)

outreg2 using mainregression3.tex, ///
    drop(educ_years exp exp2 married childunder5 i.race_cat) ///
    append bdec(3) sdec(4)

restore

******************************* Wage Dispersion ***********************************
* does wage dispersion decrease as a result of PTDH

*ssc install rif, replace

cd "$project_data"
use data_for_regressions.dta, clear // reset data

* compute rif for pre treatment female wage distribution
egen rif_p10_pre =  rifvar(ln_hourwage2) if female == 1 & post == 0, q(10)
egen rif_p50_pre =  rifvar(ln_hourwage2) if female == 1 & post == 0, q(50)
egen rif_p90_pre =  rifvar(ln_hourwage2) if female == 1 & post == 0, q(90)
egen rif_var_pre =  rifvar(ln_hourwage2) if female == 1 & post == 0, cvar
egen rif_inequality_pre =  rifvar(ln_hourwage2) if female == 1 & post == 0, gini

* compute for overall sample
egen rif_p10 =  rifvar(ln_hourwage2) if female == 1, q(10)
egen rif_p50 =  rifvar(ln_hourwage2) if female == 1, q(50)
egen rif_p90 =  rifvar(ln_hourwage2) if female == 1, q(90)
egen rif_var =  rifvar(ln_hourwage2) if female == 1, cvar
egen rif_inequality =  rifvar(ln_hourwage2) if female == 1, gini

* drop male observations
keep if female == 1

* 10th percentile
preserve
stackedev rif_p10 post, ///
    cohort(gvar) ///
    time(mdate) ///
    never_treat(never_treated) ///
    unit_fe(county) ///
    clust_unit(statefip) ///
    covariates(educ_years exp exp2 married childunder5 i.race_cat) ///
    other_fe(county_time_fe)

cd "$project_tables"
outreg2 using mainregression4a.tex, ///
    drop(educ_years exp exp2 married childunder5 i.race_cat) ///
    replace bdec(3) sdec(4)
restore

preserve
stackedev rif_p10 post, ///
    cohort(gvar) ///
    time(mdate) ///
    never_treat(never_treated) ///
    unit_fe(county) ///
    clust_unit(statefip) ///
    covariates(educ_years exp exp2 married childunder5 i.race_cat) ///
    other_fe(occ_group county_time_fe)

outreg2 using mainregression4b.tex, ///
    drop(educ_years exp exp2 married childunder5 i.race_cat) ///
    replace bdec(3) sdec(4)
restore

* 50th percentile
preserve
stackedev rif_p50 post, ///
    cohort(gvar) ///
    time(mdate) ///
    never_treat(never_treated) ///
    unit_fe(county) ///
    clust_unit(statefip) ///
    covariates(educ_years exp exp2 married childunder5 i.race_cat) ///
    other_fe(county_time_fe)

outreg2 using mainregression4a.tex, ///
    drop(educ_years exp exp2 married childunder5 i.race_cat) ///
    append bdec(3) sdec(4)
restore

preserve
stackedev rif_p50 post, ///
    cohort(gvar) ///
    time(mdate) ///
    never_treat(never_treated) ///
    unit_fe(county) ///
    clust_unit(statefip) ///
    covariates(educ_years exp exp2 married childunder5 i.race_cat) ///
    other_fe(occ_group county_time_fe)

outreg2 using mainregression4b.tex, ///
    drop(educ_years exp exp2 married childunder5 i.race_cat) ///
    append bdec(3) sdec(4)
restore

* 90th percentile
preserve
stackedev rif_p90 post, ///
    cohort(gvar) ///
    time(mdate) ///
    never_treat(never_treated) ///
    unit_fe(county) ///
    clust_unit(statefip) ///
    covariates(educ_years exp exp2 married childunder5 i.race_cat) ///
    other_fe(county_time_fe)

outreg2 using mainregression4a.tex, ///
    drop(educ_years exp exp2 married childunder5 i.race_cat) ///
    append bdec(3) sdec(4)
restore

preserve
stackedev rif_p90 post, ///
    cohort(gvar) ///
    time(mdate) ///
    never_treat(never_treated) ///
    unit_fe(county) ///
    clust_unit(statefip) ///
    covariates(educ_years exp exp2 married childunder5 i.race_cat) ///
    other_fe(occ_group county_time_fe)

outreg2 using mainregression4b.tex, ///
    drop(educ_years exp exp2 married childunder5 i.race_cat) ///
    append bdec(3) sdec(4)
restore

* variance
preserve
stackedev rif_var post, ///
    cohort(gvar) ///
    time(mdate) ///
    never_treat(never_treated) ///
    unit_fe(county) ///
    clust_unit(statefip) ///
    covariates(educ_years exp exp2 married childunder5 i.race_cat) ///
    other_fe(county_time_fe)

outreg2 using mainregression4c.tex, ///
    drop(educ_years exp exp2 married childunder5 i.race_cat) ///
    replace bdec(3) sdec(4)
restore

preserve
stackedev rif_var post, ///
    cohort(gvar) ///
    time(mdate) ///
    never_treat(never_treated) ///
    unit_fe(county) ///
    clust_unit(statefip) ///
    covariates(educ_years exp exp2 married childunder5 i.race_cat) ///
    other_fe(occ_group county_time_fe)

outreg2 using mainregression4c.tex, ///
    drop(educ_years exp exp2 married childunder5 i.race_cat) ///
    append bdec(3) sdec(4)
restore

* inequality
preserve
stackedev rif_inequality post, ///
    cohort(gvar) ///
    time(mdate) ///
    never_treat(never_treated) ///
    unit_fe(county) ///
    clust_unit(statefip) ///
    covariates(educ_years exp exp2 married childunder5 i.race_cat) ///
    other_fe(county_time_fe)

outreg2 using mainregression4c.tex, ///
    drop(educ_years exp exp2 married childunder5 i.race_cat) ///
    append bdec(3) sdec(4)
restore

preserve
stackedev rif_inequality post, ///
    cohort(gvar) ///
    time(mdate) ///
    never_treat(never_treated) ///
    unit_fe(county) ///
    clust_unit(statefip) ///
    covariates(educ_years exp exp2 married childunder5 i.race_cat) ///
    other_fe(occ_group county_time_fe)

outreg2 using mainregression4c.tex, ///
    drop(educ_years exp exp2 married childunder5 i.race_cat) ///
    append bdec(3) sdec(4)
restore

********************* Main specification without city laws ***********************
* where PTDH has been adopted in cities / counties, there may be spillover effects. This robustness check drops observations from these cities to only consider treated states

cd "$project_data"
use data_for_regressions.dta, clear // reset data

drop if nyc == 1 | cleveland == 1 | county == 34017 // drop NYC, Cleveland, and Jersey City

preserve
* no occupation fixed effects
stackedev ln_hourwage2 female_post, ///
    cohort(gvar) ///
    time(mdate) ///
    never_treat(never_treated) ///
    unit_fe(county) ///
    clust_unit(statefip) ///
    covariates(educ_years exp exp2 married childunder5 i.race_cat) ///
	other_fe(female_county_fe female_time_fe county_time_fe)

cd "$project_tables"

outreg2 using mainregression5.tex, ///
    drop(educ_years exp exp2 married childunder5 i.race_cat) ///
    replace bdec(3) sdec(4)
	
restore

preserve
* occupation fixed effects
stackedev ln_hourwage2 female_post, ///
    cohort(gvar) ///
    time(mdate) ///
    never_treat(never_treated) ///
    unit_fe(county) ///
    clust_unit(statefip) ///
    covariates(educ_years exp exp2 married childunder5 i.race_cat) ///
	other_fe(occ_group female_county_fe female_time_fe county_time_fe)

outreg2 using mainregression5.tex, ///
    drop(educ_years exp exp2 married childunder5 i.race_cat) ///
    append bdec(3) sdec(4)

restore

********************* Spillover Effects with CSAs ***********************
cd "$project_data"
use data_for_regressions.dta, clear // reset data

/* Based on US Census Bureau CSAs to identify Metfips that are grouped into the same CSA
https://www2.census.gov/geo/maps/metroarea/us_wall/Jul2023/CSA_WallMap_Jul2023.pdf

Washington DC Metro Area
--------------------------
47900 - Washington-Arlington-Alexandria, DC-VA-MD-WV
12580 - Baltimore-Columbia-Towson, MD
25180 - Hagerstown-Martinsburg, MD-WV
49020 - Winchester, VA-WV 
15680, 30500 - California-Lexington Park, MD
16540 - Chambersburg-Waynesboro, PA

NYC Metro Area
---------------------------
35620 - New York-Newark-Jersey City, NY-NJ-PA 
14860 - Bridgeport-Stamford-Norwalk, CT
39100, 28880 - Poughkeepsie-Newburgh-Middletown, NY
45940 - Trenton-Princeton, NJ 
28740 - Kingston, NY 

Portland Metro Area
---------------------------
38900 - Portland-Vancouver-Hillsboro, OR-WA
41420 - Salem, OR
31020 - Longview, WA

Twin Cities Metro Area
---------------------------
33460 - Minneapolis-St Paul-Bloomington, MN-WI
41060 - St. Cloud, MN

Chicago Metro Area
---------------------------
16980 - Chicago-Naperville-Elgin, IL-IN-WI
28100 - Kankakee-Bradley, IL
33140 - Michigan City-La Porte, IN
28450 - Kenosha, Wi

Boston Metro Area
---------------------------
14460 - Boston-Cambridge-Newton, MA-NH
39300 - Providence-Warwick, RI-MA
49340 - Worcester, MA-CT
31700 - Manchester-Nashua, NH
12700 - Barnstable, MA

Philadelphia/Reading/Camden Metro Area - NOT INCLUDED
---------------------------
37980 - Philadelphia-Camden-Wilmington, PA-NJ-DE
39740 - Reading, PA
12100 - Atlantic City-Hammonton, NJ
20100 - Dover, DE
47220 - Vineland-Bridgeton, NJ

Spokane Metro Area
---------------------------
44060 - Spokane-Spokane Valley, WA
17660 - Coeur d'Alene, ID

Duluth - Grand Rapids Metro Area
---------------------------
20260 - Duluth, MN-WI

La Crosse Metro Area
---------------------------
29100 - La Crosse, WI-MN

St. Louis Metro Area
---------------------------
41180 - St. Louis, MO-IL

Davenport Metro Area
---------------------------
19340 - Davenport-Moline-Rock Island, IA-IL
*/

* Adjust to be only metropolitan areas that cross state borders between treated and untreated
drop if metfips == 99998 // drop unidentified metro areas 
local metro_codes 47900 12580 25180 49020 15680 30500 16540 35620 14860 39100 28880 45940 28740 38900 41420 31020 33460 41060 16980 28100 33140 28450 14460 39300 49340 31700 12700 44060 17660 20260 29100 41180 19340

gen keep_metro = 0

foreach x of local metro_codes {
    replace keep_metro = 1 if metfips == `x'
}

tab keep_metro

replace treated = 1 if keep_metro == 1
drop keep_metro

* recode gvar and never_treated
* Washington DC
replace effective_m = ym(2024, 6) if metfips == 47900 | metfips == 12580 | metfips == 25180 | metfips == 49020| metfips == 15680| metfips == 30500 | metfips == 16540

* NYC
replace effective_m = ym(2023, 9) if metfips == 35620 | metfips == 14860 | metfips == 39100 | metfips == 28880 | metfips == 45940 | metfips == 28740 

* Portland
replace effective_m = ym(2023, 1) if metfips == 38900 | metfips == 41420 | metfips == 31020

* Twin Cities, Duluth, La Crosse
replace effective_m = ym(2025, 1) if metfips == 33460 | metfips == 41060 | metfips == 20260 | metfips == 29100

* Chicago / St. Louis / Davenport
replace effective_m = ym(2025, 1) if metfips == 16980 | metfips == 28100 | metfips == 33140 | metfips == 28450 | metfips == 41180 | metfips == 19340

* Boston
replace effective_m = ym(2025, 10) if metfips == 14460 | metfips == 39300 | metfips == 49340 | metfips == 31700 | metfips == 12700

* Spokane
replace effective_m = ym(2023, 1) if metfips == 44060 | metfips == 17660

* replace treatment variables
drop gvar gvar_raw never_treated post female_post

bysort statefip county: egen gvar_raw = min(effective_m) if treated == 1 // generate group variable
	replace gvar_raw = 0 if gvar_raw == . // never treated variables = 0
	bysort statefip county: egen gvar = max(gvar_raw) // ensure same for each county
	
gen never_treated = (gvar == 0) // gen never treated indicator

gen post = diff >= 0
replace post = 0 if treated==0
gen female_post = female * post // variable identify interaction

preserve
* no occupation fixed effects
stackedev ln_hourwage2 female_post, ///
    cohort(gvar) ///
    time(mdate) ///
    never_treat(never_treated) ///
    unit_fe(county) ///
    clust_unit(statefip) ///
    covariates(educ_years exp exp2 married childunder5 i.race_cat) ///
	other_fe(female_county_fe female_time_fe county_time_fe)

cd "$project_tables"

outreg2 using mainregression6.tex, ///
    drop(educ_years exp exp2 married childunder5 i.race_cat) ///
    replace bdec(3) sdec(4)

restore

preserve
* occupation fixed effects
stackedev ln_hourwage2 female_post, ///
    cohort(gvar) ///
    time(mdate) ///
    never_treat(never_treated) ///
    unit_fe(county) ///
    clust_unit(statefip) ///
    covariates(educ_years exp exp2 married childunder5 i.race_cat) ///
	other_fe(occ_group female_county_fe female_time_fe county_time_fe)

cd "$project_tables"

outreg2 using mainregression6.tex, ///
    drop(educ_years exp exp2 married childunder5 i.race_cat) ///
    append bdec(3) sdec(4)
restore

******************CS DID for County Level Panel******************************************************
cd "$project_data"
use data_for_regressions.dta, clear // reset data

drop gvar

drop if county == 0 // remove observations where county is masked
*replace county = 10000 if treated == 0 // make control group into one county

gen qdate      = qofd(dofm(mdate))         // calendar quarter for each obs
gen effective_q = qofd(dofm(effective_m))  // quarter of law effective date
format qdate %tq
format effective_q %tq

* create panel data of jurisdictions and average log wages
egen geo_unit = group(statefip county)
bysort geo_unit: egen gvar = min(effective_q) if treated == 1
replace gvar = 0 if missing(gvar)

collapse (mean) ln_hourwage2 educ_years exp exp2 married childunder5 race_1 race_2 race_3 race_4 race_5 ///
         (count) obs_count = ln_hourwage2, ///
         by(qdate geo_unit gvar statefip female) // one row for male wages and one row for female wages

bys geo_unit qdate: egen ln_female = mean(cond(female==1, ln_hourwage2, .))
bys geo_unit qdate: egen ln_male   = mean(cond(female==0, ln_hourwage2, .))

bys geo_unit qdate: keep if _n == 1 // * keep one observation per jurisdction

* Construct wage gap
gen ln_wage_gap = ln_male - ln_female

drop if missing(ln_wage_gap)

* Construct weights
bys geo_unit qdate: egen w_f = total(cond(female==1, obs_count, 0))
bys geo_unit qdate: egen w_m = total(cond(female==0, obs_count, 0))
gen w = w_f + w_m

********* Regression *************
csdid ln_wage_gap [iw=w], ///
    ivar(geo_unit) ///
    time(qdate) ///
    gvar(gvar) ///
    method(dripw) ///
	covariates(ln_hourwage2 educ_years exp exp2 married childunder5 race_2 race_3 race_4 race_5) ///
    vce(cluster statefip)

* store results
estat simple
estimates store gap_model

* pretrend test
estat pretrend
local p_gap = r(pchi2)

********* Event Study *************
estat event, window(-6 12)

csdid_plot, ///
    title("PTDH Effect on Gender Wage Gap") ///
    xtitle("Quarters Relative to Treatment") ///
    ytitle("Log(Male Wage / Female Wage)") ///
    xline(0, lpattern(dash)) ///
    xlabel(-6(2)12) ///
    xscale(range(-7 13))

cd "$project_graphs"
graph export "csdid_gender_wage_gap.png", replace

cd "$project_tables"

esttab gap_model using "gender_wage_gap.tex", replace ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    title("CS-DiD: Gender Wage Gap Effect") ///
    addnotes("Outcome: ln(male wage) - ln(female wage)", ///
             "Pretrend p-value: `p_gap'") booktabs nonum label

display "--------------------------------------"
display "CS-DiD GENDER WAGE GAP COMPLETE"
display "Pretrend p-value: `p_gap'"
display "--------------------------------------"

*-----------------------------------------------------------------------------------------------*
*************************************************************************************************
**************************** SECTION 7: HETEROGENEITY ANALYSIS **********************************
*************************************************************************************************
cd "$project_data"
use data_for_regressions.dta, clear // reset data

gen female_management = female * d13_occ1 * post
gen female_professional = female * d13_occ2 * post
gen female_education = female * d13_occ3 * post
gen female_arts = female * d13_occ4 * post
gen female_healthcare = female * d13_occ5 * post
gen female_protect = female * d13_occ6 * post
gen female_hospitality = female * d13_occ7 * post
gen female_sales = female * d13_occ8 * post
gen female_admin = female * d13_occ9 * post
gen female_farming = female * d13_occ10 * post
gen female_manufacturing = female * d13_occ11 * post
gen female_transport = female * d13_occ12 * post

gen post_management = d13_occ1 * post
gen post_professional =  d13_occ2 * post
gen post_education = d13_occ3 * post
gen post_arts = d13_occ4 * post
gen post_healthcare = d13_occ5 * post
gen post_protect = d13_occ6 * post
gen post_hospitality =  d13_occ7 * post
gen post_sales = d13_occ8 * post
gen post_admin = d13_occ9 * post
gen post_farming = d13_occ10 * post
gen post_manufacturing =  d13_occ11 * post
gen post_transport = d13_occ12 * post

local female_occs female_professional female_education female_arts female_healthcare female_protect ///
	female_hospitality female_sales female_admin female_farming female_manufacturing female_transport
	
local post_occs post_professional post_education post_arts post_healthcare post_protect post_hospitality post_sales ///
	post_admin post_farming post_manufacturing post_transport

preserve
stackedev ln_hourwage2 female_post `female_occs', ///
    cohort(gvar) ///
    time(mdate) ///
    never_treat(never_treated) ///
    unit_fe(county) ///
    clust_unit(county) ///
    covariates(educ_years exp exp2 married childunder5 i.race_cat `post_occs') ///
	other_fe(female_county_fe female_time_fe county_time_fe occ_group)

cd "$project_tables"

outreg2 using heterogeneityregression.tex, ///
    drop(educ_years exp exp2 married childunder5 i.race_cat `post_occs') ///
    replace bdec(3) sdec(4)
restore
	
************** Appendix Regression for Male vs Female Wages ********************************	
cd "$project_data"
use data_for_regressions.dta, clear // reset data

preserve
* No occupation fixed effects
stackedev ln_hourwage2 post female_post, ///
    cohort(gvar) ///
    time(mdate) ///
    never_treat(never_treated) ///
    unit_fe(county) ///
    clust_unit(statefip) ///
    covariates(female educ_years exp exp2 married childunder5 i.race_cat)

cd "$project_tables"

outreg2 using appendixreg.tex, ///
    drop(educ_years exp exp2 married childunder5 i.race_cat) ///
    replace bdec(3) sdec(4)
restore
	
	
preserve
* occupation fixed effects
stackedev ln_hourwage2 post female_post, ///
    cohort(gvar) ///
    time(mdate) ///
    never_treat(never_treated) ///
    unit_fe(county) ///
    clust_unit(statefip) ///
    covariates(female educ_years exp exp2 married childunder5 i.race_cat) ///
	other_fe(occ_group)

cd "$project_tables"

outreg2 using appendixreg.tex, ///
    drop(educ_years exp exp2 married childunder5 i.race_cat) ///
    append bdec(3) sdec(4)
restore
	
	
	
	
	
	
	
	
	
	
	
	
	
	

