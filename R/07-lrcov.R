.fmols_partition_long_run <- function(mat, y_dim, x_dim) {
  list(
    all = mat,
    uu = mat[seq_len(y_dim), seq_len(y_dim), drop = FALSE],
    uv = mat[seq_len(y_dim), y_dim + seq_len(x_dim), drop = FALSE],
    vu = mat[y_dim + seq_len(x_dim), seq_len(y_dim), drop = FALSE],
    vv = mat[y_dim + seq_len(x_dim), y_dim + seq_len(x_dim), drop = FALSE]
  )
}

.fmols_long_run_covariance <- function(z, kernel = c("bartlett", "parzen", "quadratic_spectral", "truncated"), bandwidth, demean = FALSE) {
  kernel <- match.arg(kernel)
  z <- .fmols_as_numeric_matrix(z, "z")

  bw_info <- .fmols_resolve_bandwidth(z, bandwidth = bandwidth)
  bw <- bw_info$number

  gamma0 <- .fmols_sample_autocovariance(z, lag = 0, demean = demean)
  lags <- .fmols_relevant_lags(nrow(z), bw, kernel)

  if (length(lags) == 0) {
    return(list(
      Omega = gamma0,
      Delta = gamma0,
      gamma0 = gamma0,
      lags = integer(0),
      weights = numeric(0),
      bandwidth = bw_info,
      kernel = kernel
    ))
  }

  gammas <- .fmols_autocovariances(z, lags = lags, demean = demean)
  weights <- vapply(lags, function(lag) .fmols_kernel_weight(lag, bw, kernel), numeric(1))

  omega <- gamma0
  delta <- gamma0

  for (i in seq_along(lags)) {
    omega <- omega + weights[i] * (gammas[[i]] + t(gammas[[i]]))
    delta <- delta + weights[i] * gammas[[i]]
  }

  list(
    Omega = omega,
    Delta = delta,
    gamma0 = gamma0,
    gammas = gammas,
    lags = lags,
    weights = weights,
    bandwidth = bw_info,
    kernel = kernel
  )
}

.fmols_conditional_long_run_variance <- function(omega_parts) {
  omega_vv_inv <- .fmols_safe_solve(omega_parts$vv, "Omega_vv")
  omega_vv_inv_vu <- omega_vv_inv %*% omega_parts$vu
  omega_u_v <- omega_parts$uu - (omega_parts$uv %*% omega_vv_inv_vu)

  list(
    omega_vv_inv = omega_vv_inv,
    omega_vv_inv_vu = omega_vv_inv_vu,
    omega_u_v = omega_u_v
  )
}
