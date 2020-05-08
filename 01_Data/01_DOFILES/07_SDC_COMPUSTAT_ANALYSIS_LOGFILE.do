clear
set more off 


****************************************************
*******      COMPUSTAT SDC ANALYSIS        *********
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

use "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT.dta", clear 

{	//Lists of variables 
	global FIRMlist ebitda_at3 RnDExp3 AdExp3 SGA3 CapEx3 ChangeSale3 Leverage3 Cash3 i.MNE3 i.NOL3 Intangibles3 PPE3 size3
	global FIRMlistannual ebitda_at RnDExp AdExp SGA CapEx ChangeSale Leverage Cash i.MNE i.NOL Intangibles PPE size
	global FIRMlistnoebitda RnDExp3 AdExp3 SGA3 CapEx3 ChangeSale3 Leverage3 Cash3 i.MNE3 i.NOL3 Intangibles3 PPE3 size3
	global FIRMlistnosize ebitda_at3 RnDExp3 AdExp3 SGA3 CapEx3 ChangeSale3 Leverage3 Cash3 i.MNE3 i.NOL3 Intangibles3 PPE3 
	global FIRMlistchange ChangeSale3 ChangeNOL3 ChangePIFO3 ChangeEBITDA3 ChangeLeverage3 ChangeSize3 ChangeIntangibles3
	global PARTNERlistBEA i.PARTSAMEAUDITOR i.PARTSAMEBEAREGION 
	global PARTNERlist i.PARTSAMEAUDITOR c.PROXIMITY
	global NETWORKlist i.purpose_*
	*tbd 
}

