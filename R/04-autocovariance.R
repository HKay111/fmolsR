.fmols_center_matrix <- function(z, demean = FALSE) {
  if (!demean) {
    return(z)
  }

  sweep(z, 2, colMeans(z), FUN = "-")
}

.fmols_sample_autocovariance <- function(z, lag = 0, demean = FALSE) {
  z <- .fmols_as_numeric_matrix(z, "z")

  if (lag < 0 || lag >= nrow(z)) {
    stop("lag must be between 0 and nrow(z) - 1.", call. = FALSE)
  }

  z <- .fmols_center_matrix(z, demean = demean)
  n_obs <- nrow(z)

  if (lag == 0) {
    return(crossprod(z) / n_obs)
  }

  crossprod(z[(lag + 1):n_obs, , drop = FALSE], z[seq_len(n_obs - lag), , drop = FALSE]) / n_obs
}

.fmols_autocovariances <- function(z, lags, demean = FALSE) {
  lapply(lags, function(lag) {
    .fmols_sample_autocovariance(z, lag = lag, demean = demean)
  })
}
