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
	ssc install findname
	ssc install xls2dta
	*/
	*Update packages
	adoupdate corsp estout reghdfe ftools moremata cem rangejoin rangestat coefplot findname, update
}

{	//Set user & working directory
	global USER_OS = "" // "User Inititials _ Operating System"

{	//WD & paths
		if  missing("${USER_OS}"){
		display "**** PLEASE SET USER INITIALS, OPERARTING SYSTEM, AND FILE PATH****"
		exit
		}
	
	if  !missing("${USER_OS}"){
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
/*
{	//Import SDC Data
	*Import
	cd "${pathSDC}" 
	xls2dta: import excel ./, cellrange(B2) firstrow case(upper) 

	*Append
	xls2dta , save(./SDC_ITEMS_ALL_RAW_COMPLETE.dta, replace) : append, force
	cd "${path}" 
	clear
}
*/
{	//Data Cleansing
	use "${pathSDC}\SDC_ITEMS_ALL_RAW_COMPLETE.dta", clear
	
	{	//SDC's Deal Number & Date Effective == Unique Identifier
		codebook DEALNUMBER
		drop if missing(DEALNUMBER)
		drop if missing(DATEEFFECTIVE)
		*Identification Strategy requires to identify all participants in an alliance
		drop if missing(NUMBEROFPARTICIPANTSINALLIAN)
		drop if NUMBEROFPARTICIPANTSINALLIAN == 1
	}

	{	//Strategic Alliances only
		tab STRATEGICALLIANCE 
		drop if STRATEGICALLIANCE != "Y" & STRATEGICALLIANCE != "N"
		gen SA = . 
		replace SA = 1 if STRATEGICALLIANCE == "Y" 
		replace SA = 0 if STRATEGICALLIANCE == "N"
		label var SA "STRATEGIC ALLIANCE AS CLASSIFIED BY SDC"
		drop if SA == 0 
		if JOINTVENTUREFLAG != "No" {
		display "***SAMPLE CONTAINS EQUITY JOINT VENTURES***"
		exit
		}	
	} 

	{	//Sample Period 
		*YEAR 
		gen YEAR = year(DATEEFFECTIVE)
		drop if YEAR > 2016 & !missing(YEAR)
		drop if YEAR < 1994 & !missing(YEAR)
		drop if missing(YEAR)
		*ANNOUNCEDYEAR
		gen ANNOUNCEDYEAR = year(ALLIANCEDATEANNOUNCED)
		*ENDYEAR 
		gen ENDYEAR = year(DATEALLIANCETERMINATED)
		drop if ENDYEAR <= ANNOUNCEDYEAR & !missing(ENDYEAR) & !missing(ANNOUNCEDYEAR) 	//short term alliances/ data flaws
		drop if ENDYEAR <= YEAR & !missing(ENDYEAR) & !missing(YEAR)					//short term alliances/ data flaws
		gen vhelp = YEAR - ENDYEAR
		replace vhelp = vhelp*-1
		rename vhelp DURATION
		label var DURATION "Duration, Years DATEEFFECTIVE DATEALLIANCETERMINATED"
		drop if DURATION <= 3 //respectively n = 97
		*STATUS
		drop if STATUS == "Letter of Intent" | STATUS == "Pending"
	}

	{	//Undisclosed JV-Parnter
		*SDC encodes occurences of undisclosed participants under the 6-digit CUSIP 904JVP
		*CUSIP6 "904JVP"
		*list ULTIMATEPARENTCUSIP if strpos(ULTIMATEPARENTCUSIP, "904JVP")
		drop if strpos(ULTIMATEPARENTCUSIP, "904JVP")
	}

}

{	//Prepare Alliance Data on Network Level 

{		//Create Indicator Variables from Flags 
		*Flags
		global FLAGLIST DATEOFANNOUNCEMENTESTIMATEDF DATEALLIANCESIGNEDESTIMATEDF DATEALLIANCETERMINATEDESTIMAT EXCLUSIVELICENSINGAGREEMENTFL EXPLORATIONAGREEMENTFLAG FUNDINGAGREEMENTFLAG JOINTVENTUREFLAG PARTICIPANTJOINTVENTURESTAKE LICENSINGAGREEMENTFLAG MANUFACTURINGAGREEMENTFLAG MARKETINGAGREEMENTFLAG ORIGINALEQUIPMENTMANUFVALUE PRIVATIZATIONFLAG RESEARCHANDDEVELOPMENTAGREE ROYALTIESFLAG SPINOUTFLAG SUPPLYAGREEMENTFLAG
		findname $FLAGLIST, any(length("@") > 25) detail
		foreach var of varlist `r(varlist)' {
		local new = substr("`var'", 1, 25)
		rename `var' `new'
		}
		
		global FLAGLIST DATEOFANNOUNCEMENTESTIMAT DATEALLIANCESIGNEDESTIMAT DATEALLIANCETERMINATEDEST EXCLUSIVELICENSINGAGREEME EXPLORATIONAGREEMENTFLAG FUNDINGAGREEMENTFLAG JOINTVENTUREFLAG PARTICIPANTJOINTVENTUREST LICENSINGAGREEMENTFLAG MANUFACTURINGAGREEMENTFLA MARKETINGAGREEMENTFLAG ORIGINALEQUIPMENTMANUFVAL PRIVATIZATIONFLAG RESEARCHANDDEVELOPMENTAGR ROYALTIESFLAG SPINOUTFLAG SUPPLYAGREEMENTFLAG
		foreach var of varlist $FLAGLIST {
		replace `var'= "1" if `var' == "Yes" | `var' == "Y" 
		replace `var'= "0" if `var' == "No" | `var' == "N"
		destring `var', replace
		}

		}

{		//Industry of Strategic Alliances 
		gen TWOSIC = substr(PRIMARYSICCODEOFALLIANCE,1,2)
		destring TWOSIC, replace
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
		replace IND_SA = 1 if TWOSIC <= 09 & TWOSIC >= 1
		replace IND_SA = 2 if TWOSIC <= 14 & TWOSIC >= 10
		replace IND_SA = 3 if TWOSIC <= 17 & TWOSIC >= 15
		replace IND_SA = 4 if TWOSIC == 28
		replace IND_SA = 5 if TWOSIC <= 39 & TWOSIC >= 20 & TWOSIC != 28
		replace IND_SA = 6 if TWOSIC <= 49 & TWOSIC >= 40
		replace IND_SA = 7 if TWOSIC <= 51 & TWOSIC >= 50
		replace IND_SA = 8 if TWOSIC <= 59 & TWOSIC >= 52
		replace IND_SA = 9 if TWOSIC <= 67 & TWOSIC >= 60
		replace IND_SA = 10 if TWOSIC == 73
		replace IND_SA = 11 if TWOSIC <= 89 & TWOSIC >= 70 & TWOSIC != 73
		replace IND_SA = 12 if TWOSIC <= 99 & TWOSIC >= 90
		replace IND_SA = 12 if missing(PRIMARYSICCODEOFALLIANCE)
		drop TWOSIC	
}

}

{	//Delimit Line Breaks from Data 
	global DLMLIST ULTIMATEPARENTCUSIP PARTICIPANTSINVENTUREALLIAN
	foreach var of varlist $DLMLIST{
	tostring `var', replace
	}
	local dlm = char(10)
	foreach var of varlist $DLMLIST{
	split `var', parse(`"`dlm'"')
	drop `var' 
	}

	}

{	//Keep Selected Variables Only
	keep ALLIANCEDATEANNOUNCED RELATEDMASPDATEEFFECT RELATEDMASPDATEANNOUN RELATEDMADATEEFFECTIVE RELATEDMADATEANNOUNCED RELATEDJVSADATEEFFECTIVE ANNOUNCEMENTDATEOFRELATEDJOI HISTORYDATE DATEALLIANCETERMINATED DATESOUGHT DATERENEGOTIATED DEALEXCHANGERATEDATE DATEEXTENDED DATEEXPIRED DATEEXPIRATIONEXPECTED DATEEFFECTIVE DATEOFANNOUNCEMENTESTIMAT DATEALLIANCESIGNEDESTIMAT DATEALLIANCETERMINATEDEST EXCLUSIVELICENSINGAGREEME EXPLORATIONAGREEMENTFLAG FUNDINGAGREEMENTFLAG JOINTVENTUREFLAG PARTICIPANTJOINTVENTUREST LICENSINGAGREEMENTFLAG MANUFACTURINGAGREEMENTFLA MARKETINGAGREEMENTFLAG ORIGINALEQUIPMENTMANUFVAL PRIVATIZATIONFLAG RESEARCHANDDEVELOPMENTAGR ROYALTIESFLAG SPINOUTFLAG SUPPLYAGREEMENTFLAG ULTIMATEPARENTCUSIP* PARTICIPANTSINVENTUREALLIAN* IND_SA SA STRATEGICALLIANCE YEAR DEALTEXT ALLIANCEDEALNAME DEALNUMBER NUMBEROFPARTICIPANTSINALLIAN PRIMARYSICCODEOFALLIANCE PRIMARYALLIANCEVECODE
	compress 
}
	
{	//Reshape Data from Network- to Firm-Level
	reshape long $DLMLIST, i(DEALNUMBER) j(reshapeID)
	drop if reshapeID > NUMBEROFPARTICIPANTSINALLIAN
	sort DEALNUMBER
}

{ 	//Save
	gen CUSIP6 = ULTIMATEPARENTCUSIP
	label var CUSIP6 "Ultimate PArticipant Parent 6 digit CUSIP"
	save "${pathSDC}\SDC_SA_FIRMLEVEL.dta", replace 
	clear
}

