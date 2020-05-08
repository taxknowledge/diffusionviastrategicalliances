- SDC Platinum data was downloaded using the desktop application 4.0.4.0. 

- The "report"-file (SDC_Report.rpt) in this folder was used to download the respective items (see also PDF for list of available items in SDC Platinum) on Sept/20/2018.

- Download was executed on anual/quarterly basis as application shows performance issues. Quarterly files were manually merged to annual files "SDC_final_YYYY.xlsx". 

- Pls note that Excel files contain slightly different variable names than reported in SDC by default. 

- Within .xlsx files, function Text-to-Columns was used to split items 
	"Participant Ultimate Parent Name", 
	"Participants in Venture / Alliance (Long Name - 1 Line)", 
	"Participants in Venture / Alliance (Short Name)", 
	"Participant Ticker Symbol", 
	"Participant Parent Name", 
	"Participant Ultimate Parent Name",
into 21 distinct columns (eases further data handling in Stata). 

- Columns containing dates were manually checked to be formatted as dates (prevent import excel malfunctions in Stata). 
