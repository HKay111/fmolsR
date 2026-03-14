# Test plan

This directory starts with a smoke test so you have an early green check.

Add tests in this order:

1. deterministic-term helpers
2. kernel weights
3. autocovariance and long-run covariance
4. bandwidth selection
5. single-equation FMOLS
6. panel pooled FMOLS
7. panel weighted FMOLS
8. panel group-mean FMOLS

Do not add benchmark tests until the benchmark bundle is present in
`inst/extdata/eviews_benchmarks/`.
