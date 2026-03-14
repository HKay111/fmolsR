testthat::test_that("public Grunfeld benchmark assets exist", {
  root_candidates <- c(
    system.file("extdata", "public_benchmarks", package = "fmolsR"),
    file.path("inst", "extdata", "public_benchmarks")
  )

  root <- root_candidates[nzchar(root_candidates)][1]

  testthat::expect_true(dir.exists(root))
  testthat::expect_true(file.exists(file.path(root, "README.md")))

  bench_root <- file.path(root, "grunfeld_panel_fmols")
  testthat::expect_true(dir.exists(bench_root))
  testthat::expect_true(file.exists(file.path(bench_root, "grunfeld_panel_fmols.csv")))
  testthat::expect_true(file.exists(file.path(bench_root, "settings_group_mean.txt")))
  testthat::expect_true(file.exists(file.path(bench_root, "fmolsR_group_mean_reference.csv")))
})

testthat::test_that("public Grunfeld benchmark runs group mean FMOLS", {
  root_candidates <- c(
    system.file("extdata", "public_benchmarks", package = "fmolsR"),
    file.path("inst", "extdata", "public_benchmarks")
  )

  root <- root_candidates[nzchar(root_candidates)][1]
  dat <- utils::read.csv(file.path(root, "grunfeld_panel_fmols", "grunfeld_panel_fmols.csv"))

  fit <- fmolsR::fmols_panel(
    linv ~ lvalue + lcapital,
    data = dat,
    id = "firm",
    time = "year",
    panel_method = "group_mean",
    trend = "const",
    kernel = "bartlett",
    bandwidth = 6
  )

  testthat::expect_s3_class(fit, "fmols_panel_fit")
  testthat::expect_equal(fit$settings$panel_method, "group_mean")
  testthat::expect_true(all(is.finite(fit$coefficients)))
  testthat::expect_true(all(c("lvalue", "lcapital") %in% names(fit$coefficients)))
})
