clear
set more off 


****************************************************
*******          COMPUSTAT DATA            *********
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

use "${pathCOMPUSTAT}\COMPUSTAT_RAW.dta", clear 
*Compustat North America Daily as of 02/22/2019, requires "cusip"

{	//Duplicates & data flaws
*CUSIP as identifier for matching SDC data 
	drop if missing(cusip)

*Financial Year
	drop if missing(fyear)

*Data format 
*indfmt datafmt popsrc consol curcd
	drop if consol != "C"		//Consolidated Accounts Only
	drop if datafmt != "STD"	//Represents standardized annual data and standardized restated interim data. The interim data for prior periods is restated using a subsequent filing.
	drop if indfmt != "INDL"
	drop if popsrc != "D" 		//D = Domestic Corporations. But: "Domestic includes Canadian Companies and ADRs!"
	drop if curcd != "USD"		//Analyzing domestic corporations 
	drop if fic != "USA"		//Analyzing domestic corporations
	drop if loc != "USA"		//Analyzing domestic corporations
	
*Duplicates 
	duplicates report gvkey fyear if indfmt == "INDL" & datafmt=="STD" & popsrc=="D" & consol=="C" //No duplicates in gvkey fyear reported
	duplicates tag gvkey fyear, ge(dup)
	sort gvkey fyear
	by gvkey: egen flag=max(dup)
	tab flag
	*isid gvkey fyear //works
	*isid cusip fyear //works (cusip in Compustat is originally 9-digit)
	drop dup
	
compress _all
}

{	//6-digit CUSIP 
*Information 
	//https://www.cusip.com/pdf/CUSIP_Intro_03.14.11.pdf (consider pages in the following)
	
*Issuer Identifier
	//p. 4: six characters will be assigned to an issuer
	gen CUSIP6 = substr(cusip, 1, 6) 
	*isid fyear CUSIP6 //No. There are several Issues of one Issuer included
	
*Issue Identifier
	//p. 4: The issue identifier uniquely identifies each individual issue of an issuer
	gen CUSIPISSUE = substr(cusip, 7, 2) 
	*Equity Issue "10" identifies "COM" (Common) 
	drop if CUSIPISSUE != "10"
	destring CUSIPISSUE, replace 
	
*isid fyear CUSIP6
}

