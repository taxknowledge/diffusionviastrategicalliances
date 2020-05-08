clear
set more off 


****************************************************
*******   COMPUSTAT SDC CREATE OUTPUT      *********
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

{	//Figures
	
		{	//Figure 1 Cross-Firm Connections and Tax Knowledge
			*Created with Powerpoint
		}
	
		{	//Figure 2 Sample Selection 
			*Created with Powerpoint	
		}
		
		{	//Figure 3 Network Map
			*Created with R 
		}
		
		{	//Figure 4 Word Cloud
			*Created with R 
		}
			
		{	//Figure 5 Parallel Trend (DiD)
		
			{	//Visual 
			*TREATED
			gen upperci1 = . 
			gen lowerci1 = . 
			gen mean1 = .  
			sum CASH_ETR1 if DIDYEAR == -2 & TREATED == 1, d
			replace upperci1 = r(p90) if DIDYEAR == -2 & TREATED == 1 & !missing(CASH_ETR1)
			replace lowerci1 = r(p10) if DIDYEAR == -2  & TREATED == 1 & !missing(CASH_ETR1)
			replace mean1 = r(mean) if DIDYEAR == -2  & TREATED == 1 & !missing(CASH_ETR1)
			sum CASH_ETR1 if DIDYEAR == -1 & TREATED == 1, d
			replace upperci1 = r(p90) if DIDYEAR == -1 & TREATED == 1 & !missing(CASH_ETR1)
			replace lowerci1 = r(p10) if DIDYEAR == -1  & TREATED == 1 & !missing(CASH_ETR1)
			replace mean1 = r(mean) if DIDYEAR == -1  & TREATED == 1 & !missing(CASH_ETR1)
			sum CASH_ETR1 if DIDYEAR == 0 & TREATED == 1, d
			replace upperci1 = r(p90) if DIDYEAR == 0 & TREATED == 1 & !missing(CASH_ETR1)
			replace lowerci1 = r(p10) if DIDYEAR == 0  & TREATED == 1 & !missing(CASH_ETR1)
			replace mean1 = r(mean) if DIDYEAR == 0  & TREATED == 1 & !missing(CASH_ETR1)
			*Graph Part #1 
			gen vhelp = DIDYEAR
			replace vhelp = . if DIDYEAR >0 
			sort vhelp
			set graphics off
			twoway rarea upperci1 lowerci1 vhelp, astyle(ci) || scatter mean1 vhelp, mcolor(black) msymbol(T) xlabel(-2(1)0) ///
				graphregion(fcolor(white)) xtitle("pretreatment") legend(lab(1 "90% confidence interval") lab(2 "mean")) subtitle("treatment group") ///
				saving(TREATED.gph, replace) 
			set graphics on
			sort CUSIP6 YEAR
			*CONTROL 
			gen upperci0 = . 
			gen lowerci0 = . 
			gen mean0 = .  
			sum CASH_ETR1 if DIDYEAR == -2 & TREATED == 0, d
			replace upperci0 = r(p90) if DIDYEAR == -2 & TREATED == 0 & !missing(CASH_ETR1)
			replace lowerci0 = r(p10) if DIDYEAR == -2  & TREATED == 0 & !missing(CASH_ETR1)
			replace mean0 = r(mean) if DIDYEAR == -2  & TREATED == 0 & !missing(CASH_ETR1)
			sum CASH_ETR1 if DIDYEAR == -1 & TREATED == 0, d
			replace upperci0 = r(p90) if DIDYEAR == -1 & TREATED == 0 & !missing(CASH_ETR1)
			replace lowerci0 = r(p10) if DIDYEAR == -1  & TREATED == 0 & !missing(CASH_ETR1)
			replace mean0 = r(mean) if DIDYEAR == -1  & TREATED == 0 & !missing(CASH_ETR1)
			sum CASH_ETR1 if DIDYEAR == 0 & TREATED == 0, d
			replace upperci0 = r(p90) if DIDYEAR == 0 & TREATED == 0 & !missing(CASH_ETR1)
			replace lowerci0 = r(p10) if DIDYEAR == 0  & TREATED == 0 & !missing(CASH_ETR1)
			replace mean0 = r(mean) if DIDYEAR == 0  & TREATED == 0 & !missing(CASH_ETR1)
			*Graph Part #2
			sort vhelp 
			set graphics off
			twoway rarea upperci0 lowerci0 vhelp, astyle(ci) || scatter mean0 vhelp, mcolor(black) msymbol(D) xlabel(-2(1)0) ///
				graphregion(fcolor(white)) xtitle("pretreatment") legend(lab(1 "90% confidence interval") lab(2 "mean")) subtitle("control group") /// 
				saving(CONTROL.gph, replace) 
			set graphics on	
			set graphics off
			graph combine TREATED.gph CONTROL.gph, col(2) graphregion(fcolor(white)) ycommon l1title("cash ETR") 
			graph export "${pathOUTPUT}\01_FIG\05_A_`time_string'_PRETREATMENT_VISUAL.pdf", as(pdf) replace
			set graphics on	
			sort CUSIP6 YEAR
			drop vhelp*
			erase TREATED.gph
			erase CONTROL.gph
			}
			
			{	//Empirical 
			*Foolowing Patel & Seegert (2015)
			gen vhelp = DIDYEAR
			replace vhelp = vhelp + 3
			replace vhelp = 0 if vhelp == 8		//last year of postperiod dropped for fixed effects
			reg CASH_ETR1 i.vhelp##i.TREATED 
			test (1.vhelp#1.TREATED=0) (2.vhelp#1.TREATED=0) (3.vhelp#1.TREATED= 0)
			return list // r(p)
			local pval = string(`r(p)', "%9.4f")
			*local pval = round(r(p), 0.0001)
			display `pval'
			set graphics off
			coefplot, keep(1.vhelp#1.TREATED 2.vhelp#1.TREATED 3.vhelp#1.TREATED) /// 
				color(black) xline(0, lcolor(black) lpattern(dash)) graphregion(fcolor(white)) /// 
				ciopts(lcolor(black) lwidth(.5)  recast(rcap)) rename(1.vhelp#1.TREATED  = -2 2.vhelp#1.TREATED = -1 3.vhelp#1.TREATED = 0) ///
				l1title("pretreatment") note("p-value (parallel trend) = `pval' ")
			graph export "${pathOUTPUT}\01_FIG\05_B_`time_string'_PRETREATMENT_EMP.pdf", as(pdf) replace
			set graphics on	
			drop vhelp*
			}
		
		}
		
		{	//Figure 6 Kernel Density Plot: delta cash ETR3 
		set graphics off
		sum DELTA_CASH_ETR3 if !missing(hightolow), d
		local N `r(N)'
		twoway kdensity DELTA_CASH_ETR3 if !missing(hightolow), xline(1, lcolor(black) lpattern(shortdash)) /// 
		ytitle("kernel density") xtitle("delta cash ETR3") lcolor(black) lwidth(.5) graphregion(fcolor(white)) note("N = `N'")
		graph export "${pathOUTPUT}\01_FIG\06_`time_string'_KERNEL_DENSITY.pdf", as(pdf) replace
		set graphics on	
		}
		
}

{	//Tables: As in Paper

		{	//Table 1 Descriptive Statistics 
			{	//Table 1 Panel A 
			*N
			sum HIGHTAXFIRM if MIXED == 1, d
			qui putexcel set "${pathOUTPUT}\02_TAB\01_`time_string'_TABLES_AS_IN_PAPER.xlsx", sheet(T1_A_DescStats) modify
			local row = 5
			qui putexcel A`row' = "Panel A Descriptive Statistics [t1]", bold 
			qui putexcel A`row':I`row', merge overwritefmt
			qui putexcel A`row':I`row', border(bottom) overwritefmt
			local row = 9
			qui putexcel A`row' = "N" 
			qui putexcel B`row':C`row', merge
			qui putexcel D`row':E`row', merge
			qui putexcel F`row':G`row', merge
			qui putexcel H`row':I`row', merge
			qui putexcel B`row' = `r(sum)'
			sum HIGHTAXFIRM if ONLYHIGH == 1, d 
			qui putexcel D`row' = `r(sum)'
			sum LOWTAXFIRM if MIXED == 1, d 
			qui putexcel F`row' = `r(sum)'
			sum LOWTAXFIRM if ONLYLOW == 1, d
			qui putexcel H`row' = `r(sum)'
			qui putexcel A`row':I`row', border(bottom) overwritefmt
			*hightohigh & lowtohigh 
			local row = 10
			qui putexcel A`row' = "hightolow"
			qui putexcel B`row':C`row', merge
			qui putexcel B`row' = "'== 1"
			qui putexcel D`row':E`row', merge
			qui putexcel D`row' = "'== 0"
			local row = 11
			qui putexcel A`row' = "lowtohigh"
			qui putexcel F`row':G`row', merge
			qui putexcel F`row' = "'== 1"
			qui putexcel H`row':I`row', merge
			qui putexcel H`row' = "'== 0"
			*mean p50
			local row = 12
			qui putexcel B`row' = "mean"
			qui putexcel C`row' = "p50"
			qui putexcel D`row' = "mean"
			qui putexcel E`row' = "p50"
			qui putexcel F`row' = "mean"
			qui putexcel G`row' = "p50"
			qui putexcel H`row' = "mean"
			qui putexcel I`row' = "p50"
			qui putexcel A`row':I`row', border(bottom) overwritefmt
			*Dependent Variables 
			local row = 13
			qui putexcel A`row' = "cash ETR3"
			sum CASH_ETR3 if HIGHTAXFIRM == 1 & MIXED == 1, d
			qui putexcel B`row' = `r(mean)'
			qui putexcel C`row' = `r(p50)' 
			sum CASH_ETR3 if HIGHTAXFIRM == 1 & ONLYHIGH == 1, d
			qui putexcel D`row' = `r(mean)'
			qui putexcel E`row' = `r(p50)' 
			sum CASH_ETR3 if LOWTAXFIRM == 1 & MIXED == 1, d
			qui putexcel F`row' = `r(mean)'
			qui putexcel G`row' = `r(p50)' 
			sum CASH_ETR3 if LOWTAXFIRM == 1 & ONLYLOW == 1, d
			qui putexcel H`row' = `r(mean)'
			qui putexcel I`row' = `r(p50)' 
			local row = 14
			qui putexcel A`row' = "delta cash ETR3"
			sum DELTA_CASH_ETR3 if HIGHTAXFIRM == 1 & MIXED == 1, d 
			qui putexcel B`row' = `r(mean)'
			qui putexcel C`row' = `r(p50)' 
			sum DELTA_CASH_ETR3 if HIGHTAXFIRM == 1 & ONLYHIGH == 1, d 
			qui putexcel D`row' = `r(mean)'
			qui putexcel E`row' = `r(p50)' 
			sum DELTA_CASH_ETR3 if LOWTAXFIRM == 1 & MIXED == 1, d
			qui putexcel F`row' = `r(mean)'
			qui putexcel G`row' = `r(p50)' 
			sum DELTA_CASH_ETR3 if LOWTAXFIRM == 1 & ONLYLOW == 1, d
			qui putexcel H`row' = `r(mean)'
			qui putexcel I`row' = `r(p50)' 
			qui putexcel A`row':I`row', border(bottom) overwritefmt
			*Partner Controls
			local row = 15
			qui putexcel A`row' = "SameAuditor"
			sum PARTSAMEAUDITOR if HIGHTAXFIRM == 1 & MIXED == 1, d 
			qui putexcel B`row' = `r(mean)'
			qui putexcel C`row' = `r(p50)' 
			sum PARTSAMEAUDITOR if HIGHTAXFIRM == 1 & ONLYHIGH == 1, d 
			qui putexcel D`row' = `r(mean)'
			qui putexcel E`row' = `r(p50)' 
			sum PARTSAMEAUDITOR if LOWTAXFIRM == 1 & MIXED == 1, d
			qui putexcel F`row' = `r(mean)'
			qui putexcel G`row' = `r(p50)' 
			sum PARTSAMEAUDITOR if LOWTAXFIRM == 1 & ONLYLOW == 1, d
			qui putexcel H`row' = `r(mean)'
			qui putexcel I`row' = `r(p50)' 
			local row = 16
			qui putexcel A`row' = "SameBEARegion"
			sum PARTSAMEBEAREGION if HIGHTAXFIRM == 1 & MIXED == 1, d 
			qui putexcel B`row' = `r(mean)'
			qui putexcel C`row' = `r(p50)' 
			sum PARTSAMEBEAREGION if HIGHTAXFIRM == 1 & ONLYHIGH == 1, d 
			qui putexcel D`row' = `r(mean)'
			qui putexcel E`row' = `r(p50)' 
			sum PARTSAMEBEAREGION if LOWTAXFIRM == 1 & MIXED == 1, d
			qui putexcel F`row' = `r(mean)'
			qui putexcel G`row' = `r(p50)' 
			sum PARTSAMEBEAREGION if LOWTAXFIRM == 1 & ONLYLOW == 1, d
			qui putexcel H`row' = `r(mean)'
			qui putexcel I`row' = `r(p50)' 
			local row = 17
			qui putexcel A`row' = "Proximity" 
			sum PROXIMITY if HIGHTAXFIRM == 1 & MIXED == 1, d 
			qui putexcel B`row' = `r(mean)'
			qui putexcel C`row' = `r(p50)' 
			sum PROXIMITY if HIGHTAXFIRM == 1 & ONLYHIGH == 1, d 
			qui putexcel D`row' = `r(mean)'
			qui putexcel E`row' = `r(p50)' 
			sum PROXIMITY if LOWTAXFIRM == 1 & MIXED == 1, d
			qui putexcel F`row' = `r(mean)'
			qui putexcel G`row' = `r(p50)' 
			sum PROXIMITY if LOWTAXFIRM == 1 & ONLYLOW == 1, d
			qui putexcel H`row' = `r(mean)'
			qui putexcel I`row' = `r(p50)'
			local row = 18
			qui putexcel A`row' = "SameInd"
			sum PARTSAMEIND if HIGHTAXFIRM == 1 & MIXED == 1, d 
			qui putexcel B`row' = `r(mean)'
			qui putexcel C`row' = `r(p50)' 
			sum PARTSAMEIND if HIGHTAXFIRM == 1 & ONLYHIGH == 1, d 
			qui putexcel D`row' = `r(mean)'
			qui putexcel E`row' = `r(p50)' 
			sum PARTSAMEIND if LOWTAXFIRM == 1 & MIXED == 1, d
			qui putexcel F`row' = `r(mean)'
			qui putexcel G`row' = `r(p50)' 
			sum PARTSAMEIND if LOWTAXFIRM == 1 & ONLYLOW == 1, d
			qui putexcel H`row' = `r(mean)'
			qui putexcel I`row' = `r(p50)' 
			qui putexcel A`row':I`row', border(bottom) overwritefmt
			*Firm Controls 
			local row = 19
			qui putexcel A`row' = "EBITDA3"
			sum ebitda_at3 if HIGHTAXFIRM == 1 & MIXED == 1, d 
			qui putexcel B`row' = `r(mean)'
			qui putexcel C`row' = `r(p50)' 
			sum ebitda_at3 if HIGHTAXFIRM == 1 & ONLYHIGH == 1, d 
			qui putexcel D`row' = `r(mean)'
			qui putexcel E`row' = `r(p50)' 
			sum ebitda_at3 if LOWTAXFIRM == 1 & MIXED == 1, d
			qui putexcel F`row' = `r(mean)'
			qui putexcel G`row' = `r(p50)' 
			sum ebitda_at3 if LOWTAXFIRM == 1 & ONLYLOW == 1, d
			qui putexcel H`row' = `r(mean)'
			qui putexcel I`row' = `r(p50)' 
			local row = 20
			qui putexcel A`row' = "RnDExp3"
			sum RnDExp3 if HIGHTAXFIRM == 1 & MIXED == 1, d 
			qui putexcel B`row' = `r(mean)'
			qui putexcel C`row' = `r(p50)' 
			sum RnDExp3 if HIGHTAXFIRM == 1 & ONLYHIGH == 1, d 
			qui putexcel D`row' = `r(mean)'
			qui putexcel E`row' = `r(p50)' 
			sum RnDExp3 if LOWTAXFIRM == 1 & MIXED == 1, d
			qui putexcel F`row' = `r(mean)'
			qui putexcel G`row' = `r(p50)' 
			sum RnDExp3 if LOWTAXFIRM == 1 & ONLYLOW == 1, d
			qui putexcel H`row' = `r(mean)'
			qui putexcel I`row' = `r(p50)' 
			local row = 21
			qui putexcel A`row' = "AdExp3"
			sum AdExp3 if HIGHTAXFIRM == 1 & MIXED == 1, d 
			qui putexcel B`row' = `r(mean)'
			qui putexcel C`row' = `r(p50)' 
			sum AdExp3 if HIGHTAXFIRM == 1 & ONLYHIGH == 1, d 
			qui putexcel D`row' = `r(mean)'
			qui putexcel E`row' = `r(p50)' 
			sum AdExp3 if LOWTAXFIRM == 1 & MIXED == 1, d
			qui putexcel F`row' = `r(mean)'
			qui putexcel G`row' = `r(p50)' 
			sum AdExp3 if LOWTAXFIRM == 1 & ONLYLOW == 1, d
			qui putexcel H`row' = `r(mean)'
			qui putexcel I`row' = `r(p50)' 
			local row = 22
			qui putexcel A`row' = "SGA3"
			sum SGA3 if HIGHTAXFIRM == 1 & MIXED == 1, d 
			qui putexcel B`row' = `r(mean)'
			qui putexcel C`row' = `r(p50)' 
			sum SGA3 if HIGHTAXFIRM == 1 & ONLYHIGH == 1, d 
			qui putexcel D`row' = `r(mean)'
			qui putexcel E`row' = `r(p50)' 
			sum SGA3 if LOWTAXFIRM == 1 & MIXED == 1, d
			qui putexcel F`row' = `r(mean)'
			qui putexcel G`row' = `r(p50)' 
			sum SGA3 if LOWTAXFIRM == 1 & ONLYLOW == 1, d
			qui putexcel H`row' = `r(mean)'
			qui putexcel I`row' = `r(p50)' 
			local row = 23
			qui putexcel A`row' = "CapEx3"
			sum CapEx3 if HIGHTAXFIRM == 1 & MIXED == 1, d 
			qui putexcel B`row' = `r(mean)'
			qui putexcel C`row' = `r(p50)' 
			sum CapEx3 if HIGHTAXFIRM == 1 & ONLYHIGH == 1, d 
			qui putexcel D`row' = `r(mean)'
			qui putexcel E`row' = `r(p50)' 
			sum CapEx3 if LOWTAXFIRM == 1 & MIXED == 1, d
			qui putexcel F`row' = `r(mean)'
			qui putexcel G`row' = `r(p50)' 
			sum CapEx3 if LOWTAXFIRM == 1 & ONLYLOW == 1, d
			qui putexcel H`row' = `r(mean)'
			qui putexcel I`row' = `r(p50)'
			local row = 24
			qui putexcel A`row' = "ChangeSale3"
			sum ChangeSale3 if HIGHTAXFIRM == 1 & MIXED == 1, d 
			qui putexcel B`row' = `r(mean)'
			qui putexcel C`row' = `r(p50)' 
			sum ChangeSale3 if HIGHTAXFIRM == 1 & ONLYHIGH == 1, d 
			qui putexcel D`row' = `r(mean)'
			qui putexcel E`row' = `r(p50)' 
			sum ChangeSale3 if LOWTAXFIRM == 1 & MIXED == 1, d
			qui putexcel F`row' = `r(mean)'
			qui putexcel G`row' = `r(p50)' 
			sum ChangeSale3 if LOWTAXFIRM == 1 & ONLYLOW == 1, d
			qui putexcel H`row' = `r(mean)'
			qui putexcel I`row' = `r(p50)'
			local row = 25
			qui putexcel A`row' = "Leverage3"
			sum Leverage3 if HIGHTAXFIRM == 1 & MIXED == 1, d 
			qui putexcel B`row' = `r(mean)'
			qui putexcel C`row' = `r(p50)' 
			sum Leverage3 if HIGHTAXFIRM == 1 & ONLYHIGH == 1, d 
			qui putexcel D`row' = `r(mean)'
			qui putexcel E`row' = `r(p50)' 
			sum Leverage3 if LOWTAXFIRM == 1 & MIXED == 1, d
			qui putexcel F`row' = `r(mean)'
			qui putexcel G`row' = `r(p50)' 
			sum Leverage3 if LOWTAXFIRM == 1 & ONLYLOW == 1, d
			qui putexcel H`row' = `r(mean)'
			qui putexcel I`row' = `r(p50)'
			local row = 26
			qui putexcel A`row' = "Cash3"
			sum Cash3 if HIGHTAXFIRM == 1 & MIXED == 1, d 
			qui putexcel B`row' = `r(mean)'
			qui putexcel C`row' = `r(p50)' 
			sum Cash3 if HIGHTAXFIRM == 1 & ONLYHIGH == 1, d 
			qui putexcel D`row' = `r(mean)'
			qui putexcel E`row' = `r(p50)' 
			sum Cash3 if LOWTAXFIRM == 1 & MIXED == 1, d
			qui putexcel F`row' = `r(mean)'
			qui putexcel G`row' = `r(p50)' 
			sum Cash3 if LOWTAXFIRM == 1 & ONLYLOW == 1, d
			qui putexcel H`row' = `r(mean)'
			qui putexcel I`row' = `r(p50)'
			local row = 27
			qui putexcel A`row' = "MNE3"
			sum MNE3 if HIGHTAXFIRM == 1 & MIXED == 1, d 
			qui putexcel B`row' = `r(mean)'
			qui putexcel C`row' = `r(p50)' 
			sum MNE3 if HIGHTAXFIRM == 1 & ONLYHIGH == 1, d 
			qui putexcel D`row' = `r(mean)'
			qui putexcel E`row' = `r(p50)' 
			sum MNE3 if LOWTAXFIRM == 1 & MIXED == 1, d
			qui putexcel F`row' = `r(mean)'
			qui putexcel G`row' = `r(p50)' 
			sum MNE3 if LOWTAXFIRM == 1 & ONLYLOW == 1, d
			qui putexcel H`row' = `r(mean)'
			qui putexcel I`row' = `r(p50)'
			local row = 28
			qui putexcel A`row' = "NOL3"
			sum NOL3 if HIGHTAXFIRM == 1 & MIXED == 1, d 
			qui putexcel B`row' = `r(mean)'
			qui putexcel C`row' = `r(p50)' 
			sum NOL3 if HIGHTAXFIRM == 1 & ONLYHIGH == 1, d 
			qui putexcel D`row' = `r(mean)'
			qui putexcel E`row' = `r(p50)' 
			sum NOL3 if LOWTAXFIRM == 1 & MIXED == 1, d
			qui putexcel F`row' = `r(mean)'
			qui putexcel G`row' = `r(p50)' 
			sum NOL3 if LOWTAXFIRM == 1 & ONLYLOW == 1, d
			qui putexcel H`row' = `r(mean)'
			qui putexcel I`row' = `r(p50)'
			local row = 29
			qui putexcel A`row' = "Intangibles3"
			sum Intangibles3 if HIGHTAXFIRM == 1 & MIXED == 1, d 
			qui putexcel B`row' = `r(mean)'
			qui putexcel C`row' = `r(p50)' 
			sum Intangibles3 if HIGHTAXFIRM == 1 & ONLYHIGH == 1, d 
			qui putexcel D`row' = `r(mean)'
			qui putexcel E`row' = `r(p50)' 
			sum Intangibles3 if LOWTAXFIRM == 1 & MIXED == 1, d
			qui putexcel F`row' = `r(mean)'
			qui putexcel G`row' = `r(p50)' 
			sum Intangibles3 if LOWTAXFIRM == 1 & ONLYLOW == 1, d
			qui putexcel H`row' = `r(mean)'
			qui putexcel I`row' = `r(p50)'
			local row = 30
			qui putexcel A`row' = "PPE3"
			sum PPE3 if HIGHTAXFIRM == 1 & MIXED == 1, d 
			qui putexcel B`row' = `r(mean)'
			qui putexcel C`row' = `r(p50)' 
			sum PPE3 if HIGHTAXFIRM == 1 & ONLYHIGH == 1, d 
			qui putexcel D`row' = `r(mean)'
			qui putexcel E`row' = `r(p50)' 
			sum PPE3 if LOWTAXFIRM == 1 & MIXED == 1, d
			qui putexcel F`row' = `r(mean)'
			qui putexcel G`row' = `r(p50)' 
			sum PPE3 if LOWTAXFIRM == 1 & ONLYLOW == 1, d
			qui putexcel H`row' = `r(mean)'
			qui putexcel I`row' = `r(p50)'
			local row = 31
			qui putexcel A`row' = "Size3"
			sum size3 if HIGHTAXFIRM == 1 & MIXED == 1, d 
			qui putexcel B`row' = `r(mean)'
			qui putexcel C`row' = `r(p50)' 
			sum size3 if HIGHTAXFIRM == 1 & ONLYHIGH == 1, d 
			qui putexcel D`row' = `r(mean)'
			qui putexcel E`row' = `r(p50)' 
			sum size3 if LOWTAXFIRM == 1 & MIXED == 1, d
			qui putexcel F`row' = `r(mean)'
			qui putexcel G`row' = `r(p50)' 
			sum size3 if LOWTAXFIRM == 1 & ONLYLOW == 1, d
			qui putexcel H`row' = `r(mean)'
			qui putexcel I`row' = `r(p50)'
			qui putexcel A`row':I`row', border(bottom) overwritefmt
			*Format
			qui putexcel B9:I12, hcenter
			qui putexcel B13:I31, nformat(# 0.0000) hcenter 
			qui putexcel C31, nformat(# 00.0000) hcenter 
			qui putexcel A3:I3, merge
			qui putexcel A3 = "Table 1 Information on Networks and Firms", bold 
			qui putexcel A3, hcenter
			qui putexcel A5, bold 
			qui putexcel A10, bold 
			qui putexcel B10, bold 
			qui putexcel D10, bold 
			qui putexcel A1:I31, font("Times New Roman", 11)	
			qui putexcel A1:I31, vcenter
			}
			
			{	//Table 2 Panel B 
			qui putexcel set "${pathOUTPUT}\02_TAB\01_`time_string'_TABLES_AS_IN_PAPER.xlsx", sheet(T1_B_DescStats) modify
			qui putexcel A3:P3, merge
			qui putexcel A3 = "Table 1 Information on Networks and Firms (continued)", bold
			qui putexcel A5:P5, merge
			qui putexcel A5 = "Panel B Industry Affiliation of Networks and Firms [two-digit SIC-code]", bold 
			qui putexcel A5:P5, border(bottom) 
			*Rows
			qui putexcel B8 = "Agriculture, Forestry, & Fishing [01-09]" 
			qui putexcel B9 = "Mining [10-14]" 
			qui putexcel B10 = "Construction [15-17]" 
			qui putexcel B11 = "Manufacturing: Chemical & Allied Products [28]"
			qui putexcel B12 = "Manufacturing [20-39, except 28]"
			qui putexcel B13 = "Transportation & Public Utilities [40-49]"
			qui putexcel B14 = "Wholesale Trade [50-51]"
			qui putexcel B15 = "Retail Trade [52-59]"
			qui putexcel B16 = "Finance, Insurance, & Real Estate [60-67]"
			qui putexcel B17 = "Services: Business Services [73]"
			qui putexcel B18 = "Services [70-89, except 73]"
			qui putexcel B19 = "Nonclassifiable Establishments/Other"
			qui putexcel C8 = "I" 
			qui putexcel C9 = "II" 
			qui putexcel C10 = "III" 
			qui putexcel C11 = "IV"
			qui putexcel C12 = "V"
			qui putexcel C13 = "VI"
			qui putexcel C14 = "VII"
			qui putexcel C15 = "VIII"
			qui putexcel C16 = "IX"
			qui putexcel C17 = "X"
			qui putexcel C18 = "XI"
			qui putexcel C19 = "XII"
			qui putexcel D7 = "I" 
			qui putexcel E7 = "II" 
			qui putexcel F7 = "III" 
			qui putexcel G7 = "IV"
			qui putexcel H7 = "V"
			qui putexcel I7 = "VI"
			qui putexcel J7 = "VII"
			qui putexcel K7 = "VIII"
			qui putexcel L7 = "IX"
			qui putexcel M7 = "X"
			qui putexcel N7 = "XI"
			qui putexcel O7 = "XII"
			qui putexcel P6 = "sumzz", hcenter 
			*Headers
			qui putexcel D6:O6, merge
			qui putexcel D6 = "Industry of Networks", bold
			qui putexcel A8:A19, merge
			qui putexcel A8 = "Industry of Firms", txtrotate(90) bold
			local row = 8
			*Input
			tab IND IND_SA, matcell(freq) matrow(names) 
			putexcel E`row'=matrix(freq)
			putexcel D8:D19 = 0
			*Sums
			levelsof IND_SA, local(levels) 
			foreach l of local levels{
			qui sum HIGHTAXFIRM if IND_SA == `l', d
			qui putexcel set "${pathOUTPUT}\02_TAB\01_`time_string'_TABLES_AS_IN_PAPER.xlsx", sheet(T1_B_DescStats) modify
			local row = `l'+7
			qui putexcel P`row' = formula(=sum(D`row':O`row'))
			}
			local row = 20
			qui putexcel D`row' = formula(=sum(D8:D19))
			qui putexcel E`row' = formula(=sum(E8:E19))
			qui putexcel F`row' = formula(=sum(F8:F19))
			qui putexcel G`row' = formula(=sum(G8:G19))
			qui putexcel H`row' = formula(=sum(H8:H19))
			qui putexcel I`row' = formula(=sum(I8:I19))
			qui putexcel J`row' = formula(=sum(J8:J19))
			qui putexcel K`row' = formula(=sum(K8:K19))
			qui putexcel L`row' = formula(=sum(L8:L19))
			qui putexcel M`row' = formula(=sum(M8:M19))
			qui putexcel N`row' = formula(=sum(N8:N19))
			qui putexcel O`row' = formula(=sum(O8:O19))
			qui putexcel P`row' = formula(=sum(P8:P19))
			putexcel P8 = formula(=sum(D8:O8))
			*Format
			qui putexcel A7:P7, border(bottom) 
			qui putexcel A19:P19, border(bottom) 
			qui putexcel A20:P20, border(bottom) 
			qui putexcel D7:P20, hcenter 
			qui putexcel D6, hcenter bold 
			qui putexcel C7:P7, hcenter  
			qui putexcel C8:C19, hcenter 
			qui putexcel A8, hcenter 
			qui putexcel A3, hcenter 
			qui putexcel A1:P22, font("Times New Roman", 11) 
			qui putexcel A1:P22, vcenter
			}

}

		{	//Table 2 Descriptive Analysis 
		qui putexcel set "${pathOUTPUT}\02_TAB\01_`time_string'_TABLES_AS_IN_PAPER.xlsx", sheet(T2_DescAnalysis) modify
		local row = 5
		qui putexcel A`row' = "Change from pre cash ETR3 [t-2; t0] to cash ETR3 [t1; t3]" 
		qui putexcel A`row':F`row', merge overwritefmt
		qui putexcel A`row':F`row', border(bottom) overwritefmt
		local row = 9
		qui putexcel A`row' = "N"
		qui putexcel C`row':D`row', merge
		qui putexcel E`row':F`row', merge
		sum HIGHTAXFIRM if hightolow == 1
		qui putexcel C`row' = `r(N)' 
		sum HIGHTAXFIRM if hightolow == 0
		qui putexcel E`row' = `r(N)' 
		qui putexcel A`row':F`row', border(bottom) overwritefmt
		local row = 10
		qui putexcel A`row' = "hightolow"
		qui putexcel C`row':D`row', merge
		qui putexcel E`row':F`row', merge
		qui putexcel C`row' = "'== 1"
		qui putexcel E`row' = "'== 0"
		local row = 11
		qui putexcel C`row' = "mean"
		qui putexcel D`row' = "(SD)"
		qui putexcel E`row' = "mean"
		qui putexcel F`row' = "(SD)"
		qui putexcel A`row':F`row', border(bottom) 
		*PRE_CASH_ETR3 [t-2; t0]
		local row = 12
		qui putexcel A`row' = "pre cash ETR3 [t-2; t0]"
		qui putexcel B`row' = "I"
		gen vhelp = LAG_PRE_CASH_ETR3_1
		replace vhelp = LAG_PRE_CASH_ETR3_2 if !missing(hightolow) & missing(vhelp)
		sum vhelp if hightolow == 1, d
		qui putexcel C`row' = `r(mean)'
		qui putexcel D`row' = `r(sd)'
		sum vhelp if hightolow == 0, d
		qui putexcel E`row' = `r(mean)'
		qui putexcel F`row' = `r(sd)'
		*CASH_ETR3 [t1; t3]
		local row = 13
		qui putexcel A`row' = "cash ETR3 [t1; t3]"
		qui putexcel B`row' = "II"
		sum CASH_ETR3 if hightolow == 1, d
		qui putexcel C`row' = `r(mean)'
		qui putexcel D`row' = `r(sd)'
		sum CASH_ETR3 if hightolow == 0, d
		qui putexcel E`row' = `r(mean)'
		qui putexcel F`row' = `r(sd)'
		qui putexcel A`row':F`row', border(bottom)
		*Within-Group Change
		local row = 15
		qui putexcel A`row' = "Within-Group Change"
		qui putexcel B`row' = "I to II"
		ttest CASH_ETR3 =  vhelp if hightolow == 1
		qui putexcel C`row' = formula(`r(mu_1)' - `r(mu_2)')
		local row = 16
		qui putexcel A`row' = "(p-value)"
		qui putexcel C`row':D`row', merge overwritefmt
		qui putexcel C`row' = `r(p)'
		local row = 15
		qui putexcel D`row' = formula(IF(`r(p)'>=0.10,"",IF(`r(p)'>=0.05,"*",IF(`r(p)'>=0.01,"**",IF(`r(p)'>=0,"***","")))))
		ttest CASH_ETR3 =  vhelp if hightolow == 0
		local row = 15
		qui putexcel E`row' = formula(`r(mu_1)' - `r(mu_2)')
		local row = 16
		qui putexcel E`row':F`row', merge overwritefmt
		qui putexcel E`row' = `r(p)'
		local row = 15
		qui putexcel F`row' = formula(IF(`r(p)'>=0.10,"",IF(`r(p)'>=0.05,"*",IF(`r(p)'>=0.01,"**",IF(`r(p)'>=0,"***","")))))
		*Difference in Within-Group Change 
		local row = 18
		qui putexcel A`row' = "Difference in Within-Group Change"
		local row = 19
		qui putexcel A`row' = "(p-value)"
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
		local row = 18
		qui putexcel C`row':D`row', merge overwritefmt
		qui putexcel E`row':F`row', merge overwritefmt
		qui putexcel C`row' = formula(`r(mu_1)' - `r(mu_2)')
		local row = 19
		qui putexcel C`row':F`row', merge overwritefmt
		qui putexcel C`row' = `r(p)'
		local row = 18
		qui putexcel E`row' = formula(IF(`r(p)'>=0.10,"",IF(`r(p)'>=0.05,"*",IF(`r(p)'>=0.01,"**",IF(`r(p)'>=0,"***","")))))
		drop vhelp*
		local row = 19
		qui putexcel A`row':F`row', border(bottom)
		*Format
		qui putexcel C9:F11, hcenter
		qui putexcel C12:C13, nformat(# 0.0000) hcenter
		qui putexcel D12:D13, nformat(# (0.0000)) hcenter
		qui putexcel E12:E13, nformat(# 0.0000) hcenter
		qui putexcel F12:F13, nformat(# (0.0000)) hcenter
		qui putexcel C15, nformat(# 0.0000) right
		qui putexcel E15, nformat(# 0.0000) right	
		qui putexcel D15, left
		qui putexcel F15, left
		qui putexcel C16:E16, nformat(# (0.0000)) hcenter
		qui putexcel C18, nformat(# 0.0000) right
		qui putexcel E18, left
		qui putexcel C19, nformat(# (0.0000)) hcenter
		qui putexcel B9:B19, hcenter
		*Header
		qui putexcel A3:F3, merge
		qui putexcel A3 = "Table 2 Descriptive Analysis" 
		qui putexcel A3 A5 C18 D18 C19, bold 
		qui putexcel A3, hcenter 
		qui putexcel A1:I19, font("Times New Roman", 11)
		qui putexcel A1:I19, vcenter 
		}
	
		{	//Table 3 Regression Analyses
		
		{	//Table 3 Panel A 
			*Table 3 Panel A Specification 1
			*CASH_ETR3
			reghdfe CASH_ETR3 i.hightolow $PARTNERlist $FIRMlist $NETWORKlist, absorb(IND YEAR) vce(cluster CUSIPNUM)   
			qui putexcel set "${pathOUTPUT}\02_TAB\01_`time_string'_TABLES_AS_IN_PAPER.xlsx", sheet(T3_A_RegAnalysis) modify
			qui putexcel A5 = "Panel A Regression Analysis", bold
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
			local pval = (2 * ttail(e(df_r), abs(_b[1.PARTSAMEAUDITOR] / _se[1.PARTSAMEAUDITOR]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
			display `pval'
			qui putexcel D`row' = `pval' 
			qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
			qui putexcel A`row':H`row', border(bottom) overwritefmt
			local row = 12
			qui putexcel A`row' = "Network Controls"
			qui putexcel B`row':D`row', merge overwritefmt
			qui putexcel B`row' = "Yes"
			qui putexcel F`row':H`row', merge overwritefmt
			qui putexcel F`row' = "Yes"
			qui putexcel A13 = "Firm Controls"
			qui putexcel A14 = "Fixed Effects"
			qui putexcel A15 = "SE"
			qui putexcel A16 = "N"
			qui putexcel A17 = "Adjusted R2"
			qui putexcel B13:D13, merge overwritefmt
			qui putexcel B13 = "Yes"
			qui putexcel F13:H13, merge overwritefmt
			qui putexcel F13 = "Yes"
			qui putexcel B14:D14, merge overwritefmt
			qui putexcel B14 = "Industry & Year"
			qui putexcel F14:H14, merge overwritefmt
			qui putexcel F14 = "Industry & Year"
			qui putexcel B15:D15, merge overwritefmt
			qui putexcel B15 = "Cluster @ Firm"
			qui putexcel F15:H15, merge overwritefmt
			qui putexcel F15 = "Cluster @ Firm"
			qui putexcel B16:D16, merge overwritefmt
			qui putexcel B16 = `e(N)'
			qui putexcel B17:D17, merge overwritefmt
			qui putexcel B17 = `e(r2_a)'
			*Table 3 Panel A Specification 2
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
			qui putexcel F16:H16, merge overwritefmt
			qui putexcel F16 = `e(N)'
			qui putexcel F17:H17, merge overwritefmt
			qui putexcel F17 = `e(r2_a)'
			qui putexcel A17:H17, border(bottom) overwritefmt
			*Format
			qui putexcel A3:H3, merge overwritefmt
			qui putexcel A3 = "Table 3 Regression Analysis", bold 
			qui putexcel A3, hcenter
			qui putexcel B6:H7 B12:H16, hcenter 
			qui putexcel B8:B11 F8:F11, nformat(# 0.0000) right
			qui putexcel B17 F17, nformat(# 0.0000) hcenter
			qui putexcel D8:D11 H8:H11, nformat(# (0.0000)) hcenter 
			qui putexcel A8:H9 A5 B6:H6, bold
			qui putexcel A1:H17, font("Times New Roman", 11) 
			qui putexcel A1:H17, vcenter
			}
		
		{	//Table 3 Panel B Difference in Differences
		qui putexcel set "${pathOUTPUT}\02_TAB\01_`time_string'_TABLES_AS_IN_PAPER.xlsx", sheet(T3_B_DiD) modify
		
		{	//Table 3 Panel B Specification 1
		qui putexcel A5:L5, merge overwritefmt
		qui putexcel A5:L5, border(bottom) overwritefmt
		qui putexcel A5 = "Panel B Difference-in-Differences", bold
		qui putexcel A6 = "Dependent Variable"
		qui putexcel B6:D6, merge overwritefmt
		qui putexcel B6 = "cash ETR"
		qui putexcel F6:H6, merge overwritefmt
		qui putexcel F6 = "cash ETR"
		qui putexcel J6:L6, merge overwritefmt
		qui putexcel J6 = "cash ETR"
		qui putexcel B7:C7, merge 
		qui putexcel B7 = "Coefficient" 
		qui putexcel D7 = "(p-value)"
		qui putexcel F7:G7, merge 
		qui putexcel F7 = "Coefficient" 
		qui putexcel H7 = "(p-value)"
		qui putexcel J7:K7, merge 
		qui putexcel J7 = "Coefficient" 
		qui putexcel L7 = "(p-value)"
		qui putexcel A7:L7, border(bottom) overwritefmt
		qui putexcel A8:A9, merge 
		qui putexcel B8:B9, merge 
		qui putexcel C8:C9, merge 
		qui putexcel D8:D9, merge 
		qui putexcel E8:E9, merge 
		qui putexcel F8:F9, merge 
		qui putexcel G8:G9, merge 
		qui putexcel H8:H9, merge 
		qui putexcel I8:I9, merge 
		qui putexcel J8:J9, merge 
		qui putexcel K8:K9, merge 
		qui putexcel L8:L9, merge
		qui putexcel A10:A11, merge 
		qui putexcel B10:B11, merge 
		qui putexcel C10:C11, merge 
		qui putexcel D10:D11, merge 
		qui putexcel E10:E11, merge 
		qui putexcel F10:F11, merge 
		qui putexcel G10:G11, merge 
		qui putexcel H10:H11, merge 
		qui putexcel I10:I11, merge 
		qui putexcel J10:J11, merge 
		qui putexcel K10:K11, merge 
		qui putexcel L10:L11, merge
		qui putexcel A12:A13, merge 
		qui putexcel B12:B13, merge 
		qui putexcel C12:C13, merge 
		qui putexcel D12:D13, merge 
		qui putexcel E12:E13, merge 
		qui putexcel F12:F13, merge 
		qui putexcel G12:G13, merge 
		qui putexcel H12:H13, merge 
		qui putexcel I12:I13, merge 
		qui putexcel J12:J13, merge 
		qui putexcel K12:K13, merge 
		qui putexcel L12:L13, merge
		reghdfe CASH_ETR1 TREATED##POST, noabsorb vce(robust)
		local row = 8
		qui putexcel A`row' = "treated"
		display _b[1.TREATED]
		local coef = _b[1.TREATED]
		qui putexcel B`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[1.TREATED] / _se[1.TREATED]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel D`row' = `pval' 
		qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 10
		qui putexcel A`row' = "post"
		display _b[1.POST]
		local coef = _b[1.POST]
		qui putexcel B`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[1.POST] / _se[1.POST]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
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
		qui putexcel A13:L13, border(bottom) overwritefmt
		qui putexcel A14 = "Firm Controls"
		qui putexcel A15 = "Fixed Effects"
		qui putexcel A16 = "SE"
		qui putexcel A17 = "N"
		qui putexcel A18 = "Adjusted R2"
		qui putexcel B14:D14, merge overwritefmt
		qui putexcel B14 = "No"
		qui putexcel F14:H14, merge overwritefmt
		qui putexcel F14 = "Yes (Annual Measures)"
		qui putexcel J14:L14, merge overwritefmt
		qui putexcel J14 = "Yes (Annual Measures)"
		qui putexcel B15:D15, merge overwritefmt
		qui putexcel B15 = "No"
		qui putexcel F15:H15, merge overwritefmt
		qui putexcel F15 = "Industry & Embargo Period"
		qui putexcel J15:L15, merge overwritefmt
		qui putexcel J15 = "Industry & Year & Embargo Period"
		qui putexcel B16:D16, merge overwritefmt
		qui putexcel B16 = "Robust"
		qui putexcel F16:H16, merge overwritefmt
		qui putexcel F16 = "Cluster @ Firm"
		qui putexcel J16:L16, merge overwritefmt
		qui putexcel J16 = "Cluster @ Firm"
		qui putexcel B17:D17, merge overwritefmt
		qui putexcel B17 = `e(N)'
		qui putexcel B18:D18, merge overwritefmt
		qui putexcel B18 = `e(r2_a)'
		qui putexcel A19:L19, merge
		qui putexcel A19 = "Margins of responses for cash ETR [SE]", left 
		qui putexcel A20 = "control*post"
		qui putexcel A21 = "treated*post"
		qui putexcel B20:D20, merge overwritefmt
		qui putexcel B21:D21, merge overwritefmt
		qui putexcel F20:H20, merge overwritefmt
		qui putexcel F21:H21, merge overwritefmt
		qui putexcel J20:L20, merge overwritefmt
		qui putexcel J21:L21, merge overwritefmt		
		margins TREATED#POST, post
		local cp = round(_b[0.TREATED#1.POST], 0.0001)
		display `cp' 
		local cpse = round(_se[0.TREATED#1.POST], 0.0001)
		display `cpse' 
		qui putexcel B20 = "0`cp' [0`cpse']"
		local tp = round(_b[1.TREATED#1.POST], 0.0001)
		display `tp' 
		local tpse = round(_se[1.TREATED#1.POST], 0.0001)
		display `tpse'
		qui putexcel B21 = "0`tp' [0`tpse']"
		test _b[1.TREATED#1.POST] = _b[0.TREATED#1.POST]
		local row = 22
		qui putexcel A`row' = "Difference (p-value)" 
		qui putexcel B`row' = formula(`tp'-`cp')
		local pval = `r(p)'
		display `pval'
		qui putexcel D`row' = `pval'
		qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		}
		
		{	//Table 3 Panel B Specification 2
		reghdfe CASH_ETR1 TREATED##POST $FIRMlistannual, absorb(IND DIDYEAR) vce(cluster CUSIPNUM)
		qui putexcel set "${pathOUTPUT}\02_TAB\01_`time_string'_TABLES_AS_IN_PAPER.xlsx", sheet(T3_B_DiD) modify
		local coef = _b[1.TREATED]
		local row = 8
		qui putexcel F`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[1.TREATED] / _se[1.TREATED]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel H`row' = `pval' 
		qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 12
		display _b[1.TREATED#1.POST]
		local coef = _b[1.TREATED#1.POST]
		qui putexcel F`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[1.TREATED#1.POST] / _se[1.TREATED#1.POST]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel H`row' = `pval' 
		qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		qui putexcel F17:H17, merge overwritefmt
		qui putexcel F17 = `e(N)'
		qui putexcel F18:H18, merge overwritefmt
		qui putexcel F18 = `e(r2_a)'
		qui reghdfe CASH_ETR1 TREATED##POST $FIRMlistannual, absorb(IND) vce(cluster CUSIPNUM)
		margins TREATED#POST, post
		local cp = round(_b[0.TREATED#1.POST], 0.0001)
		display `cp' 
		local cpse = round(_se[0.TREATED#1.POST], 0.0001)
		display `cpse' 
		qui putexcel F20 = "0`cp' [0`cpse']"
		local tp = round(_b[1.TREATED#1.POST], 0.0001)
		display `tp' 
		local tpse = round(_se[1.TREATED#1.POST], 0.0001)
		display `tpse'
		qui putexcel F21 = "0`tp' [0`tpse']"
		test _b[1.TREATED#1.POST] = _b[0.TREATED#1.POST]
		local row = 22 
		qui putexcel F`row' = formula(`tp'-`cp')
		local pval = `r(p)'
		display `pval'
		qui putexcel H`row' = `pval' 
		qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		}
		
		{	//Table 3 Panel B Specification 3
		reghdfe CASH_ETR1 TREATED##POST $FIRMlistannual, absorb(IND YEAR DIDYEAR) vce(cluster CUSIPNUM)
		qui putexcel set "${pathOUTPUT}\02_TAB\01_`time_string'_TABLES_AS_IN_PAPER.xlsx", sheet(T3_B_DiD) modify
		display _b[1.TREATED]
		local coef = _b[1.TREATED]
		local row = 8
		qui putexcel J`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[1.TREATED] / _se[1.TREATED]) ) ) // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel L`row' = `pval' 
		qui putexcel K`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 12
		display _b[1.TREATED#1.POST]
		local coef = _b[1.TREATED#1.POST]
		qui putexcel J`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[1.TREATED#1.POST] / _se[1.TREATED#1.POST]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel L`row' = `pval' 
		qui putexcel K`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		qui putexcel J17:L17, merge overwritefmt
		qui putexcel J17 = `e(N)'
		qui putexcel J18:L18, merge overwritefmt
		qui putexcel J18 = `e(r2_a)'
		qui putexcel A18:L18, border(bottom) overwritefmt
		qui reghdfe CASH_ETR1 TREATED##POST $FIRMlistannual, absorb(IND YEAR) vce(cluster CUSIPNUM)
		margins TREATED#POST, post 
		local cp = round(_b[0.TREATED#1.POST], 0.0001)
		display `cp' 
		local cpse = round(_se[0.TREATED#1.POST], 0.0001)
		display `cpse' 
		qui putexcel J20 = "0`cp' [0`cpse']"
		local tp = round(_b[1.TREATED#1.POST], 0.0001)
		display `tp' 
		local tpse = round(_se[1.TREATED#1.POST], 0.0001)
		display `tpse'
		qui putexcel J21 = "0`tp' [0`tpse']"
		test _b[1.TREATED#1.POST] = _b[0.TREATED#1.POST]
		local row = 22
		qui putexcel J`row' = formula(`tp'-`cp')
		local pval = `r(p)'
		display `pval'
		qui putexcel L`row' = `pval' 
		qui putexcel K`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		qui putexcel A`row':L`row', border(bottom) overwritefmt
		*Format
		qui putexcel A3:L3, merge overwritefmt
		qui putexcel A3 = "Table 3 Regression Analysis (continued)", bold 
		qui putexcel A3, hcenter
		qui putexcel B6:L7, hcenter 
		qui putexcel B14:L17 B20:L21, hcenter 
		qui putexcel B8:B13 F8:F13 J8:J13 B22 F22 J22, nformat(# 0.0000) right
		qui putexcel B18 F18 J18, nformat(# 0.0000) hcenter
		qui putexcel D8:D13 H8:H13 L8:L13 D22 H22 L22, nformat(# (0.0000)) hcenter 
		qui putexcel A12:L13 B6:L6, bold 
		qui putexcel A1:L22, font("Times New Roman", 11) 
		qui putexcel A1:L22, vcenter
		
		}
				
		}	
			
		{	//Table 3 Panel C Adjustment Speed
		qui putexcel set "${pathOUTPUT}\02_TAB\01_`time_string'_TABLES_AS_IN_PAPER.xlsx", sheet(T3_C_AdjSpeed) modify
		qui putexcel A5:D5, merge overwritefmt
		qui putexcel A5:D5, border(bottom) overwritefmt
		qui putexcel A5 = "Panel C Adjustment Speed", bold
		qui putexcel A6 = "Dependent Variable"
		qui putexcel B6:D6, merge overwritefmt
		qui putexcel B6 = "cash ETR", bold
		qui putexcel A7 = "(#) of Specification"
		qui putexcel B7:C7, merge overwritefmt
		qui putexcel B7 = "Coefficient" 
		qui putexcel D7 = "(p-value)"
		qui putexcel A7:D7, border(bottom) overwritefmt
		qui putexcel A8:A9, merge 
		qui putexcel B8:B9, merge 
		qui putexcel C8:C9, merge 
		qui putexcel D8:D9, merge 
		qui putexcel A10:A11, merge 
		qui putexcel B10:B11, merge 
		qui putexcel C10:C11, merge 
		qui putexcel D10:D11, merge 
		qui putexcel A12:A13, merge 
		qui putexcel B12:B13, merge 
		qui putexcel C12:C13, merge 
		qui putexcel D12:D13, merge 
		qui putexcel A14:A15, merge 
		qui putexcel B14:B15, merge 
		qui putexcel C14:C15, merge 
		qui putexcel D14:D15, merge 
		qui putexcel A16:A17, merge 
		qui putexcel B16:B17, merge 
		qui putexcel C16:C17, merge 
		qui putexcel D16:D17, merge 
		qui putexcel A17:D17, border(bottom) overwritefmt
		qui putexcel A18 = "Controls"
		qui putexcel A19 = "Fixed Effects"
		qui putexcel A20 = "SE"
		qui putexcel A21 = "N"
		qui putexcel B21:D21, merge overwritefmt
		qui putexcel A22 = "Adjusted R2"
		qui putexcel B22:D22, merge overwritefmt
		qui putexcel B18:D18, merge overwritefmt
		qui putexcel B18 = "Firm (Annual Measures) & treated"
		qui putexcel B19:D19, merge overwritefmt
		qui putexcel B19 = "Industry & Year & Embargo Period"
		qui putexcel B20:D20, merge overwritefmt
		qui putexcel B20 = "Cluster @ Firm"
		qui putexcel A22:D22, border(bottom) overwritefmt
		forvalues q=1(1)5{
		reghdfe CASH_ETR1 TREATED##POST $FIRMlistannual if DIDYEAR <=`q', absorb(IND YEAR DIDYEAR) vce(cluster CUSIPNUM)
		local row = 2*`q'+6
		if `q' == 1{
		qui putexcel A`row' = "(`q') treated*post [t1]"
		}
		else {
		qui putexcel A`row' = "(`q') treated*post [t1; t`q']"
		}
		display _b[1.TREATED#1.POST]
		local coef = _b[1.TREATED#1.POST]
		qui putexcel B`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[1.TREATED#1.POST] / _se[1.TREATED#1.POST]) ) )
		display `pval'
		qui putexcel D`row' = `pval' 
		qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local n`q' = `e(N)'
		local r`q' = string(`e(r2_a)', "%9.4f")
		}
		qui putexcel B21 = "`n1'; `n2'; `n3'; `n4'; `n5'"
		qui putexcel B22 = "`r1'; `r2'; `r3'; `r4'; `r5'"
		*Format
		qui putexcel A3:D3, merge overwritefmt
		qui putexcel A3 = "Table 3 Regression Analysis (continued)", bold 
		qui putexcel A3, hcenter
		qui putexcel B6:D7, hcenter 
		qui putexcel B18:D22, hcenter 
		qui putexcel B8:B17, nformat(# 0.0000) right
		qui putexcel D8:D17, nformat(# (0.0000)) hcenter 
		qui putexcel B6:D6, bold 
		qui putexcel A1:D22, font("Times New Roman", 11) 
		qui putexcel A1:D22, vcenter
			}
			
		}

		{	//Table 4 Additional Analyses 
		qui putexcel set "${pathOUTPUT}\02_TAB\01_`time_string'_TABLES_AS_IN_PAPER.xlsx", sheet(T4_AddAnalyses) modify
		
		{	//Table 4 Panel A
		*Table 4 Panel A Specification 1
		reghdfe CASH_ETR3 i.hightolow##i.PARTSAMEBEAREGION $NETWORKlist $PARTNERlistBEA $FIRMlist, absorb(IND YEAR) vce(cluster CUSIPNUM)
		qui putexcel A5:H5, merge 
		qui putexcel A5 = "Panel A Distance", bold
		qui putexcel A5:H5, border(bottom) 
		qui putexcel A6 = "Dependent Variable"
		qui putexcel B6:D6, merge overwritefmt
		qui putexcel B6 = "cash ETR3 [t1; t3]", bold hcenter
		qui putexcel F6:H6, merge overwritefmt
		qui putexcel F6 = "delta cash ETR3", bold hcenter
		qui putexcel B7:C7, merge overwritefmt
		qui putexcel B7 = "Coefficient", hcenter
		qui putexcel F7:G7, merge overwritefmt
		qui putexcel F7 = "Coefficient", hcenter
		qui putexcel D7 = "(p-value)", hcenter
		qui putexcel H7 = "(p-value)", hcenter
		qui putexcel A7:H7, border(bottom) 
		qui putexcel A8:A9, merge
		qui putexcel B8:B9, merge
		qui putexcel C8:C9, merge
		qui putexcel D8:D9, merge
		qui putexcel F8:F9, merge
		qui putexcel G8:G9, merge
		qui putexcel H8:H9, merge
		qui putexcel A10:A11, merge
		qui putexcel B10:B11, merge
		qui putexcel C10:C11, merge
		qui putexcel D10:D11, merge
		qui putexcel F10:F11, merge
		qui putexcel G10:G11, merge
		qui putexcel H10:H11, merge
		qui putexcel A12:A13, merge
		qui putexcel B12:B13, merge
		qui putexcel C12:C13, merge
		qui putexcel D12:D13, merge
		qui putexcel F12:F13, merge
		qui putexcel G12:G13, merge
		qui putexcel H12:H13, merge
		local row = 8
		qui putexcel A`row' = "hightolow"
		local coef = _b[1.hightolow]
		qui putexcel B`row' = `coef', nformat(# 0.0000) right
		local pval = (2 * ttail(e(df_r), abs(_b[1.hightolow] / _se[1.hightolow]) ) ) 
		display `pval'
		qui putexcel D`row' = `pval', nformat("(0.0000)") hcenter 
		qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 10 
		qui putexcel A`row' = "SameBEARegion"
		local coef = _b[1.PARTSAMEBEAREGION]
		qui putexcel B`row' = `coef', nformat(# 0.0000) right
		local pval = (2 * ttail(e(df_r), abs(_b[1.PARTSAMEBEAREGION] / _se[1.PARTSAMEBEAREGION]) ) ) 
		display `pval'
		qui putexcel D`row' = `pval', nformat("(0.0000)") hcenter 
		qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 12
		qui putexcel A`row' = "hightolow*SameBEARegion"
		local coef = _b[1.hightolow#1.PARTSAMEBEAREGION]
		qui putexcel B`row' = `coef', nformat(# 0.0000) right
		local pval = (2 * ttail(e(df_r), abs(_b[1.hightolow#1.PARTSAMEBEAREGION] / _se[1.hightolow#1.PARTSAMEBEAREGION]) ) ) 
		display `pval'
		qui putexcel D`row' = `pval', nformat("(0.0000)") hcenter 
		qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		qui putexcel A13:H13, border(bottom)
		local row = 14
		qui putexcel A`row' = "Controls"
		qui putexcel B`row':D`row', merge overwritefmt
		qui putexcel F`row':H`row', merge overwritefmt
		qui putexcel B`row' = "Partner & Network & Firm", hcenter
		qui putexcel F`row' = "Partner & Network & Firm", hcenter
		local row = 15
		qui putexcel A`row' = "Fixed Effects"
		qui putexcel B`row':D`row', merge overwritefmt
		qui putexcel F`row':H`row', merge overwritefmt
		qui putexcel B`row' = "Industry & Year", hcenter
		qui putexcel F`row' = "Industry & Year", hcenter
		local row = 16
		qui putexcel A`row' = "SE"
		qui putexcel B`row':D`row', merge overwritefmt
		qui putexcel F`row':H`row', merge overwritefmt
		qui putexcel B`row' = "Cluster @ Firm", hcenter
		qui putexcel F`row' = "Cluster @ Firm", hcenter
		local row = 17
		qui putexcel A`row' = "N"
		qui putexcel B`row':D`row', merge overwritefmt
		qui putexcel F`row':H`row', merge overwritefmt
		qui putexcel B`row' = `e(N)', hcenter
		local row = 18
		qui putexcel A`row' = "Adjusted R2"
		qui putexcel B`row':D`row', merge overwritefmt
		qui putexcel F`row':H`row', merge overwritefmt
		qui putexcel B`row' = `e(r2_a)', nformat(# 0.0000) hcenter
		qui putexcel A`row':H`row', border(bottom) 
		*Table 4 Panel A Specification 2
		reghdfe DELTA_CASH_ETR3 i.hightolow##i.PARTSAMEBEAREGION $NETWORKlist $PARTNERlistBEA $FIRMlist, absorb(IND YEAR) vce(cluster CUSIPNUM)
		local row = 8
		local coef = _b[1.hightolow]
		qui putexcel F`row' = `coef', nformat(# 0.0000) right
		local pval = (2 * ttail(e(df_r), abs(_b[1.hightolow] / _se[1.hightolow]) ) ) 
		display `pval'
		qui putexcel H`row' = `pval', nformat("(0.0000)") hcenter 
		qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 10 
		local coef = _b[1.PARTSAMEBEAREGION]
		qui putexcel F`row' = `coef', nformat(# 0.0000) right
		local pval = (2 * ttail(e(df_r), abs(_b[1.PARTSAMEBEAREGION] / _se[1.PARTSAMEBEAREGION]) ) ) 
		display `pval'
		qui putexcel H`row' = `pval', nformat("(0.0000)") hcenter 
		qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 12
		local coef = _b[1.hightolow#1.PARTSAMEBEAREGION]
		qui putexcel F`row' = `coef', nformat(# 0.0000) right
		local pval = (2 * ttail(e(df_r), abs(_b[1.hightolow#1.PARTSAMEBEAREGION] / _se[1.hightolow#1.PARTSAMEBEAREGION]) ) ) 
		display `pval'
		qui putexcel H`row' = `pval', nformat("(0.0000)") hcenter 
		qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 17
		qui putexcel F`row' = `e(N)', hcenter
		local row = 18
		qui putexcel F`row' = `e(r2_a)', nformat(# 0.0000) hcenter
		}
		
		{	//Table 4 Panel B
		*Table 4 Panel B Specification 1
		reghdfe CASH_ETR3 i.hightolow##i.PARTSAMEIND $NETWORKlist $PARTNERlistBEA $FIRMlist, absorb(YEAR) vce(cluster CUSIPNUM)
		qui putexcel A21:H21, merge 
		qui putexcel A21 = "Panel B Industry", bold
		qui putexcel A21:H21, border(bottom) 
		qui putexcel A22 = "Dependent Variable"
		qui putexcel B22:D22, merge overwritefmt
		qui putexcel B22 = "cash ETR3 [t1; t3]", bold hcenter
		qui putexcel F22:H22, merge overwritefmt
		qui putexcel F22 = "delta cash ETR3", bold hcenter
		qui putexcel B23:C23, merge overwritefmt
		qui putexcel B23 = "Coefficient", hcenter
		qui putexcel F23:G23, merge overwritefmt
		qui putexcel F23 = "Coefficient", hcenter
		qui putexcel D23 = "(p-value)", hcenter
		qui putexcel H23 = "(p-value)", hcenter
		qui putexcel A23:H23, border(bottom) 
		qui putexcel A24:A25, merge
		qui putexcel B24:B25, merge
		qui putexcel C24:C25, merge
		qui putexcel D24:D25, merge
		qui putexcel F24:F25, merge
		qui putexcel G24:G25, merge
		qui putexcel H24:H25, merge
		qui putexcel A26:A27, merge
		qui putexcel B26:B27, merge
		qui putexcel C26:C27, merge
		qui putexcel D26:D27, merge
		qui putexcel F26:F27, merge
		qui putexcel G26:G27, merge
		qui putexcel H26:H27, merge
		qui putexcel A28:A29, merge
		qui putexcel B28:B29, merge
		qui putexcel C28:C29, merge
		qui putexcel D28:D29, merge
		qui putexcel F28:F29, merge
		qui putexcel G28:G29, merge
		qui putexcel H28:H29, merge
		local row = 24
		qui putexcel A`row' = "hightolow"
		local coef = _b[1.hightolow]
		qui putexcel B`row' = `coef', nformat(# 0.0000) right
		local pval = (2 * ttail(e(df_r), abs(_b[1.hightolow] / _se[1.hightolow]) ) ) 
		display `pval'
		qui putexcel D`row' = `pval', nformat("(0.0000)") hcenter 
		qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 26 
		qui putexcel A`row' = "SameInd"
		local coef = _b[1.PARTSAMEIND]
		qui putexcel B`row' = `coef', nformat(# 0.0000) right
		local pval = (2 * ttail(e(df_r), abs(_b[1.PARTSAMEIND] / _se[1.PARTSAMEIND]) ) ) 
		display `pval'
		qui putexcel D`row' = `pval', nformat("(0.0000)") hcenter 
		qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 28
		qui putexcel A`row' = "hightolow*SameInd"
		local coef = _b[1.hightolow#1.PARTSAMEIND]
		qui putexcel B`row' = `coef', nformat(# 0.0000) right
		local pval = (2 * ttail(e(df_r), abs(_b[1.hightolow#1.PARTSAMEIND] / _se[1.hightolow#1.PARTSAMEIND]) ) ) 
		display `pval'
		qui putexcel D`row' = `pval', nformat("(0.0000)") hcenter 
		qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		qui putexcel A29:H29, border(bottom) 
		local row = 30
		qui putexcel A`row' = "Controls"
		qui putexcel B`row':D`row', merge overwritefmt
		qui putexcel F`row':H`row', merge overwritefmt
		qui putexcel B`row' = "Partner & Network & Firm", hcenter
		qui putexcel F`row' = "Partner & Network & Firm", hcenter
		local row = 31
		qui putexcel A`row' = "Fixed Effects"
		qui putexcel B`row':D`row', merge overwritefmt
		qui putexcel F`row':H`row', merge overwritefmt
		qui putexcel B`row' = "Year", hcenter
		qui putexcel F`row' = "Year", hcenter
		local row = 32
		qui putexcel A`row' = "SE"
		qui putexcel B`row':D`row', merge overwritefmt
		qui putexcel F`row':H`row', merge overwritefmt
		qui putexcel B`row' = "Cluster @ Firm", hcenter
		qui putexcel F`row' = "Cluster @ Firm", hcenter
		local row = 33
		qui putexcel A`row' = "N"
		qui putexcel B`row':D`row', merge overwritefmt
		qui putexcel F`row':H`row', merge overwritefmt
		qui putexcel B`row' = `e(N)', hcenter
		local row = 34
		qui putexcel A`row' = "Adjusted R2"
		qui putexcel B`row':D`row', merge overwritefmt
		qui putexcel F`row':H`row', merge overwritefmt
		qui putexcel B`row' = `e(r2_a)', nformat(# 0.0000) hcenter
		qui putexcel A`row':H`row', border(bottom) 
		*Table 4 Panel B Specification 2 
		reghdfe DELTA_CASH_ETR3 i.hightolow##i.PARTSAMEIND $NETWORKlist $PARTNERlistBEA $FIRMlist, absorb(YEAR) vce(cluster CUSIPNUM)
		local row = 24
		local coef = _b[1.hightolow]
		qui putexcel F`row' = `coef', nformat(# 0.0000) right
		local pval = (2 * ttail(e(df_r), abs(_b[1.hightolow] / _se[1.hightolow]) ) ) 
		display `pval'
		qui putexcel H`row' = `pval', nformat("(0.0000)") hcenter 
		qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 26 
		local coef = _b[1.PARTSAMEIND]
		qui putexcel F`row' = `coef', nformat(# 0.0000) right
		local pval = (2 * ttail(e(df_r), abs(_b[1.PARTSAMEIND] / _se[1.PARTSAMEIND]) ) ) 
		display `pval'
		qui putexcel H`row' = `pval', nformat("(0.0000)") hcenter 
		qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 28 
		local coef = _b[1.hightolow#1.PARTSAMEIND]
		qui putexcel F`row' = `coef', nformat(# 0.0000) right
		local pval = (2 * ttail(e(df_r), abs(_b[1.hightolow#1.PARTSAMEIND] / _se[1.hightolow#1.PARTSAMEIND]) ) ) 
		display `pval'
		qui putexcel H`row' = `pval', nformat("(0.0000)") hcenter 
		qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 33
		qui putexcel F`row' = `e(N)', hcenter
		local row = 34
		qui putexcel F`row' = `e(r2_a)', nformat(# 0.0000) hcenter
		qui putexcel A`row':H`row', border(bottom)
		}
		
		{	//Table 4 Panel C
		*Table 4 Panel C Specification 1
		reghdfe CASH_ETR3 i.hightolow##i.PARTSAMEAUDITOR $NETWORKlist $PARTNERlistBEA $FIRMlist, absorb(IND YEAR) vce(cluster CUSIPNUM)
		qui putexcel A37:H37, merge 
		qui putexcel A37 = "Panel C Auditor", bold
		qui putexcel A37:H37, border(bottom) 
		qui putexcel A38 = "Dependent Variable"
		qui putexcel B38:D38, merge overwritefmt
		qui putexcel B38 = "cash ETR3 [t1; t3]", bold hcenter
		qui putexcel F38:H38, merge overwritefmt
		qui putexcel F38 = "delta cash ETR3", bold hcenter
		qui putexcel B39:C39, merge overwritefmt
		qui putexcel B39 = "Coefficient", hcenter
		qui putexcel F39:G39, merge overwritefmt
		qui putexcel F39 = "Coefficient", hcenter
		qui putexcel D39 = "(p-value)", hcenter
		qui putexcel H39 = "(p-value)", hcenter
		qui putexcel A39:H39, border(bottom) 
		qui putexcel A40:A41, merge
		qui putexcel B40:B41, merge
		qui putexcel C40:C41, merge
		qui putexcel D40:D41, merge
		qui putexcel F40:F41, merge
		qui putexcel G40:G41, merge
		qui putexcel H40:H41, merge
		qui putexcel A42:A43, merge
		qui putexcel B42:B43, merge
		qui putexcel C42:C43, merge
		qui putexcel D42:D43, merge
		qui putexcel F42:F43, merge
		qui putexcel G42:G43, merge
		qui putexcel H42:H43, merge
		qui putexcel A44:A45, merge
		qui putexcel B44:B45, merge
		qui putexcel C44:C45, merge
		qui putexcel D44:D45, merge
		qui putexcel F44:F45, merge
		qui putexcel G44:G45, merge
		qui putexcel H44:H45, merge
		local row = 40
		qui putexcel A`row' = "hightolow"
		local coef = _b[1.hightolow]
		qui putexcel B`row' = `coef', nformat(# 0.0000) right
		local pval = (2 * ttail(e(df_r), abs(_b[1.hightolow] / _se[1.hightolow]) ) ) 
		display `pval'
		qui putexcel D`row' = `pval', nformat("(0.0000)") hcenter 
		qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 42 
		qui putexcel A`row' = "SameAuditor"
		local coef = _b[1.PARTSAMEAUDITOR]
		qui putexcel B`row' = `coef', nformat(# 0.0000) right
		local pval = (2 * ttail(e(df_r), abs(_b[1.PARTSAMEAUDITOR] / _se[1.PARTSAMEAUDITOR]) ) ) 
		display `pval'
		qui putexcel D`row' = `pval', nformat("(0.0000)") hcenter 
		qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 44 
		qui putexcel A`row' = "hightolow*SameAuditor"
		local coef = _b[1.hightolow#1.PARTSAMEAUDITOR]
		qui putexcel B`row' = `coef', nformat(# 0.0000) right
		local pval = (2 * ttail(e(df_r), abs(_b[1.hightolow#1.PARTSAMEAUDITOR] / _se[1.hightolow#1.PARTSAMEAUDITOR]) ) ) 
		display `pval'
		qui putexcel D`row' = `pval', nformat("(0.0000)") hcenter 
		qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		qui putexcel A45:H45, border(bottom)
		local row = 46
		qui putexcel A`row' = "Controls"
		qui putexcel B`row':D`row', merge overwritefmt
		qui putexcel F`row':H`row', merge overwritefmt
		qui putexcel B`row' = "Partner & Network & Firm", hcenter
		qui putexcel F`row' = "Partner & Network & Firm", hcenter
		local row = 47
		qui putexcel A`row' = "Fixed Effects"
		qui putexcel B`row':D`row', merge overwritefmt
		qui putexcel F`row':H`row', merge overwritefmt
		qui putexcel B`row' = "Industry & Year", hcenter
		qui putexcel F`row' = "Industry & Year", hcenter
		local row = 48
		qui putexcel A`row' = "SE"
		qui putexcel B`row':D`row', merge overwritefmt
		qui putexcel F`row':H`row', merge overwritefmt
		qui putexcel B`row' = "Cluster @ Firm", hcenter
		qui putexcel F`row' = "Cluster @ Firm", hcenter
		local row = 49
		qui putexcel A`row' = "N"
		qui putexcel B`row':D`row', merge overwritefmt
		qui putexcel F`row':H`row', merge overwritefmt
		qui putexcel B`row' = `e(N)', hcenter
		local row = 50
		qui putexcel A`row' = "Adjusted R2"
		qui putexcel B`row':D`row', merge overwritefmt
		qui putexcel F`row':H`row', merge overwritefmt
		qui putexcel B`row' = `e(r2_a)', nformat(# 0.0000) hcenter
		qui putexcel A`row':H`row', border(bottom) 
		*Table 4 Panel C Specification 1
		reghdfe DELTA_CASH_ETR3 i.hightolow##i.PARTSAMEAUDITOR $NETWORKlist $PARTNERlistBEA $FIRMlist, absorb(IND YEAR) vce(cluster CUSIPNUM)
		local row = 40
		local coef = _b[1.hightolow]
		qui putexcel F`row' = `coef', nformat(# 0.0000) right
		local pval = (2 * ttail(e(df_r), abs(_b[1.hightolow] / _se[1.hightolow]) ) ) 
		display `pval'
		qui putexcel H`row' = `pval', nformat("(0.0000)") hcenter 
		qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 42 
		local coef = _b[1.PARTSAMEAUDITOR]
		qui putexcel F`row' = `coef', nformat(# 0.0000) right
		local pval = (2 * ttail(e(df_r), abs(_b[1.PARTSAMEAUDITOR] / _se[1.PARTSAMEAUDITOR]) ) ) 
		display `pval'
		qui putexcel H`row' = `pval', nformat("(0.0000)") hcenter 
		qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 44 
		local coef = _b[1.hightolow#1.PARTSAMEAUDITOR]
		qui putexcel F`row' = `coef', nformat(# 0.0000) right
		local pval = (2 * ttail(e(df_r), abs(_b[1.hightolow#1.PARTSAMEAUDITOR] / _se[1.hightolow#1.PARTSAMEAUDITOR]) ) ) 
		display `pval'
		qui putexcel H`row' = `pval', nformat("(0.0000)") hcenter 
		qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 49
		qui putexcel F`row' = `e(N)', hcenter
		local row = 50
		qui putexcel F`row' = `e(r2_a)', nformat(# 0.0000) hcenter
		*Format 
		qui putexcel A3:H3, merge
		qui putexcel A3 = "Table 4 Additional Analyses", hcenter bold 
		qui putexcel A3, hcenter 
		qui putexcel A1:H`row', font("Times New Roman", 11)
		qui putexcel A1:H`row', vcenter 
	}	
		
} 

		{	//Table 5 Robustness Checks: Alternative Explanations  
		qui putexcel set "${pathOUTPUT}\02_TAB\01_`time_string'_TABLES_AS_IN_PAPER.xlsx", sheet(T5_Rob_AltExplanations) modify
		
		{	//Table 5 Panel A
		*Exclude Non-Survivors (network falls within last 3 years of firms in sample)
		gen vhelp = LAST 															// LAST = MAX(FYEAR) - CURRENT(FYEAR)
		replace vhelp = . if missing(COOPFIRMYEAR)
		replace vhelp =  . if YEAR == 2014 | YEAR == 2015 | YEAR == 2016			//Non-Survivors are not determined by end of panel 
		reghdfe DELTA_CASH_ETR3 i.hightolow $NETWORKlist $PARTNERlist $FIRMlist if vhelp > 2, absorb(IND YEAR) vce(cluster CUSIPNUM)
		drop vhelp
		qui putexcel A5 = "Panel A Survivorship Bias", bold
		qui putexcel A5:D5, merge overwritefmt
		qui putexcel A5:D5, border(bottom) overwritefmt
		qui putexcel A6 = "Dependent Variable"
		qui putexcel B6:D6, merge overwritefmt
		qui putexcel B6 = "delta cash ETR3", bold
		qui putexcel A7 = "Specification"
		qui putexcel B7:D7, merge overwritefmt
		qui putexcel B7 = "exclude nonsurvivors", 
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
		}
		
		{	//Table 5 Panel B
		*Decreases in ETR
		reghdfe DELTA_CASH_ETR3 i.hightolow $NETWORKlist $PARTNERlist $FIRMlist if DELTA_CASH_ETR3 < 1, absorb(IND YEAR) vce(cluster CUSIPNUM)
		qui putexcel G5 = "Panel B Increases in cash ETR3", bold
		qui putexcel G5:J5, merge overwritefmt
		qui putexcel G5:J5, border(bottom) overwritefmt
		qui putexcel G6 = "Dependent Variable"
		qui putexcel H6:J6, merge overwritefmt
		qui putexcel H6 = "delta cash ETR3", bold
		qui putexcel G7 = "Specification"
		qui putexcel H7:J7, merge overwritefmt
		qui putexcel H7 = "if delta cash ETR3 < 1"
		qui putexcel H8:I8, merge overwritefmt
		qui putexcel H8 = "Coefficient" 
		qui putexcel J8 = "(p-value)"
		qui putexcel G8:J8, border(bottom) overwritefmt
		qui putexcel G9:G10, merge 
		qui putexcel H9:H10, merge 
		qui putexcel I9:I10, merge 
		qui putexcel J9:J10, merge 
		local row = 9
		qui putexcel G`row' = "hightolow"
		display _b[1.hightolow]
		local coef = _b[1.hightolow]
		qui putexcel H`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[1.hightolow] / _se[1.hightolow]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel J`row' = `pval' 
		qui putexcel I`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 11
		qui putexcel G`row' = "Proximity"
		display _b[PROXIMITY]
		local coef = _b[PROXIMITY]
		qui putexcel H`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[PROXIMITY] / _se[PROXIMITY]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel J`row' = `pval' 
		qui putexcel I`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 12
		qui putexcel G`row' = "SameAuditor"
		display _b[1.PARTSAMEAUDITOR]
		local coef = _b[1.PARTSAMEAUDITOR]
		qui putexcel H`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[1.PARTSAMEAUDITOR] / _se[1.PARTSAMEAUDITOR]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel J`row' = `pval' 
		qui putexcel I`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		qui putexcel G`row':J`row', border(bottom) overwritefmt
		qui putexcel G13 = "Network Controls"
		qui putexcel G14 = "Firm Controls"
		qui putexcel G15 = "Fixed Effects"
		qui putexcel G16 = "SE"
		qui putexcel G17 = "N"
		qui putexcel G18 = "Adjusted R2"
		qui putexcel H13:J13, merge overwritefmt
		qui putexcel H13 = "Yes"
		qui putexcel H14:J14, merge overwritefmt
		qui putexcel H14 = "Yes"
		qui putexcel H15:J15, merge overwritefmt
		qui putexcel H15 = "Industry & Year"
		qui putexcel H16:J16, merge overwritefmt
		qui putexcel H16 = "Cluster @ Firm"
		qui putexcel H17:J17, merge overwritefmt
		qui putexcel H17 = `e(N)'
		qui putexcel H18:J18, merge overwritefmt
		qui putexcel H18 = `e(r2_a)'
		qui putexcel G18:J18, border(bottom) overwritefmt
		}
		
		{	//Table 5 Panel C
		*lowtohigh
		reghdfe CASH_ETR3 i.lowtohigh $NETWORKlist $PARTNERlistBEA $FIRMlist, absorb(IND YEAR) vce(cluster CUSIPNUM)
		qui putexcel A20 = "Panel C low-tax firms", bold
		qui putexcel A20:D20, merge overwritefmt
		qui putexcel A20:D20, border(bottom) overwritefmt
		qui putexcel A21 = "Dependent Variable"
		qui putexcel B21:D21, merge overwritefmt
		qui putexcel B21 = "cash ETR3 [t1; t3]", bold
		qui putexcel A22 = "Specification"
		qui putexcel B22:D22, merge overwritefmt
		qui putexcel B22 = "only low-tax firms"
		qui putexcel B23:C23, merge overwritefmt
		qui putexcel B23 = "Coefficient" 
		qui putexcel D23 = "(p-value)"
		qui putexcel A23:D23, border(bottom) overwritefmt
		qui putexcel A24:A25, merge 
		qui putexcel B24:B25, merge 
		qui putexcel C24:C25, merge 
		qui putexcel D24:D25, merge 
		local row = 24
		qui putexcel A`row' = "lowtohigh"
		display _b[1.lowtohigh]
		local coef = _b[1.lowtohigh]
		qui putexcel B`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[1.lowtohigh] / _se[1.lowtohigh]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel D`row' = `pval' 
		qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 26
		qui putexcel A`row' = "SameBEARegion"
		display _b[1.PARTSAMEBEAREGION]
		local coef = _b[1.PARTSAMEBEAREGION]
		qui putexcel B`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[1.PARTSAMEBEAREGION] / _se[1.PARTSAMEBEAREGION]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel D`row' = `pval' 
		qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 27
		qui putexcel A`row' = "SameAuditor"
		display _b[1.PARTSAMEAUDITOR]
		local coef = _b[1.PARTSAMEAUDITOR]
		qui putexcel B`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[1.PARTSAMEAUDITOR] / _se[1.PARTSAMEAUDITOR]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel D`row' = `pval' 
		qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		qui putexcel A`row':D`row', border(bottom) overwritefmt
		qui putexcel A28 = "Network Controls"
		qui putexcel A29 = "Firm Controls"
		qui putexcel A30 = "Fixed Effects"
		qui putexcel A31 = "SE"
		qui putexcel A32 = "N"
		qui putexcel A33 = "Adjusted R2"
		qui putexcel B28:D28, merge overwritefmt
		qui putexcel B28 = "Yes"
		qui putexcel B29:D29, merge overwritefmt
		qui putexcel B29 = "Yes"
		qui putexcel B30:D30, merge overwritefmt
		qui putexcel B30 = "Industry & Year"
		qui putexcel B31:D31, merge overwritefmt
		qui putexcel B31 = "Cluster @ Firm"
		qui putexcel B32:D32, merge overwritefmt
		qui putexcel B32 = `e(N)'
		qui putexcel B33:D33, merge overwritefmt
		qui putexcel B33 = `e(r2_a)'
		qui putexcel A33:D33, border(bottom) overwritefmt
		}
		
		{	//Table 5 Panel D
		*Effect on Profitability
		reghdfe PROFITABILITY3 i.hightolow $NETWORKlist $PARTNERlist $FIRMlistnoebitda, absorb(IND YEAR) vce(cluster CUSIPNUM) 
		qui putexcel G20 = "Panel D Profitability", bold
		qui putexcel G20:J20, merge overwritefmt
		qui putexcel G20:J20, border(bottom) overwritefmt
		qui putexcel G21 = "Dependent Variable"
		qui putexcel H21:J21, merge overwritefmt
		qui putexcel H21 = "Profitability3 [t1; t3]", bold
		qui putexcel H23:I23, merge overwritefmt
		qui putexcel H23 = "Coefficient" 
		qui putexcel J23 = "(p-value)"
		qui putexcel G23:J23, border(bottom) overwritefmt
		qui putexcel G24:G25, merge 
		qui putexcel H24:H25, merge 
		qui putexcel I24:I25, merge 
		qui putexcel J24:J25, merge 
		local row = 24
		qui putexcel G`row' = "hightolow"
		display _b[1.hightolow]
		local coef = _b[1.hightolow]
		qui putexcel H`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[1.hightolow] / _se[1.hightolow]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel J`row' = `pval' 
		qui putexcel I`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 26
		qui putexcel G`row' = "Proximity"
		display _b[PROXIMITY]
		local coef = _b[PROXIMITY]
		qui putexcel H`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[PROXIMITY] / _se[PROXIMITY]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel J`row' = `pval' 
		qui putexcel I`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 27
		qui putexcel G`row' = "SameAuditor"
		display _b[1.PARTSAMEAUDITOR]
		local coef = _b[1.PARTSAMEAUDITOR]
		qui putexcel H`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[1.PARTSAMEAUDITOR] / _se[1.PARTSAMEAUDITOR]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel J`row' = `pval' 
		qui putexcel I`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		qui putexcel G`row':J`row', border(bottom) overwritefmt
		qui putexcel G28 = "Networks Controls"
		qui putexcel G29 = "Firm Controls"
		qui putexcel G30 = "Fixed Effects"
		qui putexcel G31 = "SE"
		qui putexcel G32 = "N"
		qui putexcel G33 = "Adjusted R2"
		qui putexcel H28:J28, merge overwritefmt
		qui putexcel H28 = "Yes"
		qui putexcel H29:J29, merge overwritefmt
		qui putexcel H29 = "Yes (EBITDA3 excluded)"
		qui putexcel H30:J30, merge overwritefmt
		qui putexcel H30 = "Industry & Year"
		qui putexcel H31:J31, merge overwritefmt
		qui putexcel H31 = "Cluster @ Firm"
		qui putexcel H32:J32, merge overwritefmt
		qui putexcel H32 = `e(N)'
		qui putexcel H33:J33, merge overwritefmt
		qui putexcel H33 = `e(r2_a)'
		qui putexcel G33:J33, border(bottom) overwritefmt
		*Format 
		qui putexcel A3:J3, merge overwritefmt
		qui putexcel A3 = "Table 5 Robustness Checks: Alternative Explanations", bold hcenter 
		qui putexcel B6:D8 H6:J8 B21:D23 H21:J23, hcenter
		qui putexcel B13:B17 H13:H17 B28:B32 H28:H32, hcenter
		qui putexcel B9:B12 H9:H12 B24:B27 H24:H27, nformat(# 0.0000) right
		qui putexcel D9:D12 J9:J12 D24:D27 J24:J27, nformat(# (0.0000)) hcenter
		qui putexcel B18 B33 H18 H33, nformat(# 0.0000) hcenter
		qui putexcel A5 A20 G5 G20, bold 
		qui putexcel A9:D10 G9:J10 A24:D25 G24:J25, bold 
		qui putexcel A1:J33, font("Times New Roman", 11)
		qui putexcel A1:J33, vcenter 
		}

		}
		
		{	//Table 6 Robustness Checks: Alternative Tax Knowledge Measrues 
		qui putexcel set "${pathOUTPUT}\02_TAB\01_`time_string'_TABLES_AS_IN_PAPER.xlsx", sheet(T6_Rob_AltTaxKnowledge) modify
		
		{	//Table 6 Specification 1 (CTD)
		qui putexcel A5:H5, merge overwritefmt
		qui putexcel A5:H5, border(bottom) overwritefmt
		qui putexcel A5 = "Henry/Sansing Cash Tax Differential (CTD) & GAAP ETR", bold
		qui putexcel A6 = "Dependent Variable"
		qui putexcel B6:D6, merge overwritefmt
		qui putexcel B7:C7, merge
		qui putexcel B6 = "CTD"
		qui putexcel F6:H6, merge overwritefmt
		qui putexcel F6 = "GAAP ETR"
		qui putexcel B7 = "Coefficient" 
		qui putexcel D7 = "(p-value)"
		qui putexcel F7:G7, merge 
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
		qui putexcel A10:A11, merge 
		qui putexcel B10:B11, merge 
		qui putexcel C10:C11, merge 
		qui putexcel D10:D11, merge 
		qui putexcel E10:E11, merge 
		qui putexcel F10:F11, merge 
		qui putexcel G10:G11, merge 
		qui putexcel H10:H11, merge 
		qui putexcel A12:A13, merge 
		qui putexcel B12:B13, merge 
		qui putexcel C12:C13, merge 
		qui putexcel D12:D13, merge 
		qui putexcel E12:E13, merge 
		qui putexcel F12:F13, merge 
		qui putexcel G12:G13, merge 
		qui putexcel H12:H13, merge 
		reghdfe CTD1 TREATED##POST $FIRMlistannual if !missing(CASH_ETR1), absorb(IND) vce(cluster CUSIPNUM)
		local row = 8
		qui putexcel A`row' = "treated"
		display _b[1.TREATED]
		local coef = _b[1.TREATED]
		qui putexcel B`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[1.TREATED] / _se[1.TREATED]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel D`row' = `pval' 
		qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 10
		qui putexcel A`row' = "post"
		display _b[1.POST]
		local coef = _b[1.POST]
		qui putexcel B`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[1.POST] / _se[1.POST]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
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
		qui putexcel A13:H13, border(bottom) overwritefmt
		qui putexcel A14 = "Firm Controls"
		qui putexcel A15 = "Fixed Effects"
		qui putexcel A16 = "SE"
		qui putexcel A17 = "N"
		qui putexcel A18 = "Adjusted R2"
		qui putexcel B14:D14, merge overwritefmt
		qui putexcel B14 = "Yes (Annual Measures)"
		qui putexcel F14:H14, merge overwritefmt
		qui putexcel F14 = "Yes (Annual Measures)"
		qui putexcel B15:D15, merge overwritefmt
		qui putexcel B15 = "Industry"
		qui putexcel F15:H15, merge overwritefmt
		qui putexcel F15 = "Industry"
		qui putexcel B16:D16, merge overwritefmt
		qui putexcel B16 = "Cluster @ Firm"
		qui putexcel F16:H16, merge overwritefmt
		qui putexcel F16 = "Cluster @ Firm"
		qui putexcel B17:D17, merge overwritefmt
		qui putexcel B17 = `e(N)'
		qui putexcel B18:D18, merge overwritefmt
		qui putexcel B18 = `e(r2_a)'
		}
		
		{	//Table 6 Specification 1 (GAAP ETR)
		reghdfe GAAP_ETR1 TREATED##POST $FIRMlistannual if !missing(CASH_ETR1), absorb(IND) vce(cluster CUSIPNUM)
		local coef = _b[1.TREATED]
		local row = 8
		qui putexcel F`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[1.TREATED] / _se[1.TREATED]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel H`row' = `pval' 
		qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 10
		display _b[1.POST]
		local coef = _b[1.POST]
		qui putexcel F`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[1.POST] / _se[1.POST]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel H`row' = `pval' 
		qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 12
		display _b[1.TREATED#1.POST]
		local coef = _b[1.TREATED#1.POST]
		qui putexcel F`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[1.TREATED#1.POST] / _se[1.TREATED#1.POST]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel H`row' = `pval' 
		qui putexcel G`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		qui putexcel F17:H17, merge overwritefmt
		qui putexcel F17 = `e(N)'
		qui putexcel F18:H18, merge overwritefmt
		qui putexcel F18 = `e(r2_a)'
		qui putexcel A18:H18, border(bottom) overwritefmt
		*Format
		qui putexcel A3:H3, merge overwritefmt
		qui putexcel A3 = "Table 6 Robustness Checks: Alternative Tax Knowledge Measures", bold 
		qui putexcel A3, hcenter
		qui putexcel B6:H7, hcenter 
		qui putexcel B14:H17, hcenter 
		qui putexcel B8:B13 F8:F13, nformat(# 0.0000) right
		qui putexcel B18 F18, nformat(# 0.0000) hcenter
		qui putexcel D8:D13 H8:H13, nformat(# (0.0000)) hcenter 
		qui putexcel A12:H13 B6:H6, bold 
		qui putexcel A1:H22, font("Times New Roman", 11) 
		qui putexcel A1:H22, vcenter
		}
		
		}
		
		{	//Table 7 Robustness Checks: Alternative Identification Strategy
		qui putexcel set "${pathOUTPUT}\02_TAB\01_`time_string'_TABLES_AS_IN_PAPER.xlsx", sheet(T7_Rob_AltIdentification) modify
		reg CASH_ETR3 i.HIGHTAXFIRM##c.PARTPRECETR3 $PARTNERlistBEA $NETWORKlist $FIRMlist i.IND, vce(robust)
		qui putexcel A5 = "Interact Indicator with Continuous Variable", bold
		qui putexcel A5:D5, merge overwritefmt
		qui putexcel A5:D5, border(bottom) overwritefmt
		qui putexcel A6 = "Dependent Variable"
		qui putexcel B6:D6, merge overwritefmt
		qui putexcel B6 = "cash ETR3 [t1; t3]", bold
		qui putexcel B7:C7, merge overwritefmt
		qui putexcel B7 = "Coefficient" 
		qui putexcel D7= "(p-value)"
		qui putexcel A7:D7, border(bottom) overwritefmt
		qui putexcel A8:A9, merge 
		qui putexcel B8:B9, merge 
		qui putexcel C8:C9, merge 
		qui putexcel D8:D9, merge
		qui putexcel A10:A11, merge 
		qui putexcel B10:B11, merge 
		qui putexcel C10:C11, merge 
		qui putexcel D10:D11, merge
		qui putexcel A12:A13, merge 
		qui putexcel B12:B13, merge 
		qui putexcel C12:C13, merge 
		qui putexcel D12:D13, merge
		local row = 8
		qui putexcel A`row' = "high-tax firm"
		display _b[1.HIGHTAXFIRM ]
		local coef = _b[1.HIGHTAXFIRM ]
		qui putexcel B`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[1.HIGHTAXFIRM ] / _se[1.HIGHTAXFIRM ]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel D`row' = `pval' 
		qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 10
		qui putexcel A`row' = "partner pre cash ETR3 [t-2; t0]"
		display _b[PARTPRECETR3]
		local coef = _b[PARTPRECETR3]
		qui putexcel B`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[PARTPRECETR3] / _se[PARTPRECETR3]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel D`row' = `pval' 
		qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 12
		qui putexcel A`row' = "high-tax firm * partner pre cash ETR3 [t-2; t0]"
		display _b[1.HIGHTAXFIRM#PARTPRECETR3]
		local coef = _b[1.HIGHTAXFIRM#PARTPRECETR3]
		qui putexcel B`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[1.HIGHTAXFIRM#PARTPRECETR3] / _se[1.HIGHTAXFIRM#PARTPRECETR3]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel D`row' = `pval' 
		qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 14
		qui putexcel A`row' = "SameBEARegion"
		display _b[1.PARTSAMEBEAREGION]
		local coef = _b[1.PARTSAMEBEAREGION]
		qui putexcel B`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[1.PARTSAMEBEAREGION] / _se[1.PARTSAMEBEAREGION]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel D`row' = `pval' 
		qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 15
		qui putexcel A`row' = "SameAuditor"
		display _b[1.PARTSAMEAUDITOR]
		local coef = _b[1.PARTSAMEAUDITOR]
		qui putexcel B`row' = `coef'
		local pval = (2 * ttail(e(df_r), abs(_b[1.PARTSAMEAUDITOR] / _se[1.PARTSAMEAUDITOR]) ) )  // https://stackoverflow.com/questions/55301924/export-p-values-from-reghdfe-to-excel
		display `pval'
		qui putexcel D`row' = `pval' 
		qui putexcel C`row' = formula(IF(`pval'>=0.10,"",IF(`pval'>=0.05,"*",IF(`pval'>=0.01,"**",IF(`pval'>=0,"***","")))))
		local row = 15
		qui putexcel A`row':D`row', border(bottom) overwritefmt
		qui putexcel A16 = "Network Controls"
		qui putexcel A17 = "Firm Controls"
		qui putexcel A18 = "Fixed Effects"
		qui putexcel A19 = "SE"
		qui putexcel A20 = "N"
		qui putexcel A21 = "Adjusted R2"
		qui putexcel B16:D16, merge overwritefmt
		qui putexcel B16 = "Yes"
		qui putexcel B17:D17, merge overwritefmt
		qui putexcel B17 = "Yes"
		qui putexcel B18:D18, merge overwritefmt
		qui putexcel B18 = "Industry"
		qui putexcel B19:D19, merge overwritefmt
		qui putexcel B19 = "Robust"
		qui putexcel B20:D20, merge overwritefmt
		qui putexcel B20 = `e(N)'
		qui putexcel B21:D21, merge overwritefmt
		qui putexcel B21 = `e(r2_a)'
		qui putexcel A21:D21, border(bottom) overwritefmt
		*Format
		qui putexcel A3:D3, merge overwritefmt
		qui putexcel A3 = "Table 7 Robustness Checks: Alternative Identification Strategy", bold hcenter 
		qui putexcel B6:D7, hcenter
		qui putexcel B16:B21, hcenter
		qui putexcel B8:B15, nformat(# 0.0000) right
		qui putexcel D8:D15, nformat(# (0.0000)) hcenter
		qui putexcel B21, nformat(# 0.0000) hcenter
		qui putexcel A5, bold 
		qui putexcel A12:D13, bold 
		local row = 21 
		qui putexcel A1:D`row', font("Times New Roman", 11)
		qui putexcel A1:D`row', vcenter 
		}
		
}

clear
		