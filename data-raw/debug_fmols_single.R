# Run this script manually from the package root after installation to inspect
# the first working FMOLS training slice.

library(fmolsR)

set.seed(42)
n <- 250
v <- rnorm(n)
x <- cumsum(v)
y <- 1 + 0.8 * x + 0.5 * v + rnorm(n, sd = 0.5)

dat <- data.frame(y = y, x = x)

fit <- fmols_single(
  y ~ x,
  data = dat,
  trend = "const",
  first_stage = "level",
  kernel = "bartlett",
  bandwidth = 6
)

print(fit)
print(summary(fit))

# Debug objects to inspect while learning:
str(fit$detrended)
str(fit$first_stage)
str(fit$long_run)
str(fit$transformed)

fit$coefficients
fit$stderr

fit_auto <- fmols_single(
  y ~ x,
  data = dat,
  trend = "const",
  first_stage = "level",
  kernel = "bartlett",
  bandwidth = "andrews"
)

print(fit_auto)
