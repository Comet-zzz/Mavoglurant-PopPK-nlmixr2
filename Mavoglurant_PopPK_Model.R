# Mavoglurant PopPK Model Development Pipeline
library(nlmixr2)
library(nlmixr2data)
data(mavoglurant)

# Unit conversion
mavoglurant$DV <- mavoglurant$DV / 1000

# Base structural model (two-compartment IV infusion)
base_model <- function() {
  ini({
    tcl <- log(58.7); tv1 <- log(88.2); tq <- log(41.2); tv2 <- log(105.5)
    eta.cl ~ 0.1; eta.v1 ~ 0.1
    add.sd <- 0.1
  })
  model({
    cl <- exp(tcl + eta.cl); v1 <- exp(tv1 + eta.v1)
    q <- exp(tq); v2 <- exp(tv2)
    linCmt() ~ add(add.sd)
  })
}
fit_base <- nlmixr2(base_model, mavoglurant, est = "focei")
cat("\n[Base Model] OFV:", fit_base$objf, "\n")

# Stepwise covariate analysis: add weight effect on CL
wt_model <- function() {
  ini({
    tcl <- log(58.7); tv1 <- log(88.2); tq <- log(41.2); tv2 <- log(105.5)
    beta_wt_cl <- 0.75
    eta.cl ~ 0.1; eta.v1 ~ 0.1
    add.sd <- 0.1
  })
  model({
    cl <- exp(tcl + eta.cl + beta_wt_cl * log(WT / 70))
    v1 <- exp(tv1 + eta.v1); q <- exp(tq); v2 <- exp(tv2)
    linCmt() ~ add(add.sd)
  })
}
fit_wt <- nlmixr2(wt_model, mavoglurant, est = "focei")
cat("[Weight Model] OFV:", fit_wt$objf, "\n")
cat("[Weight Model] Delta OFV (vs Base):", fit_base$objf - fit_wt$objf, "\n")
cat("[Weight Model] Estimated WT exponent:", exp(fit_wt$parFixedDf["beta_wt_cl", "Estimate"]), "\n")
cat("[Weight Model] WT exponent %RSE:", fit_wt$parFixedDf["beta_wt_cl", "%RSE"], "%\n")

# Add age effect on top of weight
wt_age_model <- function() {
  ini({
    tcl <- log(58.7); tv1 <- log(88.2); tq <- log(41.2); tv2 <- log(105.5)
    beta_wt_cl  <- 0.75
    beta_age_cl <- 0
    eta.cl ~ 0.1; eta.v1 ~ 0.1
    add.sd <- 0.1
  })
  model({
    cl <- exp(tcl + eta.cl + beta_wt_cl * log(WT / 70) + beta_age_cl * (AGE - 40))
    v1 <- exp(tv1 + eta.v1); q <- exp(tq); v2 <- exp(tv2)
    linCmt() ~ add(add.sd)
  })
}
fit_wt_age <- nlmixr2(wt_age_model, mavoglurant, est = "focei")
cat("[WT+AGE Model] OFV:", fit_wt_age$objf, "\n")
cat("[WT+AGE Model] Delta OFV (vs Weight):", fit_wt$objf - fit_wt_age$objf, "\n")

# Final model: apply standard allometric scaling
# CL and Q scaled to WT^0.75; V1 and V2 scaled to WT^1.0
allo_model <- function() {
  ini({
    tcl <- log(58.7); tv1 <- log(88.2); tq <- log(41.2); tv2 <- log(105.5)
    eta.cl ~ 0.1; eta.v1 ~ 0.1
    add.sd <- 0.1
  })
  model({
    wt_cl <- (WT / 70)^0.75
    wt_v  <- (WT / 70)^1.0

    cl <- exp(tcl + eta.cl) * wt_cl
    v1 <- exp(tv1 + eta.v1) * wt_v
    q  <- exp(tq) * wt_cl
    v2 <- exp(tv2) * wt_v

    linCmt() ~ add(add.sd)
  })
}
fit_allo <- nlmixr2(allo_model, mavoglurant, est = "focei")
cat("[Allometric Model] OFV:", fit_allo$objf, "\n")
cat("[Allometric Model] Delta OFV (vs Base):", fit_base$objf - fit_allo$objf, "\n")

# Output final parameter table
df_out <- as.data.frame(fit_allo$parFixedDf)
df_out$Parameter <- rownames(df_out)
df_out <- df_out[, c("Parameter", "Estimate", "SE", "%RSE", "Back-transformed", "CI Lower", "CI Upper", "BSV(CV%)", "Shrink(SD)%")]
print(knitr::kable(df_out, digits = 3, caption = "Final Model Parameters (Standard Allometric Scaling)", row.names = FALSE))

# Export summary to CSV
write.csv(df_out, file = "Mavoglurant_Final_Model_Summary.csv", row.names = FALSE)
