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
	
	if  "${USER_OS}"=="AW_WINDOWS" {
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
	global FIRMlistebalance ebitda_at RnDExp AdExp SGA CapEx ChangeSale Leverage Cash Intangibles PPE size
	global FIRMlistlagannual LAG_ebitda_at_1 LAG_RnDExp_1 LAG_AdExp_1 LAG_SGA_1 LAG_CapEx_1 LAG_ChangeSale_1 LAG_Leverage_1 LAG_Cash_1 LAG_Intangibles_1 LAG_PPE_1 LAG_size_1
	global FIRMlistnoebitda RnDExp3 AdExp3 SGA3 CapEx3 ChangeSale3 Leverage3 Cash3 i.MNE3 i.NOL3 Intangibles3 PPE3 size3
	global FIRMlistnosize ebitda_at3 RnDExp3 AdExp3 SGA3 CapEx3 ChangeSale3 Leverage3 Cash3 i.MNE3 i.NOL3 Intangibles3 PPE3 
	global FIRMlistchange ChangeSale3 ChangeNOL3 ChangePIFO3 ChangeEBITDA3 ChangeLeverage3 ChangeSize3 ChangeIntangibles3
	global PARTNERlistBEA i.PARTSAMEAUDITOR i.PARTSAMEBEAREGION 
	global PARTNERlist i.PARTSAMEAUDITOR c.PROXIMITY
	global NETWORKlist i.purpose_* 
}

