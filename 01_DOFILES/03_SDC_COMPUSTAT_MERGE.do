clear
set more off 


****************************************************
*******       COMPUSTAT SDC MERGE          *********
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

{	//Match (command "merge"); style m:1
	use "${pathSDC}\SDC_SA_FIRMLEVEL.dta", clear 
	sort YEAR CUSIP6
	merge m:1 YEAR CUSIP6 using "${pathCOMPUSTAT}\COMPUSTAT.dta"
	
}

{	//"fyr" before "DATEEFFECTIVE": Network belongs to next fiscal year
	gen MONTH = month(DATEEFFECTIVE)
	gen vhelp = 0
	replace vhelp = 1 if fyr < MONTH & _merge == 3
	replace YEAR = YEAR + vhelp
	drop gvkey - vhelp 
	drop if missing(DATEEFFECTIVE) 
	gen CALENDERYEAR = year(DATEEFFECTIVE)
	sort DEALNUMBER YEAR
	by DEALNUMBER: egen vhelp2 = max(YEAR)
	drop if vhelp2 == 2017
	drop vhelp*
	sort CUSIP6 YEAR
	
}

{	//2nd Match
	sort YEAR CUSIP6
	merge m:1 YEAR CUSIP6 using "${pathCOMPUSTAT}\COMPUSTAT.dta"
	sort CUSIP6 YEAR
	drop if _merge == 1
}

*compress _all
save "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT_MERGED.dta", replace 
clear