{	//Lead & lag variables
*Period for analysis: 1994 - 2016
	drop if fyear < 1994 
	drop if fyear > 2016

*List of variables 
	// fyear pi spi txt txpd at ebitda oibdp xrd sale xad xsga capx ppegt dltt dlc che pifo tlcf intan 

*Create Leads
sort CUSIP6 fyear
	foreach var of varlist fyear pi spi txt txpd at ebitda oibdp xrd sale xad xsga capx ppegt dltt dlc che pifo tlcf intan {
		forvalues q = 1(1)5{
			by CUSIP6: gen LEAD_`var'_`q' = `var'[_n+`q']
		}
	}

*Create Lags
gsort CUSIP6 -fyear
	foreach var of varlist fyear pi spi txt txpd at ebitda oibdp xrd sale xad xsga capx ppegt dltt dlc che pifo tlcf intan {
		forvalues q = 1(1)5{
			by CUSIP6: gen LAG_`var'_`q' = `var'[_n+`q']
		}
	}
sort CUSIP6 fyear

}

{	//Effective Tax Rate (ETR)
	sort CUSIP6 fyear

{	//Special items: reset to 0 if missing (common approach)
	replace spi = 0 if missing(spi) 
	replace LEAD_spi_1 = 0 if missing(LEAD_spi_1)
	replace LEAD_spi_2 = 0 if missing(LEAD_spi_2)
	replace LEAD_spi_3 = 0 if missing(LEAD_spi_3)
	replace LEAD_spi_4 = 0 if missing(LEAD_spi_4)
	replace LEAD_spi_5 = 0 if missing(LEAD_spi_5)
	replace LAG_spi_1 = 0 if missing(LAG_spi_1)
	replace LAG_spi_2 = 0 if missing(LAG_spi_2)
	replace LAG_spi_3 = 0 if missing(LAG_spi_3)
	replace LAG_spi_4 = 0 if missing(LAG_spi_4)
	replace LAG_spi_5 = 0 if missing(LAG_spi_5)
	}

{	//Denominator
	*ETR = Numerator (varies with measure) / denominator (does not vary with measures)
	*One Year 
	by CUSIP6: gen DENOMINATOR1 = pi - spi 			//pretax income adjusted by special items
	*Three Years Forward 
	by CUSIP6: gen vhelp1 = pi - spi 
	by CUSIP6: gen vhelp2 = LEAD_pi_1 - LEAD_spi_1 
	by CUSIP6: gen vhelp3 = LEAD_pi_2 - LEAD_spi_2 
	by CUSIP6: gen  DENOMINATOR3 = vhelp1 + vhelp2 + vhelp3
	drop vhelp*
	*Five Years Forward 
	by CUSIP6: gen vhelp1 = pi - spi 
	by CUSIP6: gen vhelp2 = LEAD_pi_1 - LEAD_spi_1 
	by CUSIP6: gen vhelp3 = LEAD_pi_2 - LEAD_spi_2 
	by CUSIP6: gen vhelp4 = LEAD_pi_3 - LEAD_spi_3 
	by CUSIP6: gen vhelp5 = LEAD_pi_4 - LEAD_spi_4 
	by CUSIP6: gen  DENOMINATOR5 = vhelp1 + vhelp2 + vhelp3 + vhelp4 + vhelp5
	drop vhelp*
	*Three Years Backward 
	by CUSIP6: gen vhelp1 = pi - spi 
	by CUSIP6: gen vhelp2 = LAG_pi_1 - LAG_spi_1 
	by CUSIP6: gen vhelp3 = LAG_pi_2 - LAG_spi_2
	by CUSIP6: gen  LAG_DENOMINATOR3 = vhelp1 + vhelp2 + vhelp3 
	drop vhelp*
	*Five Years Backward 
	by CUSIP6: gen vhelp1 = pi - spi 
	by CUSIP6: gen vhelp2 = LAG_pi_1 - LAG_spi_1 
	by CUSIP6: gen vhelp3 = LAG_pi_2 - LAG_spi_2
	by CUSIP6: gen vhelp4 = LAG_pi_3 - LAG_spi_3
	by CUSIP6: gen vhelp5 = LAG_pi_4 - LAG_spi_4
	by CUSIP6: gen  LAG_DENOMINATOR5 = vhelp1 + vhelp2 + vhelp3 + vhelp4 + vhelp5
	drop vhelp*
}

{	//Cash ETR
*Current Year
	//Measure 
	by CUSIP6: gen CASH_ETR1 = txpd/DENOMINATOR1
	replace CASH_ETR1 = . if DENOMINATOR1 < 0
	
*3 Year Rolling Forward 
	//Measure 
	by CUSIP6: gen vhelp = txpd + LEAD_txpd_1 + LEAD_txpd_2
	by CUSIP6: gen CASH_ETR3 = vhelp/DENOMINATOR3
	drop vhelp*
	replace CASH_ETR3 = . if DENOMINATOR3 < 0
	
*5 Year Rolling Forward
	by CUSIP6: gen vhelp = txpd + LEAD_txpd_1 + LEAD_txpd_2 + LEAD_txpd_3 + LEAD_txpd_4
	by CUSIP6: gen CASH_ETR5 = vhelp/DENOMINATOR5
	drop vhelp*
	replace CASH_ETR5 = . if DENOMINATOR5 < 0

*3 Year Rolling Backward
	by CUSIP6: gen vhelp = txpd + LAG_txpd_1 + LAG_txpd_2
	by CUSIP6: gen PRE_CASH_ETR3 = vhelp/LAG_DENOMINATOR3
	drop vhelp*
	replace PRE_CASH_ETR3 = . if LAG_DENOMINATOR3 < 0

*5 Year Rolling Backward
	by CUSIP6: gen vhelp = txpd + LAG_txpd_1 + LAG_txpd_2 + LAG_txpd_3 + LAG_txpd_4
	by CUSIP6: gen PRE_CASH_ETR5 = vhelp/LAG_DENOMINATOR5
	drop vhelp*
	replace PRE_CASH_ETR5 = . if LAG_DENOMINATOR5 < 0

	//Substitution for edge-firm-years
	*Example: CASH_ETR3 would always be missing in 2016 (edge of sample) 
	*>> requires a substitution, while ensuring that one does not misinterpret multiyear measures
	sort CUSIP6 fyear 
	by CUSIP6: egen FYEAR_MAX = max(fyear)
	by CUSIP6: gen LAST = FYEAR_MAX-fyear
	replace CASH_ETR3 = CASH_ETR1 if !missing(CASH_ETR1) & LAST <= 1
	replace CASH_ETR5 = CASH_ETR3 if missing(CASH_ETR5) & !missing(CASH_ETR3)
	replace PRE_CASH_ETR5 = PRE_CASH_ETR3 if missing(PRE_CASH_ETR5) & !missing(PRE_CASH_ETR3) 
	drop FYEAR_MAX
	
	//Winsorizing
		//CASH_ETR1
		replace CASH_ETR1 = 0 if CASH_ETR1 < 0
		replace CASH_ETR1 = 1 if CASH_ETR1 > 1 & !missing(CASH_ETR1)
		
		//CASH_ETR3
		replace CASH_ETR3 = 0 if CASH_ETR3 < 0
		replace CASH_ETR3 = 1 if CASH_ETR3 > 1 & !missing(CASH_ETR3)

		//CASH_ETR5
		replace CASH_ETR5 = 0 if CASH_ETR5 < 0
		replace CASH_ETR5 = 1 if CASH_ETR5 > 1 & !missing(CASH_ETR5)

		//PRE_CASH_ETR3
		replace PRE_CASH_ETR3 = 0 if PRE_CASH_ETR3 < 0
		replace PRE_CASH_ETR3 = 1 if PRE_CASH_ETR3 > 1 & !missing(PRE_CASH_ETR3)

		//PRE_CASH_ETR5
		replace PRE_CASH_ETR5 = 0 if PRE_CASH_ETR5 < 0
		replace PRE_CASH_ETR5 = 1 if PRE_CASH_ETR5 > 1 & !missing(PRE_CASH_ETR5)
		
}

{	//GAAP ETR
*Current Year
	//Measure 
	by CUSIP6: gen GAAP_ETR1 = txt/DENOMINATOR1
	replace GAAP_ETR1 = . if DENOMINATOR1 < 0

*3 Year Rolling Forward 
	//Measure 
	by CUSIP6: gen vhelp = txt + LEAD_txt_1 + LEAD_txt_2
	by CUSIP6: gen GAAP_ETR3 = vhelp/DENOMINATOR3
	drop vhelp*
	replace GAAP_ETR3 = . if DENOMINATOR3 < 0

*5 Year Rolling Forward
	by CUSIP6: gen vhelp = txt + LEAD_txt_1 + LEAD_txt_2 + LEAD_txt_3 + LEAD_txt_4
	by CUSIP6: gen GAAP_ETR5 = vhelp/DENOMINATOR5
	drop vhelp*
	replace GAAP_ETR5 = . if DENOMINATOR5 < 0

*3 Year Rolling Backward
	by CUSIP6: gen vhelp = txt + LAG_txt_1 + LAG_txt_2
	by CUSIP6: gen PRE_GAAP_ETR3 = vhelp/LAG_DENOMINATOR3
	drop vhelp*
	replace PRE_GAAP_ETR3 = . if LAG_DENOMINATOR3 < 0

*5 Year Rolling Backward
	by CUSIP6: gen vhelp = txt + LAG_txt_1 + LAG_txt_2 + LAG_txt_3 + LAG_txt_4
	by CUSIP6: gen PRE_GAAP_ETR5 = vhelp/LAG_DENOMINATOR5
	drop vhelp*
	replace PRE_GAAP_ETR5 = . if LAG_DENOMINATOR5 < 0

	//Substitution for edge-firm-years
	*Example: GAAP_ETR3 would always be missing in 2016 (edge of sample) 
	*>> requires a substitution, while ensuring that one does not misinterpret multiyear measures
	sort CUSIP6 fyear 
	replace GAAP_ETR3 = GAAP_ETR1 if !missing(GAAP_ETR1) & LAST <= 1  
	replace GAAP_ETR5 = GAAP_ETR3 if missing(GAAP_ETR5) & !missing(GAAP_ETR3) 
	replace PRE_GAAP_ETR5 = PRE_GAAP_ETR3 if missing(PRE_GAAP_ETR5) & !missing(PRE_GAAP_ETR3) 
	
	//Winsorizing
		//GAAP_ETR1
		replace GAAP_ETR1 = 0 if GAAP_ETR1 < 0
		replace GAAP_ETR1 = 1 if GAAP_ETR1 > 1 & !missing(GAAP_ETR1)

		//GAAP_ETR3
		replace GAAP_ETR3 = 0 if GAAP_ETR3 < 0
		replace GAAP_ETR3 = 1 if GAAP_ETR3 > 1 & !missing(GAAP_ETR3)

		//GAAP_ETR5
		replace GAAP_ETR5 = 0 if GAAP_ETR5 < 0
		replace GAAP_ETR5 = 1 if GAAP_ETR5 > 1 & !missing(GAAP_ETR5)

		//PRE_GAAP_ETR3
		replace PRE_GAAP_ETR3 = 0 if PRE_GAAP_ETR3 < 0
		replace PRE_GAAP_ETR3 = 1 if PRE_GAAP_ETR3 > 1 & !missing(PRE_GAAP_ETR3)

		//PRE_GAAP_ETR5
		replace PRE_GAAP_ETR5 = 0 if PRE_GAAP_ETR5 < 0
		replace PRE_GAAP_ETR5 = 1 if PRE_GAAP_ETR5 > 1 & !missing(PRE_GAAP_ETR5)
		
}

{	//LEADS & LAGS of ETRs 
*LEADS
sort CUSIP6 fyear
	foreach var of varlist CASH_ETR* PRE_CASH_ETR* GAAP_ETR* PRE_GAAP_ETR* {
		forvalues q = 1(1)5{
			by CUSIP6: gen LEAD_`var'_`q' = `var'[_n+`q']
		}
	}

*LAGS
gsort CUSIP6 -fyear
	foreach var of varlist CASH_ETR* PRE_CASH_ETR* GAAP_ETR* PRE_GAAP_ETR* {
		forvalues q = 1(1)5{
			by CUSIP6: gen LAG_`var'_`q' = `var'[_n+`q']
		}
	}
sort CUSIP6 fyear

}

{	//Henry Sansing Cash Tax Differential (CTD)
	
*1 Year Measure 
	gen vhelp = txpd 
	gen vhelp2 = pi-spi
	gen vhelp3 = 0.35
	gen vhelp4 = vhelp2*vhelp3
	gen vhelp5 = at
	gen CTD1 = (vhelp-vhelp4)/vhelp5
	sum CTD1, d 
	drop vhelp*

*3 Year Measure 
	gen vhelp = txpd + LEAD_txpd_1 + LEAD_txpd_2 
	gen vhelp2 = (pi-spi) + (LEAD_pi_1 - LEAD_spi_1) + (LEAD_pi_2 - LEAD_spi_2) 
	gen vhelp3 = 0.35
	gen vhelp4 = vhelp2*vhelp3
	gen vhelp5 = at + LEAD_at_1 + LEAD_at_2
	gen CTD3 = (vhelp-vhelp4)/vhelp5
	drop vhelp*

	//Winsorizing
	sum CTD1, d 
	replace CTD1 = r(p1) if CTD1 < r(p1)
	replace CTD1 = r(p99) if CTD1 > r(p99) & !missing(CTD1)
	
	sum CTD3, d 
	replace CTD3 = r(p1) if CTD3 < r(p1)
	replace CTD3 = r(p99) if CTD3 > r(p99) & !missing(CTD3)
	
}

}

{	//Industry classification
 
{	//Exclude REITS
	foreach var of varlist CASH_ETR* GAAP_ETR* PRE_* LAG_CASH_* LAG_GAAP_* LEAD_CASH* LEAD_GAAP* {
	replace `var' = . if sic == "6798" 
	}
}

{	//2-digit Industry Cluster
	gen twosic = substr(sic,1,2)
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
	* X = Public Administration --> 91-98 --> not in my sample
	* 12 = Nonclassifiable Establishments --> 99
	gen IND = . 
	replace IND = 1 if twosic <= 09 & twosic >= 1
	replace IND = 2 if twosic <= 14 & twosic >= 10
	replace IND = 3 if twosic <= 17 & twosic >= 15
	replace IND = 4 if twosic == 28
	replace IND = 5 if twosic <= 39 & twosic >= 20 & twosic != 28
	replace IND = 6 if twosic <= 49 & twosic >= 40
	replace IND = 7 if twosic <= 51 & twosic >= 50
	replace IND = 8 if twosic <= 59 & twosic >= 52
	replace IND = 9 if twosic <= 67 & twosic >= 60
	replace IND = 10 if twosic == 73
	replace IND = 11 if twosic <= 89 & twosic >= 70 & twosic != 73
	replace IND = 12 if twosic == 99

}

}

{	//Control variables
	
{	//Annual Measures
	sort CUSIP6 fyear 
	
	//Measures
	*EBITDA to total assets
	gen ebitda_at = ebitda/at 
	replace ebitda_at = 0 if missing(ebitda_at)
	*SIZE
	gen size = ln(at)
	replace size = 0 if missing(size)
	*RnD Expense
	gen RnDExp = xrd/sale
	replace RnDExp = 0 if missing(RnDExp)
	*Advertising Expense
	gen AdExp  = xad/sale
	replace AdExp = 0 if missing(AdExp)
	*Selling, general, and administrative expense
	gen SGA = xsga/sale 
	replace SGA = 0 if missing(SGA)
	*Capital Expenditures 
	gen CapEx = capx/ppegt
	replace CapEx = 0 if missing(CapEx)
	*Change in Sales
	gen ChangeSale = (sale/LAG_sale_1)-1
	replace ChangeSale = 0 if missing(ChangeSale)
	*Leverage
	gen vhelp = dltt + dlc
	gen Leverage = vhelp/at
	replace Leverage = 0 if missing(Leverage)
	drop vhelp*
	*Cash Holdings
	gen Cash = che/at
	replace Cash = 0 if missing(Cash)
	*Foreign Operations
	gen MNE = 0
	replace MNE = 1 if pifo != 0 & !missing(pifo)
	*NOL 
	gen NOL = 0
	replace NOL = 1 if tlcf > 0 & !missing(tlcf)
	*Intangibles
	gen Intangibles = intan/at
	replace Intangibles = 0 if missing(Intangibles)
	*GrossPPE 
	gen PPE = ppegt/at 
	replace PPE = 0 if missing(PPE)
	*PCM
	gen PCM = (sale-xsga-cogs)/sale
	replace PCM = 0 if missing(PCM)
	*Profitablity 
	gen PROFITABILITY = ln(pi)
	
	//Winsorizing 
	*Winsorize one year measures 
	sum ebitda_at, d
	replace ebitda_at = r(p1) if ebitda_at < r(p1)
	replace ebitda_at = r(p99) if ebitda_at > r(p99)
	sum ebitda_at, d
	qui sum RnDExp, d
	replace RnDExp = r(p1) if RnDExp < r(p1)
	replace RnDExp = r(p99) if RnDExp > r(p99)
	qui sum RnDExp, d
	qui sum AdExp, d
	replace AdExp = r(p1) if AdExp < r(p1)
	replace AdExp = r(p99) if AdExp > r(p99)
	qui sum SGA, d
	replace SGA = r(p1) if SGA < r(p1)
	replace SGA = r(p99) if SGA > r(p99)
	qui sum CapEx, d
	replace CapEx = r(p1) if SGA < r(p1)
	replace CapEx = r(p99) if SGA > r(p99)
	qui sum ChangeSale, d
	replace ChangeSale = r(p1) if ChangeSale < r(p1)
	replace ChangeSale = r(p99) if ChangeSale > r(p99)
	qui sum Leverage, d
	replace Leverage = r(p1) if Leverage < r(p1)
	replace Leverage = r(p99) if Leverage > r(p99)
	qui sum Cash, d
	replace Cash = r(p1) if Cash < r(p1)
	replace Cash = r(p99) if Cash > r(p99)
	qui sum Intangibles, d
	replace Intangibles = r(p1) if Intangibles < r(p1)
	replace Intangibles = r(p99) if Intangibles > r(p99)
	qui sum PPE, d
	replace PPE = r(p1) if PPE < r(p1)
	replace PPE = r(p99) if PPE > r(p99)
	qui sum size, d
	replace size = r(p1) if size < r(p1)
	replace size = r(p99) if size > r(p99)
	qui sum PCM, d
	replace PCM = r(p1) if PCM < r(p1)
	replace PCM = r(p99) if PCM > r(p99)
	qui sum PROFITABILITY, d
	replace PROFITABILITY = r(p1) if PROFITABILITY < r(p1)
	replace PROFITABILITY = r(p99) if PROFITABILITY > r(p99)

}

{	//3 Year Measures
	sort CUSIP6 fyear 
	
	//Ratios
		*EBITDA to total assets
		gen ebitda_at3 = (ebitda + LEAD_ebitda_1 + LEAD_ebitda_2)/(at + LEAD_at_1 + LEAD_at_2)
		replace ebitda_at3 = ebitda_at if missing(ebitda_at3)
		*SIZE
		gen size3 = ln(at + LEAD_at_1 + LEAD_at_2)
		replace size3 = size if missing(size3)
		*RnD Expense
		gen RnDExp3 = (xrd + LEAD_xrd_1 + LEAD_xrd_2)/(sale + LEAD_sale_1 + LEAD_sale_2)
		replace RnDExp3 = RnDExp if missing(RnDExp3)
		*Advertising Expense
		gen AdExp3  = (xad + LEAD_xad_1 + LEAD_xad_2)/(sale + LEAD_sale_1 + LEAD_sale_2)
		replace AdExp3 = AdExp if missing(AdExp3)
		*Selling, general, and administrative expense
		gen SGA3 = (xsga + LEAD_xsga_1 + LEAD_xsga_2)/(sale + LEAD_sale_1 + LEAD_sale_2)
		replace SGA3 = SGA if missing(SGA3)
		*Capital Expenditures 
		gen CapEx3 = (capx + LEAD_capx_1 + LEAD_capx_2)/(ppegt + LEAD_ppegt_1 + LEAD_ppegt_2)
		replace CapEx3 = CapEx if missing(CapEx3)
		*Leverage
		gen vhelp = (dltt + dlc) + (LEAD_dltt_1 + LEAD_dlc_1) + (LEAD_dltt_1 + LEAD_dlc_2)
		gen Leverage3 = vhelp/(at + LEAD_at_1 + LEAD_at_2)
		replace Leverage3 = Leverage if missing(Leverage3)
		drop vhelp*
		*Cash Holdings
		gen Cash3 = (che + LEAD_che_1 + LEAD_che_2)/(at + LEAD_at_1 + LEAD_at_2)
		replace Cash3 = Cash if missing(Cash3)
		*Foreign Operations
		gen MNE3 = 0
		replace MNE3 = 1 if (pifo + LEAD_pifo_1 + LEAD_pifo_2) != 0 & !missing((pifo + LEAD_pifo_1 + LEAD_pifo_2))
		*NOL 
		gen NOL3 = 0
		replace NOL3 = 1 if (tlcf + LEAD_tlcf_1 + LEAD_tlcf_2) > 0 & !missing((tlcf + LEAD_tlcf_1 + LEAD_tlcf_2))
		*Intangibles
		gen Intangibles3 = (intan + LEAD_intan_1 + LEAD_intan_2)/(at + LEAD_at_1 + LEAD_at_2)
		replace Intangibles3 = Intangibles if missing(Intangibles3)
		*GrossPPE 
		gen PPE3 = (ppegt + LEAD_ppegt_1 + LEAD_ppegt_2)/(at + LEAD_at_1 + LEAD_at_2)
		replace PPE3 = PPE if missing(PPE3)
		*Profitability3
		gen PROFITABILITY3 = ln(pi + LEAD_pi_1 + LEAD_pi_2)

	//ANNUAL AVERAGE GROWTH RATES (t1 to t3)
		*Change in Sales
		gen vhelp = LEAD_sale_2/sale
		gen vhelp2 = vhelp^(1/3)-1
		replace vhelp2 = 0 if missing(vhelp2)
		rename vhelp2 ChangeSale3 
		drop vhelp*
		*Change in NOL 
		gen vhelp = LEAD_tlcf_2/tlcf
		gen vhelp2 = vhelp^(1/3)-1
		replace vhelp2 = 0 if missing(vhelp2)
		rename vhelp2 ChangeNOL3 
		drop vhelp*
		*Change in Foreign Income 
		gen vhelp = LEAD_pifo_2/pifo
		gen vhelp2 = vhelp^(1/3)-1
		replace vhelp2 = 0 if missing(vhelp2)
		rename vhelp2 ChangePIFO3 
		drop vhelp*
		*Change in EBITDA3
		gen vhelp = LEAD_ebitda_2/ebitda
		gen vhelp2 = vhelp^(1/3)-1
		replace vhelp2 = 0 if missing(vhelp2)
		rename vhelp2 ChangeEBITDA3 
		drop vhelp*
		*Change in Leverage3
		gen vhelp = (LEAD_dltt_2 + LEAD_dlc_2)/(dltt + dlc)
		gen vhelp2 = vhelp^(1/3)-1
		replace vhelp2 = 0 if missing(vhelp2)
		rename vhelp2 ChangeLeverage3 
		drop vhelp*
		*Change in Size3
		gen vhelp = LEAD_at_2/at
		gen vhelp2 = vhelp^(1/3)-1
		replace vhelp2 = 0 if missing(vhelp2)
		rename vhelp2 ChangeSize3 
		drop vhelp*
		*Change in Intangibles3
		gen vhelp = LEAD_intan_2/intan
		gen vhelp2 = vhelp^(1/3)-1
		replace vhelp2 = 0 if missing(vhelp2)
		rename vhelp2 ChangeIntangibles3 
		drop vhelp*
		
	//Winsorizing
		sum ebitda_at3, d
		replace ebitda_at3 = r(p1) if ebitda_at3 < r(p1)
		replace ebitda_at3 = r(p99) if ebitda_at3 > r(p99)
		sum ebitda_at3, d
		qui sum RnDExp3, d
		replace RnDExp3 = r(p1) if RnDExp3 < r(p1)
		replace RnDExp3 = r(p99) if RnDExp3 > r(p99)
		qui sum RnDExp3, d
		qui sum AdExp3, d
		replace AdExp3 = r(p1) if AdExp3 < r(p1)
		replace AdExp3 = r(p99) if AdExp3 > r(p99)
		qui sum SGA3, d
		replace SGA3 = r(p1) if SGA3 < r(p1)
		replace SGA3 = r(p99) if SGA3 > r(p99)
		qui sum CapEx3, d
		replace CapEx3 = r(p1) if SGA3 < r(p1)
		replace CapEx3 = r(p99) if SGA3 > r(p99)
		qui sum Leverage3, d
		replace Leverage3 = r(p1) if Leverage3 < r(p1)
		replace Leverage3 = r(p99) if Leverage3 > r(p99)
		qui sum Cash3, d
		replace Cash3 = r(p1) if Cash3 < r(p1)
		replace Cash3 = r(p99) if Cash3 > r(p99)
		qui sum Intangibles3, d
		replace Intangibles3 = r(p1) if Intangibles3 < r(p1)
		replace Intangibles3 = r(p99) if Intangibles3 > r(p99)
		qui sum PPE3, d
		replace PPE3 = r(p1) if PPE3 < r(p1)
		replace PPE3 = r(p99) if PPE3 > r(p99)
		qui sum size3, d
		replace size3 = r(p1) if size3 < r(p1)
		replace size3 = r(p99) if size3 > r(p99)
		qui sum ChangeSale3, d
		replace ChangeSale3 = r(p1) if ChangeSale3 < r(p1)
		replace ChangeSale3 = r(p99) if ChangeSale3 > r(p99)
		qui sum ChangeNOL3, d
		replace ChangeNOL3 = r(p1) if ChangeNOL3 < r(p1)
		replace ChangeNOL3 = r(p99) if ChangeNOL3 > r(p99)
		qui sum ChangePIFO3, d
		replace ChangePIFO3 = r(p1) if ChangePIFO3 < r(p1)
		replace ChangePIFO3 = r(p99) if ChangePIFO3 > r(p99)
		qui sum ChangeEBITDA3, d
		replace ChangeEBITDA3 = r(p1) if ChangeEBITDA3 < r(p1)
		replace ChangeEBITDA3 = r(p99) if ChangeEBITDA3 > r(p99)
		qui sum ChangeLeverage3, d
		replace ChangeLeverage3 = r(p1) if ChangeLeverage3 < r(p1)
		replace ChangeLeverage3 = r(p99) if ChangeLeverage3 > r(p99)
		qui sum ChangeSize3, d
		replace ChangeSize3 = r(p1) if ChangeSize3 < r(p1)
		replace ChangeSize3 = r(p99) if ChangeSize3 > r(p99)
		qui sum ChangeIntangibles3, d
		replace ChangeIntangibles3 = r(p1) if ChangeIntangibles3 < r(p1)
		replace ChangeIntangibles3 = r(p99) if ChangeIntangibles3 > r(p99)	
		qui sum PROFITABILITY3, d
		replace PROFITABILITY3 = r(p1) if PROFITABILITY3 < r(p1)
		replace PROFITABILITY3 = r(p99) if PROFITABILITY3 > r(p99)

}

sort CUSIP6 fyear 

}

{	//Industry adjusted effective tax rates 
	
	//Determine mean(ETR) by industry 
	sort IND CUSIP6 fyear 
	foreach var of varlist CASH_ETR* GAAP_ETR* PRE_CASH_ETR* PRE_GAAP_ETR*{
		by IND: egen indmean_`var' = mean(`var')
		}
		
	//Adjusted ETRs 
	sort IND CUSIP6 fyear 
	foreach var of varlist CASH_ETR* GAAP_ETR* PRE_CASH_ETR* PRE_GAAP_ETR*{
		by IND: gen indadj_`var' = `var' - indmean_`var'
		}

	//Lag of PRE_CASH_ETR3 needed for identification strategy (missings: (L2) PRE_CASH_ETR3 for identification strategy)
	sort IND CUSIP6 fyear 
	gen vhelp = LAG_PRE_CASH_ETR3_1
	by IND: gen indadj_LAG_PRE_CASH_ETR3_1 = vhelp - indmean_PRE_CASH_ETR3
	drop vhelp*
	gen vhelp = LAG_PRE_CASH_ETR3_2
	by IND: gen indadj_LAG_PRE_CASH_ETR3_2 = vhelp - indmean_PRE_CASH_ETR3
	drop vhelp*
	sort CUSIP6 fyear 

}

{	//BEA regions
	*https://fred.stlouisfed.org/categories/32061

	{	//Overview regions
		*Far West --> bearegion == 1
		*Alaska --> AK
		*Hawaii --> HI
		*California --> CA
		*Nevada --> NV
		*Oregon --> OR 
		*Washington --> WA

		*Great Lakes --> bearegion == 2
		*Illinois --> IL
		*Indiana --> IN
		*Michigan --> MI
		*Ohio --> OH
		*Wisconsin  --> WI

		*Mideast --> bearegion == 3
		*Delaware --> DE
		*DC --> DC
		*Maryland --> MD
		*New Jersey --> NJ
		*New York --> NY
		*Pennsylvania --> PA 

		*New England--> bearegion == 4
		*Connecticut --> CT
		*Maine --> ME
		*Massachusetts --> MA
		*New Hampshire --> NH
		*Rhode Island --> RI
		*Vermont --> VT

		*Plains --> bearegion == 5
		*Iowa --> IA
		*Kansas --> KS
		*Minnesota --> MN
		*Missouri --> MO
		*Nebraska --> NE 
		*North Dakota --> ND
		*South Dakota --> SD

		*Rocky Mountains --> bearegion == 6
		*Colorado --> CO
		*Idaho --> ID
		*Montana --> MT
		*Utah  --> UT
		*Wyoming --> WY

		*South East --> bearegion == 7
		*Alabama --> AL
		*Arkansas --> AR
		*Florida --> FL
		*Georgia --> GA
		*Kentucky --> KY
		*Louisiana --> LA
		*Mississippi --> MS
		*North Carolina --> NC
		*South Carolina --> SC
		*Tennessee --> TN
		*Virgina  --> VA
		*West Virgina  --> WV

		*Southwest --> bearegion == 8
		*Arizona --> AZ
		*New Mexico --> NM
		*Oklahoma --> OK
		*Texas --> TX 
		}
		
	gen bearegion = . 
	tab state if state == "CA" | state == "NV" | state == "OR" | state == "WA" | state == "AK" | state == "HI"
	replace bearegion = 1 if state == "CA" | state == "NV" | state == "OR" | state == "WA"  | state == "AK" | state == "HI"
	tab state if state == "IL" | state == "IN" | state == "MI" | state == "OH" | state == "WI"
	replace bearegion = 2 if state == "IL" | state == "IN" | state == "MI" | state == "OH" | state == "WI"
	tab state if state == "DE" | state == "DC" | state == "MD" | state == "NJ" | state == "NY" | state == "PA" 
	replace bearegion = 3 if state == "DE" | state == "DC" | state == "MD" | state == "NJ" | state == "NY" | state == "PA" 
	tab state if state == "CT" | state == "ME" | state == "MA" | state == "NH" | state == "RI" | state == "VT"
	replace bearegion = 4 if state == "CT" | state == "ME" | state == "MA" | state == "NH" | state == "RI" | state == "VT"
	tab state if state == "IA" | state == "KS" | state == "MN" | state == "MO" | state == "NE" | state == "ND" | state == "SD" 
	replace bearegion = 5 if state == "IA" | state == "KS" | state == "MN" | state == "MO" | state == "NE" | state == "ND" | state == "SD" 
	tab state if state == "CO" | state == "ID" | state == "MT" | state == "UT" | state == "WY" 
	replace bearegion = 6 if state == "CO" | state == "ID" | state == "MT" | state == "UT" | state == "WY" 
	tab state if state == "AL" | state == "AR" | state == "FL" | state == "GA" | state == "KY" | state == "LA" | state == "MS" | state == "NC" | state == "SC" | state == "TN" | state == "VA" | state == "WV" 
	replace bearegion = 7 if state == "AL" | state == "AR" | state == "FL" | state == "GA" | state == "KY" | state == "LA" | state == "MS" | state == "NC" | state == "SC" | state == "TN" | state == "VA" | state == "WV" 
	tab state if state == "AZ" | state == "NM" | state == "OK" | state == "TX" 
	replace bearegion = 8 if state == "AZ" | state == "NM" | state == "OK" | state == "TX" 
	label define bearegion 1 "Far West", add
	label define bearegion 2 "Great Lakes", modify
	label define bearegion 3 "Mideast", modify
	label define bearegion 4 "New England", modify
	label define bearegion 5 "Plains", modify
	label define bearegion 6 "Rocky Mountains", modify
	label define bearegion 7 "South East", modify
	label define bearegion 8 "South West", modify
	label values bearegion bearegion

}

gen YEAR = fyear
sort CUSIP6 YEAR
save "${pathCOMPUSTAT}\COMPUSTAT.dta", replace  
clear