{	//Logfile for Tables as in Paper
	log using "${pathOUTPUT}\03_ONLINE_SUPPLEMENT\LOGFILE_`time_string'_FULL_ANALYSES.smcl", replace nomsg

	{	//Table 2 
	{	//Table 2 Panel A Descriptive Analysis
		ttest CASH_ETR3 =  LAG_PRE_CASH_ETR3_1 if hightolow == 1
		return list 
		local obs1 = `r(N_1)'
		local mean1 = (-1*`r(mu_2)')+`r(mu_1)'
		local sd1 = (`r(N_1)'^(1/2))*`r(se)'
		display `obs1'
		display `mean1'
		display `sd1'
		ttest CASH_ETR3 =  LAG_PRE_CASH_ETR3_1 if hightolow == 0
		return list 
		local obs2 = `r(N_1)'
		local mean2 = (-1*`r(mu_2)')+`r(mu_1)'
		local sd2 = (`r(N_1)'^(1/2))*`r(se)'
		display `obs2'
		display `mean2'
		display `sd2'
		ttesti `obs1' `mean1' `sd1' `obs2' `mean2' `sd2'
		}
		
	{	//Table 2 Panel B 
		ranksum DELTA_CASH_ETR3, by(hightolow) porder
		median DELTA_CASH_ETR3, by(hightolow)
		qreg DELTA_CASH_ETR3 i.hightolow
	}
	
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
			*Unbalanced Sample, Exlcudes Overlapping Events, full set of controls & FE
			reghdfe CASH_ETR1 i.TREATED##i.POST $FIRMlistannual, absorb(IND YEAR DIDYEAR) vce(cluster CUSIPNUM)
			
			*Table 3 Panel B Specification 2
			*Balanced Sample, ENTROPY WEIGHTS calculated in dofile "04_SDC_COMPUSTAT_PREPARE", Exlcudes Overlapping Events, full set of controls & FE
			reghdfe CASH_ETR1 i.TREATED_EBAL##i.POST $FIRMlistannual [pweight = _webal], absorb(IND YEAR DIDYEAR) vce(cluster CUSIPNUM)
						
		}
		
		{	//Table 3 Panel C Adjustment Speed
			forvalues q=1(1)5{
			reghdfe CASH_ETR1 TREATED_EBAL##POST $FIRMlistannual [pweight = _webal] if DIDYEAR <=`q', absorb(IND YEAR DIDYEAR) vce(cluster CUSIPNUM)
			}
		}
		}
		
	{	//Table 4 Additional Analyses: Effects on Reporting of Operations
		*Table 4 Specification 1
		reghdfe SENTIMENT  i.TREATED##i.POST $FIRMlistannual, absorb(IND YEAR DIDYEAR) vce(cluster CUSIPNUM)
		
		*Table 4 Specification 2
		reghdfe USE_OF_NEGATIVE_WORDS  i.TREATED##i.POST $FIRMlistannual , absorb(IND YEAR DIDYEAR) vce(cluster CUSIPNUM)
		
		*Table 4 Specification 3
		reghdfe USE_OF_TAXHAVEN  i.TREATED##i.POST $FIRMlistannual, absorb(IND YEAR DIDYEAR) vce(cluster CUSIPNUM)
		
		*Table 4 Specification 4
		reghdfe NUMBER_OF_TAXHAVENS i.TREATED##i.POST $FIRMlistannual, absorb(IND YEAR DIDYEAR) vce(cluster CUSIPNUM)
	}
	
	{	//Table 5 Additional Analyses: Partner Characteristics
		
		//Table 5 Panel A
		*PARTSAMEBEAREGION
		*Table 5 Panel A Specification 1
		reghdfe CASH_ETR3 i.hightolow##i.PARTSAMEBEAREGION $NETWORKlist $PARTNERlistBEA $FIRMlist, absorb(IND YEAR) vce(cluster CUSIPNUM)
		*Table 5 Panel A Specification 2
		reghdfe DELTA_CASH_ETR3 i.hightolow##i.PARTSAMEBEAREGION $NETWORKlist $PARTNERlistBEA $FIRMlist, absorb(IND YEAR) vce(cluster CUSIPNUM)
		
		//Table 5 Panel B
		*PARTSAMEIND
		*Table 5 Panel B Specification 1
		reghdfe CASH_ETR3 i.hightolow##i.PARTSAMEIND $NETWORKlist $PARTNERlistBEA $FIRMlist, absorb(YEAR) vce(cluster CUSIPNUM)
		*Table 5 Panel B Specification 2
		reghdfe DELTA_CASH_ETR3 i.hightolow##i.PARTSAMEIND $NETWORKlist $PARTNERlistBEA $FIRMlist, absorb(YEAR) vce(cluster CUSIPNUM)
		
		//Table 5 Panel C
		*PARTSAMEAUDITOR
		*Table 5 Panel C Specification 1
		reghdfe CASH_ETR3 i.hightolow##i.PARTSAMEAUDITOR $NETWORKlist $PARTNERlistBEA $FIRMlist, absorb(IND YEAR) vce(cluster CUSIPNUM)
		*Table 5 Panel C Specification 2
		reghdfe DELTA_CASH_ETR3 i.hightolow##i.PARTSAMEAUDITOR $NETWORKlist $PARTNERlistBEA $FIRMlist, absorb(IND YEAR) vce(cluster CUSIPNUM)
	}
	
	{	//Table 6 Robustness Checks: Alternative Explanations
	
		//Table 6 Panel A
		*Exclude Non-Survivors (network falls within last 3 years of firms in sample) (controls for substitution of cash ETR3 by cash ETR1 in firm-edge years)
		reghdfe DELTA_CASH_ETR3 i.hightolow $NETWORKlist $PARTNERlist $FIRMlist if LAST >= 2, absorb(IND YEAR) vce(cluster CUSIPNUM)
			
		//Table 6 Panel B
		reghdfe CASH_ETR3 i.lowtohigh $NETWORKlist $PARTNERlistBEA $FIRMlist, absorb(IND YEAR) vce(cluster CUSIPNUM)
	}
	
	{	//Table 7 Robustness Checks: Alternative Identification Strategy
		reghdfe CASH_ETR3 i.HIGHTAXFIRM##c.PARTPRECETR3 $PARTNERlist $FIRMlist, absorb(IND IND_SA) vce(cluster CUSIPNUM)
	}
	
log close
translate "${pathOUTPUT}\03_ONLINE_SUPPLEMENT\LOGFILE_`time_string'_FULL_ANALYSES.smcl" "${pathOUTPUT}\03_ONLINE_SUPPLEMENT\LOGFILE_`time_string'_FULL_ANALYSES.pdf", fontsize(6)

}

clear
exit
