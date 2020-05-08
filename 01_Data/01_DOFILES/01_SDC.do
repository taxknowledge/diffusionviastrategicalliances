clear
set more off 


****************************************************
*******            SDC RAW DATA            *********
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

{	//Convert .xlsx to .dta
	qui forvalues q=1994(1)2016{
	import excel using "${pathSDC}\01_SDC_RAW\SDC_final_`q'.xlsx", cellrange(A2) firstrow clear
	save "${pathSDC}\SDC_final_`q'.dta", replace
	}
	
}

{	//Append data 
	use "${pathSDC}\SDC_final_1994.dta", clear 
	qui forvalues q=1995(1)2016{
	append using "${pathSDC}\SDC_final_`q'.dta", force 
	}
	save "${pathSDC}\SDC_1994_2016.dta", replace 
	forvalues q=1994(1)2016{
	erase "${pathSDC}\SDC_final_`q'.dta"
	}
	clear
}



****************************************************
*******            PREPARE DATA            *********
****************************************************

{	//Read data
use "${pathSDC}\SDC_1994_2016.dta", clear 
compress _all
describe
rename CU PartinJV_Alliance_
rename EX PartParentCUSIP_
rename FA PartCUSIP_
rename FI PartTicker_
rename FJ JVTickerSymbol_
rename FL PartUltParentPrimSIC_Desc_
rename FR PartPrimSIC_Desc_
}

{	//Indicator Variables
*Joint Venture Flag
codebook JointVentureFlag
drop if missing(JointVentureFlag)
codebook JointVentureFlag
generate JV = . 
replace JV = 0 if JointVentureFlag  == "N" 
replace JV = 0 if JointVentureFlag  == "No" 
replace JV = 1 if JointVentureFlag == "Yes" 
replace JV = . if missing(JointVentureFlag) 
label variable JV "JointVentureFlag 1=Yes 0=No/N"
tab JointVentureFlag JV

*Strategic Alliance Flag 
codebook StrategicAlliance  
generate SA = .
replace SA = 0 if StrategicAlliance  == "N" 
replace SA = 0 if StrategicAlliance  == "No" 
replace SA = 1 if StrategicAlliance  == "Y"

*SA & JV check 
drop if SA == JV 
}

{ 	//Identifier for matching

*Year
gen EFFECTIVEYEAR = year(DateEffective)
gen year_ = EFFECTIVEYEAR
codebook year_
drop if missing(year_) 
drop if year_ > 2016
drop if year_ < 1994

*Time between "Effective" and "Terminated" (exclude data flaws & short term alliances)
gen DATECLOSE = . 
replace DATECLOSE = DateAllianceTerminated if missing(DATECLOSE) & !missing(DateAllianceTerminated)
gen ENDYEAR = year(DATECLOSE)
gen ANNOUNCEDYEAR = year(AllianceDateAnnounced)
gen vhelp = 0
replace vhelp = 1 if ENDYEAR == ANNOUNCEDYEAR
drop if vhelp == 1
drop vhelp 
replace EFFECTIVEYEAR = ANNOUNCEDYEAR if !missing(ENDYEAR) 
drop if EFFECTIVEYEAR > 2016 


*Firm-year observation with cooperation 
gen COOPFIRMYEAR = 1 

*Firm-level identifyer 
{ //6-digit CUSIP number of ultimate parent of the cooperating firm
describe UltimateParentCUSIP // str146
gen str UltimateParentCUSIP_1 = substr(UltimateParentCUSIP, 1, 6)
label variable UltimateParentCUSIP_1 "UltimateParentCUSIP"
gen str UltimateParentCUSIP_2 = substr(UltimateParentCUSIP, 8, 6)
label variable UltimateParentCUSIP_2 "UltimateParentCUSIP"
gen str UltimateParentCUSIP_3 = substr(UltimateParentCUSIP, 15, 6)
label variable UltimateParentCUSIP_3 "UltimateParentCUSIP"
gen str UltimateParentCUSIP_4 = substr(UltimateParentCUSIP, 22, 6)
label variable UltimateParentCUSIP_4 "UltimateParentCUSIP"
gen str UltimateParentCUSIP_5 = substr(UltimateParentCUSIP, 29, 6)
label variable UltimateParentCUSIP_5 "UltimateParentCUSIP"
gen str UltimateParentCUSIP_6 = substr(UltimateParentCUSIP, 36, 6)
label variable UltimateParentCUSIP_6 "UltimateParentCUSIP"
gen str UltimateParentCUSIP_7 = substr(UltimateParentCUSIP, 43, 6)
label variable UltimateParentCUSIP_7 "UltimateParentCUSIP"
gen str UltimateParentCUSIP_8 = substr(UltimateParentCUSIP, 50, 6)
label variable UltimateParentCUSIP_8 "UltimateParentCUSIP"
gen str UltimateParentCUSIP_9 = substr(UltimateParentCUSIP, 57, 6)
label variable UltimateParentCUSIP_9 "UltimateParentCUSIP"
gen str UltimateParentCUSIP_10 = substr(UltimateParentCUSIP, 64, 6)
label variable UltimateParentCUSIP_10 "UltimateParentCUSIP"
gen str UltimateParentCUSIP_11 = substr(UltimateParentCUSIP, 71, 6) 
label variable UltimateParentCUSIP_11 "UltimateParentCUSIP"
gen str UltimateParentCUSIP_12 = substr(UltimateParentCUSIP, 78, 6) 
label variable UltimateParentCUSIP_12 "UltimateParentCUSIP"
gen str UltimateParentCUSIP_13 = substr(UltimateParentCUSIP, 85, 6) 
label variable UltimateParentCUSIP_13 "UltimateParentCUSIP"
gen str UltimateParentCUSIP_14 = substr(UltimateParentCUSIP, 92, 6) 
label variable UltimateParentCUSIP_14 "UltimateParentCUSIP"
gen str UltimateParentCUSIP_15 = substr(UltimateParentCUSIP, 99, 6) 
label variable UltimateParentCUSIP_15 "UltimateParentCUSIP"
gen str UltimateParentCUSIP_16 = substr(UltimateParentCUSIP, 106, 6) 
label variable UltimateParentCUSIP_16 "UltimateParentCUSIP"
gen str UltimateParentCUSIP_17 = substr(UltimateParentCUSIP, 113, 6) 
label variable UltimateParentCUSIP_17 "UltimateParentCUSIP"
gen str UltimateParentCUSIP_18 = substr(UltimateParentCUSIP, 120, 6) 
label variable UltimateParentCUSIP_18 "UltimateParentCUSIP"
gen str UltimateParentCUSIP_19 = substr(UltimateParentCUSIP, 127, 6) 
label variable UltimateParentCUSIP_19 "UltimateParentCUSIP"
gen str UltimateParentCUSIP_20 = substr(UltimateParentCUSIP, 134, 6) 
label variable UltimateParentCUSIP_20 "UltimateParentCUSIP"
gen str UltimateParentCUSIP_21 = substr(UltimateParentCUSIP, 141, 6) 
label variable UltimateParentCUSIP_21 "UltimateParentCUSIP"
}

}

