# data-raw

Use this directory for scripts that prepare benchmark inputs or synthetic data.

Good uses:

- import EViews CSV exports
- create benchmark bundle folders
- generate synthetic cointegrated data for unit tests
- create expected-output registries

Privacy rule:

- do not hard-code private absolute paths here
- keep secret benchmark data outside the public repo unless anonymized

Do not treat this directory as package code. It is for reproducible data preparation only.
