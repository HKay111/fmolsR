testthat::test_that("fmols_single returns a usable fit object", {
  set.seed(42)
  n <- 250
  v <- rnorm(n)
  x <- cumsum(v)
  y <- 1 + 0.8 * x + 0.5 * v + rnorm(n, sd = 0.5)
  dat <- data.frame(y = y, x = x)

  fit <- fmolsR::fmols_single(y ~ x, data = dat, trend = "const", bandwidth = 6)

  testthat::expect_s3_class(fit, "fmols_fit")
  testthat::expect_true(all(c("const", "x") %in% names(fit$coefficients)))
  testthat::expect_true(is.finite(fit$coefficients[["x"]]))
  testthat::expect_true(abs(fit$coefficients[["x"]] - 0.8) < 0.2)
  testthat::expect_true(length(fit$transformed$y_plus) == n - 1)
  testthat::expect_equal(fit$long_run$bandwidth$method, "fixed")
})

testthat::test_that("fmols_single supports first-stage difference regression with extra deterministics", {
  set.seed(99)
  n <- 180
  trend_z2 <- seq_len(n)
  x <- cumsum(rnorm(n) + 0.01 * trend_z2)
  y <- 2 + 1.1 * x + rnorm(n)
  dat <- data.frame(y = y, x = x, z2 = trend_z2)

  fit <- fmolsR::fmols_single(
    y ~ x,
    data = dat,
    trend = "const",
    additional_deterministics = "z2",
    first_stage = "difference",
    bandwidth = 5
  )

  testthat::expect_true(is.matrix(fit$first_stage$innovations))
  testthat::expect_equal(nrow(fit$first_stage$innovations), n - 1)
  testthat::expect_true(all(is.finite(fit$stderr)))
})

testthat::test_that("fmols_single supports automatic bandwidth selection", {
  set.seed(7)
  n <- 220
  x <- cumsum(rnorm(n))
  y <- 1.5 + 0.7 * x + rnorm(n)
  dat <- data.frame(y = y, x = x)

  fit <- fmolsR::fmols_single(y ~ x, data = dat, bandwidth = "andrews")

  testthat::expect_true(fit$settings$bandwidth$number > 0)
  testthat::expect_equal(fit$settings$bandwidth$method, "andrews")
})