{	//Strategic Alliances only
	drop if SA == 0 
} 

{	//Data flaws
	drop if missing(AllianceDateAnnounced)
	drop if missing(NumberofParticipantsinAllian)
	drop if missing(JointVentureFlag)
	*drop if missing(PercentOwnershipbyParticipant) if JV == 1
	
	//Undisclosed JV-Parnter >> CUSIP6 "904JVP"
	drop if strpos(UltimateParentCUSIP, "904JVP")

}

{	//Industry of Strategic Alliances
	gen twosic = substr(PrimarySICCodeofAlliance,1,2)
	destring twosic, replace
	
	*https://mckimmoncenter.ncsu.edu/2digitsiccodes/
	* 1 = Agriculture, Forestry, & Fishing --> 01-09
	* 2 = Mining --> 10-14
	* 3 = Construction --> 15-17
	* 4/5 = Manufacturing -->  20 - 39 ---> to be splitted as it clusters around chemical & allied products  (28)
	* 6 = Transportation & Public Utilities --> 40-49
	* 7 = Wholesale Trade --> 50-51
	* 8 = Retail Trade --> 52-59
	* 9 = Finance, Insurance & Real Estate --> 60-67
	* 10/11 = Services --> 70-89 ----> to be splitted as it clusters around business services  
	* 12 = Public Administration --> 91-98 // Nonclassifiable Establishments --> 99 // missings
	gen IND_SA = . 
	replace IND_SA = 1 if twosic <= 09 & twosic >= 1
	replace IND_SA = 2 if twosic <= 14 & twosic >= 10
	replace IND_SA = 3 if twosic <= 17 & twosic >= 15
	replace IND_SA = 4 if twosic == 28
	replace IND_SA = 5 if twosic <= 39 & twosic >= 20 & twosic != 28
	replace IND_SA = 6 if twosic <= 49 & twosic >= 40
	replace IND_SA = 7 if twosic <= 51 & twosic >= 50
	replace IND_SA = 8 if twosic <= 59 & twosic >= 52
	replace IND_SA = 9 if twosic <= 67 & twosic >= 60
	replace IND_SA = 10 if twosic == 73
	replace IND_SA = 11 if twosic <= 89 & twosic >= 70 & twosic != 73
	replace IND_SA = 12 if twosic <= 99 & twosic >= 90 
	replace IND_SA = 12 if missing(PrimarySICCodeofAlliance)
	drop twosic
}

{	//Select variables
compress _all
keep DateEffective year_ DealText JointVentureFlag JV AllianceDealName StrategicAlliance SA PartName_L_* PartName_S_* PartUltParentName_* UltimateParentCUSIP_* COOPFIRMYEAR NumberofParticipantsinAllian PrimarySICCodeofAlliance DealNumber IND_SA
describe
}

