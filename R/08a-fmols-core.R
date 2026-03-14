.fmols_prepare_single_unit <- function(
    formula,
    data,
    trend,
    additional_deterministics,
    first_stage,
    kernel,
    bandwidth,
    demean) {
  parsed <- .fmols_parse_formula_data(formula = formula, data = data)
  y <- parsed$y
  x <- parsed$x
  n_obs <- nrow(x)
  x_names <- colnames(x)

  z1 <- .fmols_build_deterministics(n_obs = n_obs, trend = trend)
  z2 <- .fmols_resolve_additional_deterministics(
    additional_deterministics = additional_deterministics,
    data = data,
    n_obs = n_obs
  )

  detrended_y <- .fmols_partial_out(y, z1)
  detrended_x <- .fmols_partial_out(x, z1)

  z <- cbind(z1, x)
  colnames(z) <- c(colnames(z1), x_names)

  ols_fit <- stats::lm.fit(x = z, y = y)
  theta_ols <- drop(ols_fit$coefficients)
  names(theta_ols) <- colnames(z)
  u_ols <- drop(ols_fit$residuals)

  first_stage_fit <- .fmols_first_stage_innovations(x = x, z2 = z2, method = first_stage)
  v_hat <- .fmols_as_numeric_matrix(first_stage_fit$innovations, "first-stage innovations")
  colnames(v_hat) <- x_names

  uv_stack <- cbind(u_ols[-1], v_hat)
  colnames(uv_stack) <- c("u", x_names)

  lrcov <- .fmols_long_run_covariance(
    z = uv_stack,
    kernel = kernel,
    bandwidth = bandwidth,
    demean = demean
  )

  omega_parts <- .fmols_partition_long_run(lrcov$Omega, y_dim = 1, x_dim = ncol(x))
  delta_parts <- .fmols_partition_long_run(lrcov$Delta, y_dim = 1, x_dim = ncol(x))
  cond_lr <- .fmols_conditional_long_run_variance(omega_parts)

  delta_vu_plus <- delta_parts$vu - (delta_parts$vv %*% cond_lr$omega_vv_inv_vu)
  correction_term <- v_hat %*% cond_lr$omega_vv_inv_vu
  y_plus <- y[-1, , drop = FALSE] - correction_term
  z_fm <- z[-1, , drop = FALSE]

  list(
    parsed = parsed,
    y = y,
    x = x,
    z1 = z1,
    z2 = z2,
    z = z,
    x_names = x_names,
    n_obs = n_obs,
    theta_ols = theta_ols,
    u_ols = u_ols,
    detrended_y = detrended_y,
    detrended_x = detrended_x,
    first_stage = first_stage_fit,
    uv_stack = uv_stack,
    lrcov = lrcov,
    omega_parts = omega_parts,
    delta_parts = delta_parts,
    cond_lr = cond_lr,
    delta_vu_plus = delta_vu_plus,
    correction_term = correction_term,
    y_plus = y_plus,
    z_fm = z_fm
  )
}

.fmols_finalize_single_unit <- function(prepped, df_adjust = TRUE) {
  n_obs <- prepped$n_obs
  z_fm <- prepped$z_fm
  z1 <- prepped$z1
  x <- prepped$x

  rhs <- crossprod(z_fm, prepped$y_plus) - c(rep(0, ncol(z1)), n_obs * drop(prepped$delta_vu_plus))
  z_cross_inv <- .fmols_safe_solve(crossprod(z_fm), "crossprod(Z_fm)")
  theta_fm <- drop(z_cross_inv %*% rhs)
  names(theta_fm) <- colnames(prepped$z)

  fm_residuals <- c(NA_real_, drop(prepped$y[-1, , drop = FALSE] - z_fm %*% theta_fm))
  fitted_values <- drop(prepped$z %*% theta_fm)

  omega_u_v <- as.numeric(prepped$cond_lr$omega_u_v[1, 1])
  n_eff <- nrow(z_fm)
  p_total <- ncol(z_fm)

  if (df_adjust && (n_eff - p_total) > 0) {
    omega_u_v <- omega_u_v * (n_eff / (n_eff - p_total))
  }

  vcov_theta <- omega_u_v * z_cross_inv
  stderr <- sqrt(diag(vcov_theta))
  t_stat <- theta_fm / stderr
  p_value <- 2 * stats::pt(-abs(t_stat), df = max(1, n_eff - p_total))

  list(
    coefficients = theta_fm,
    deterministic_coefficients = theta_fm[seq_len(ncol(z1))],
    beta = theta_fm[ncol(z1) + seq_len(ncol(x))],
    vcov = vcov_theta,
    stderr = stderr,
    t_stat = t_stat,
    p_value = p_value,
    residuals = fm_residuals,
    fitted.values = fitted_values,
    conditional_variance = omega_u_v,
    z_cross_inv = z_cross_inv
  )
}

