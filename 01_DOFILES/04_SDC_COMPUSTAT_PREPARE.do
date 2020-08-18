clear
set more off 


****************************************************
*******      COMPUSTAT SDC PREPARE         *********
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
		display "**** PLEASE SET USER INITIALS AND OPERARTING SYSTEM BELOW AND ADJUST PATHS IN DO-FILE CHUNK ****"
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

use "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT_MERGED.dta", clear 

{	//Sample Selection
	egen CUSIPNUM = group(CUSIP6)
	sort CUSIP6 YEAR DEALNUMBER
	
	//Exclude firms without a match in the SDC database 
	sort CUSIP6 YEAR DEALNUMBER
	by CUSIP6: egen vhelp = max(_merge)
	drop if vhelp == 2
	drop vhelp*
	drop _merge
	
	//Exclude networks of firms who cooperate with e.g. private investors (shows in data as if cooperating with themselves)
	duplicates tag CUSIP6 YEAR DEALNUMBER DATEEFFECTIVE, gen(vhelp)
	drop if vhelp != 0 
	drop vhelp
	sort CUSIP6 YEAR DEALNUMBER
	gen COOPFIRMYEAR = SA
	by CUSIP6: egen vhelp = max(COOPFIRMYEAR)
	drop if vhelp !=  1
	drop vhelp
	
		//Sample Selection Table Entry #1 
		egen vhelp = group(CUSIP6)
		sum vhelp, d
		display r(max)
		gen firms1 = r(max)
		sum vhelp, d
		display r(N) 
		gen firmyears1 = r(N)
		drop vhelp*
		sum COOPFIRMYEAR if COOPFIRMYEAR == 1, d
		display r(N) 
		gen networkfirmobs1 = r(N)
		egen vhelp = group(DEALNUMBER)
		sum vhelp, d
		display r(max)
		gen networks1 = r(max)
		drop vhelp*
	
	//Sample Selection: identify all contracting participants
	sort DEALNUMBER CUSIP6 YEAR 
	gen vhelp = 1
	replace vhelp = . if missing(DEALNUMBER)
	by DEALNUMBER: gen vhelp2 = sum(vhelp)
	replace vhelp2 = . if missing(DEALNUMBER)
	by DEALNUMBER: egen vhelp3 = max(vhelp2)
	drop if vhelp3 != NUMBEROFPARTICIPANTSINALLIAN
	drop if vhelp3 == 1
	drop vhelp*
	sort CUSIP6 YEAR DEALNUMBER
	by CUSIP6: egen vhelp = max(COOPFIRMYEAR)
	drop if vhelp !=  1
	drop vhelp
	
		//Sample Selection Table Entry #2
		egen vhelp = group(CUSIP6)
		sum vhelp, d
		display r(max)
		gen firms2 = r(max)
		sum vhelp, d
		display r(N) 
		gen firmyears2 = r(N)
		drop vhelp*
		sum COOPFIRMYEAR if COOPFIRMYEAR == 1, d
		display r(N) 
		gen networkfirmobs2 = r(N)
		egen vhelp = group(DEALNUMBER)
		sum vhelp, d
		display r(max)
		gen networks2 = r(max)
		drop vhelp*
		
	//Sample Selection: require to identify CASH_ETR3 and LAG_PRE_CASH_ETR3_1 of all firms in a network 
	gen vhelp = . 
	replace vhelp = 1 if !missing(CASH_ETR3) 
	replace vhelp = . if missing(COOPFIRMYEAR)
	replace vhelp = . if vhelp == 1 & missing(LAG_PRE_CASH_ETR3_1)
	sort DEALNUMBER CUSIP6 YEAR 
	by DEALNUMBER: gen vhelp2 = sum(vhelp)
	replace vhelp2 = . if missing(DEALNUMBER)
	by DEALNUMBER: egen vhelp3 = max(vhelp2)
	drop if vhelp3 != NUMBEROFPARTICIPANTSINALLIAN
	drop vhelp*
	sort CUSIP6 YEAR DEALNUMBER
	by CUSIP6: egen vhelp = max(COOPFIRMYEAR)
	drop if vhelp !=  1
	drop vhelp
	
		//Sample Selection Table Entry #3
		egen vhelp = group(CUSIP6)
		sum vhelp, d
		display r(max)
		gen firms3 = r(max)
		sum vhelp, d
		display r(N) 
		gen firmyears3 = r(N)
		drop vhelp*
		sum COOPFIRMYEAR if COOPFIRMYEAR == 1, d
		display r(N) 
		gen networkfirmobs3 = r(N)
		egen vhelp = group(DEALNUMBER)
		sum vhelp, d
		display r(max)
		gen networks3 = r(max)
		drop vhelp*
		
}

