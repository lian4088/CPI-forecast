
# CPI Forecast Project

This project aims to forecast the U.S. Consumer Price Index (CPI) over a 12-month horizon using two statistical models: an AR(4) component model and a corporate bond spread-based ADL(2) model. The models are implemented in STATA, and the project includes data cleaning, forecasting, interval estimation, and model comparison.

## 📁 Project Structure

```
CPI-forecast/
│
├── ADL data cleaning.do         # STATA script for cleaning macroeconomic data
├── AR(4) forecast.do            # Forecasting with AR(4) component model
├── ADL forecast.do             # Forecasting with ADL(2) model using corporate bond spreads
├── major_project_data.dta      # Final processed dataset (⚠️ for demo only, may require permission)
├── Forecast Essay.pdf          # Full project report explaining the methodology and findings
└── README.md                   # This file
```

## 🧠 Methodology Overview

- **AR(4) Component Model**: Captures internal patterns in CPI including trend, seasonality, and cycles.
- **ADL(2) Model**: Incorporates macroeconomic predictors (corporate bond spreads) to improve forecasting accuracy.
- **Forecasting**: 
  - AR model uses simulation-based forecasting with 95% intervals.
  - ADL model applies the direct method to forecast dCPI and transforms results into CPI values.
- **Evaluation**: Compared based on AIC, BIC, PLS, and width of forecast intervals.

## 🔧 Technologies Used

- **STATA**: Primary tool for data analysis and model estimation
- **LaTeX / PDF**: For formatting the written report

## 📊 Key Results

- ADL(2) model offered slightly narrower forecast intervals than AR(4), implying higher confidence.
- Both models forecasted similar point estimates for CPI in the coming year.
- Demonstrated the use of macroeconomic indicators (e.g., corporate bond yield spreads) to improve inflation forecasts.

## 📎 Citation

If using this project, please cite:
```
Lian Lian (2024). Forecasting CPI: A Comparative Study on U.S. Inflation Rate with AR and ADL Models.
```

## 📬 Contact

For questions or collaboration, feel free to reach out: xlian408@gmail.com
