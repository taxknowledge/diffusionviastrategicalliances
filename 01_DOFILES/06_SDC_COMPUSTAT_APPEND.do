clear
set more off 


****************************************************
*******      COMPUSTAT SDC APPEND         *********
****************************************************

{ 	//Packages
*Graphs
graph set window fontface "Times New Roman"
*graph set window fontface default
*Install packages
/*
ssc install corsp
ssc install estout
ssc install reghdfe
reghdfe, compile
ssc install ftools
ftools, compile
ssc install moremata
ssc install cem
ssc install rangejoin
ssc istall rangestat
ssc install coefplot
*/
*Update packages
adoupdate corsp estout reghdfe ftools moremata cem rangejoin rangestat coefplot, update
}

{	//Set user & working directory
global USER_OS = "" // "User Inititials _ Operating System"

{	//WD & paths
		if  missing("${USER_OS}"){
		display "**** PLEASE SET USER INITIALS, OPERARTING SYSTEM, AND FILE PATH****"
		exit
		}
	
	if  !missing("${USER_OS}") {
		global path ""	//enter your file path here (Mac: adjust \ to / below!)
		global pathSDC "${path}\02_SDC"
		global pathCOMPUSTAT "${path}\03_COMPUSTAT"
		global pathSDCCOMPUSTAT "${path}\04_SDC_COMPUSTAT"
		global pathOTHER "${path}\05_OTHER"
		global pathOUTPUT "${path}\06_OUTPUT"
		cd "${path}" 
		}
	
}

{	//Time & date
	local c_date = c(current_date)
	local c_time = c(current_time)
	local c_time_date = "`c_date'"+"_" +"`c_time'"
	display "`c_time_date'"
	local time_string = subinstr("`c_time_date'", ":", "_", .)
	local time_string = subinstr("`time_string'", " ", "_", .)
	display "`time_string'"
}

}

{	//Business purpose of network 
	use "${pathOTHER}\SDC_COMPUSTAT_DEALTEXT_PROCESSED.dta", clear 
	*isid ALLIANCEDEALNAME CUSIP6 DEALNUMBER
	keep ALLIANCEDEALNAME CUSIP6 DEALNUMBER purpose_* 
	save "${pathOTHER}\INTERMEDIATE.dta", replace
	//Merge
	clear 
	use "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT_TOAPPEND.dta", clear 
	merge m:1 ALLIANCEDEALNAME CUSIP6 DEALNUMBER using "${pathOTHER}\INTERMEDIATE.dta"
	//check: _merge2 has 0 observations
	drop _merge*
	sort CUSIP6 YEAR 
	//Save
	save "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT_INTERMEDIATE.dta", replace
	erase "${pathOTHER}\INTERMEDIATE.dta"
	clear 

}

{	//Distance
	import excel using "${pathOTHER}\SDC_COMPUSTAT_DISTANCE_COMPLETED.xlsx", firstrow
	drop if missing(DEALNUMBER)
	isid ALLIANCEDEALNAME CUSIP6 DEALNUMBER
	keep ALLIANCEDEALNAME CUSIP6 DEALNUMBER ZIP_USA DISTANCE
	save "${pathOTHER}\INTERMEDIATE.dta", replace 
	clear
	//Merge
	use "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT_INTERMEDIATE.dta", clear 
	merge m:1 ALLIANCEDEALNAME CUSIP6 DEALNUMBER using "${pathOTHER}\INTERMEDIATE.dta"
	*Distance = distance in miles as the crow flies from freemaptools.com
	gen vhelp = 1/DISTANCE 
	egen vhelpmin = min(vhelp)
	egen vhelpmax = max(vhelp)
	gen vhelp2 = (vhelp-vhelpmin)/(vhelpmax-vhelpmin)
	rename vhelp2 PROXIMITY 
	drop vhelp*
	drop  _merge
	//Save 
	save "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT_INTERMEDIATE2.dta", replace 
	erase "${pathOTHER}\INTERMEDIATE.dta"
	clear
}

