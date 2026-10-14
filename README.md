# Mavoglurant PopPK Analysis using nlmixr2

This repository contains a population pharmacokinetic (PopPK) analysis of mavoglurant using the `nlmixr2` package in R. It serves as a self-directed modeling exercise demonstrating a standard model development workflow: base model construction, stepwise covariate evaluation, and standard allometric scaling.

## Dataset
The analysis uses the built-in `mavoglurant` dataset from the `nlmixr2data` package, which contains 2,678 plasma concentration observations from 20 subjects, along with covariates including body weight (WT) and age (AGE).

## Methods
1. **Base Model**: A two-compartment model with first-order absorption and linear elimination was established to describe the concentration-time profiles.
2. **Covariate Screening**: A stepwise approach was applied to evaluate the effects of body weight (WT) and age (AGE) on clearance (CL).
3. **Standard Allometric Scaling**: Based on physiological principles, standard allometric scaling was applied (CL and Q scaled to WT^0.75, V1 and V2 scaled to WT^1.0) to avoid parameter estimation bias.

## Key Results
- **Age Effect**: Adding AGE on top of the weight model did not improve the objective function value (ΔOFV ≈ 0), indicating age is not a significant covariate for mavoglurant clearance in this dataset.
- **Weight Effect**: Applying standard allometric scaling significantly improved the model fit compared to the base model (ΔOFV = 40.16, p < 0.001).
- **Parameter Precision**: The final model achieved excellent precision, with all %RSE values below 5%. The shrinkage for inter-individual variability (IIV) on CL and V1 was 12.3% and 3.7%, respectively, indicating reliable parameter estimates.

## File Structure
- `Mavoglurant_PopPK_Model.R`: The main R script containing the model building, covariate screening, and final parameter estimation.
- `Mavoglurant_Final_Model_Summary.csv`: The final model parameter estimates, standard errors, %RSE, and OFV comparison.

## Environment & Dependencies
- R (>= 4.0)
- `nlmixr2`
- `nlmixr2data`
- `knitr`

## How to Run
1. Install R and RStudio.
2. Install the required packages:
   ```R
3. install.packages(c("nlmixr2", "nlmixr2data", "knitr"))
Source the script Mavoglurant_PopPK_Model.R. The script will automatically load the data, fit the models, print the OFV comparison, and export the final parameter table to CSV.