.fmols_build_single_fit <- function(
    formula,
    trend,
    first_stage,
    kernel,
    demean,
    df_adjust,
    prepped,
    solved) {
  out <- list(
    call = match.call(),
    formula = formula,
    coefficients = solved$coefficients,
    deterministic_coefficients = solved$deterministic_coefficients,
    beta = solved$beta,
    vcov = solved$vcov,
    stderr = solved$stderr,
    t_stat = solved$t_stat,
    p_value = solved$p_value,
    residuals = solved$residuals,
    fitted.values = solved$fitted.values,
    ols = list(
      coefficients = prepped$theta_ols,
      residuals = prepped$u_ols
    ),
    detrended = list(
      y = drop(prepped$detrended_y$residuals),
      x = prepped$detrended_x$residuals,
      deterministic_design = prepped$z1,
      first_stage_design = prepped$z2,
      deterministic_coefficients_y = prepped$detrended_y$coefficients,
      deterministic_coefficients_x = prepped$detrended_x$coefficients
    ),
    first_stage = prepped$first_stage,
    long_run = list(
      Omega = prepped$omega_parts,
      Delta = prepped$delta_parts,
      gamma0 = prepped$lrcov$gamma0,
      gammas = prepped$lrcov$gammas,
      lags = prepped$lrcov$lags,
      weights = prepped$lrcov$weights,
      conditional_variance = solved$conditional_variance,
      bandwidth = prepped$lrcov$bandwidth,
      kernel = prepped$lrcov$kernel
    ),
    transformed = list(
      y_plus = drop(prepped$y_plus),
      correction_term = drop(prepped$correction_term),
      delta_vu_plus = drop(prepped$delta_vu_plus),
      design_matrix = prepped$z,
      fm_design_matrix = prepped$z_fm,
      stacked_innovations = prepped$uv_stack
    ),
    settings = list(
      trend = trend,
      first_stage = first_stage,
      kernel = kernel,
      bandwidth = prepped$lrcov$bandwidth,
      demean = demean,
      df_adjust = df_adjust,
      n_obs = prepped$n_obs,
      n_regressors = ncol(prepped$x)
    )
  )

  class(out) <- "fmols_fit"
  out
}

.fmols_fit_single_unit <- function(
    formula,
    data,
    trend,
    additional_deterministics,
    first_stage,
    kernel,
    bandwidth,
    demean,
    df_adjust) {
  prepped <- .fmols_prepare_single_unit(
    formula = formula,
    data = data,
    trend = trend,
    additional_deterministics = additional_deterministics,
    first_stage = first_stage,
    kernel = kernel,
    bandwidth = bandwidth,
    demean = demean
  )

  solved <- .fmols_finalize_single_unit(prepped = prepped, df_adjust = df_adjust)

  .fmols_build_single_fit(
    formula = formula,
    trend = trend,
    first_stage = first_stage,
    kernel = kernel,
    demean = demean,
    df_adjust = df_adjust,
    prepped = prepped,
    solved = solved
  )
}
