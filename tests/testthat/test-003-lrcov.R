testthat::test_that("sample autocovariance matches hand-computable lag zero case", {
  z <- cbind(c(1, 2, 3), c(2, 4, 6))
  gamma0 <- fmolsR:::.fmols_sample_autocovariance(z, lag = 0, demean = FALSE)

  testthat::expect_equal(gamma0, crossprod(z) / nrow(z))
})

testthat::test_that("long-run covariance object contains key pieces", {
  set.seed(10)
  z <- cbind(rnorm(30), rnorm(30))
  out <- fmolsR:::.fmols_long_run_covariance(z, kernel = "bartlett", bandwidth = 4)

  testthat::expect_true(is.matrix(out$Omega))
  testthat::expect_true(is.matrix(out$Delta))
  testthat::expect_equal(length(out$weights), length(out$lags))
  testthat::expect_equal(out$bandwidth$method, "fixed")
})

testthat::test_that("automatic bandwidth methods return positive values", {
  set.seed(11)
  z <- cbind(rnorm(80), rnorm(80))

  out_and <- fmolsR:::.fmols_long_run_covariance(z, kernel = "bartlett", bandwidth = "andrews")
  out_nw <- fmolsR:::.fmols_long_run_covariance(z, kernel = "bartlett", bandwidth = "newey_west")

  testthat::expect_true(out_and$bandwidth$number > 0)
  testthat::expect_true(out_nw$bandwidth$number > 0)
  testthat::expect_equal(out_and$bandwidth$method, "andrews")
  testthat::expect_equal(out_nw$bandwidth$method, "newey_west")
})
