testthat::test_that("deterministic builder returns expected columns", {
  d_const <- fmolsR:::.fmols_build_deterministics(5, trend = "const")
  d_trend <- fmolsR:::.fmols_build_deterministics(5, trend = "trend")
  d_quad <- fmolsR:::.fmols_build_deterministics(5, trend = "quadratic")

  testthat::expect_equal(dim(d_const), c(5, 1))
  testthat::expect_equal(colnames(d_trend), c("const", "trend"))
  testthat::expect_equal(colnames(d_quad), c("const", "trend", "quadratic"))
})

testthat::test_that("partial out leaves data unchanged when no deterministics are supplied", {
  y <- matrix(1:5, ncol = 1)
  out <- fmolsR:::.fmols_partial_out(y, matrix(numeric(0), nrow = 5, ncol = 0))

  testthat::expect_equal(out$residuals, y)
})
