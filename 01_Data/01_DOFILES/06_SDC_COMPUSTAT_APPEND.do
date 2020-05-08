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
	
	if  "${USER_OS}"=="" {
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
	*isid NAME_NETWORK CUSIP6 
	keep NAME_NETWORK CUSIP6 DEALNUMBER purpose_* 
	save "${pathOTHER}\INTERMEDIATE.dta", replace
	
	//Merge
	clear 
	use "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT_TOAPPEND.dta", clear 
	merge m:1 NAME_NETWORK CUSIP6 DEALNUMBER using "${pathOTHER}\INTERMEDIATE.dta"
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
	isid NAME_NETWORK CUSIP6 DEALNUMBER
	keep NAME_NETWORK CUSIP6 DEALNUMBER ZIP_USA Distance
	save "${pathOTHER}\INTERMEDIATE.dta", replace 
	clear
	
	//Merge
	use "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT_INTERMEDIATE.dta", clear 
	merge m:1 NAME_NETWORK CUSIP6 DEALNUMBER using "${pathOTHER}\INTERMEDIATE.dta"
	*Distance = distance in miles as the crow flies from freemaptools.com
	gen vhelp = 1/Distance 
	egen vhelpmin = min(vhelp)
	egen vhelpmax = max(vhelp)
	gen vhelp2 = (vhelp-vhelpmin)/(vhelpmax-vhelpmin)
	rename Distance DISTANCE
	rename vhelp2 PROXIMITY 
	drop vhelp*
	
	//Save 
	save "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT.dta", replace 
	
	//Erase
	erase "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT_MERGED.dta"
	erase "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT_TOAPPEND.dta"
	erase "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT_INTERMEDIATE.dta"
	erase "${pathOTHER}\SDC_COMPUSTAT_DEALTEXT_PROCESSED.dta"
	erase "${pathOTHER}\SDC_COMPUSTAT_DEALTEXT_RAW.dta"
	erase "${pathOTHER}\SDC_COMPUSTAT_NETWORK_RAW1.dta"
	erase "${pathOTHER}\SDC_COMPUSTAT_NETWORK_RAW2.dta"
	erase "${pathOTHER}\INTERMEDIATE.dta"
	clear
}


