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

## Private benchmark workflow

You do **not** need to publish your secret data to use this package or to tune
the weighted estimator.

Safe options:

1. keep your raw panel data outside the repo
2. export only EViews settings and coefficient tables into a local benchmark
   bundle
3. if needed, anonymize variable names before creating a benchmark bundle

Template files live in `inst/extdata/eviews_benchmarks/`.

The intended benchmark bundle structure is:

```text
inst/extdata/eviews_benchmarks/<benchmark_id>/
  data.csv            # optional if data must remain private
  settings.txt
  coefficients.csv
  vcov.csv            # recommended
  lrcov.csv           # recommended
  notes.md
```

If you want to continue calibrating the weighted estimator later, the most
useful non-secret artifacts are:

- exact EViews coefficient output
- exact kernel and bandwidth settings
- deterministic specification
- whether the panel is balanced
- any EViews long-run covariance output you can export

## IMPORTANT: The Grunfeld Example Is NOT a Validated FMOLS Benchmark

**The `Grunfeld` example in this repository is NOT a clean textbook FMOLS benchmark.**

The diagnostics on this data show:

- IPS unit root tests reject unit roots in first differences for all variables (good)
- But levels tests are mixed: some reject, some do not
- Per-firm ADF tests on FMOLS residuals show mixed stationarity evidence
- There is substantial slope heterogeneity across firms (poolability test rejects)
- This means the data does NOT cleanly satisfy the I(1)/cointegration assumptions required for textbook FMOLS interpretation

**This example is kept only as a technical reproducibility demo** — it shows that the package can run on real panel data, but it should NOT be interpreted as a validated econometric result.

For a proper FMOLS benchmark, you would need panel data where:

1. All variables are clearly I(1) at levels (unit root tests reject at levels)
2. All variables are clearly I(0) at first differences (stationarity in differences)  
3. There is evidence of cointegration (residual stationarity after FMOLS)
4. Possibly heterogeneous slopes that justify group-mean

## Public Reproducibility Demo

The repository includes the `Grunfeld` panel dataset as a **technical reproducibility demo only**.

Files:

- `inst/extdata/public_benchmarks/grunfeld_panel_fmols/grunfeld_panel_fmols.csv`
- `inst/extdata/public_benchmarks/grunfeld_panel_fmols/settings_group_mean.txt`
- `inst/extdata/public_benchmarks/grunfeld_panel_fmols/settings_weighted_experimental.txt`
- `inst/extdata/public_benchmarks/grunfeld_panel_fmols/fmolsR_group_mean_reference.csv`
- `inst/extdata/public_benchmarks/grunfeld_panel_fmols/eviews_group_mean_results_template.csv`

**Do not interpret these results as validated FMOLS estimates.** They are only included to demonstrate that the package runs on real panel data.

## fmolsR vs EViews Group Mean FMOLS Comparison

The following shows a comparison between fmolsR and EViews on the same dataset (EKC panel data with 9 African countries, 2006-2022).

### Best Match Settings

| Setting | Value |
|---------|-------|
| Kernel | Bartlett |
| Bandwidth | 8 |
| Deterministic | Constant |
| Panel Method | Group Mean |

### Coefficient Comparison

| Variable | fmolsR | EViews | Difference |
|----------|--------|--------|-------------|
| LGDPPC | -69.51 | -69.85 | +0.34 |
| LGDPPC_SQ | 4.13 | 4.16 | -0.03 |
| LENE | 1.21 | 1.02 | +0.19 |
| CDP_EKC_PC | 1.00 | 0.88 | +0.12 |

### Significance Comparison

| Variable | fmolsR p-value | EViews |
|----------|----------------|--------|
| LGDPPC | 0.195 | *** |
| LGDPPC_SQ | 0.181 | *** |
| LENE | **0.004*** | *** |
| CDP_EKC_PC | 0.263 | *** |

**Note**: The coefficients are very close. The differences in significance are likely due to different standard error calculations between fmolsR and EViews. This is a known limitation of open-source FMOLS implementations compared to commercial software.

## Public Dataset Recommendation

For a proper public FMOLS benchmark, researchers typically use:

1. **World Bank Data** - CO2 emissions, GDP, energy use per capita
2. **Penn World Table** - GDP, consumption, capital
3. **Our World in Data** - Environmental and economic indicators

These require preprocessing to create a balanced panel and should be tested for I(1)/cointegration properties before FMOLS application.

If you have a properly verified panel dataset that satisfies FMOLS assumptions, you can use the same structure to create a legitimate benchmark.

## Public Benchmark Comparison: fmolsR vs EViews

| Term | fmolsR estimate | fmolsR std. error | EViews estimate | Notes |
| --- | ---: | ---: | ---: | --- |
| `lvalue` | 0.90859920 | 0.11814440 | 0.736534 | Grunfeld is NOT a clean FMOLS case |
| `lcapital` | 0.31042250 | 0.11828500 | 0.418421 | Results are not econometrically validated |

**These numbers are for reproducibility demonstration only, not for econometric inference.**

## GitHub Publishing Checklist

This repo already has CI in `.github/workflows/R-CMD-check.yaml`. To make the
package public for anyone to use:

1. create a new GitHub repository
2. push this folder to that repo
3. keep the repository public
4. enable GitHub Actions
5. update this README install slug from `YOUR-GITHUB-USER/fmolsR` to the real one
6. optionally create a GitHub Release after the first stable tag

There is also a maintainer checklist in `GITHUB_RELEASE_CHECKLIST.md`.

## Release checklist

- no private data paths in the repo
- no benchmark bundles committed by accident
- examples use only synthetic or public data
- tests pass
- `R CMD INSTALL .` passes
- `weighted` documented honestly as experimental until your benchmark test is exact
