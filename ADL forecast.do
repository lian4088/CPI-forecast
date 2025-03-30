* merge with major data*
* merge m:1 date_var using aaa_baa_monthly.dta *

use major_project_data.dta, clear
merge m:1 date_var using aaa_baa_monthly.dta
drop if date_var  > tm(2024m10)

format date_var %tm
tsset date_var


*--------------------------------------------------*
** In-sample Model selection (AIC, BIC)**
** Estimate AR for different lags **
estimates clear
foreach L of numlist 1/12{
	reg dcpi L(1/`L').dcpi
	estimates store AR`L'
	
}

** test **
estimates stats AR1 AR2 AR3 AR4 AR5 AR6 AR7 AR8 AR9 AR10 AR11 AR12

** Results: AR(2)  -4116.662  -4104.249

*------------------------*
** Granger-cause test **
*------------------------*
**
reg dcpi L(1/2).dcpi L(1/2).corporate
test L1.corporate L2.corporate 

reg dcpi L(1/2).dcpi L(1/2).spread2
test L1.spread2 L2.spread2 

**
reg dcpi L(1/2).dcpi L(1/2).dt12
test L1.dt12 L2.dt12

**
reg dcpi L(1/2).dcpi L(1/2).dt3
test L1.dt3 L2.dt3

reg dcpi L(1/2).dcpi L(1/2).spread1
test L1.spread1 L2.spread1

**
reg dcpi L(1/2).dcpi L(1/2).rGDP_monthly
test L1.rGDP_monthly L2.rGDP_monthly

**
reg dcpi L(1/2).dcpi L(1/2).dgdp
test L1.dgdp L2.dgdp


reg dcpi L(1/2).dcpi L(1/2).UNRATE
test L1.UNRATE L2.UNRATE

reg dcpi L(1/2).dcpi L(1/2).dunrate
test L1.dunrate L2.dunrate

*------------------------------------------*
** In-sample Model selection (AIC, BIC)**
*------------------------------------------*
reg dcpi L.dcpi L.corporate
estimates store corporateADL1

**
reg dcpi L(1/2).dcpi L(1/2).corporate
estimates store corporateADL2

reg dcpi L.dcpi L.dt12
estimates store dt12ADL1

reg dcpi L(1/2).dcpi L(1/2).dt12
estimates store dt12ADL2

reg dcpi L.dcpi L.dt3
estimates store dt3ADL1

reg dcpi L(1/2).dcpi L(1/2).dt3
estimates store dt3ADL2

reg dcpi L.dcpi L.rGDP_monthly
estimates store gdpADL1

reg dcpi L(1/2).dcpi L(1/2).rGDP_monthly
estimates store gdpADL2

reg dcpi L.dcpi L.dgdp
estimates store dgdpADL1

reg dcpi L(1/2).dcpi L(1/2).dgdp
estimates store dgdpADL2

estimates stats corporateADL1 corporateADL2 dt12ADL1 dt12ADL2 dt3ADL1 dt3ADL2 gdpADL1 gdpADL2 dgdpADL1 dgdpADL2


*-------------------------------------*
** Out-sample Model selection (PLS) **
*-------------------------------------*

** Stores the total number of observations minus one in a local variable **
** _N is the total number of observations in the dataset. **
local Tminus1 = _N - 1

** starting point for the pseudo-out-of-sample period. **
local B = 30

** corporate **
** Loops over ADL(1) to ADL(2) depends on how a/b set in for loop **
foreach L of numlist 1/2 {
	** Creates a new variable oos_errorL with each L to store the squared forecast errors for each AR model. **
	gen oos_error`L' = .
	** Loops over subsamples starting from observation B to the second-to-last observation (T-1) **
	foreach t of numlist `B'/`Tminus1' {
		** fits AR(L) model using up to t obs **
		** _n is built-in system variable refers to row number **
		** _n <= `t' ensures only use data up to t-th obs **
		** _n > 4 ensure enough data points are available for the lags L to be meaningful **
		reg dcpi L(1/`L').dcpi L(1/`L').corporate if _n <= `t' & _n > 4
		** get point estimate **
		predict forecast, xb
		** save error at time t+1 **
		replace oos_error`L' = (dgdp-forecast)^2 if _n == `t'+1
		drop forecast
	}
}

