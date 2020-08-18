clear
set more off 

****************************************************
*******   ONLINE SUPPLEMENT      *********
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

{	//Lists of Variables 
	global FIRMlist ebitda_at3 RnDExp3 AdExp3 SGA3 CapEx3 ChangeSale3 Leverage3 Cash3 i.MNE3 i.NOL3 Intangibles3 PPE3 size3
	global FIRMlistannual ebitda_at RnDExp AdExp SGA CapEx ChangeSale Leverage Cash i.MNE i.NOL Intangibles PPE size
	global FIRMlistnoebitda RnDExp3 AdExp3 SGA3 CapEx3 ChangeSale3 Leverage3 Cash3 i.MNE3 i.NOL3 Intangibles3 PPE3 size3
	global FIRMlistnosize ebitda_at3 RnDExp3 AdExp3 SGA3 CapEx3 ChangeSale3 Leverage3 Cash3 i.MNE3 i.NOL3 Intangibles3 PPE3 
	global FIRMlistchange ChangeSale3 ChangeNOL3 ChangePIFO3 ChangeEBITDA3 ChangeLeverage3 ChangeSize3 ChangeIntangibles3
	global PARTNERlistBEA i.PARTSAMEAUDITOR i.PARTSAMEBEAREGION 
	global PARTNERlist i.PARTSAMEAUDITOR c.PROXIMITY
	global NETWORKlist i.purpose_*
}

{	//Log-file Online Supplement
	use "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT.dta", clear  
	log using "${pathOUTPUT}\03_ONLINE_SUPPLEMENT\LOGFILE_`time_string'_ONLINE_SUPPLEMENT.smcl", replace nomsg
	*Table OS 1
	reghdfe CASH_ETR3 i.hightolow $PARTNERlist $FIRMlist $NETWORKlist, absorb(IND YEAR) vce(cluster CUSIPNUM)   
	reghdfe DELTA_CASH_ETR3 i.hightolow $PARTNERlist $FIRMlist $NETWORKlist, absorb(IND YEAR) vce(cluster CUSIPNUM)   
	
	*Table OS 2
	reghdfe CASH_ETR1 i.TREATED##i.POST, absorb(DIDYEAR) vce(robust) 
	
	*Table OS 3
	reghdfe CTD1 i.TREATED_EBAL##i.POST $FIRMlistannual [pweight = _webal], absorb(IND YEAR DIDYEAR) vce(cluster CUSIPNUM) 
	
	*Table OS 4
	reghdfe ChangeEBITDA3 i.hightolow $NETWORKlist $PARTNERlist $FIRMlistnoebitda, absorb(IND YEAR) vce(cluster CUSIPNUM) 

	log close
	translate "${pathOUTPUT}\03_ONLINE_SUPPLEMENT\LOGFILE_`time_string'_ONLINE_SUPPLEMENT.smcl" "${pathOUTPUT}\03_ONLINE_SUPPLEMENT\LOGFILE_`time_string'_ONLINE_SUPPLEMENT.pdf", fontsize(6)
}

