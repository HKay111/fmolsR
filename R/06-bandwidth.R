.fmols_vectorize_for_bandwidth <- function(z) {
  z <- .fmols_as_numeric_matrix(z, "z")

  if (ncol(z) == 1) {
    return(drop(z))
  }

  drop(rowMeans(z^2))
}

.fmols_bw_scale_constant <- function(kernel) {
  switch(
    kernel,
    bartlett = 1.1447,
    parzen = 2.6614,
    quadratic_spectral = 1.3221,
    truncated = 0.6611,
    1.1447
  )
}

.fmols_safe_ar1 <- function(x) {
  x <- as.numeric(x)

  if (length(x) < 3) {
    return(0)
  }

  x_t <- x[-1]
  x_tm1 <- x[-length(x)]
  denom <- sum(x_tm1^2)

  if (!is.finite(denom) || denom <= .Machine$double.eps) {
    return(0)
  }

  rho <- sum(x_t * x_tm1) / denom
  rho <- max(min(rho, 0.97), -0.97)
  rho
}

.fmols_bandwidth_andrews <- function(z, kernel) {
  x <- .fmols_vectorize_for_bandwidth(z)
  x <- x - mean(x)
  n_obs <- length(x)

  if (n_obs < 3) {
    return(1)
  }

  rho <- .fmols_safe_ar1(x)
  alpha <- if (abs(1 - rho) < 1e-6) 1 else abs(rho / (1 - rho))
  exponent <- if (kernel == "quadratic_spectral") 0.2 else 0.2
  rate <- n_obs^exponent
  bw <- .fmols_bw_scale_constant(kernel) * (alpha^0.4) * rate

  max(1, as.numeric(bw))
}

.fmols_bandwidth_neweywest <- function(z, kernel) {
  x <- .fmols_vectorize_for_bandwidth(z)
  n_obs <- length(x)

  if (n_obs < 3) {
    return(1)
  }

  exponent <- if (kernel == "quadratic_spectral") 2 / 25 else 2 / 9
  constant <- if (kernel == "quadratic_spectral") 1.3221 else 4
  bw <- constant * (n_obs / 100)^exponent

  max(1, as.numeric(bw))
}

.fmols_resolve_bandwidth <- function(z, bandwidth, kernel = c("bartlett", "parzen", "quadratic_spectral", "truncated")) {
  kernel <- match.arg(kernel)

  if (is.numeric(bandwidth) && length(bandwidth) == 1L && is.finite(bandwidth) && bandwidth > 0) {
    return(list(number = as.numeric(bandwidth), method = "fixed"))
  }

  if (is.character(bandwidth) && length(bandwidth) == 1L) {
    bandwidth <- match.arg(bandwidth, c("andrews", "newey_west"))

    bw <- if (bandwidth == "andrews") {
      .fmols_bandwidth_andrews(z = z, kernel = kernel)
    } else {
      .fmols_bandwidth_neweywest(z = z, kernel = kernel)
    }

    return(list(number = bw, method = bandwidth))
  }

  stop(
    "bandwidth must be a positive numeric value or one of 'andrews' or 'newey_west'.",
    call. = FALSE
  )
}