{ 	//Reshape from network to firm-level 
sort DateEffective DealNumber
save "${pathSDC}\SDC_Intermediate.dta", replace 
clear
*Varlist 
/*
DateEffective 
DealText 
JointVentureFlag 
PartName_L_1 
PartName_L_2 
PartName_L_3 
PartName_L_4 
PartName_L_5 
PartName_L_6 
PartName_L_7 
PartName_L_8 
PartName_L_9 
PartName_L_10 
PartName_L_11 
PartName_L_12 
PartName_L_13 
PartName_L_14 
PartName_L_15 
PartName_L_16 
PartName_L_17 
PartName_L_18 
PartName_L_19 
PartName_L_20 
PartName_L_21 
PartName_S_1 
PartName_S_2 
PartName_S_3 
PartName_S_4 
PartName_S_5 
PartName_S_6 
PartName_S_7 
PartName_S_8 
PartName_S_9 
PartName_S_10 
PartName_S_11 
PartName_S_12 
PartName_S_13 
PartName_S_14 
PartName_S_15 
PartName_S_16 
PartName_S_17 
PartName_S_18 
PartName_S_19 
PartName_S_20 
PartName_S_21 
StrategicAlliance 
PartUltParentName_1 
PartUltParentName_2 
PartUltParentName_3 
PartUltParentName_4 
PartUltParentName_5 
PartUltParentName_6 
PartUltParentName_7 
PartUltParentName_8 
PartUltParentName_9 
PartUltParentName_10 
PartUltParentName_11 
PartUltParentName_12 
PartUltParentName_13 
PartUltParentName_14 
PartUltParentName_15 
PartUltParentName_16 
PartUltParentName_17 
PartUltParentName_18 
PartUltParentName_19 
PartUltParentName_20 
PartUltParentName_21 
SA 
JV 
year_ 
UltimateParentCUSIP_1 
UltimateParentCUSIP_2 
UltimateParentCUSIP_3 
UltimateParentCUSIP_4 
UltimateParentCUSIP_5 
UltimateParentCUSIP_6 
UltimateParentCUSIP_7 
UltimateParentCUSIP_8 
UltimateParentCUSIP_9 
UltimateParentCUSIP_10 
UltimateParentCUSIP_11 
UltimateParentCUSIP_12 
UltimateParentCUSIP_13 
UltimateParentCUSIP_14 
UltimateParentCUSIP_15 
UltimateParentCUSIP_16 
UltimateParentCUSIP_17 
UltimateParentCUSIP_18 
UltimateParentCUSIP_19 
UltimateParentCUSIP_20 
UltimateParentCUSIP_21 
COOPFIRMYEAR
NumberofParticipantsinAllian
PrimarySICCodeofAlliance
AllianceDealName
DealNumber
*/

qui forvalues q=1(1)21{
use "${pathSDC}\SDC_Intermediate.dta", clear
gen PARTNAME_L = PartName_L_`q'  
gen PARTNAME_S = PartName_S_`q' 
gen PARTULTNAME = PartUltParentName_`q' 
gen ULTPARENTCUSIP = UltimateParentCUSIP_`q' 
drop if missing(ULTPARENTCUSIP)
save "${pathSDC}\SDC_tempfile_`q'.dta", replace
clear
}

}

{	//Create dataset with firm-level observations 
clear
use "${pathSDC}\SDC_tempfile_1.dta", clear
qui forvalues q=2(1)21{
append using "${pathSDC}\SDC_tempfile_`q'.dta", force
}
save "${pathSDC}\SDC_SA_FIRMLEVEL.dta", replace 
forvalues q=1(1)21{
erase "${pathSDC}\SDC_tempfile_`q'.dta"
}
erase "${pathSDC}\SDC_Intermediate.dta"
erase "${pathSDC}\SDC_1994_2016.dta"
clear

use "${pathSDC}\SDC_SA_FIRMLEVEL.dta", clear 
keep DateEffective DealText JointVentureFlag StrategicAlliance JV SA year_ COOPFIRMYEAR PARTNAME_L PARTNAME_S PARTULTNAME ULTPARENTCUSIP NumberofParticipantsinAllian PrimarySICCodeofAlliance AllianceDealName DealNumber IND_SA
rename DateEffective DATEEFFECTIVE
rename DealText DEALTEXT
rename JointVentureFlag JOINTVENTUREFLAG
rename StrategicAlliance STRATEGICALLIANCEFLAG
rename year_ YEAR 
gen CUSIP6 = ULTPARENTCUSIP
rename NumberofParticipantsinAllian NUM_PARTICIPANTS 
rename PrimarySICCodeofAlliance SIC_NETWORK 
rename AllianceDealName NAME_NETWORK
rename DealNumber DEALNUMBER
sort DEALNUMBER
save "${pathSDC}\SDC_SA_FIRMLEVEL.dta", replace 
}

clear
