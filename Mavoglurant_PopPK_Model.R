# Mavoglurant PopPK - Standard Allometric Scaling (Final)
library(nlmixr2)
library(nlmixr2data)
data(mavoglurant)

mavoglurant$DV <- mavoglurant$DV / 1000

# 1. Base Model (No Covariates)
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

# 2. Standard Allometric Scaling Model (WT applied to ALL parameters)
allo_model <- function() {
  ini({
    tcl <- log(58.7); tv1 <- log(88.2); tq <- log(41.2); tv2 <- log(105.5)
    eta.cl ~ 0.1; eta.v1 ~ 0.1
    add.sd <- 0.1
  })
  model({
    # Allometric scaling factors
    wt_cl <- (WT / 70)^0.75
    wt_v  <- (WT / 70)^1.0
    
    # Apply scaling to all clearance and volume parameters
    cl <- exp(tcl + eta.cl) * wt_cl
    v1 <- exp(tv1 + eta.v1) * wt_v
    q  <- exp(tq) * wt_cl
    v2 <- exp(tv2) * wt_v
    
    linCmt() ~ add(add.sd)
  })
}
fit_allo <- nlmixr2(allo_model, mavoglurant, est = "focei")

# 3. Output OFV Comparison
cat("\n=== OFV Comparison ===\n")
cat("Base Model OFV:", fit_base$objf, "\n")
cat("Allometric Scaling Model OFV:", fit_allo$objf, " (Delta:", fit_base$objf - fit_allo$objf, ")\n\n")

# 4. Final Model Table
df_out <- as.data.frame(fit_allo$parFixedDf)
df_out$Parameter <- rownames(df_out)
df_out <- df_out[, c("Parameter", "Estimate", "SE", "%RSE", "Back-transformed", "CI Lower", "CI Upper", "BSV(CV%)", "Shrink(SD)%")]
print(knitr::kable(df_out, digits = 3, caption = "Final Model with Standard Allometric Scaling", row.names = FALSE))

# 5. Export CSV
write.csv(df_out, file = "Mavoglurant_Allometric_Model_Summary.csv", row.names = FALSE)
cat("Final table exported successfully.\n")