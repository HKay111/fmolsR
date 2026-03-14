# GitHub Release Checklist

Use this when you are ready to publish `fmolsR` so anyone can install it.

## Before pushing

1. fill in the real author name and email in `DESCRIPTION`
2. confirm `README.md` still matches the current package status
3. run:

```bash
R CMD INSTALL .
Rscript -e "library(fmolsR); testthat::test_dir('tests/testthat')"
R CMD build .
```

## Create the GitHub repo

1. create a new public GitHub repository named `fmolsR`
2. from the package root, run:

```bash
git init
git add .
git commit -m "Initial public release"
git branch -M main
git remote add origin git@github.com:YOUR-GITHUB-USER/fmolsR.git
git push -u origin main
```

Replace `YOUR-GITHUB-USER` with your real GitHub username.

## After pushing

1. enable GitHub Actions
2. confirm `.github/workflows/R-CMD-check.yaml` runs cleanly
3. update the README install example to your real GitHub repo slug
4. optionally create a GitHub Release and attach the source tarball from `R CMD build .`

## How users will install it

```r
install.packages("remotes")
remotes::install_github("YOUR-GITHUB-USER/fmolsR")
```

## Benchmark follow-up

If you later add a real public FMOLS benchmark dataset, update `README.md` with the matching EViews comparison only after the dataset passes the required I(1) and cointegration diagnostics.