{	//Identification strategy
	sort CUSIP6 YEAR DEALNUMBER
	
	//Multiple Observations per CUSIP6 per YEAR
	sort CUSIP6 YEAR DEALNUMBER
	by CUSIP6 YEAR:  gen dup = cond(_N==1,0,_n)
	gen vhelp = . 
	replace vhelp = 0 if dup == 0
	replace vhelp = 0  if dup == 1
	rename vhelp excldup
	drop dup
	
	//TAXBIN 
	*Align observations into 4 bins for identification strategy
	sort CUSIP6 YEAR DEALNUMBER
	gen vhelp = . 
	*forvalue q = 1997(1)2016{
	sum LAG_indyearadj_PRE_CASH_ETR3_1 if !missing(excldup) & !missing(COOPFIRMYEAR), d 
	replace vhelp = 1 if LAG_indyearadj_PRE_CASH_ETR3_1 < `r(p25)' & !missing(COOPFIRMYEAR) 
	replace vhelp = 2 if LAG_indyearadj_PRE_CASH_ETR3_1 >= `r(p25)' & LAG_indyearadj_PRE_CASH_ETR3_1 < `r(p50)' & !missing(COOPFIRMYEAR) 
	replace vhelp = 3 if LAG_indyearadj_PRE_CASH_ETR3_1 >= `r(p50)' & LAG_indyearadj_PRE_CASH_ETR3_1 < `r(p75)'  & !missing(COOPFIRMYEAR) 
	replace vhelp = 4 if LAG_indyearadj_PRE_CASH_ETR3_1 >= `r(p75)' & !missing(LAG_indyearadj_PRE_CASH_ETR3_1) & !missing(COOPFIRMYEAR) 
	rename vhelp TAXBIN
	
	//Firms 
	*LOWTAX-FIRMS
	gen LOWTAXFIRM = .
	replace LOWTAXFIRM = 0 if TAXBIN == 2 | TAXBIN == 3 | TAXBIN == 4
	replace LOWTAXFIRM =  1 if TAXBIN == 1
	replace LOWTAXFIRM = . if missing(COOPFIRMYEAR)		//check
	
	*HIGHTAX-FIRMS (inverse to LOWTAXFIRM)
	gen HIGHTAXFIRM = .
	replace HIGHTAXFIRM = 0 if TAXBIN == 1
	replace HIGHTAXFIRM =  1 if TAXBIN == 2 | TAXBIN == 3 | TAXBIN == 4
	replace HIGHTAXFIRM = . if missing(COOPFIRMYEAR)	//check
	
	//Networks 
	gen vhelp = . 
	replace vhelp = 0 if LOWTAXFIRM == 1
	replace vhelp = 1 if HIGHTAXFIRM == 1
	sort DEALNUMBER CUSIP6 YEAR 
	by DEALNUMBER: egen vhelp2 = max(vhelp)
	*Networks with only LOWTAXFIRMS in it
	gen ONLYLOW = . 
	replace ONLYLOW =  1 if vhelp2 == 0
	*Networks with LOWTAXFIRMS and HIGHTAXFIRMS in it 
	gen vhelp3 = . 
	replace vhelp3 = 1 if vhelp == 0 & vhelp2 == 1
	by DEALNUMBER: egen vhelp4 = max(vhelp3)
	gen MIXED = . 
	replace MIXED = 1 if vhelp4 == 1
	*Networks with only HIGHTAXFIRMS in it
	gen ONLYHIGH = .  
	replace ONLYHIGH = 1 if !missing(DEALNUMBER) & missing(MIXED) & missing(ONLYLOW)
	drop vhelp*
	
	//Main variable of interest: hightolow 
	gen hightolow = . 
	replace hightolow = 1 if MIXED == 1 & HIGHTAXFIRM == 1
	replace hightolow = 0 if ONLYHIGH == 1 & HIGHTAXFIRM == 1
	
	//Network (all observations with hightaxfirms in it)
	sort DEALNUMBER CUSIP6 YEAR
	by DEALNUMBER: egen vhelp = max(hightolow)
	gen vhelp2 = . 
	replace vhelp2 = 1 if !missing(vhelp)
	rename vhelp2 network 
	drop vhelp*
	
	//Robustness check: lowtohigh 
	sort CUSIP6 YEAR
	gen lowtohigh = . 
	replace lowtohigh = 0 if ONLYLOW == 1
	replace lowtohigh =  1 if MIXED == 1 & LOWTAXFIRM == 1 
	
}

{	//Partner Controls

	//PARTSAMEBEAREGION
	sort DEALNUMBER CUSIP6 YEAR
	gen vhelp = 0 
	by DEALNUMBER: replace vhelp = 1 if bearegion == bearegion[_n+1] & NUMBEROFPARTICIPANTSINALLIAN == 2
	by DEALNUMBER: replace vhelp = 1 if bearegion == bearegion[_n+1] & bearegion == bearegion[_n+2] & NUMBEROFPARTICIPANTSINALLIAN == 3
	by DEALNUMBER: replace vhelp = 1 if bearegion == bearegion[_n+1] & bearegion == bearegion[_n+2] & bearegion == bearegion[_n+3] & NUMBEROFPARTICIPANTSINALLIAN == 4
	by DEALNUMBER: egen PARTSAMEBEAREGION = max(vhelp)
	replace PARTSAMEBEAREGION = . if missing(COOPFIRMYEAR)
	drop vhelp*
	sort CUSIP6 YEAR DEALNUMBER 
	
	//PARTSAMESTATE
	sort DEALNUMBER CUSIP6 YEAR
	gen vhelp = 0 
	by DEALNUMBER: replace vhelp = 1 if state == state[_n+1] & NUMBEROFPARTICIPANTSINALLIAN == 2
	by DEALNUMBER: replace vhelp = 1 if state == state[_n+1] & state == state[_n+2] & NUMBEROFPARTICIPANTSINALLIAN == 3
	by DEALNUMBER: replace vhelp = 1 if state == state[_n+1] & state == state[_n+2] & state == state[_n+3] & NUMBEROFPARTICIPANTSINALLIAN == 4
	by DEALNUMBER: egen PARTSAMESTATE = max(vhelp)
	replace PARTSAMESTATE = . if missing(COOPFIRMYEAR)
	drop vhelp*
	sort CUSIP6 YEAR DEALNUMBER 
	
	//PARTSAMEAUDITOR
	destring au, gen(au2)
	sort DEALNUMBER CUSIP6 YEAR
	gen vhelp = 0 
	by DEALNUMBER: replace vhelp = 1 if au2 == au2[_n+1] & NUMBEROFPARTICIPANTSINALLIAN == 2 & au2 != 0
	by DEALNUMBER: replace vhelp = 1 if au2 == au2[_n+1] & au2 == au2[_n+2] & NUMBEROFPARTICIPANTSINALLIAN == 3 & au2 != 0 
	by DEALNUMBER: replace vhelp = 1 if au2 == au2[_n+1] & au2 == au2[_n+2] & au2 == au2[_n+3] & NUMBEROFPARTICIPANTSINALLIAN == 4 & au2 != 0
	by DEALNUMBER: egen PARTSAMEAUDITOR = max(vhelp)
	replace PARTSAMEAUDITOR = . if missing(COOPFIRMYEAR)
	drop vhelp*
	drop au2
	sort CUSIP6 YEAR DEALNUMBER 
	
	//PARTSAMEIND
	sort DEALNUMBER CUSIP6 YEAR
	gen vhelp = 0 
	by DEALNUMBER: replace vhelp = 1 if IND == IND[_n+1] & NUMBEROFPARTICIPANTSINALLIAN == 2 & IND != 12
	by DEALNUMBER: replace vhelp = 1 if IND == IND[_n+1] & IND == IND[_n+2] & NUMBEROFPARTICIPANTSINALLIAN == 3 & IND != 12 
	by DEALNUMBER: replace vhelp = 1 if IND == IND[_n+1] & IND == IND[_n+2] & IND == IND[_n+3] & NUMBEROFPARTICIPANTSINALLIAN == 4 & IND != 12
	by DEALNUMBER: egen PARTSAMEIND = max(vhelp)
	replace PARTSAMEIND = . if missing(COOPFIRMYEAR)
	drop vhelp*
	sort CUSIP6 YEAR DEALNUMBER 
	
	//PARTSIZE (take average if NUMBEROFPARTICIPANTSINALLIAN > 2)
	sort DEALNUMBER CUSIPNUM YEAR
	gen vhelp = . 
	by DEALNUMBER: replace vhelp = size[_n+1] if NUMBEROFPARTICIPANTSINALLIAN == 2
	gsort DEALNUMBER -CUSIPNUM YEAR
	by DEALNUMBER: replace vhelp = size[_n+1] if NUMBEROFPARTICIPANTSINALLIAN == 2 & missing(vhelp)
	sort DEALNUMBER CUSIPNUM YEAR
	rename vhelp PARTSIZE 
	by DEALNUMBER: gen vhelp = _n
	gen vhelp2 = . 
	by DEALNUMBER: egen vhelp3 = mean(size) if vhelp != 1 & NUMBEROFPARTICIPANTSINALLIAN != 2
	by DEALNUMBER: egen vhelp4 = max(vhelp3)
	replace vhelp2 = vhelp4 if missing(vhelp2) & missing(vhelp3)
	drop vhelp3 vhelp4
	
	by DEALNUMBER: egen vhelp3 = mean(size) if vhelp != 2 & NUMBEROFPARTICIPANTSINALLIAN != 2
	by DEALNUMBER: egen vhelp4 = max(vhelp3)
	replace vhelp2 = vhelp4 if missing(vhelp2) & missing(vhelp3)
	drop vhelp3 vhelp4
	
	by DEALNUMBER: egen vhelp3 = mean(size) if vhelp != 3 & NUMBEROFPARTICIPANTSINALLIAN != 2
	by DEALNUMBER: egen vhelp4 = max(vhelp3)
	replace vhelp2 = vhelp4 if missing(vhelp2) & missing(vhelp3)
	drop vhelp3 vhelp4
	
	by DEALNUMBER: egen vhelp3 = mean(size) if vhelp != 4 & NUMBEROFPARTICIPANTSINALLIAN != 2
	by DEALNUMBER: egen vhelp4 = max(vhelp3)
	replace vhelp2 = vhelp4 if missing(vhelp2) & missing(vhelp3)
	drop vhelp3 vhelp4
	
	drop vhelp
	replace vhelp2 = . if missing(COOPFIRMYEAR)
	replace PARTSIZE = vhelp2 if missing(PARTSIZE) & !missing(vhelp2)
	drop vhelp*	
	
	//PARTCETR3
	sort DEALNUMBER CUSIPNUM YEAR
	gen vhelp = . 
	by DEALNUMBER: replace vhelp = CASH_ETR3[_n+1] if NUMBEROFPARTICIPANTSINALLIAN == 2
	gsort DEALNUMBER -CUSIPNUM YEAR
	by DEALNUMBER: replace vhelp = CASH_ETR3[_n+1] if NUMBEROFPARTICIPANTSINALLIAN == 2 & missing(vhelp)
	sort DEALNUMBER CUSIPNUM YEAR
	rename vhelp PARTCETR3
	by DEALNUMBER: gen vhelp = _n
	gen vhelp2 = . 
	by DEALNUMBER: egen vhelp3 = mean(CASH_ETR3) if vhelp != 1 & NUMBEROFPARTICIPANTSINALLIAN != 2
	by DEALNUMBER: egen vhelp4 = max(vhelp3)
	replace vhelp2 = vhelp4 if missing(vhelp2) & missing(vhelp3)
	drop vhelp3 vhelp4
	
	by DEALNUMBER: egen vhelp3 = mean(CASH_ETR3) if vhelp != 2 & NUMBEROFPARTICIPANTSINALLIAN != 2
	by DEALNUMBER: egen vhelp4 = max(vhelp3)
	replace vhelp2 = vhelp4 if missing(vhelp2) & missing(vhelp3)
	drop vhelp3 vhelp4
	
	by DEALNUMBER: egen vhelp3 = mean(CASH_ETR3) if vhelp != 3 & NUMBEROFPARTICIPANTSINALLIAN != 2
	by DEALNUMBER: egen vhelp4 = max(vhelp3)
	replace vhelp2 = vhelp4 if missing(vhelp2) & missing(vhelp3)
	drop vhelp3 vhelp4
	
	by DEALNUMBER: egen vhelp3 = mean(CASH_ETR3) if vhelp != 4 & NUMBEROFPARTICIPANTSINALLIAN != 2
	by DEALNUMBER: egen vhelp4 = max(vhelp3)
	replace vhelp2 = vhelp4 if missing(vhelp2) & missing(vhelp3)
	drop vhelp3 vhelp4
	
	drop vhelp
	replace vhelp2 = . if missing(COOPFIRMYEAR)
	replace PARTCETR3 = vhelp2 if missing(PARTCETR) & !missing(vhelp2)
	drop vhelp*	
	
	//PARTPRECETR3
	sort DEALNUMBER CUSIPNUM YEAR
	gen vhelp = . 
	gen vhelpX = LAG_PRE_CASH_ETR3_1
	by DEALNUMBER: replace vhelp = vhelpX[_n+1] if NUMBEROFPARTICIPANTSINALLIAN == 2
	gsort DEALNUMBER -CUSIPNUM YEAR
	by DEALNUMBER: replace vhelp = vhelpX[_n+1] if NUMBEROFPARTICIPANTSINALLIAN == 2 & missing(vhelp)
	sort DEALNUMBER CUSIPNUM YEAR
	rename vhelp PARTPRECETR3
	by DEALNUMBER: gen vhelp = _n
	gen vhelp2 = . 
	by DEALNUMBER: egen vhelp3 = mean(vhelpX) if vhelp != 1 & NUMBEROFPARTICIPANTSINALLIAN != 2
	by DEALNUMBER: egen vhelp4 = max(vhelp3)
	replace vhelp2 = vhelp4 if missing(vhelp2) & missing(vhelp3)
	drop vhelp3 vhelp4
	
	by DEALNUMBER: egen vhelp3 = mean(vhelpX) if vhelp != 2 & NUMBEROFPARTICIPANTSINALLIAN != 2
	by DEALNUMBER: egen vhelp4 = max(vhelp3)
	replace vhelp2 = vhelp4 if missing(vhelp2) & missing(vhelp3)
	drop vhelp3 vhelp4
	
	by DEALNUMBER: egen vhelp3 = mean(vhelpX) if vhelp != 3 & NUMBEROFPARTICIPANTSINALLIAN != 2
	by DEALNUMBER: egen vhelp4 = max(vhelp3)
	replace vhelp2 = vhelp4 if missing(vhelp2) & missing(vhelp3)
	drop vhelp3 vhelp4
	
	by DEALNUMBER: egen vhelp3 = mean(vhelpX) if vhelp != 4 & NUMBEROFPARTICIPANTSINALLIAN != 2
	by DEALNUMBER: egen vhelp4 = max(vhelp3)
	replace vhelp2 = vhelp4 if missing(vhelp2) & missing(vhelp3)
	drop vhelp3 vhelp4
	
	drop vhelp
	replace vhelp2 = . if missing(COOPFIRMYEAR)
	replace PARTPRECETR3 = vhelp2 if missing(PARTPRECETR3) & !missing(vhelp2)
	drop vhelp*	
	
	//PARTPREINDADJCETR3
	*LAG_indyearadj_PRE_CASH_ETR3_1
	sort DEALNUMBER CUSIPNUM YEAR
	gen vhelp = . 
	gen vhelpX = LAG_indyearadj_PRE_CASH_ETR3_1
	by DEALNUMBER: replace vhelp = vhelpX[_n+1] if NUMBEROFPARTICIPANTSINALLIAN == 2
	gsort DEALNUMBER -CUSIPNUM YEAR
	by DEALNUMBER: replace vhelp = vhelpX[_n+1] if NUMBEROFPARTICIPANTSINALLIAN == 2 & missing(vhelp)
	sort DEALNUMBER CUSIPNUM YEAR
	rename vhelp PARTPREINDADJCETR3
	by DEALNUMBER: gen vhelp = _n
	gen vhelp2 = . 
	by DEALNUMBER: egen vhelp3 = mean(vhelpX) if vhelp != 1 & NUMBEROFPARTICIPANTSINALLIAN != 2
	by DEALNUMBER: egen vhelp4 = max(vhelp3)
	replace vhelp2 = vhelp4 if missing(vhelp2) & missing(vhelp3)
	drop vhelp3 vhelp4
	
	by DEALNUMBER: egen vhelp3 = mean(vhelpX) if vhelp != 2 & NUMBEROFPARTICIPANTSINALLIAN != 2
	by DEALNUMBER: egen vhelp4 = max(vhelp3)
	replace vhelp2 = vhelp4 if missing(vhelp2) & missing(vhelp3)
	drop vhelp3 vhelp4
	
	by DEALNUMBER: egen vhelp3 = mean(vhelpX) if vhelp != 3 & NUMBEROFPARTICIPANTSINALLIAN != 2
	by DEALNUMBER: egen vhelp4 = max(vhelp3)
	replace vhelp2 = vhelp4 if missing(vhelp2) & missing(vhelp3)
	drop vhelp3 vhelp4
	
	by DEALNUMBER: egen vhelp3 = mean(vhelpX) if vhelp != 4 & NUMBEROFPARTICIPANTSINALLIAN != 2
	by DEALNUMBER: egen vhelp4 = max(vhelp3)
	replace vhelp2 = vhelp4 if missing(vhelp2) & missing(vhelp3)
	drop vhelp3 vhelp4
	
	drop vhelp
	replace vhelp2 = . if missing(COOPFIRMYEAR)
	replace PARTPREINDADJCETR3 = vhelp2 if missing(PARTPRECETR3) & !missing(vhelp2)
	drop vhelp*	
}

{	//Difference-in-Differences  

	//Embargo period 
	*are there overlapping events (aka other networks [t-2;t5] years?
	duplicates tag CUSIP6 YEAR, gen(vhelp)
	replace vhelp = vhelp + 1 
	rename vhelp NUMSAinYEAR
	replace NUMSAinYEAR = . if missing(COOPFIRMYEAR)
	*[t-2; t5] with network-start in t1
	gen vhelp = 0 if !missing(COOPFIRMYEAR)
	qui forval q=1(1)100 {
	sort CUSIP6 YEAR DEALNUMBER
	by CUSIP6: gen vhelp_`q' = 1 if vhelp[_n+`q'] == 0 & YEAR-YEAR[_n+`q'] >= -8
	replace vhelp_`q' = .  if missing(vhelp)
	}
	qui forval q=1(1)100 {
	gsort CUSIP6 -YEAR -DEALNUMBER
	by CUSIP6: gen vhelp_m`q' = 1 if vhelp[_n+`q'] == 0 & YEAR-YEAR[_n+`q'] <= 8	
	replace vhelp_m`q' = .  if missing(vhelp)
	}
	sort CUSIP6 YEAR DEALNUMBER
	foreach var of varlist vhelp_* {
	replace vhelp = `var' if `var' == 1 & vhelp == 0
	}
	if NUMSAinYEAR > 1 & vhelp == 0 & !missing(NUMSAinYEAR) {
	display "***Something went wrong***"
	exit
	}
	rename vhelp OVERLAP 	// OVERLAP == 1 >> signals that there is another network for firm within range [t-2;t5]
	drop vhelp*
	
	//Assign TREATMENT without overlapping events 
	gen TREATMENT = . 
	replace TREATMENT = 1 if hightolow == 1
	replace TREATMENT = 0 if hightolow == 0
	replace TREATMENT = . if OVERLAP == 1
	gen HIGHTOLOW_NO_OVERLAP =  TREATMENT
	
	{  	// TREATED##POST
		//Period around network [DIDYEAR t-2;t5]
	gen vhelp = . 
	replace vhelp =  1 if !missing(TREATMENT)	//t1, strategic alliance becomes effective
	gen vhelp2 = YEAR if vhelp == 1
	qui forvalue q=1(1)50 {
	sort CUSIP6 YEAR DEALNUMBER
	by CUSIP6: replace vhelp = YEAR-vhelp2[_n-`q']+1 if missing(vhelp) & vhelp[_n-`q'] == 1 
	}
	replace vhelp = . if vhelp > 5 & !missing(vhelp) 
	qui forvalue q=1(1)50 {
	sort CUSIP6 YEAR DEALNUMBER
	by CUSIP6: replace vhelp = YEAR-vhelp2[_n+`q']+1 if missing(vhelp) & vhelp[_n+`q'] == 1
	}
	replace vhelp = . if vhelp < -2 & !missing(vhelp)
	rename vhelp DIDYEAR
	drop vhelp*
	
	//Post
	gen POST = 0
	replace POST = 1 if DIDYEAR >= 1 & DIDYEAR <= 5
	replace POST = . if missing(DIDYEAR)
	
	//Treated
	gen vhelp = TREATMENT
	forval q=1(1)6 {
	sort CUSIP6 YEAR DEALNUMBER
	by CUSIP6: replace vhelp = vhelp[_n-`q'] if missing(vhelp) & DIDYEAR >= 1 & !missing(DIDYEAR) & YEAR-YEAR[_n+`q'] >= -5	//3
	}
	forval q=1(1)6 {
	gsort CUSIP6 -YEAR DEALNUMBER
	by CUSIP6: replace vhelp = vhelp[_n-`q'] if missing(vhelp) & DIDYEAR < 1 & !missing(DIDYEAR) & YEAR-YEAR[_n+`q'] >= -5	//3
	}
	sort CUSIP6 YEAR DEALNUMBER
	rename vhelp TREATED
	
	//Treated*Post
	gen TREATED_POST = TREATED*POST
	}	
	
	{	//Balanced Sample: Entropy Balancing WEIGHTING
	*List of covariates
	global FIRMlistebalance ebitda_at RnDExp AdExp SGA CapEx ChangeSale Leverage Cash Intangibles PPE size
	*Entropy Balancing
	gen TREATED_EBAL = TREATED
	ebalance TREATED_EBAL $FIRMlistebalance, tar(2)
	
	}

}

save "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT_TOAPPEND.dta", replace 

clear

{	//Export data for further data collection

	//Business purpose
	use "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT_TOAPPEND.dta", clear 
	drop if missing(DEALTEXT) 
	keep ALLIANCEDEALNAME CUSIP6 DEALNUMBER DEALTEXT DEALNUMBER
	save "${path}\05_OTHER\SDC_COMPUSTAT_DEALTEXT_RAW.dta", replace
	clear 
	
	//Network map 
	use "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT_TOAPPEND.dta", clear 
	drop if missing(COOPFIRMYEAR)
	drop if NUMBEROFPARTICIPANTSINALLIAN != 2
	gen vhelp = "Y" if LOWTAXFIRM == 1
	replace vhelp = "N" if LOWTAXFIRM == 0 
	drop if missing(vhelp)	//check
	gen vhelp2 = CUSIPNUM
	egen vhelp3 = concat(vhelp2 vhelp)
	rename vhelp3 CUSIPNEW
	rename vhelp LOWTAX
	drop vhelp*
	save "${pathSDCCOMPUSTAT}\INT.dta", replace 
	use "${pathSDCCOMPUSTAT}\INT.dta", clear 
	duplicates drop CUSIPNEW, force
	keep CUSIPNEW LOWTAX
	save "${path}\05_OTHER\SDC_COMPUSTAT_NETWORK_RAW2.dta", replace 
	use "${pathSDCCOMPUSTAT}\INT.dta", clear 
	sort DEALNUMBER CUSIPNEW YEAR 
	by DEALNUMBER: gen IDhelp = _n
	keep CUSIPNEW DEALNUMBER IDhelp
	reshape wide CUSIPNEW, i(DEALNUMBER) j(IDhelp)
	rename CUSIPNEW1 FROM
	rename CUSIPNEW2 TO
	drop DEALNUMBER
	save "${path}\05_OTHER\SDC_COMPUSTAT_NETWORK_RAW1.dta", replace
	clear
	erase "${pathSDCCOMPUSTAT}\INT.dta"
	
	//Distance
	use "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT_TOAPPEND.dta", clear 
	drop if missing(COOPFIRMYEAR)		//distances not collected for lowtolow connections
	export excel DATEEFFECTIVE DEALNUMBER ALLIANCEDEALNAME CUSIP6 YEAR NUMBEROFPARTICIPANTSINALLIAN conm add1 addzip using "${path}\05_OTHER\SDC_COMPUSTAT_DISTANCE_RAW.xlsx", firstrow(var) replace 
	clear
}