** summarize square error to get average**
sum oos_*
drop oos_*
** corporate adl1: 0.0000159 **
** corporate adl2: 0.0000159 **

** dt12 **
** Loops over ADL(1) to ADL(2) depends on how a/b set in for loop **
foreach L of numlist 1/2 {
	** Creates a new variable oos_errorL with each L to store the squared forecast errors for each AR model. **
	gen oos_error`L' = .
	** Loops over subsamples starting from observation B to the second-to-last observation (T-1) **
	foreach t of numlist `B'/`Tminus1' {
		** fits AR(L) model using up to t obs **
		** _n is built-in system variable refers to row number **
		** _n <= `t' ensures only use data up to t-th obs **
		** _n > 4 ensure enough data points are available for the lags L to be meaningful **
		reg dcpi L(1/`L').dcpi L(1/`L').dt12 if _n <= `t' & _n > 4
		** get point estimate **
		predict forecast, xb
		** save error at time t+1 **
		replace oos_error`L' = (dgdp-forecast)^2 if _n == `t'+1
		drop forecast
	}
}

** summarize square error to get average**
sum oos_*
drop oos_*
** dt12 adl1: 0.0000154 **
** dt12 adl2: 0.0000151 **


** dt3 **
** Loops over ADL(1) to ADL(2) depends on how a/b set in for loop **
foreach L of numlist 1/2 {
	** Creates a new variable oos_errorL with each L to store the squared forecast errors for each AR model. **
	gen oos_error`L' = .
	** Loops over subsamples starting from observation B to the second-to-last observation (T-1) **
	foreach t of numlist `B'/`Tminus1' {
		** fits AR(L) model using up to t obs **
		** _n is built-in system variable refers to row number **
		** _n <= `t' ensures only use data up to t-th obs **
		** _n > 4 ensure enough data points are available for the lags L to be meaningful **
		reg dcpi L(1/`L').dcpi L(1/`L').dt3 if _n <= `t' & _n > 4
		** get point estimate **
		predict forecast, xb
		** save error at time t+1 **
		replace oos_error`L' = (dgdp-forecast)^2 if _n == `t'+1
		drop forecast
	}
}

** summarize square error to get average**
sum oos_*
drop oos_*
** dt3 adl1: 0.0000153 **
** dt3 adl2: 0.0000151 **

** gdp **
** Loops over ADL(1) to ADL(2) depends on how a/b set in for loop **
foreach L of numlist 1/2 {
	** Creates a new variable oos_errorL with each L to store the squared forecast errors for each AR model. **
	gen oos_error`L' = .
	** Loops over subsamples starting from observation B to the second-to-last observation (T-1) **
	foreach t of numlist `B'/`Tminus1' {
		** fits AR(L) model using up to t obs **
		** _n is built-in system variable refers to row number **
		** _n <= `t' ensures only use data up to t-th obs **
		** _n > 4 ensure enough data points are available for the lags L to be meaningful **
		reg dcpi L(1/`L').dcpi L(1/`L').rGDP_monthly if _n <= `t' & _n > 4
		** get point estimate **
		predict forecast, xb
		** save error at time t+1 **
		replace oos_error`L' = (dgdp-forecast)^2 if _n == `t'+1
		drop forecast
	}
}

** summarize square error to get average**
sum oos_*
drop oos_*
** gdp adl1: 0.0000159 **
** gdp adl2: 0.0000149 **

** dgdp **
** Loops over ADL(1) to ADL(2) depends on how a/b set in for loop **
foreach L of numlist 1/2 {
	** Creates a new variable oos_errorL with each L to store the squared forecast errors for each AR model. **
	gen oos_error`L' = .
	** Loops over subsamples starting from observation B to the second-to-last observation (T-1) **
	foreach t of numlist `B'/`Tminus1' {
		** fits AR(L) model using up to t obs **
		** _n is built-in system variable refers to row number **
		** _n <= `t' ensures only use data up to t-th obs **
		** _n > 4 ensure enough data points are available for the lags L to be meaningful **
		reg dcpi L(1/`L').dcpi L(1/`L').dgdp if _n <= `t' & _n > 4
		** get point estimate **
		predict forecast, xb
		** save error at time t+1 **
		replace oos_error`L' = (dgdp-forecast)^2 if _n == `t'+1
		drop forecast
	}
}