{	//Figures Online Supplement
	
	{	//Figure Online Supplement 1 Identification Strategy
	*Panel A Industry-Year-Mean-PRECETR3
	use "${pathCOMPUSTAT}\COMPUSTAT.dta", clear
	drop if missing(indyearmean_PRE_CASH_ETR3)
	keep fyear IND indyearmean_PRE_CASH_ETR3
	sort IND fyear
	duplicates drop IND fyear, force
	separate indyearmean_PRE_CASH_ETR3, by(IND)
	rename indyearmean_PRE_CASH_ETR3 old
	*graph query, schemes
	*palette symbolpalette
	*graph query colorstyle
	set graphics off
		graph twoway scatter indyearmean_PRE_CASH_ETR3* fyear, msymbol(o d t s smplus x oh dh th sh a v) ///
		graphregion(fcolor(white)) legend(off) scheme(s2mono) ytitle("") xtitle("") xlabel(1996(1)2016, ang(v)) ///
		saving(INDYEARMEANETR.gph, replace) 
	clear
	*Panel B Industry-Year-Mean-Adjusted-PRECETR3
	use "${pathCOMPUSTAT}\COMPUSTAT.dta", clear
	keep fyear indyearadj_PRE_CASH_ETR3
	drop if missing(indyearadj_PRE_CASH_ETR3)
	sort fyear
	graph box indyearadj_PRE_CASH_ETR3, over(fyear, total  label(angle(90) ticks)) ///
		graphregion(fcolor(white)) legend(off) scheme(s2mono) ytitle("") ///
		saving(INDYEARMEANADJETR.gph, replace) 
	clear
	graph combine INDYEARMEANETR.gph INDYEARMEANADJETR.gph, rows(2) graphregion(fcolor(white)) ///
		title("Figure OS 1 Identification Strategy ", size(tiny)) ///
		l1title("industry-year-mean(-adjusted) pre cash ETR3", size(tiny)) ///
		note("Panel A (upper) depicts industry-year-means of pre cash ETR3." "Panel A legend: symbol = industry (as in Table I): circle = I, diamond = II, triangle = III, square = IV, small plus = V, x = VI, hollow circle = VII, hollow diamond = VIII, hollow triangle = IX, hollow square = X, arrow = XI, v = XII." "Panel B (lower) depcits the distribution (boxplot) of industry-year-mean-adjusted pre cash ETR3 over fiscal years and in total.", size(tiny))
	graph export "${pathOUTPUT}\03_ONLINE_SUPPLEMENT\FIG_OS_1_`time_string'_FIG_IDENTIFICATION_STRATEGY.pdf", as(pdf) replace
	set graphics on
	erase INDYEARMEANETR.gph
	erase INDYEARMEANADJETR.gph
	clear
	}

	{	//Figure Online Supplement 2 PARALLEL TRENDS
	use "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT.dta", clear 
	{ 	// CTD 
	*TREATMENT
	gen upperci1_ctd = . 
	gen lowerci1_ctd = . 
	gen mean1_ctd = .  
	sum CTD1 if DIDYEAR == -2 & TREATED == 1, d
	replace upperci1_ctd = r(p95) if DIDYEAR == -2 & TREATED == 1 & !missing(CTD1) 
	replace lowerci1_ctd = r(p5) if DIDYEAR== -2  & TREATED == 1 & !missing(CTD1) 
	replace mean1_ctd = r(mean) if DIDYEAR == -2  & TREATED == 1 & !missing(CTD1) 
	sum CTD1 if DIDYEAR == -1 & TREATED == 1, d
	replace upperci1_ctd = r(p95) if DIDYEAR == -1 & TREATED == 1 & !missing(CTD1) 
	replace lowerci1_ctd = r(p5) if DIDYEAR == -1  & TREATED == 1 & !missing(CTD1) 
	replace mean1_ctd = r(mean) if DIDYEAR == -1  & TREATED == 1 & !missing(CTD1) 
	sum CTD1 if DIDYEAR == 0 & TREATED == 1, d
	replace upperci1_ctd = r(p95) if DIDYEAR == 0 & TREATED == 1 & !missing(CTD1) 
	replace lowerci1_ctd = r(p5) if DIDYEAR == 0  & TREATED == 1 & !missing(CTD1) 
	replace mean1_ctd = r(mean) if DIDYEAR == 0  & TREATED == 1 & !missing(CTD1) 
	*Graph Part #1 
	gen vhelp = DIDYEAR
	replace vhelp = . if DIDYEAR >0 
	sort vhelp
	set graphics off
	twoway rarea upperci1_ctd lowerci1_ctd vhelp, color(gray*.2) || scatter mean1_ctd vhelp, mcolor(black) msymbol(T) xlabel(-2(1)0) ///
			graphregion(fcolor(white)) xtitle("pretreatment") legend(lab(1 "90% confidence interval") lab(2 "mean")) ///
			saving(TREATED_CTD.gph, replace) 
	set graphics on
	sort CUSIP6 YEAR
	*CONTROL 
	gen upperci0_ctd = . 
	gen lowerci0_ctd = . 
	gen mean0_ctd = .  
	sum CTD1 if DIDYEAR == -2 & TREATED == 0, d
	replace upperci0_ctd = r(p95) if DIDYEAR == -2 & TREATED == 0 & !missing(CTD1) 
	replace lowerci0_ctd = r(p5) if DIDYEAR == -2  & TREATED == 0 & !missing(CTD1)
	replace mean0_ctd = r(mean) if DIDYEAR == -2  & TREATED == 0 & !missing(CTD1) 
	sum CTD1 if DIDYEAR == -1 & TREATED == 0, d
	replace upperci0_ctd = r(p95) if DIDYEAR == -1 & TREATED == 0 & !missing(CTD1) 
	replace lowerci0_ctd = r(p5) if DIDYEAR == -1  & TREATED == 0 & !missing(CTD1) 
	replace mean0_ctd = r(mean) if DIDYEAR == -1  & TREATED == 0 & !missing(CTD1)
	sum CTD1 if DIDYEAR == 0 & TREATED == 0, d
	replace upperci0_ctd = r(p95) if DIDYEAR == 0 & TREATED == 0 & !missing(CTD1) 
	replace lowerci0_ctd = r(p5) if DIDYEAR == 0  & TREATED == 0 & !missing(CTD1)
	replace mean0_ctd = r(mean) if DIDYEAR == 0  & TREATED == 0 & !missing(CTD1)
	*Graph Part #2
	sort vhelp 
	set graphics off
	twoway rarea upperci0_ctd lowerci0_ctd vhelp, color(gray*.2) || scatter mean0_ctd vhelp, mcolor(black) msymbol(D) xlabel(-2(1)0) ///
			graphregion(fcolor(white)) xtitle("pretreatment") legend(lab(1 "90% confidence interval") lab(2 "mean")) /// 
			saving(CONTROL_CTD.gph, replace) 
	set graphics on	
	set graphics off
	graph combine TREATED_CTD.gph CONTROL_CTD.gph, col(2) graphregion(fcolor(white)) ycommon l1title("CTD") saving(CTD.gph)
	set graphics on	
	sort CUSIP6 YEAR
	drop vhelp*
	erase TREATED_CTD.gph
	erase CONTROL_CTD.gph
	}
	
	{ 	// TEXTUAL SENTIMENT 
	
	{ 	// SENTIMENT
	gen upperci1_sent = . 
	gen lowerci1_sent = . 
	gen mean1_sent = .  
	sum SENTIMENT if DIDYEAR == -2 & TREATED == 1, d
	replace upperci1_sent = r(p95) if DIDYEAR == -2 & TREATED == 1 & !missing(SENTIMENT)
	replace lowerci1_sent = r(p5) if DIDYEAR== -2  & TREATED == 1 & !missing(SENTIMENT)
	replace mean1_sent = r(mean) if DIDYEAR == -2  & TREATED == 1 & !missing(SENTIMENT)
	sum SENTIMENT if DIDYEAR == -1 & TREATED == 1, d
	replace upperci1_sent = r(p95) if DIDYEAR == -1 & TREATED == 1 & !missing(SENTIMENT)
	replace lowerci1_sent = r(p5) if DIDYEAR == -1  & TREATED == 1 & !missing(SENTIMENT)
	replace mean1_sent = r(mean) if DIDYEAR == -1  & TREATED == 1 & !missing(SENTIMENT)
	sum SENTIMENT if DIDYEAR == 0 & TREATED == 1, d
	replace upperci1_sent = r(p95) if DIDYEAR == 0 & TREATED == 1 & !missing(SENTIMENT)
	replace lowerci1_sent = r(p5) if DIDYEAR == 0  & TREATED == 1 & !missing(SENTIMENT)
	replace mean1_sent = r(mean) if DIDYEAR == 0  & TREATED == 1 & !missing(SENTIMENT)
	*Graph Part #1 
	gen vhelp = DIDYEAR
	replace vhelp = . if DIDYEAR >0 
	sort vhelp
	set graphics off
	twoway rarea upperci1_sent lowerci1_sent vhelp, color(gray*.2) || scatter mean1_sent vhelp, mcolor(black) msymbol(T) xlabel(-2(1)0) ///
			graphregion(fcolor(white)) xtitle("pretreatment") legend(lab(1 "90% confidence interval") lab(2 "mean")) ///
			saving(TREATED_SENT.gph, replace) 
	set graphics on
	sort CUSIP6 YEAR
	*CONTROL 
	gen upperci0_sent = . 
	gen lowerci0_sent = . 
	gen mean0_sent = .  
	sum SENTIMENT if DIDYEAR == -2 & TREATED == 0, d
	replace upperci0_sent = r(p95) if DIDYEAR == -2 & TREATED == 0 & !missing(SENTIMENT)
	replace lowerci0_sent = r(p5) if DIDYEAR == -2  & TREATED == 0 & !missing(SENTIMENT)
	replace mean0_sent = r(mean) if DIDYEAR == -2  & TREATED == 0 & !missing(SENTIMENT)
	sum SENTIMENT if DIDYEAR == -1 & TREATED == 0, d
	replace upperci0_sent = r(p95) if DIDYEAR == -1 & TREATED == 0 & !missing(SENTIMENT)
	replace lowerci0_sent = r(p5) if DIDYEAR == -1  & TREATED == 0 & !missing(SENTIMENT)
	replace mean0_sent = r(mean) if DIDYEAR == -1  & TREATED == 0 & !missing(SENTIMENT)
	sum SENTIMENT if DIDYEAR == 0 & TREATED == 0, d
	replace upperci0_sent = r(p95) if DIDYEAR == 0 & TREATED == 0 & !missing(SENTIMENT)
	replace lowerci0_sent = r(p5) if DIDYEAR == 0  & TREATED == 0 & !missing(SENTIMENT)
	replace mean0_sent = r(mean) if DIDYEAR == 0  & TREATED == 0 & !missing(SENTIMENT)
	*Graph Part #2
	sort vhelp 
	set graphics off
	twoway rarea upperci0_sent lowerci0_sent vhelp, color(gray*.2) || scatter mean0_sent vhelp, mcolor(black) msymbol(D) xlabel(-2(1)0) ///
			graphregion(fcolor(white)) xtitle("pretreatment") legend(lab(1 "90% confidence interval") lab(2 "mean")) /// 
			saving(CONTROL_SENT.gph, replace) 
	set graphics on	
	set graphics off
	graph combine TREATED_SENT.gph CONTROL_SENT.gph, col(2) graphregion(fcolor(white)) l1title("Sentiment") ycommon saving(Sentiment.gph)
	set graphics on	
	sort CUSIP6 YEAR
	drop vhelp*
	erase TREATED_SENT.gph
	erase CONTROL_SENT.gph
	} 
	
	{ // USE OF NEGATIVE WORDS
	gen upperci1_negwords = . 
	gen lowerci1_negwords = . 
	gen mean1_negwords = .  
	sum USE_OF_NEGATIVE_WORDS if DIDYEAR == -2 & TREATED == 1, d
	replace upperci1_negwords = r(p95) if DIDYEAR == -2 & TREATED == 1 & !missing(USE_OF_NEGATIVE_WORDS)
	replace lowerci1_negwords = r(p5) if DIDYEAR== -2  & TREATED == 1 & !missing(USE_OF_NEGATIVE_WORDS)
	replace mean1_negwords = r(mean) if DIDYEAR == -2  & TREATED == 1 & !missing(USE_OF_NEGATIVE_WORDS)
	sum USE_OF_NEGATIVE_WORDS if DIDYEAR == -1 & TREATED == 1, d
	replace upperci1_negwords = r(p95) if DIDYEAR == -1 & TREATED == 1 & !missing(USE_OF_NEGATIVE_WORDS)
	replace lowerci1_negwords = r(p5) if DIDYEAR == -1  & TREATED == 1 & !missing(USE_OF_NEGATIVE_WORDS)
	replace mean1_negwords = r(mean) if DIDYEAR == -1  & TREATED == 1 & !missing(USE_OF_NEGATIVE_WORDS)
	sum USE_OF_NEGATIVE_WORDS if DIDYEAR == 0 & TREATED == 1, d
	replace upperci1_negwords = r(p95) if DIDYEAR == 0 & TREATED == 1 & !missing(USE_OF_NEGATIVE_WORDS)
	replace lowerci1_negwords = r(p5) if DIDYEAR == 0  & TREATED == 1 & !missing(USE_OF_NEGATIVE_WORDS)
	replace mean1_negwords = r(mean) if DIDYEAR == 0  & TREATED == 1 & !missing(USE_OF_NEGATIVE_WORDS)
	*Graph Part #1 
	gen vhelp = DIDYEAR
	replace vhelp = . if DIDYEAR >0 
	sort vhelp
	set graphics off
	twoway rarea upperci1_negwords lowerci1_negwords vhelp, color(gray*.2) || scatter mean1_negwords vhelp, mcolor(black) msymbol(T) xlabel(-2(1)0) ///
			graphregion(fcolor(white)) xtitle("pretreatment") legend(lab(1 "90% confidence interval") lab(2 "mean")) ///
			saving(TREATED_NEGWORDS.gph, replace) 
	set graphics on
	sort CUSIP6 YEAR
	*CONTROL 
	gen upperci0_negwords = . 
	gen lowerci0_negwords = . 
	gen mean0_negwords = .  
	sum USE_OF_NEGATIVE_WORDS if DIDYEAR == -2 & TREATED == 0, d
	replace upperci0_negwords = r(p95) if DIDYEAR == -2 & TREATED == 0 & !missing(USE_OF_NEGATIVE_WORDS)
	replace lowerci0_negwords = r(p5) if DIDYEAR == -2  & TREATED == 0 & !missing(USE_OF_NEGATIVE_WORDS)
	replace mean0_negwords = r(mean) if DIDYEAR == -2  & TREATED == 0 & !missing(USE_OF_NEGATIVE_WORDS)
	sum USE_OF_NEGATIVE_WORDS if DIDYEAR == -1 & TREATED == 0, d
	replace upperci0_negwords = r(p95) if DIDYEAR == -1 & TREATED == 0 & !missing(USE_OF_NEGATIVE_WORDS)
	replace lowerci0_negwords = r(p5) if DIDYEAR == -1  & TREATED == 0 & !missing(USE_OF_NEGATIVE_WORDS)
	replace mean0_negwords = r(mean) if DIDYEAR == -1  & TREATED == 0 & !missing(USE_OF_NEGATIVE_WORDS)
	sum USE_OF_NEGATIVE_WORDS if DIDYEAR == 0 & TREATED == 0, d
	replace upperci0_negwords = r(p95) if DIDYEAR == 0 & TREATED == 0 & !missing(USE_OF_NEGATIVE_WORDS)
	replace lowerci0_negwords = r(p5) if DIDYEAR == 0  & TREATED == 0 & !missing(USE_OF_NEGATIVE_WORDS)
	replace mean0_negwords = r(mean) if DIDYEAR == 0  & TREATED == 0 & !missing(USE_OF_NEGATIVE_WORDS)
	*Graph Part #2
	sort vhelp 
	set graphics off
	twoway rarea upperci0_negwords lowerci0_negwords vhelp, color(gray*.2) || scatter mean0_negwords vhelp, mcolor(black) msymbol(D) xlabel(-2(1)0) ///
			graphregion(fcolor(white)) xtitle("pretreatment") legend(lab(1 "90% confidence interval") lab(2 "mean")) /// 
			saving(CONTROL_NEGWORDS.gph, replace) 
	set graphics on	
	set graphics off
	graph combine TREATED_NEGWORDS.gph CONTROL_NEGWORDS.gph, col(2) graphregion(fcolor(white)) ycommon l1title("Use of Negative Words") saving(NegativeWords.gph)
	set graphics on	
	sort CUSIP6 YEAR
	drop vhelp*
	erase TREATED_NEGWORDS.gph
	erase CONTROL_NEGWORDS.gph
	}
		
	}
	
	{	// EXHIBIT 21
	
	{	// USE OF TAX HAVEN
	*TREATMENT
	gen upperci1_taxhaven = . 
	gen lowerci1_taxhaven = . 
	gen mean1_taxhaven = .  
	sum USE_OF_TAXHAVEN if DIDYEAR == -2 & TREATED == 1, d
	replace upperci1_taxhaven = r(p95) if DIDYEAR == -2 & TREATED == 1 & !missing(USE_OF_TAXHAVEN) 
	replace lowerci1_taxhaven = r(p5) if DIDYEAR== -2  & TREATED == 1 & !missing(USE_OF_TAXHAVEN) 
	replace mean1_taxhaven = r(mean) if DIDYEAR == -2  & TREATED == 1 & !missing(USE_OF_TAXHAVEN) 
	sum USE_OF_TAXHAVEN if DIDYEAR == -1 & TREATED == 1, d
	replace upperci1_taxhaven = r(p95) if DIDYEAR == -1 & TREATED == 1 & !missing(USE_OF_TAXHAVEN) 
	replace lowerci1_taxhaven = r(p5) if DIDYEAR == -1  & TREATED == 1 & !missing(USE_OF_TAXHAVEN) 
	replace mean1_taxhaven = r(mean) if DIDYEAR == -1  & TREATED == 1 & !missing(USE_OF_TAXHAVEN) 
	sum USE_OF_TAXHAVEN if DIDYEAR == 0 & TREATED == 1, d
	replace upperci1_taxhaven = r(p95) if DIDYEAR == 0 & TREATED == 1 & !missing(USE_OF_TAXHAVEN) 
	replace lowerci1_taxhaven = r(p5) if DIDYEAR == 0  & TREATED == 1 & !missing(USE_OF_TAXHAVEN) 
	replace mean1_taxhaven = r(mean) if DIDYEAR == 0  & TREATED == 1 & !missing(USE_OF_TAXHAVEN) 
	*Graph Part #1 
	gen vhelp = DIDYEAR
	replace vhelp = . if DIDYEAR >0 
	sort vhelp
	set graphics off
	twoway rarea upperci1_taxhaven lowerci1_taxhaven vhelp, color(gray*.2) || scatter mean1_taxhaven vhelp, mcolor(black) msymbol(T) xlabel(-2(1)0) ///
			graphregion(fcolor(white)) xtitle("pretreatment") legend(lab(1 "90% confidence interval") lab(2 "mean")) ///
			saving(TREATED_TAXHAVEN.gph, replace) 
	set graphics on
	sort CUSIP6 YEAR
	*CONTROL 
	gen upperci0_taxhaven = . 
	gen lowerci0_taxhaven = . 
	gen mean0_taxhaven = .  
	sum USE_OF_TAXHAVEN if DIDYEAR == -2 & TREATED == 0, d
	replace upperci0_taxhaven = r(p95) if DIDYEAR == -2 & TREATED == 0 & !missing(USE_OF_TAXHAVEN) 
	replace lowerci0_taxhaven = r(p5) if DIDYEAR == -2  & TREATED == 0 & !missing(USE_OF_TAXHAVEN) 
	replace mean0_taxhaven = r(mean) if DIDYEAR == -2  & TREATED == 0 & !missing(USE_OF_TAXHAVEN) 
	sum USE_OF_TAXHAVEN if DIDYEAR == -1 & TREATED == 0, d
	replace upperci0_taxhaven = r(p95) if DIDYEAR == -1 & TREATED == 0 & !missing(USE_OF_TAXHAVEN) 
	replace lowerci0_taxhaven = r(p5) if DIDYEAR == -1  & TREATED == 0 & !missing(USE_OF_TAXHAVEN) 
	replace mean0_taxhaven = r(mean) if DIDYEAR == -1  & TREATED == 0 & !missing(USE_OF_TAXHAVEN) 
	sum USE_OF_TAXHAVEN if DIDYEAR == 0 & TREATED == 0, d
	replace upperci0_taxhaven = r(p95) if DIDYEAR == 0 & TREATED == 0 & !missing(USE_OF_TAXHAVEN) 
	replace lowerci0_taxhaven = r(p5) if DIDYEAR == 0  & TREATED == 0 & !missing(USE_OF_TAXHAVEN) 
	replace mean0_taxhaven = r(mean) if DIDYEAR == 0  & TREATED == 0 & !missing(USE_OF_TAXHAVEN) 
	*Graph Part #2
	sort vhelp 
	set graphics off
	twoway rarea upperci0_taxhaven lowerci0_taxhaven vhelp, color(gray*.2) || scatter mean0_taxhaven vhelp, mcolor(black) msymbol(D) xlabel(-2(1)0) ///
			graphregion(fcolor(white)) xtitle("pretreatment") legend(lab(1 "90% confidence interval") lab(2 "mean")) /// 
			saving(CONTROL_TAXHAVEN.gph, replace) 
	set graphics on	
	set graphics off
	graph combine TREATED_TAXHAVEN.gph CONTROL_TAXHAVEN.gph, col(2) graphregion(fcolor(white)) l1title("Use of Tax Haven") ycommon saving(USEOFTAXHAVEN.gph)
	set graphics on	
	sort CUSIP6 YEAR
	drop vhelp*
	erase TREATED_TAXHAVEN.gph
	erase CONTROL_TAXHAVEN.gph
	}
	
	{	//NUMBER_OF_TAX HAVEN SUBSIDIARIES
	*TREATMENT
	gen upperci1_numtaxhaven = . 
	gen lowerci1_numtaxhaven = . 
	gen mean1_numtaxhaven = .  
	sum NUMBER_OF_TAXHAVENS if DIDYEAR == -2 & TREATED == 1, d
	replace upperci1_numtaxhaven = r(p95) if DIDYEAR == -2 & TREATED == 1 & !missing(NUMBER_OF_TAXHAVENS) 
	replace lowerci1_numtaxhaven = r(p5) if DIDYEAR== -2  & TREATED == 1 & !missing(NUMBER_OF_TAXHAVENS) 
	replace mean1_numtaxhaven = r(mean) if DIDYEAR == -2  & TREATED == 1 & !missing(NUMBER_OF_TAXHAVENS) 
	sum NUMBER_OF_TAXHAVENS if DIDYEAR == -1 & TREATED == 1, d
	replace upperci1_numtaxhaven = r(p95) if DIDYEAR == -1 & TREATED == 1 & !missing(NUMBER_OF_TAXHAVENS) 
	replace lowerci1_numtaxhaven = r(p5) if DIDYEAR == -1  & TREATED == 1 & !missing(NUMBER_OF_TAXHAVENS) 
	replace mean1_numtaxhaven = r(mean) if DIDYEAR == -1  & TREATED == 1 & !missing(NUMBER_OF_TAXHAVENS) 
	sum NUMBER_OF_TAXHAVENS if DIDYEAR == 0 & TREATED == 1, d
	replace upperci1_numtaxhaven = r(p95) if DIDYEAR == 0 & TREATED == 1 & !missing(NUMBER_OF_TAXHAVENS) 
	replace lowerci1_numtaxhaven = r(p5) if DIDYEAR == 0  & TREATED == 1 & !missing(NUMBER_OF_TAXHAVENS) 
	replace mean1_numtaxhaven = r(mean) if DIDYEAR == 0  & TREATED == 1 & !missing(NUMBER_OF_TAXHAVENS) 
	*Graph Part #1 
	gen vhelp = DIDYEAR
	replace vhelp = . if DIDYEAR >0 
	sort vhelp
	set graphics off
	twoway rarea upperci1_numtaxhaven lowerci1_numtaxhaven vhelp, color(gray*.2) || scatter mean1_numtaxhaven vhelp, mcolor(black) msymbol(T) xlabel(-2(1)0) ///
			graphregion(fcolor(white)) xtitle("pretreatment") legend(lab(1 "90% confidence interval") lab(2 "mean")) ///
			saving(TREATED_NUMTAXHAVEN.gph, replace) 
	set graphics on
	sort CUSIP6 YEAR
	*CONTROL 
	gen upperci0_numtaxhaven = . 
	gen lowerci0_numtaxhaven = . 
	gen mean0_numtaxhaven = .  
	sum NUMBER_OF_TAXHAVENS if DIDYEAR == -2 & TREATED == 0, d
	replace upperci0_numtaxhaven = r(p95) if DIDYEAR == -2 & TREATED == 0 & !missing(NUMBER_OF_TAXHAVENS) 
	replace lowerci0_numtaxhaven = r(p5) if DIDYEAR == -2  & TREATED == 0 & !missing(NUMBER_OF_TAXHAVENS) 
	replace mean0_numtaxhaven = r(mean) if DIDYEAR == -2  & TREATED == 0 & !missing(NUMBER_OF_TAXHAVENS) 
	sum NUMBER_OF_TAXHAVENS if DIDYEAR == -1 & TREATED == 0, d
	replace upperci0_numtaxhaven = r(p95) if DIDYEAR == -1 & TREATED == 0 & !missing(NUMBER_OF_TAXHAVENS) 
	replace lowerci0_numtaxhaven = r(p5) if DIDYEAR == -1  & TREATED == 0 & !missing(NUMBER_OF_TAXHAVENS) 
	replace mean0_numtaxhaven = r(mean) if DIDYEAR == -1  & TREATED == 0 & !missing(NUMBER_OF_TAXHAVENS) 
	sum NUMBER_OF_TAXHAVENS if DIDYEAR == 0 & TREATED == 0, d
	replace upperci0_numtaxhaven = r(p95) if DIDYEAR == 0 & TREATED == 0 & !missing(NUMBER_OF_TAXHAVENS) 
	replace lowerci0_numtaxhaven = r(p5) if DIDYEAR == 0  & TREATED == 0 & !missing(NUMBER_OF_TAXHAVENS) 
	replace mean0_numtaxhaven = r(mean) if DIDYEAR == 0  & TREATED == 0 & !missing(NUMBER_OF_TAXHAVENS) 
	*Graph Part #2
	sort vhelp 
	set graphics off
	twoway rarea upperci0_numtaxhaven lowerci0_numtaxhaven vhelp, color(gray*.2) || scatter mean0_numtaxhaven vhelp, mcolor(black) msymbol(D) xlabel(-2(1)0) ///
			graphregion(fcolor(white)) xtitle("pretreatment") legend(lab(1 "90% confidence interval") lab(2 "mean"))  /// 
			saving(CONTROL_NUMTAXHAVEN.gph, replace) 
	graph combine TREATED_NUMTAXHAVEN.gph CONTROL_NUMTAXHAVEN.gph, col(2) graphregion(fcolor(white)) ycommon l1title("Num of Tax Haven Subsidiaries") saving(NUMTAXHAVEN.gph)
	sort CUSIP6 YEAR
	drop vhelp*
	erase TREATED_NUMTAXHAVEN.gph
	erase CONTROL_NUMTAXHAVEN.gph
	}
	
}

	//Panels
	set graphics off
	graph combine CTD.gph, rows(1) graphregion(fcolor(white)) subtitle("Figure OS 2 Panel A Parallel Trend CTD") 
	graph export "${pathOUTPUT}\03_ONLINE_SUPPLEMENT\FIG_0S_2_A_`time_string'_FIG_PARALLEL_TREND_CTD.pdf", as(pdf) replace
	graph combine Sentiment.gph NegativeWords.gph, rows(2) graphregion(fcolor(white)) subtitle("Figure OS 2 Panel B Parallel Trend Textual Sentiment of 10-K Filings") 
	graph export "${pathOUTPUT}\03_ONLINE_SUPPLEMENT\FIG_0S_2_B_`time_string'_FIG_PARALLEL_TREND_SENTIMENT.pdf", as(pdf) replace
	graph combine USEOFTAXHAVEN.gph NUMTAXHAVEN.gph, rows(2) graphregion(fcolor(white)) subtitle("Figure OS 2 Panel C Parallel Trend Tax Haven Operations") 
	graph export "${pathOUTPUT}\03_ONLINE_SUPPLEMENT\FIG_0S_2_C_`time_string'_FIG_PARALLEL_TREND_TAXHAVEN.pdf", as(pdf) replace
	*set graphics on
	erase CTD.gph
	erase Sentiment.gph
	erase NegativeWords.gph
	erase USEOFTAXHAVEN.gph
	erase NUMTAXHAVEN.gph

}

}


