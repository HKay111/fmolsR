testthat::test_that("fmols_panel returns pooled panel fit", {
  set.seed(101)
  n_id <- 5
  n_t <- 70
  id <- rep(seq_len(n_id), each = n_t)
  time <- rep(seq_len(n_t), times = n_id)
  x <- ave(rnorm(n_id * n_t), id, FUN = cumsum)
  y <- 2 + 0.9 * x + rnorm(n_id * n_t, sd = 0.7)
  dat <- data.frame(id = id, time = time, y = y, x = x)

  fit <- fmolsR::fmols_panel(
    y ~ x,
    data = dat,
    id = "id",
    time = "time",
    panel_method = "pooled",
    bandwidth = "andrews"
  )

  testthat::expect_s3_class(fit, "fmols_panel_fit")
  testthat::expect_true("x" %in% names(fit$coefficients))
  testthat::expect_true(is.finite(fit$coefficients[["x"]]))
  testthat::expect_equal(fit$settings$panel_method, "pooled")
})

testthat::test_that("fmols_panel returns weighted and group-mean fits", {
  set.seed(202)
  n_id <- 4
  n_t <- 60
  id <- rep(seq_len(n_id), each = n_t)
  time <- rep(seq_len(n_t), times = n_id)
  x <- ave(rnorm(n_id * n_t), id, FUN = cumsum)
  y <- 1 + 1.1 * x + rnorm(n_id * n_t)
  dat <- data.frame(id = id, time = time, y = y, x = x)

  fit_w <- fmolsR::fmols_panel(
    y ~ x,
    data = dat,
    id = "id",
    time = "time",
    panel_method = "weighted",
    bandwidth = 5
  )

  fit_gm <- fmolsR::fmols_panel(
    y ~ x,
    data = dat,
    id = "id",
    time = "time",
    panel_method = "group_mean",
    bandwidth = 5
  )

  testthat::expect_equal(fit_w$settings$panel_method, "weighted")
  testthat::expect_equal(fit_gm$settings$panel_method, "group_mean")
  testthat::expect_true(is.matrix(fit_gm$unit_coefficients))
  testthat::expect_true(all(is.finite(fit_w$stderr)))
})
