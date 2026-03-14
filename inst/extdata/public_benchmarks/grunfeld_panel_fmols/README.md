# Grunfeld Public Reproducibility Demo (NOT a Validated FMOLS Benchmark)

**This is NOT a clean textbook FMOLS benchmark.** The data does not satisfy the standard I(1)/cointegration assumptions required for proper FMOLS interpretation.

## Diagnostic Evidence

- IPS unit root tests on levels: mixed (some reject, some do not)
- IPS unit root tests on first differences: all reject (good)
- Per-firm FMOLS residual stationarity: 5/10 reject at 5% (mixed)
- Poolability test: rejects homogeneous slopes (significant heterogeneity)
- Per-firm FMOLS coefficient SD: `lvalue` SD = 0.37, `lcapital` SD = 0.37

## What This Is

This folder contains the classic `Grunfeld` panel dataset as a **technical reproducibility demo only**. It demonstrates that the package can run on real panel data, but the results should NOT be interpreted as validated econometric estimates.

For a proper FMOLS benchmark, you would need data where:

1. Variables are clearly I(1) at levels
2. Variables are clearly I(0) at first differences  
3. There is evidence of cointegration
4. Possibly heterogeneous slopes that justify group-mean

## Dataset

- source: `plm::Grunfeld`
- structure: 10 firms x 20 years = 200 observations
- panel ids: `firm`
- time ids: `year`

Variables: `firm`, `year`, `inv`, `value`, `capital`, `linv`, `lvalue`, `lcapital`

## Files in This Folder

- `grunfeld_panel_fmols.csv` - the dataset
- `settings_group_mean.txt` - frozen specification used
- `fmolsR_group_mean_reference.csv` - fmolsR results (for reproducibility only)
- `eviews_group_mean_results_template.csv` - EViews results template