{	//Tables Online Supplement
		
	{	//Table Online Supplement 1
		
		{	//Table Online Supplement 1 Specification 1
		use "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT.dta", clear 
			*CASH_ETR3 Full Controls
			reghdfe CASH_ETR3 i.hightolow $PARTNERlist $FIRMlist $NETWORKlist, absorb(IND YEAR) vce(cluster CUSIPNUM)   
			qui putexcel set "${pathOUTPUT}\03_ONLINE_SUPPLEMENT\TAB_OS_`time_string'_TABLES_ONLINE_SUPPLEMENT.xlsx", sheet(OS_T1_RegAnalysis) modify
			qui putexcel A5 = "Regression Analysis", bold
			qui putexcel A5:H5, merge overwritefmt
			qui putexcel A5:H5, border(bottom) overwritefmt
			qui putexcel A6 = "Dependent Variable"
			qui putexcel B6:D6, merge overwritefmt
			qui putexcel B6 = "cash ETR3 [t1; t3]"
			qui putexcel F6:H6, merge overwritefmt
			qui putexcel F6 = "delta cash ETR3"
			qui putexcel B7:C7, merge overwritefmt
			qui putexcel B7 = "Coefficient" 
			qui putexcel D7 = "(p-value)"
			qui putexcel F7:G7, merge overwritefmt
			qui putexcel F7 = "Coefficient" 
			qui putexcel H7 = "(p-value)"
			qui putexcel A7:H7, border(bottom) overwritefmt
			qui putexcel A8:A9, merge 
			qui putexcel B8:B9, merge 
			qui putexcel C8:C9, merge 
			qui putexcel D8:D9, merge 
			qui putexcel E8:E9, merge 
			qui putexcel F8:F9, merge 
			qui putexcel G8:G9, merge 
			qui putexcel H8:H9, merge 
			local row = 8
			qui putexcel A`row' = "hightolow"
			display _b[1.hightolow]
			local coef = _b[1.hightolow]
			qui putexcel B`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[1.hightolow] / _se[1.hightolow]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
			display `pval'
			qui putexcel D`row' = `pval' 
			qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 10
			qui putexcel A`row' = "Proximity"
			display _b[PROXIMITY]
			local coef = _b[PROXIMITY]
			qui putexcel B`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[PROXIMITY] / _se[PROXIMITY]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
			display `pval'
			qui putexcel D`row' = `pval' 
			qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 11
			qui putexcel A`row' = "SameAuditor"
			display _b[1.PARTSAMEAUDITOR]
			local coef = _b[1.PARTSAMEAUDITOR]
			qui putexcel B`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[1.PARTSAMEAUDITOR] / _se[1.PARTSAMEAUDITOR]) ) )
			display `pval'
			qui putexcel D`row' = `pval' 
			qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 12
			qui putexcel A`row' = "EBITDA3"
			display _b[ebitda_at3]
			local coef = _b[ebitda_at3]
			qui putexcel B`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[ebitda_at3] / _se[ebitda_at3]) ) )
			display `pval'
			qui putexcel D`row' = `pval' 
			qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 13
			qui putexcel A`row' = "RnDExp3"
			display _b[RnDExp3]
			local coef = _b[RnDExp3]
			qui putexcel B`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[RnDExp3] / _se[RnDExp3]) ) )
			display `pval'
			qui putexcel D`row' = `pval' 
			qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 14
			qui putexcel A`row' = "AdExp3"
			display _b[AdExp3]
			local coef = _b[AdExp3]
			qui putexcel B`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[AdExp3] / _se[AdExp3]) ) )
			display `pval'
			qui putexcel D`row' = `pval' 
			qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 15
			qui putexcel A`row' = "SGA3"
			display _b[SGA3]
			local coef = _b[SGA3]
			qui putexcel B`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[SGA3] / _se[SGA3]) ) )
			display `pval'
			qui putexcel D`row' = `pval' 
			qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 16
			qui putexcel A`row' = "CapEx3"
			display _b[CapEx3]
			local coef = _b[CapEx3]
			qui putexcel B`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[CapEx3] / _se[CapEx3]) ) )
			display `pval'
			qui putexcel D`row' = `pval' 
			qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 17
			qui putexcel A`row' = "ChangeSale3"
			display _b[ChangeSale3]
			local coef = _b[ChangeSale3]
			qui putexcel B`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[ChangeSale3] / _se[ChangeSale3]) ) )
			display `pval'
			qui putexcel D`row' = `pval' 
			qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 18
			qui putexcel A`row' = "Leverage3"
			display _b[Leverage3]
			local coef = _b[Leverage3]
			qui putexcel B`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[Leverage3] / _se[Leverage3]) ) )
			display `pval'
			qui putexcel D`row' = `pval' 
			qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 19
			qui putexcel A`row' = "Cash3"
			display _b[Cash3]
			local coef = _b[Cash3]
			qui putexcel B`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[Cash3] / _se[Cash3]) ) )
			display `pval'
			qui putexcel D`row' = `pval' 
			qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 20
			qui putexcel A`row' = "MNE3"
			display _b[1.MNE3]
			local coef = _b[1.MNE3]
			qui putexcel B`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[1.MNE3] / _se[1.MNE3]) ) )
			display `pval'
			qui putexcel D`row' = `pval' 
			qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 21
			qui putexcel A`row' = "NOL3"
			display _b[1.NOL3]
			local coef = _b[1.NOL3]
			qui putexcel B`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[1.NOL3] / _se[1.NOL3]) ) )
			display `pval'
			qui putexcel D`row' = `pval' 
			qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 22
			qui putexcel A`row' = "Intangibles3"
			display _b[Intangibles3]
			local coef = _b[Intangibles3]
			qui putexcel B`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[Intangibles3] / _se[Intangibles3]) ) )
			display `pval'
			qui putexcel D`row' = `pval' 
			qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 23
			qui putexcel A`row' = "PPE3"
			display _b[PPE3]
			local coef = _b[PPE3]
			qui putexcel B`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[PPE3] / _se[PPE3]) ) )
			display `pval'
			qui putexcel D`row' = `pval' 
			qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 24
			qui putexcel A`row' = "Size3"
			display _b[size3]
			local coef = _b[size3]
			qui putexcel B`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[size3] / _se[size3]) ) )
			display `pval'
			qui putexcel D`row' = `pval' 
			qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 25
			qui putexcel A`row' = "PurposeWholesale"
			display _b[1.purpose_wholesale]
			local coef = _b[1.purpose_wholesale]
			qui putexcel B`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[1.purpose_wholesale] / _se[1.purpose_wholesale]) ) )
			display `pval'
			qui putexcel D`row' = `pval' 
			qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 26
			qui putexcel A`row' = "PurposeR&D"
			display _b[1.purpose_develop]
			local coef = _b[1.purpose_develop]
			qui putexcel B`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[1.purpose_develop] / _se[1.purpose_develop]) ) )
			display `pval'
			qui putexcel D`row' = `pval' 
			qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 27
			qui putexcel A`row' = "PurposeLicensing"
			display _b[1.purpose_license]
			local coef = _b[1.purpose_license]
			qui putexcel B`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[1.purpose_license] / _se[1.purpose_license]) ) )
			display `pval'
			qui putexcel D`row' = `pval' 
			qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 28
			qui putexcel A`row' = "PurposeService"
			display _b[1.purpose_service]
			local coef = _b[1.purpose_service]
			qui putexcel B`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[1.purpose_service] / _se[1.purpose_service]) ) )
			display `pval'
			qui putexcel D`row' = `pval' 
			qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 29
			qui putexcel A`row' = "PurposeMarketing"
			display _b[1.purpose_marketing]
			local coef = _b[1.purpose_marketing]
			qui putexcel B`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[1.purpose_marketing] / _se[1.purpose_marketing]) ) )
			display `pval'
			qui putexcel D`row' = `pval' 
			qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 30
			qui putexcel A`row' = "PurposeSupply"
			display _b[1.purpose_supply]
			local coef = _b[1.purpose_supply]
			qui putexcel B`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[1.purpose_supply] / _se[1.purpose_supply]) ) )
			display `pval'
			qui putexcel D`row' = `pval' 
			qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 31
			qui putexcel A`row' = "PurposeManufacturing"
			display _b[1.purpose_manufacture]
			local coef = _b[1.purpose_manufacture]
			qui putexcel B`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[1.purpose_manufacture] / _se[1.purpose_manufacture]) ) )
			display `pval'
			qui putexcel D`row' = `pval' 
			qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 32
			qui putexcel A`row' = "Intercept"
			display _b[_cons]
			local coef = _b[_cons]
			qui putexcel B`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[_cons] / _se[_cons]) ) )
			display `pval'
			qui putexcel D`row' = `pval' 
			qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			*Format			
			qui putexcel A`row':H`row', border(bottom) overwritefmt
			qui putexcel A33 = "Firm Controls"
			qui putexcel A34 = "Fixed Effects"
			qui putexcel A35 = "SE"
			qui putexcel A36 = "N"
			qui putexcel A37 = "Adjusted R2"
			qui putexcel B33:D33, merge overwritefmt
			qui putexcel B33 = "Yes"
			qui putexcel F33:H33, merge overwritefmt
			qui putexcel F33 = "Yes"
			qui putexcel B34:D34, merge overwritefmt
			qui putexcel B34 = "Industry & Year"
			qui putexcel F34:H34, merge overwritefmt
			qui putexcel F34 = "Industry & Year"
			qui putexcel B35:D35, merge overwritefmt
			qui putexcel B35 = "Cluster @ Firm"
			qui putexcel F35:H35, merge overwritefmt
			qui putexcel F35 = "Cluster @ Firm"
			qui putexcel B36:D36, merge overwritefmt
			qui putexcel B36 = `e(N)'
			qui putexcel B37:D37, merge overwritefmt
			qui putexcel B37 = `e(r2_a)'
			qui putexcel A32:H32, border(bottom) overwritefmt
			}
			
		{	//Table Online Supplement 1 Specification 2
			*DELTA_CASH_ETR3
			reghdfe DELTA_CASH_ETR3 i.hightolow $PARTNERlist $FIRMlist $NETWORKlist, absorb(IND YEAR) vce(cluster CUSIPNUM)   
			display _b[1.hightolow]
			local coef = _b[1.hightolow]
			local row = 8
			qui putexcel F`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[1.hightolow] / _se[1.hightolow]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
			display `pval'
			qui putexcel H`row' = `pval' 
			qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 10
			display _b[PROXIMITY]
			local coef = _b[PROXIMITY]
			qui putexcel F`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[PROXIMITY] / _se[PROXIMITY]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
			display `pval'
			qui putexcel H`row' = `pval' 
			qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 11
			display _b[1.PARTSAMEAUDITOR]
			local coef = _b[1.PARTSAMEAUDITOR]
			qui putexcel F`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[1.PARTSAMEAUDITOR] / _se[1.PARTSAMEAUDITOR]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
			display `pval'
			qui putexcel H`row' = `pval' 
			qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 12
			display _b[ebitda_at3]
			local coef = _b[ebitda_at3]
			qui putexcel F`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[ebitda_at3] / _se[ebitda_at3]) ) )
			display `pval'
			qui putexcel H`row' = `pval' 
			qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 13
			display _b[RnDExp3]
			local coef = _b[RnDExp3]
			qui putexcel F`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[RnDExp3] / _se[RnDExp3]) ) )
			display `pval'
			qui putexcel H`row' = `pval' 
			qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 14
			display _b[AdExp3]
			local coef = _b[AdExp3]
			qui putexcel F`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[AdExp3] / _se[AdExp3]) ) )
			display `pval'
			qui putexcel H`row' = `pval' 
			qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 15
			display _b[SGA3]
			local coef = _b[SGA3]
			qui putexcel F`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[SGA3] / _se[SGA3]) ) )
			display `pval'
			qui putexcel H`row' = `pval' 
			qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 16
			display _b[CapEx3]
			local coef = _b[CapEx3]
			qui putexcel F`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[CapEx3] / _se[CapEx3]) ) )
			display `pval'
			qui putexcel H`row' = `pval' 
			qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 17
			display _b[ChangeSale3]
			local coef = _b[ChangeSale3]
			qui putexcel F`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[ChangeSale3] / _se[ChangeSale3]) ) )
			display `pval'
			qui putexcel H`row' = `pval' 
			qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 18
			display _b[Leverage3]
			local coef = _b[Leverage3]
			qui putexcel F`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[Leverage3] / _se[Leverage3]) ) )
			display `pval'
			qui putexcel H`row' = `pval' 
			qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 19
			display _b[Cash3]
			local coef = _b[Cash3]
			qui putexcel F`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[Cash3] / _se[Cash3]) ) )
			display `pval'
			qui putexcel H`row' = `pval' 
			qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 20
			display _b[1.MNE3]
			local coef = _b[1.MNE3]
			qui putexcel F`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[1.MNE3] / _se[1.MNE3]) ) )
			display `pval'
			qui putexcel H`row' = `pval' 
			qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 21
			display _b[1.NOL3]
			local coef = _b[1.NOL3]
			qui putexcel F`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[1.NOL3] / _se[1.NOL3]) ) )
			display `pval'
			qui putexcel H`row' = `pval' 
			qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 22
			display _b[Intangibles3]
			local coef = _b[Intangibles3]
			qui putexcel F`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[Intangibles3] / _se[Intangibles3]) ) )
			display `pval'
			qui putexcel H`row' = `pval' 
			qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 23
			display _b[PPE3]
			local coef = _b[PPE3]
			qui putexcel F`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[PPE3] / _se[PPE3]) ) )
			display `pval'
			qui putexcel H`row' = `pval' 
			qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 24
			display _b[size3]
			local coef = _b[size3]
			qui putexcel F`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[size3] / _se[size3]) ) )
			display `pval'
			qui putexcel H`row' = `pval' 
			qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 25
			display _b[1.purpose_wholesale]
			local coef = _b[1.purpose_wholesale]
			qui putexcel F`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[1.purpose_wholesale] / _se[1.purpose_wholesale]) ) )
			display `pval'
			qui putexcel H`row' = `pval' 
			qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 26
			display _b[1.purpose_develop]
			local coef = _b[1.purpose_develop]
			qui putexcel F`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[1.purpose_develop] / _se[1.purpose_develop]) ) )
			display `pval'
			qui putexcel H`row' = `pval' 
			qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 27
			display _b[1.purpose_license]
			local coef = _b[1.purpose_license]
			qui putexcel F`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[1.purpose_license] / _se[1.purpose_license]) ) )
			display `pval'
			qui putexcel H`row' = `pval' 
			qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 28
			display _b[1.purpose_service]
			local coef = _b[1.purpose_service]
			qui putexcel F`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[1.purpose_service] / _se[1.purpose_service]) ) )
			display `pval'
			qui putexcel H`row' = `pval' 
			qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 29
			display _b[1.purpose_marketing]
			local coef = _b[1.purpose_marketing]
			qui putexcel F`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[1.purpose_marketing] / _se[1.purpose_marketing]) ) )
			display `pval'
			qui putexcel H`row' = `pval' 
			qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 30
			display _b[1.purpose_supply]
			local coef = _b[1.purpose_supply]
			qui putexcel F`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[1.purpose_supply] / _se[1.purpose_supply]) ) )
			display `pval'
			qui putexcel H`row' = `pval' 
			qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 31
			display _b[1.purpose_manufacture]
			local coef = _b[1.purpose_manufacture]
			qui putexcel F`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[1.purpose_manufacture] / _se[1.purpose_manufacture]) ) )
			display `pval'
			qui putexcel H`row' = `pval' 
			qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			local row = 32
			display _b[_cons]
			local coef = _b[_cons]
			qui putexcel F`row' = `coef'
			local pval = (2 * ttail(e(df_r), abs(_b[_cons] / _se[_cons]) ) )
			display `pval'
			qui putexcel H`row' = `pval' 
			qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			qui putexcel F36:H36, merge overwritefmt
			qui putexcel F36 = `e(N)'
			qui putexcel F37:H37, merge overwritefmt
			qui putexcel F37 = `e(r2_a)'
			qui putexcel A37:H37, border(bottom) overwritefmt
			*Format
			qui putexcel A3:H3, merge overwritefmt
			qui putexcel A3 = "Table OS 1", bold 
			qui putexcel A3, hcenter
			qui putexcel B6:H7 B33:H37, hcenter 
			qui putexcel B8:B32 F8:F32, nformat(# 0.0000) right
			qui putexcel B37 F37, nformat(# 0.0000) hcenter
			qui putexcel D8:D32 H8:H32, nformat(# (0.0000)) hcenter 
			qui putexcel A8:H9 A5 B6:H6, bold
			qui putexcel A1:H37, font("Times New Roman", 11) 
			qui putexcel A1:H37, vcenter
			clear
			}

}

	{	//Table Online Supplement 2
		use "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT.dta", clear 
		*DiD no Controls
		reghdfe CASH_ETR1 i.TREATED##i.POST, absorb(DIDYEAR) vce(robust) 
		qui putexcel set "${pathOUTPUT}\03_ONLINE_SUPPLEMENT\TAB_OS_`time_string'_TABLES_ONLINE_SUPPLEMENT.xlsx", sheet(OS_T2_DiDNoControls) modify
		qui putexcel A5:D5, merge overwritefmt
		qui putexcel A5:D5, border(bottom) overwritefmt
		qui putexcel A5 = "Difference in Differences without Control Variables", bold
		qui putexcel A6 = "Dependent Variable"
		qui putexcel A7 = "Embargo Period"
		qui putexcel A8 = "Entropy Balancing"
		qui putexcel B6:D6, merge overwritefmt
		qui putexcel B6 = "cash ETR"
		qui putexcel B7:D7, merge overwritefmt
		qui putexcel B7 = "Yes [t-2; t5]"
		qui putexcel B8:D8, merge overwritefmt
		qui putexcel B8 = "Balanced Sample"
		qui putexcel B9:C9, merge
		qui putexcel B9 = "Coefficient" 
		qui putexcel D9 = "(p-value)"
		qui putexcel A9:D9, border(bottom) overwritefmt
		qui putexcel A10:A11, merge 
		qui putexcel B10:B11, merge 
		qui putexcel C10:C11, merge 
		qui putexcel D10:D11, merge 
		qui putexcel A12:A13, merge 
		qui putexcel B12:B13, merge 
		qui putexcel C12:C13, merge 
		qui putexcel D12:D13, merge 
		local row = 10
		qui putexcel A`row' = "treated"
		display _b[1.TREATED]
		local coef = _b[1.TREATED]
		qui putexcel B`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[1.TREATED] / _se[1.TREATED]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel D`row' = `pval' 
		qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 12
		qui putexcel A`row' = "treated*post"
		display _b[1.TREATED#1.POST]
		local coef = _b[1.TREATED#1.POST]
		qui putexcel B`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[1.TREATED#1.POST] / _se[1.TREATED#1.POST]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel D`row' = `pval' 
		qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		qui putexcel A13:D13, border(bottom) 
		qui putexcel A14 = "Firm Controls"
		qui putexcel A15 = "Fixed Effects"
		qui putexcel A16 = "SE"
		qui putexcel A17 = "N"
		qui putexcel A18 = "Adjusted R2"
		qui putexcel B14:D14, merge overwritefmt
		qui putexcel B14 = "No"
		qui putexcel B15:D15, merge overwritefmt
		qui putexcel B15 = "Embargo Period"
		qui putexcel B16:D16, merge overwritefmt
		qui putexcel B16 = "Robust"
		qui putexcel B17:D17, merge overwritefmt
		qui putexcel B17 = `e(N)'
		qui putexcel B18:D18, merge overwritefmt
		qui putexcel B18 = `e(r2_a)'
		qui putexcel A18:D18, border(bottom)
		*Format
		qui putexcel A3:D3, merge overwritefmt
		qui putexcel A3 = "Table OS 2", bold 
		qui putexcel A3, hcenter
		qui putexcel B6:D9, hcenter 
		qui putexcel B14:D17, hcenter 
		qui putexcel B10:B13, nformat(# 0.0000) right
		qui putexcel B18, nformat(# 0.0000) hcenter
		qui putexcel D10:D13, nformat(# (0.0000)) hcenter 
		qui putexcel A12:D13 B6:D6, bold 
		qui putexcel A1:D18, font("Times New Roman", 11) 
		qui putexcel A1:D18, vcenter
		clear
		}

	{	//Table Online Supplement 3
		use "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT.dta", clear 
		*Alternative Tax Knowledge Measrue
		reghdfe CTD1 i.TREATED_EBAL##i.POST $FIRMlistannual [pweight = _webal], absorb(IND YEAR DIDYEAR) vce(cluster CUSIPNUM) 
		qui putexcel set "${pathOUTPUT}\03_ONLINE_SUPPLEMENT\TAB_OS_`time_string'_TABLES_ONLINE_SUPPLEMENT.xlsx", sheet(OS_T3_AltTaxKnowledge) modify
		qui putexcel A5:D5, merge overwritefmt
		qui putexcel A5:D5, border(bottom) overwritefmt
		qui putexcel A5 = "Henry/Sansing Cash Tax Differential (CTD)", bold
		qui putexcel A6 = "Dependent Variable"
		qui putexcel A7 = "Embargo Period"
		qui putexcel A8 = "Entropy Balancing"
		qui putexcel B6:D6, merge overwritefmt
		qui putexcel B6 = "CTD"
		qui putexcel B7:D7, merge overwritefmt
		qui putexcel B7 = "Yes [t-2; t5]"
		qui putexcel B8:D8, merge overwritefmt
		qui putexcel B8 = "Balanced Sample"
		qui putexcel B9:C9, merge
		qui putexcel B9 = "Coefficient" 
		qui putexcel D9 = "(p-value)"
		qui putexcel A9:D9, border(bottom) overwritefmt
		qui putexcel A10:A11, merge 
		qui putexcel B10:B11, merge 
		qui putexcel C10:C11, merge 
		qui putexcel D10:D11, merge 
		qui putexcel A12:A13, merge 
		qui putexcel B12:B13, merge 
		qui putexcel C12:C13, merge 
		qui putexcel D12:D13, merge 
		local row = 10
		qui putexcel A`row' = "treated"
		display _b[1.TREATED_EBAL]
		local coef = _b[1.TREATED_EBAL]
		qui putexcel B`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[1.TREATED_EBAL] / _se[1.TREATED_EBAL]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel D`row' = `pval' 
		qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 12
		qui putexcel A`row' = "treated*post"
		display _b[1.TREATED_EBAL#1.POST]
		local coef = _b[1.TREATED_EBAL#1.POST]
		qui putexcel B`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[1.TREATED_EBAL#1.POST] / _se[1.TREATED_EBAL#1.POST]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel D`row' = `pval' 
		qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		qui putexcel A13:D13, border(bottom) 
		qui putexcel A14 = "Firm Controls"
		qui putexcel A15 = "Fixed Effects"
		qui putexcel A16 = "SE"
		qui putexcel A17 = "N"
		qui putexcel A18 = "Adjusted R2"
		qui putexcel B14:D14, merge overwritefmt
		qui putexcel B14 = "Yes (Annual Measures)"
		qui putexcel B15:D15, merge overwritefmt
		qui putexcel B15 = "Industry & Year & Embargo Period"
		qui putexcel B16:D16, merge overwritefmt
		qui putexcel B16 = "Cluster @ Firm"
		qui putexcel B17:D17, merge overwritefmt
		qui putexcel B17 = `e(N)'
		qui putexcel B18:D18, merge overwritefmt
		qui putexcel B18 = `e(r2_a)'
		qui putexcel A18:D18, border(bottom)
		*Format
		qui putexcel A3:D3, merge overwritefmt
		qui putexcel A3 = "Table OS 3", bold 
		qui putexcel A3, hcenter
		qui putexcel B6:D9, hcenter 
		qui putexcel B14:D17, hcenter 
		qui putexcel B10:B13, nformat(# 0.0000) right
		qui putexcel B18, nformat(# 0.0000) hcenter
		qui putexcel D10:D13, nformat(# (0.0000)) hcenter 
		qui putexcel A12:D13 B6:D6, bold 
		qui putexcel A1:D18, font("Times New Roman", 11) 
		qui putexcel A1:D18, vcenter
		clear
		}

	{	//Table Online Supplement 4 
		use "${pathSDCCOMPUSTAT}\SDC_COMPUSTAT.dta", clear 
		*Effect on Profitability 
		reghdfe ChangeEBITDA3 i.hightolow $NETWORKlist $PARTNERlist $FIRMlistnoebitda, absorb(IND YEAR) vce(cluster CUSIPNUM) 
		qui putexcel set "${pathOUTPUT}\03_ONLINE_SUPPLEMENT\TAB_OS_`time_string'_TABLES_ONLINE_SUPPLEMENT.xlsx", sheet(OS_T4_EffectProfit) modify
		qui putexcel A5 = "Effect on Profitability", bold
		qui putexcel A5:D5, merge overwritefmt
		qui putexcel A5:D5, border(bottom) overwritefmt
		qui putexcel A6 = "Dependent Variable"
		qui putexcel B6:D6, merge overwritefmt
		qui putexcel B6 = "EBITDA3", bold
		qui putexcel A7 = "Specification"
		qui putexcel B7:D7, merge overwritefmt
		qui putexcel B7 = "annual average growth rate", 
		qui putexcel B8:C8, merge overwritefmt
		qui putexcel B8 = "Coefficient" 
		qui putexcel D8 = "(p-value)"
		qui putexcel A8:D8, border(bottom) overwritefmt
		qui putexcel A9:A10, merge 
		qui putexcel B9:B10, merge 
		qui putexcel C9:C10, merge 
		qui putexcel D9:D10, merge 
		local row = 9
		qui putexcel A`row' = "hightolow"
		display _b[1.hightolow]
		local coef = _b[1.hightolow]
		qui putexcel B`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[1.hightolow] / _se[1.hightolow]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel D`row' = `pval' 
		qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 11
		qui putexcel A`row' = "Proximity"
		display _b[PROXIMITY]
		local coef = _b[PROXIMITY]
		qui putexcel B`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[PROXIMITY] / _se[PROXIMITY]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel D`row' = `pval' 
		qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 12
		qui putexcel A`row' = "SameAuditor"
		display _b[1.PARTSAMEAUDITOR]
		local coef = _b[1.PARTSAMEAUDITOR]
		qui putexcel B`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[1.PARTSAMEAUDITOR] / _se[1.PARTSAMEAUDITOR]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel D`row' = `pval' 
		qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		qui putexcel A`row':D`row', border(bottom) overwritefmt
		qui putexcel A13 = "Network Controls"
		qui putexcel A14 = "Firm Controls"
		qui putexcel A15 = "Fixed Effects"
		qui putexcel A16 = "SE"
		qui putexcel A17 = "N"
		qui putexcel A18 = "Adjusted R2"
		qui putexcel B13:D13, merge overwritefmt
		qui putexcel B13 = "Yes"
		qui putexcel B14:D14, merge overwritefmt
		qui putexcel B14 = "Yes"
		qui putexcel B15:D15, merge overwritefmt
		qui putexcel B15 = "Industry & Year"
		qui putexcel B16:D16, merge overwritefmt
		qui putexcel B16 = "Cluster @ Firm"
		qui putexcel B17:D17, merge overwritefmt
		qui putexcel B17 = `e(N)'
		qui putexcel B18:D18, merge overwritefmt
		qui putexcel B18 = `e(r2_a)'
		qui putexcel A18:D18, border(bottom) overwritefmt
		*Format 
		qui putexcel A3:D3, merge overwritefmt
		qui putexcel A3 = "Table OS 4", bold hcenter 
		qui putexcel B6:D8, hcenter
		qui putexcel B13:B17, hcenter
		qui putexcel B9:B12, nformat(# 0.0000) right
		qui putexcel D9:D12, nformat(# (0.0000)) hcenter
		qui putexcel B18, nformat(# 0.0000) hcenter
		qui putexcel A5, bold 
		qui putexcel A9:D10, bold 
		qui putexcel A1:D18, font("Times New Roman", 11)
		qui putexcel A1:D18, vcenter 
		clear
	}
	
		
}

clear		
