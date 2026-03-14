# Run this script manually from the package root to regenerate the public
# Grunfeld benchmark CSV shipped in inst/extdata/public_benchmarks/.

data("Grunfeld", package = "plm")

dat <- Grunfeld[order(Grunfeld[["firm"]], Grunfeld[["year"]]), c(
  "firm",
  "year",
  "inv",
  "value",
  "capital"
)]

dat$linv <- log(dat$inv)
dat$lvalue <- log(dat$value)
dat$lcapital <- log(dat$capital)

out_path <- file.path(
  "inst",
  "extdata",
  "public_benchmarks",
  "grunfeld_panel_fmols",
  "grunfeld_panel_fmols.csv"
)

utils::write.csv(dat, out_path, row.names = FALSE)

out_path