{	//10K Sentiment 
	import delimited "${pathOTHER}\LM_10X_Summaries_2018.csv", varnames(1) 
	sort cik filing_date
	keep if form_type == "10-K"
	*FISCAL YEAR END DATE:
	gen vhelp = fye
	tostring vhelp, replace
	gen vhelp2 = substr(vhelp, 1, 4)
	drop if vhelp2 < "1994"
	drop if vhelp2 > "2016"
	destring vhelp2, replace
	gen vhelp3 = substr(vhelp, 5, 2)
	destring vhelp3, replace
	duplicates tag cik vhelp2 vhelp3, gen(vhelp4)
	drop if vhelp4 != 0	//297 of 170K obs 
	rename vhelp2 FYE_YEAR
	rename vhelp3 FYE_MONTH
	*isid cik FYE_YEAR FYE_MONTH
	drop file_name sic ffind vhelp*
	gen SENTIMENT = ((n_positive-n_negation)-n_negative)/n_words								//https://sraf.nd.edu/textual-analysis/resources/ --> Positive words need to be adjusted for negations
	gen POLARITY = ((n_positive-n_negation)-n_negative)/((n_positive-n_negation)+n_negative)
	gen SUBJECTIVITY = ((n_positive-n_negation)+n_negative)/n_words
	gen USE_OF_NEGATIVE_WORDS = n_negative/n_words	// Law/Mills 2015 JAR
	*LEAD&LAGS
	sort cik FYE_YEAR
	foreach var of varlist SENTIMENT USE_OF_NEGATIVE_WORDS {
	forvalues q = 1(1)5{
		by cik: gen LEAD_`var'_`q' = `var'[_n+`q']
		}
		}
	gsort cik -FYE_YEAR
	foreach var of varlist SENTIMENT USE_OF_NEGATIVE_WORDS {
	forvalues q = 1(1)5{
		by cik: gen LAG_`var'_`q' = `var'[_n+`q']
		}
		}
	save "${pathOTHER}\LM_SENTIMENT.dta", replace 
	clear 
	use "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT_INTERMEDIATE2.dta", clear
	gen FYE_YEAR = fyear
	gen FYE_MONTH = fyr
	destring cik, replace
	sort cik FYE_YEAR FYE_MONTH
	*Merge
	merge m:1 cik FYE_YEAR FYE_MONTH using "${pathOTHER}\LM_SENTIMENT.dta"
	drop if _merge == 2
	drop _merge
	//Save
	save "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT_INTERMEDIATE3.dta", replace 
	 
	
	
	}
	
{	//Exhibit 21 data from 10-K
	use "${pathOTHER}\EXHIBIT21_COUNTRY.dta"
	keep CIK DATADATE ISO3 COUNTRY TAXHAVEN
	sort CIK DATADATE
	gen FYE_YEAR = year(DATADATE)
	drop if FYE_YEAR < 1994
	gen FYE_MONTH = month(DATADATE)
	*Tax Haven Activity
	*Totals
	gen vhelp  =1 
	by CIK DATADATE: egen vhelp2 = sum(vhelp)
	rename vhelp2 TOTAL_SUBS_YEAR 
	drop vhelp
	by CIK DATADATE: egen vhelp3 = sum(TAXHAVEN)
	rename vhelp3 TAXHAVEN_SUBS_YEAR
	gen NUMBER_OF_TAXHAVENS = ln(1+TAXHAVEN_SUBS_YEAR)
	*Law/Mills 2019 --> Use of Tax Havens as Indicator
	gen vhelp = .
	replace vhelp = 0 if TAXHAVEN_SUBS_YEAR == 0
	replace vhelp = 1 if TAXHAVEN_SUBS_YEAR > 0 & !missing(TAXHAVEN_SUBS_YEAR)
	rename vhelp USE_OF_TAXHAVEN
	*Ratio
	gen SHARE_TAXHAVEN_SUBS_YEAR = TAXHAVEN_SUBS_YEAR/TOTAL_SUBS_YEAR
	*reshape, so that m:1 merge (m = SDC_Compustat) (1 = EX21) is possible
	sort CIK DATADATE
	by CIK DATADATE: gen vhelp = _n
	reshape wide ISO3 COUNTRY TAXHAVEN, i(CIKNUMBER DATADATE FYE_YEAR FYE_MONTH TOTAL_SUBS_YEAR TAXHAVEN_SUBS_YEAR) j(vhelp)
	*LEAD&LAGS
	sort CIK FYE_YEAR
	foreach var of varlist TOTAL_SUBS_YEAR TAXHAVEN_SUBS_YEAR USE_OF_TAXHAVEN SHARE_TAXHAVEN_SUBS_YEAR NUMBER_OF_TAXHAVENS {
	forvalues q = 1(1)5{
		by CIK: gen LEAD_`var'_`q' = `var'[_n+`q']
		}
		}
	gsort CIK -FYE_YEAR
	foreach var of varlist TOTAL_SUBS_YEAR TAXHAVEN_SUBS_YEAR USE_OF_TAXHAVEN SHARE_TAXHAVEN_SUBS_YEAR NUMBER_OF_TAXHAVENS {
	forvalues q = 1(1)5{
		by CIK: gen LAG_`var'_`q' = `var'[_n+`q']
		}
		}
	sort CIK FYE_YEAR
	rename CIKNUMBER cik
	duplicates tag cik FYE_YEAR FYE_MONTH, gen(vhelp)
	drop if vhelp != 0 // only 85 of 205K obs
	drop vhelp
	*isid cik FYE_YEAR FYE_MONTH
	save "${pathOTHER}\EXHIBIT21_COUNTRY_INTERMEDIATE.dta", replace 
	clear	
	*merge
		*use ${pathSDCCOMPUSTAT}\SDC_COMPUSTAT.dta, clear
		*save ${pathSDCCOMPUSTAT}\SDC_COMPUSTAT_INTERMEDIATE3.dta, replace
	use ${pathSDCCOMPUSTAT}\SDC_COMPUSTAT_INTERMEDIATE3.dta, clear
	merge m:1 cik FYE_YEAR FYE_MONTH using "${pathOTHER}\EXHIBIT21_COUNTRY_INTERMEDIATE.dta"
	drop if _merge == 2
	drop _merge
	//Save
	save "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT.dta", replace
	
	clear
	
	}
	
{	//Erase
	erase "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT_MERGED.dta"
	erase "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT_TOAPPEND.dta"
	erase "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT_INTERMEDIATE.dta"
	erase "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT_INTERMEDIATE2.dta"
	erase "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT_INTERMEDIATE3.dta"
	erase "${pathOTHER}\SDC_COMPUSTAT_DEALTEXT_PROCESSED.dta"
	erase "${pathOTHER}\SDC_COMPUSTAT_DEALTEXT_RAW.dta"
	erase "${pathOTHER}\SDC_COMPUSTAT_NETWORK_RAW1.dta"
	erase "${pathOTHER}\SDC_COMPUSTAT_NETWORK_RAW2.dta"
	}
	exit
	
