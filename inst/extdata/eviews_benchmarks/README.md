# EViews benchmark bundles

Store one folder per benchmark run here.

Recommended structure:

```text
<benchmark_id>/
  data.csv
  settings.txt
  coefficients.csv
  vcov.csv
  lrcov.csv
  notes.md
```

## Minimum contents

- `data.csv`
- `settings.txt`
- `coefficients.csv`

## Strongly recommended contents

- `vcov.csv`
- `lrcov.csv`
- a note with the exact reported bandwidth and EViews version

## Export advice

- export full precision where possible
- record panel ids and time ids explicitly
- record whether the panel is balanced
- record missing-value handling
- record whether the first-stage regressors equations were estimated in levels or differences

Use `registry_template.csv` in this same directory to keep an index of the benchmark folders.
