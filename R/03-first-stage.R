.fmols_first_stage_innovations <- function(x, z2 = NULL, method = c("level", "difference")) {
  method <- match.arg(method)
  x <- .fmols_as_numeric_matrix(x, "x")

  dx <- x[-1, , drop = FALSE] - x[-nrow(x), , drop = FALSE]

  if (is.null(z2) || ncol(z2) == 0) {
    return(list(
      innovations = dx,
      fitted = matrix(0, nrow = nrow(dx), ncol = ncol(dx)),
      coefficients = matrix(0, nrow = 0, ncol = ncol(dx)),
      design = matrix(numeric(0), nrow = nrow(dx), ncol = 0),
      method = method
    ))
  }

  z2 <- .fmols_as_numeric_matrix(z2, "additional_deterministics")

  if (method == "level") {
    fit <- stats::lm.fit(x = z2, y = x)
    residual_levels <- x - z2 %*% fit$coefficients
    innovations <- residual_levels[-1, , drop = FALSE] - residual_levels[-nrow(residual_levels), , drop = FALSE]
    design <- z2
  } else {
    design <- z2[-1, , drop = FALSE]
    fit <- stats::lm.fit(x = design, y = dx)
    innovations <- dx - design %*% fit$coefficients
  }

  coefficients <- fit$coefficients

  if (is.null(dim(coefficients))) {
    coefficients <- matrix(coefficients, ncol = 1)
  }

  fitted <- if (method == "level") {
    level_fit <- z2 %*% coefficients
    level_fit[-1, , drop = FALSE] - level_fit[-nrow(level_fit), , drop = FALSE]
  } else {
    design %*% coefficients
  }

  list(
    innovations = innovations,
    fitted = fitted,
    coefficients = coefficients,
    design = if (method == "level") z2 else design,
    method = method
  )
}
