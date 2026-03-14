testthat::test_that("Bartlett kernel weights behave as expected", {
  testthat::expect_equal(fmolsR:::.fmols_kernel_weight(0, 4, "bartlett"), 1)
  testthat::expect_equal(fmolsR:::.fmols_kernel_weight(1, 4, "bartlett"), 0.75)
  testthat::expect_equal(fmolsR:::.fmols_kernel_weight(4, 4, "bartlett"), 0)
  testthat::expect_equal(fmolsR:::.fmols_kernel_weight(5, 4, "bartlett"), 0)
})

testthat::test_that("relevant lag selection is finite and non-empty when possible", {
  testthat::expect_equal(fmolsR:::.fmols_relevant_lags(10, 4, "bartlett"), 1:4)
  testthat::expect_equal(tail(fmolsR:::.fmols_relevant_lags(10, 4, "quadratic_spectral"), 1), 9)
})
