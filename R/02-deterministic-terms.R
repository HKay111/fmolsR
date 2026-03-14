.fmols_build_deterministics <- function(n_obs, trend = c("const", "none", "trend", "quadratic")) {
  trend <- match.arg(trend)

  if (trend == "none") {
    return(matrix(numeric(0), nrow = n_obs, ncol = 0))
  }

  time_index <- seq_len(n_obs)

  if (trend == "const") {
    out <- cbind(const = rep(1, n_obs))
  } else if (trend == "trend") {
    out <- cbind(const = rep(1, n_obs), trend = time_index)
  } else {
    out <- cbind(
      const = rep(1, n_obs),
      trend = time_index,
      quadratic = time_index^2
    )
  }

  unclass(out)
}

.fmols_partial_out <- function(y, x) {
  x <- .fmols_as_numeric_matrix(x, "deterministic design")

  if (ncol(x) == 0) {
    return(list(residuals = y, fitted = matrix(0, nrow = nrow(y), ncol = ncol(y)), coefficients = matrix(0, nrow = 0, ncol = ncol(y))))
  }

  fit <- stats::lm.fit(x = x, y = y)
  coefficients <- fit$coefficients

  if (is.null(dim(coefficients))) {
    coefficients <- matrix(coefficients, ncol = 1)
  }

  fitted <- x %*% coefficients

  list(
    residuals = y - fitted,
    fitted = fitted,
    coefficients = coefficients
  )
}
