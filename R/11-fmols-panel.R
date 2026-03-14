#' FMOLS for panel cointegrating regressions
#'
#' Training implementation of pooled, weighted, and group-mean panel FMOLS.
#' This function is designed to remain inspectable rather than maximally compact.
#'
#' @param formula A regression formula such as `y ~ x1 + x2`.
#' @param data A data.frame containing the variables.
#' @param id Name of the cross-section identifier column.
#' @param time Optional name of the time identifier column.
#' @param panel_method One of `"pooled"`, `"weighted"`, or `"group_mean"`.
#' @param trend Deterministic specification.
#' @param additional_deterministics Optional additional deterministic regressors.
#' @param first_stage Either `"level"` or `"difference"`.
#' @param kernel Long-run covariance kernel.
#' @param bandwidth Positive numeric bandwidth or one of `"andrews"` or
#'   `"newey_west"`.
#' @param demean Logical; whether to demean before long-run covariance estimation.
#' @param df_adjust Logical finite-sample adjustment flag.
#'
#' @return An object of class `fmols_panel_fit`.
#' @export
fmols_panel <- function(
    formula,
    data,
    id,
    time = NULL,
    panel_method = c("pooled", "weighted", "group_mean"),
    trend = c("const", "none", "trend", "quadratic"),
    additional_deterministics = NULL,
    first_stage = c("level", "difference"),
    kernel = c("bartlett", "parzen", "quadratic_spectral", "truncated"),
    bandwidth = 6,
    demean = FALSE,
    df_adjust = TRUE) {
  panel_method <- match.arg(panel_method)
  trend <- match.arg(trend)
  first_stage <- match.arg(first_stage)
  kernel <- match.arg(kernel)

  panel_data <- .fmols_panel_unit_fits(
    formula = formula,
    data = data,
    id = id,
    time = time,
    trend = trend,
    additional_deterministics = additional_deterministics,
    first_stage = first_stage,
    kernel = kernel,
    bandwidth = bandwidth,
    demean = demean,
    df_adjust = df_adjust
  )

  fits <- panel_data$fits
  unit_ids <- names(fits)
  beta_mat <- .fmols_panel_common_beta(fits)
  rownames(beta_mat) <- unit_ids

  if (panel_method == "group_mean") {
    beta_hat <- colMeans(beta_mat)
    vcov_beta <- .fmols_panel_named_variance(beta_mat) / nrow(beta_mat)
    stderr <- sqrt(diag(vcov_beta))
    t_stat <- beta_hat / stderr
    p_value <- 2 * stats::pt(-abs(t_stat), df = max(1, nrow(beta_mat) - 1))

    out <- list(
      call = match.call(),
      formula = formula,
      panel_method = panel_method,
      coefficients = beta_hat,
      vcov = vcov_beta,
      stderr = stderr,
      t_stat = t_stat,
      p_value = p_value,
      unit_coefficients = beta_mat,
      unit_fits = fits,
      settings = list(
        id = id,
        time = time,
        trend = trend,
        first_stage = first_stage,
        kernel = kernel,
        bandwidth = fits[[1]]$settings$bandwidth,
        panel_method = panel_method,
        demean = demean,
        df_adjust = df_adjust
      )
    )

    class(out) <- "fmols_panel_fit"
    return(out)
  }

  x_names <- names(fits[[1]]$beta)
  xtx <- NULL
  rhs <- NULL

  if (panel_method == "weighted") {
    beta_0 <- .fmols_panel_preliminary_beta(fits)

    for (fit in fits) {
      terms <- .fmols_panel_unit_terms(fit)
      omega_vv_inv <- .fmols_matrix_inverse(fit$long_run$Omega$vv)
      x_star <- terms$x %*% omega_vv_inv
      y_star <- terms$y_fm +
        drop(x_star %*% beta_0) -
        drop(terms$x %*% beta_0)
      delta_star <- drop(omega_vv_inv %*% terms$delta)

      term_xtx <- crossprod(x_star)
      term_rhs <- crossprod(x_star, y_star) - terms$n_eff * delta_star

      if (is.null(xtx)) {
        xtx <- term_xtx
        rhs <- term_rhs
      } else {
        xtx <- xtx + term_xtx
        rhs <- rhs + term_rhs
      }
    }
  } else {
    for (fit in fits) {
      terms <- .fmols_panel_unit_terms(fit)
      term_xtx <- crossprod(terms$x)
      term_rhs <- crossprod(terms$x, terms$y_fm) - terms$n_eff * terms$delta

      if (is.null(xtx)) {
        xtx <- term_xtx
        rhs <- term_rhs
      } else {
        xtx <- xtx + term_xtx
        rhs <- rhs + term_rhs
      }
    }
  }

  beta_hat <- drop(.fmols_safe_solve(xtx, panel_method) %*% rhs)
  names(beta_hat) <- x_names

  pooled_variance <- mean(vapply(
    fits,
    function(fit) fit$long_run$conditional_variance,
    numeric(1)
  ))
  vcov_beta <- pooled_variance * .fmols_safe_solve(xtx, "panel vcov")
  stderr <- sqrt(diag(vcov_beta))
  t_stat <- beta_hat / stderr
  n_units <- length(fits)
  n_obs <- sum(vapply(fits, function(fit) fit$settings$n_obs - 1L, integer(1)))
  n_params <- length(beta_hat)
  p_value <- 2 * stats::pt(-abs(t_stat), df = max(1, n_obs - n_units - n_params))

  out <- list(
    call = match.call(),
    formula = formula,
    panel_method = panel_method,
    coefficients = beta_hat,
    vcov = vcov_beta,
    stderr = stderr,
    t_stat = t_stat,
    p_value = p_value,
    unit_coefficients = beta_mat,
    unit_fits = fits,
    settings = list(
      id = id,
      time = time,
      trend = trend,
      first_stage = first_stage,
      kernel = kernel,
      bandwidth = fits[[1]]$settings$bandwidth,
      panel_method = panel_method,
      demean = demean,
      df_adjust = df_adjust
    )
  )

  class(out) <- "fmols_panel_fit"
  out
}
