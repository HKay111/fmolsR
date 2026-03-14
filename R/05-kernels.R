.fmols_kernel_weight <- function(lag, bandwidth, kernel = c("bartlett", "parzen", "quadratic_spectral", "truncated")) {
  kernel <- match.arg(kernel)

  if (!is.finite(bandwidth) || bandwidth <= 0) {
    stop("bandwidth must be a positive numeric value.", call. = FALSE)
  }

  x <- abs(lag / bandwidth)

  if (kernel == "bartlett") {
    return(ifelse(x < 1, 1 - x, 0))
  }

  if (kernel == "truncated") {
    return(ifelse(x <= 1, 1, 0))
  }

  if (kernel == "parzen") {
    if (x <= 0.5) {
      return(1 - 6 * x^2 + 6 * x^3)
    }

    return(ifelse(x <= 1, 2 * (1 - x)^3, 0))
  }

  if (x == 0) {
    return(1)
  }

  q <- 6 * pi * x / 5
  (25 / (12 * pi^2 * x^2)) * ((sin(q) / q) - cos(q))
}

.fmols_relevant_lags <- function(n_obs, bandwidth, kernel) {
  if (n_obs < 2) {
    return(integer(0))
  }

  if (kernel == "quadratic_spectral") {
    return(seq_len(n_obs - 1))
  }

  max_lag <- min(n_obs - 1, ceiling(bandwidth))

  if (max_lag < 1) {
    return(integer(0))
  }

  seq_len(max_lag)
}
