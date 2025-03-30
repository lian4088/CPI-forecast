set fredkey "70e17e07f4c44a7325c4f35218c9cb48"

** import data **
import fred CPIAUCNS, clear
ren CPIAUCNS CPI

** generate year, quarter, and yearquarter variable **
gen year = year(daten)
gen month = month(daten)
gen date_var = ym(year, month)
format date_var %tm
tsset date_var

* variable needed *
* mean_shift component *
gen postpolicy = date_var >= ym(1983,1) 

* growth rate approximation *
gen logCPI = log(CPI)
gen growth_rate = logCPI - L.logCPI 

* generate month dummy variables *
foreach mm of numlist 1/12 {
	gen m`mm' = month(dofm(date_var)) == `mm'
} 

** CPI time-series plot **
tsline CPI, ytitle("Relative CPI") title(CPI monthly time-series)


*--------------------------------------------------*
* CPI Seasonal + Trend + cycle *
** trend component **
reg CPI date_var
predict trend, xb
predict detrended, residual

** mean shift **
* gen postpolicy = date_var >= ym(1983,1) *
reg detrended postpolicy
predict mean_shift, xb
predict detrended_demeaned, residual

** seasonal component **
reg detrended_demeaned i.month
predict seasonal, xb
predict detrended_demeaned_sa, residual

ac detrended_demeaned_sa

* Results: detrended_demeaned_sa has Highly *
*          persistent in autoregression     *
*--------------------------------------------------*


*--------------------------------------------------*
* CPI growth, Seasonal + Trend + cycle *

* gen logCPI = log(CPI) *
* gen growth_rate = logCPI - L.logCPI *

** trend component **
reg growth_rate date_var
predict rate_trend, xb
predict rate_detrended, residual

** mean shift **
/* gen postpolicy = date_var >= ym(1983,1) */
reg rate_detrended postpolicy
predict rate_mean_shift, xb
predict rate_detrended_demeaned, residual

** seasonal component **
reg rate_detrended_demeaned i.month
predict rate_seasonal, xb
predict rate_detrended_demeaned_sa, residual

ac rate_detrended_demeaned_sa

* Results: growth_rate is not highly peresistent *
*          in ac, and can do further model       *
*		   selection.                            *
* A lot of persistent, meaning we should choose  *
* AR rather than MA                              *
*--------------------------------------------------*

*--------------------------------------------------*
** In-sample Model selection (AIC, BIC)**
** Estimate AR for different lags **
estimates clear
foreach L of numlist 1/12{
	reg growth_rate L(1/`L').growth_rate
	estimates store AR`L'
	
}

** test **
estimates stats AR1 AR2 AR3 AR4 AR5 AR6 AR7 AR8 AR9 AR10 AR11 AR12

* Results: Lag4 has smallest AIC and BIC *
*--------------------------------------------------*

*--------------------------------------------------*
** Out-sample Model selection (PLS) **

** generate month dummy variables **
foreach mm of numlist 1/12 {
	gen m`mm' = month(dofm(date_var)) == `mm'
}


** Stores the total number of observations minus one in a local variable **
** _N is the total number of observations in the dataset. **
local Tminus1 = _N - 1

** starting point for the pseudo-out-of-sample period. **
local B = 30

** Loops over AR(1) to AR(4) depends on how a/b set in for loop **
foreach L of numlist 1/19 {
	** Creates a new variable oos_errorL with each L to store the squared forecast errors for each AR model. **
	gen oos_error`L' = .
	** Loops over subsamples starting from observation B to the second-to-last observation (T-1) **
	foreach t of numlist `B'/`Tminus1' {
		** fits AR(L) model using up to t obs **
		** _n is built-in system variable refers to row number **
		** _n <= `t' ensures only use data up to t-th obs **
		** _n > 4 ensure enough data points are available for the lags L to be meaningful **
		reg growth_rate L(1/`L').growth_rate m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 m11 date_var postpolicy  if _n <= `t' & _n > 4
		** get point estimate **
		predict forecast, xb
		** save error at time t+1 **
		replace oos_error`L' = (growth_rate-forecast)^2 if _n == `t'+1
		drop forecast
	}
}

** summarize square error to get average**
sum oos_*

** Results: choose AR(4) or AR(5)
*--------------------------------------------------*

*--------------------------------------------------*
* simulation forecast *
tsappend , add (12)
* regression model AR(4) + seasonal components + mean shift + trend
reg growth_rate L(1/4).growth_rate m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 m11 postpolicy date_var
* store results of estimations
estimates store mod_results

* add dummy variables to new adding time*
foreach mm of numlist 1/12 {
	replace m`mm' = month(dofm(date_var)) == `mm'
}
replace postpolicy = date_var >= ym(1983,1)

forecast create our_model, replace
forecast estimates mod_results

* use simulation to forecast *
set seed 1983
forecast solve, simulate(errors betas, statistic(stddev, prefix(sd_)) reps(1000))

* plotting growth rate forecast *
gen L_forecast = f_growth_rate + invnormal(0.025)*sd_growth_rate
gen U_forecast = f_growth_rate + invnormal(0.975)*sd_growth_rate

tsline f_growth_rate growth_rate L_forecast U_forecast if date_var > ym(2020,1), legend(label(1 "Growth_rate") label(2 "Point forecast") label(3 "95% Interval") order(1 2 3)) lcolor(blue black red red) lpattern(dash solid dash_dot dash_dot) ytitle("growth rate")

* plotting CPI growth rate forecast *
replace CPI = L.CPI*exp(f_growth_rate) if date_var >= ym(2024,11)
gen f_CPI = CPI if date_var >= ym(2024,11)
gen L_CPI_forecast = L.CPI*exp(f_growth_rate + invnormal(0.025)*sd_growth_rate) 
gen U_CPI_forecast = L.CPI*exp(f_growth_rate + invnormal(0.975)*sd_growth_rate)

tsline CPI f_CPI L_CPI_forecast U_CPI_forecast if date_var > ym(2020,1), legend(label(1 "CPI") label(2 "Point forecast") label(3 "95% Interval") order(1 2 3)) lcolor(black blue red red) lpattern(solid solid dash_dot dash_dot) ytitle("Relative value(index 1982-1984=100)")
