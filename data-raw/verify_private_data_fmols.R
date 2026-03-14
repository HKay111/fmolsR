# FMOLS Group Mean Verification for Your Private Data
#
# Data: /Users/hkay/Documents/College/Research/comdata.csv
# Variables: lco2, lgdp, lene, ltro, lrvc, lenv, linst, lgei, cdp

library(fmolsR)

# Load your data
dat <- read.csv('/Users/hkay/Documents/College/Research/comdata.csv')

cat("Data loaded:", nrow(dat), "observations\n")
cat("Countries:", paste(unique(dat$country), collapse=", "), "\n")
cat("Years:", min(dat$year), "-", max(dat$year), "\n\n")

# Run Group Mean FMOLS - matching your EViews specification
# Dependent: lco2
# Regressors: lgdp, lene, ltro, lrvc, lenv, linst, lgei, cdp
# Kernel: Bartlett
# Bandwidth: 6

cat("=== FMOLS GROUP MEAN RESULTS ===\n\n")

fit <- fmols_panel(
  lco2 ~ lgdp + lene + ltro + lrvc + lenv + linst + lgei + cdp,
  data = dat,
  id = "country",
  time = "year",
  panel_method = "group_mean",
  trend = "const",
  kernel = "bartlett",
  bandwidth = 6
)

cat("Formula: lco2 ~ lgdp + lene + ltro + lrvc + lenv + linst + lgei + cdp\n")
cat("Kernel: Bartlett\n")
cat("Bandwidth: 6\n\n")

cat("=== COEFFICIENTS ===\n")
print(coef(fit))

cat("\n=== STANDARD ERRORS ===\n")
print(fit$stderr)

cat("\n=== T-STATISTICS ===\n")
print(fit$t_stat)

cat("\n=== P-VALUES ===\n")
print(fit$p_value)

cat("\n==============================================\n")
cat("=== YOUR EVIEWS RESULTS (from earlier) ===\n")
cat("==============================================\n")
cat("\nDependent Variable: LINV\n")
cat("Method: Panel Fully Modified Least Squares (FMOLS)\n")
cat("Sample (adjusted): 1936 1954\n")
cat("Panel method: Grouped estimation\n")
cat("Cointegrating equation deterministics: C\n")
cat("Long-run covariance estimates (Bartlett kernel, User bandwidth = 6.0000)\n\n")
cat("Variable\tCoefficient\tStd. Error\tt-Statistic\tProb.\n")
cat("---------\t-----------\t-----------\t----------\t-----\n")
cat("LVALUE\t0.736534\t0.097004\t7.592857\t0.0000\n")
cat("LCAPITAL\t0.418421\t0.032399\t12.91453\t0.0000\n\n")

cat("NOTE: Your EViews used DIFFERENT variables (LVALUE, LCAPITAL)\n")
cat("The fmolsR results above use: lgdp, lene, ltro, lrvc, lenv, linst, lgei, cdp\n")