** summarize square error to get average**
sum oos_*
drop oos_*
** dgdp adl1: 0.0000149 **
** dgdp adl2: 0.0000146 **

** AR+seasonal+trend **
foreach mm of numlist 1/12 {
	gen m`mm' = month(dofm(date_var)) == `mm'
}

** Loops over ADL(1) to ADL(2) depends on how a/b set in for loop **
foreach L of numlist 1/2 {
	** Creates a new variable oos_errorL with each L to store the squared forecast errors for each AR model. **
	gen oos_error`L' = .
	** Loops over subsamples starting from observation B to the second-to-last observation (T-1) **
	foreach t of numlist `B'/`Tminus1' {
		** fits AR(L) model using up to t obs **
		** _n is built-in system variable refers to row number **
		** _n <= `t' ensures only use data up to t-th obs **
		** _n > 4 ensure enough data points are available for the lags L to be meaningful **
		reg dcpi L(1/`L').dcpi m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 m11 date_var if _n <= `t' & _n > 4
		** get point estimate **
		predict forecast, xb
		** save error at time t+1 **
		replace oos_error`L' = (dgdp-forecast)^2 if _n == `t'+1
		drop forecast
	}
}

** summarize square error to get average**
sum oos_*
drop oos_*
** dcpi: 0.0000185 **
** dcpi: 0.0000183 **

*----------------------------------------------------------------------*
** Dickey-Fuller test: test whether dcpi is unit root (with 4 lags) **
*----------------------------------------------------------------------*
** r means robust SE **
** D. means first difference (x_t - x_t-1)**
reg D.dcpi L.dcpi L(1/2).D.dcpi, r
test L.dcpi 

** not a unit root **


*-------------------------------------------------*
** ADL(2) of corporate forecast (direct method) **
*-------------------------------------------------*
** add 12 future time **
tsappend, add(12)

** create an empty variable to store point forecasts and se for ADL model **
gen point_adl = .
gen sf_adl = .

** Loops over different forecast horizons representing the number of months into the future for which the forecast is made. **
foreach h of numlist 1/12 {
	** +1 means using an ADL(2) model **
	local l = `h'
	local L = `h'+1
	** regress the ADL model from lag l to lag L (h-step ahead)**
	reg dcpi L(`l'/`L').dcpi L(`l'/`L').corporate 
	predict y_adl`h', xb
	predict sf_adl`h', stdf
	** store value **
	replace point_adl = y_adl`h' if date_var == ym(2024,10)+`h'
	replace sf_adl = sf_adl`h' if date_var == ym(2024,10)+`h'
}

** Generate forecast inetrval**
gen L_adl = point_adl + invnorm(0.025) * sf_adl
gen U_adl = point_adl + invnorm(0.975) * sf_adl

* plotting growth rate forecast *
tsline dcpi point_adl L_adl U_adl if date_var > ym(2020,1), legend(label(1 "dgdp") label(2 "Point forecast") label(3 "95% Interval") order(1 2 3)) lcolor(black blue red red) lpattern(solid dash dash_dot dash_dot) ytitle("growth rate")


* plotting CPI growth rate forecast *
replace CPI = L.CPI*exp(point_adl) if date_var >= ym(2024,11)
gen f_CPI = CPI if date_var >= ym(2024,11)
gen L_CPI_forecast = L.CPI*exp(point_adl + invnormal(0.025)*sf_adl) 
gen U_CPI_forecast = L.CPI*exp(point_adl + invnormal(0.975)*sf_adl)

tsline CPI f_CPI L_CPI_forecast U_CPI_forecast if date_var > ym(2020,1), legend(label(1 "CPI") label(2 "Point forecast") label(3 "95% Interval") order(1 2 3)) lcolor(black blue red red) lpattern(solid solid dash_dot dash_dot) ytitle("Relative value(index 1982-1984=100)")




