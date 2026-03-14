# Public Reproducibility Demos

This folder contains public datasets that can be run in both R and EViews.

**IMPORTANT: These are technical reproducibility demos, NOT validated econometric benchmarks.**

The included `Grunfeld` example does NOT satisfy clean FMOLS assumptions (see the diagnostics in the subfolder README).

For a proper FMOLS benchmark, you would need panel data where variables are clearly I(1) at levels, clearly I(0) at first differences, and show evidence of cointegration.

Current demo:

- `grunfeld_panel_fmols/` - technical reproducibility demo only (NOT a validated benchmark)

Purpose of these demos:

- show that the package can run on real panel data
- provide a frozen specification anyone can reproduce
- provide reference results for comparison

These are different from private EViews calibration bundles:

- public demos are committed to the repo
- private bundles should stay local