{	//Logfile for Tables as in Paper
	log using "${pathOUTPUT}\02_TAB\02_`time_string'_FULL_TABLES_AS_IN_PAPER.smcl", replace nomsg

	{	//Table 2 Descriptive Analysis
		gen vhelp = LAG_PRE_CASH_ETR3_1
		replace vhelp = LAG_PRE_CASH_ETR3_2 if !missing(hightolow) & missing(vhelp)
		ttest CASH_ETR3 =  vhelp if hightolow == 1
		return list 
		local obs1 = `r(N_1)'
		local mean1 = (-1*`r(mu_2)')+`r(mu_1)'
		local sd1 = (`r(N_1)'^(1/2))*`r(se)'
		display `obs1'
		display `mean1'
		display `sd1'
		ttest CASH_ETR3 =  vhelp if hightolow == 0
		return list 
		local obs2 = `r(N_1)'
		local mean2 = (-1*`r(mu_2)')+`r(mu_1)'
		local sd2 = (`r(N_1)'^(1/2))*`r(se)'
		display `obs2'
		display `mean2'
		display `sd2'
		ttesti `obs1' `mean1' `sd1' `obs2' `mean2' `sd2'
		drop vhelp*
		}

	{	//Table 3 Regression Analyses 
		{	//Table 3 Panel A
		*Table 3 Panel A Specification 1
		*Table 3 Panel A Specification 2
		foreach var of varlist CASH_ETR3 DELTA_CASH_ETR3{
		reghdfe `var' i.hightolow $NETWORKlist $PARTNERlist $FIRMlist, absorb(IND YEAR) vce(cluster CUSIPNUM)
		}
		}

		{	//Table 3 Panel B Difference in Differences
		*Table 3 Panel B Specification 1
		*SE robust
		reghdfe CASH_ETR1 TREATED##POST, noabsorb vce(robust)
		margins TREATED#POST, post
		test _b[1.TREATED#1.POST] = _b[0.TREATED#1.POST]
		*Table 3 Panel B Specification 2
		*Cluster VCE
		reghdfe CASH_ETR1 TREATED##POST $FIRMlistannual, absorb(IND DIDYEAR) vce(cluster CUSIPNUM)
		qui reghdfe CASH_ETR1 TREATED##POST $FIRMlistannual, absorb(IND) vce(cluster CUSIPNUM)
		margins TREATED#POST, post
		test _b[1.TREATED#1.POST] = _b[0.TREATED#1.POST]
		*Table 3 Panel B Specification 3
		*Add YEAR-FE
		reghdfe CASH_ETR1 TREATED##POST $FIRMlistannual, absorb(IND YEAR DIDYEAR) vce(cluster CUSIPNUM)
		qui reghdfe CASH_ETR1 TREATED##POST $FIRMlistannual, absorb(IND YEAR) vce(cluster CUSIPNUM)
		margins TREATED#POST, post
		test _b[1.TREATED#1.POST] = _b[0.TREATED#1.POST]
		}
		
		{	//Table 3 Panel C Adjustment Speed
		forvalues q=1(1)5{
		reghdfe CASH_ETR1 TREATED##POST $FIRMlistannual if DIDYEAR <=`q', absorb(IND YEAR DIDYEAR) vce(cluster CUSIPNUM)
		}
		
		}
		
		}
			
	{	//Table 4 Additional Analyses 
		
		//Table 4 Panel A
		*PARTSAMEBEAREGION
		*Table 4 Panel A Specification 1
		reghdfe CASH_ETR3 i.hightolow##i.PARTSAMEBEAREGION $NETWORKlist $PARTNERlistBEA $FIRMlist, absorb(IND YEAR) vce(cluster CUSIPNUM)
		*Table 4 Panel A Specification 2
		reghdfe DELTA_CASH_ETR3 i.hightolow##i.PARTSAMEBEAREGION $NETWORKlist $PARTNERlistBEA $FIRMlist, absorb(IND YEAR) vce(cluster CUSIPNUM)
		
		//Table 4 Panel B
		*PARTSAMEIND
		*Table 4 Panel B Specification 1
		reghdfe CASH_ETR3 i.hightolow##i.PARTSAMEIND $NETWORKlist $PARTNERlistBEA $FIRMlist, absorb(YEAR) vce(cluster CUSIPNUM)
		*Table 4 Panel B Specification 2
		reghdfe DELTA_CASH_ETR3 i.hightolow##i.PARTSAMEIND $NETWORKlist $PARTNERlistBEA $FIRMlist, absorb(YEAR) vce(cluster CUSIPNUM)
		
		//Table 4 Panel C
		*PARTSAMEAUDITOR
		*Table 4 Panel C Specification 1
		reghdfe CASH_ETR3 i.hightolow##i.PARTSAMEAUDITOR $NETWORKlist $PARTNERlistBEA $FIRMlist, absorb(IND YEAR) vce(cluster CUSIPNUM)
		*Table 4 Panel C Specification 2
		reghdfe DELTA_CASH_ETR3 i.hightolow##i.PARTSAMEAUDITOR $NETWORKlist $PARTNERlistBEA $FIRMlist, absorb(IND YEAR) vce(cluster CUSIPNUM)
	}
	
	{	//Table 5 Robustness Checks: Alternative Explanations
	
		//Table 5 Panel A
		*Exclude Non-Survivors (network falls within last 2 years of firms in sample)
		gen vhelp = LAST 															// LAST = MAX(FYEAR) - CURRENT(FYEAR)
		replace vhelp = . if missing(COOPFIRMYEAR)
		replace vhelp =  . if YEAR == 2014 | YEAR == 2015 | YEAR == 2016			//Non-Survivors are not determined by end of panel 
		reghdfe DELTA_CASH_ETR3 i.hightolow $NETWORKlist $PARTNERlist $FIRMlist if vhelp > 2, absorb(IND YEAR) vce(cluster CUSIPNUM)
		drop vhelp
		
		//Table 5 Panel B
		reghdfe DELTA_CASH_ETR3 i.hightolow $NETWORKlist $PARTNERlist $FIRMlist if DELTA_CASH_ETR3 < 1, absorb(IND YEAR) vce(cluster CUSIPNUM)
		
		//Table 5 Panel C
		reghdfe CASH_ETR3 i.lowtohigh $NETWORKlist $PARTNERlistBEA $FIRMlist, absorb(IND YEAR) vce(cluster CUSIPNUM)
		
		//Table 5 Panel D
		reghdfe PROFITABILITY3 i.hightolow $NETWORKlist $PARTNERlist $FIRMlistnoebitda, absorb(IND YEAR) vce(cluster CUSIPNUM) 
	
	}
	
	{	//Table 6 Robustness Checks: Alternative Tax Knowledge Measrues 
	
		//Table 6 Specification 1 (CTD)
		reghdfe CTD1 TREATED##POST $FIRMlistannual if !missing(CASH_ETR1), absorb(IND) vce(cluster CUSIPNUM)
	
		//Table 6 Specification 1 (GAAP ETR)
		reghdfe GAAP_ETR1 TREATED##POST $FIRMlistannual if !missing(CASH_ETR1), absorb(IND) vce(cluster CUSIPNUM)
		
	}
	
	{	//Table 7 Robustness Checks: Alternative Identification Strategy
		reg CASH_ETR3 i.HIGHTAXFIRM##c.PARTPRECETR3 $PARTNERlistBEA $NETWORKlist $FIRMlist i.IND, vce(robust)
		vif 				//makes hightolow indication trustworthy since it produces lower VIFs
	}
	
log close
translate "${pathOUTPUT}\02_TAB\02_`time_string'_FULL_TABLES_AS_IN_PAPER.smcl" "${pathOUTPUT}\02_TAB\02_`time_string'_FULL_TABLES_AS_IN_PAPER.pdf", fontsize(6)

}

clear
