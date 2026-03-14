#' Fully Modified OLS for a single cointegrating regression
#'
#' A readable training implementation of a single-equation FMOLS estimator.
#' This version is intentionally transparent: it exposes deterministic terms,
#' first-stage innovations, long-run covariance pieces, and transformed data so
#' you can debug and reverse-engineer the estimator step by step.
#'
#' @param formula A regression formula such as `y ~ x1 + x2`.
#' @param data A data.frame containing the variables in `formula`.
#' @param trend Deterministic specification for the cointegrating equation.
#' @param additional_deterministics Optional deterministic regressors used only
#'   in the first-stage regressors equations. May be a matrix/data.frame or a
#'   character vector naming columns in `data`.
#' @param first_stage Either `"level"` or `"difference"`.
#' @param kernel Long-run covariance kernel.
#' @param bandwidth Positive numeric bandwidth or one of `"andrews"` or
#'   `"newey_west"`.
#' @param demean Logical; whether to demean the stacked residual/innovation data
#'   before long-run covariance estimation.
#' @param df_adjust Logical; whether to apply a simple finite-sample scaling to
#'   the conditional long-run variance used in the coefficient covariance.
#'
#' @return An object of class `fmols_fit`.
#' @export
fmols_single <- function(
    formula,
    data,
    trend = c("const", "none", "trend", "quadratic"),
    additional_deterministics = NULL,
    first_stage = c("level", "difference"),
    kernel = c("bartlett", "parzen", "quadratic_spectral", "truncated"),
    bandwidth = 6,
    demean = FALSE,
    df_adjust = TRUE) {
  trend <- match.arg(trend)
  first_stage <- match.arg(first_stage)
  kernel <- match.arg(kernel)

  .fmols_fit_single_unit(
    formula = formula,
    data = data,
    trend = trend,
    additional_deterministics = additional_deterministics,
    first_stage = first_stage,
    kernel = kernel,
    bandwidth = bandwidth,
    demean = demean,
    df_adjust = df_adjust
  )
}
