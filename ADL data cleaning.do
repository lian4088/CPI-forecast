set fredkey "70e17e07f4c44a7325c4f35218c9cb48"

** import monthly data **
import fred CPIAUCNS GDPC1 UNRATE GS10 TB3MS GS1, clear
ren CPIAUCNS CPI
ren GDPC1 rGDP

** generate year, quarter, and yearquarter variable **
gen year = year(daten)
gen month = month(daten)
gen date_var = ym(year, month)
format date_var %tm
tsset date_var

drop if date_var  < tm(1986m1)

ipolate rGDP date_var, gen(rGDP_monthly)

* growth rate approximation *
gen logCPI = log(CPI)
gen dcpi = logCPI - L.logCPI 

gen logGDP = log(rGDP_monthly)
gen dgdp = logGDP - L.logGDP

gen logUNRATE = log(UNRATE)
gen dunrate = logUNRATE - L.logUNRATE

gen spread2 = GS10 - TB3MS
gen dt12 = GS1 - L.GS1
gen dt3 = TB3MS - L.TB3MS
gen spread1 = GS1 - TB3MS

save major_project_data.dta, replace

*--------------------------------------------------*
** import DAAA DBAA data **
import fred DAAA DBAA, clear

** generate year, quarter, and yearquarter variable **
gen year = year(daten)
gen month = month(daten)
gen date_var = ym(year, month)
format date_var %tm
tsset date_var

drop if date_var  < tm(1986m1)

** collapse DAAA DBAA data into monthly by average **
gen date_daily = date(datestr, "YMD")
format date_daily %td
collapse (mean) DAAA DBAA, by(date_var)
gen corporate = DBAA - DAAA 

save aaa_baa_monthly.dta, replace
