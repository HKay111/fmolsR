# fmolsR

**This is an undergraduate learning project** - not a professionally validated econometric package.

`fmolsR` is an attempt to learn how to implement Fully Modified OLS (FMOLS) cointegrating regression in R by studying how EViews does it. This is a learning exercise using AI assistance.

**Use with caution** - validate against trusted software like EViews before publishing any results.

## Current release status

- `fmols_single()`: usable for learning
- panel `group_mean`: the safest estimator in this package
- panel `pooled`: usable for experimentation
- panel `weighted`: experimental - still needs calibration against EViews

## Install

```r
# from the package root
install.packages(c("MASS", "testthat"))
devtools::install_local(".")
```

## Install From GitHub

```r
install.packages("remotes")
remotes::install_github("HKay111/fmolsR")
```

## Public-safe example

This example uses synthetic panel data only.

```r
library(fmolsR)

set.seed(123)
n_id <- 5
n_t <- 80
id <- rep(sprintf("id_%02d", seq_len(n_id)), each = n_t)
time <- rep(seq_len(n_t), times = n_id)

build_unit <- function(n) {
  v1 <- rnorm(n, sd = 0.7)
  v2 <- rnorm(n, sd = 0.5)
  x1 <- cumsum(v1)
  x2 <- cumsum(v2)
  y <- 0.8 * x1 - 0.4 * x2 + 0.3 * v1 + rnorm(n, sd = 0.4)
  data.frame(y = y, x1 = x1, x2 = x2)
}

panel_dat <- do.call(rbind, lapply(seq_len(n_id), function(i) {
  out <- build_unit(n_t)
  out$id <- sprintf("id_%02d", i)
  out$time <- seq_len(n_t)
  out
}))

fit_gm <- fmols_panel(
  y ~ x1 + x2,
  data = panel_dat,
  id = "id",
  time = "time",
  panel_method = "group_mean",
  trend = "const",
  bandwidth = "andrews"
)

summary(fit_gm)
```

## What gets trimmed in FMOLS

FMOLS in this package drops exactly one observation per unit in the transformed
estimation step. That is because the first-stage innovations and FM correction
are built from lagged or differenced information, so the estimator uses `y[-1]`
and the aligned innovation matrix.

This means:

- yearly data loses one year per unit
- quarterly data loses one quarter per unit
- monthly data loses one month per unit
- weekly data loses one week per unit
- daily data loses one day per unit

More precisely, the package drops one ordered time row per unit, whatever your
time index represents.
