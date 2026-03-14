#' @export
print.fmols_fit <- function(x, digits = max(3L, getOption("digits") - 2L), ...) {
  cat("fmols_single fit\n")
  cat("  trend:      ", x$settings$trend, "\n", sep = "")
  cat("  first stage:", x$settings$first_stage, "\n", sep = "")
  cat("  kernel:     ", x$settings$kernel, "\n", sep = "")
  cat("  bandwidth:  ", format(x$settings$bandwidth$number, digits = digits), " (", x$settings$bandwidth$method, ")\n", sep = "")
  cat("\nCoefficients\n")
  print(round(x$coefficients, digits = digits))
  invisible(x)
}

#' @export
summary.fmols_fit <- function(object, ...) {
  coefficient_table <- cbind(
    estimate = object$coefficients,
    std.error = object$stderr,
    t.stat = object$t_stat,
    p.value = object$p_value
  )

  out <- list(
    call = object$call,
    coefficients = coefficient_table,
    long_run_variance = object$long_run$conditional_variance,
    settings = object$settings
  )

  class(out) <- "summary.fmols_fit"
  out
}

#' @export
print.summary.fmols_fit <- function(x, digits = max(3L, getOption("digits") - 2L), ...) {
  cat("Summary of fmols_single fit\n\n")
  stats::printCoefmat(x$coefficients, digits = digits, P.values = TRUE, has.Pvalue = TRUE)
  cat("\nConditional long-run variance:", format(x$long_run_variance, digits = digits), "\n")
  cat("Kernel:", x$settings$kernel, "| Bandwidth:", format(x$settings$bandwidth$number, digits = digits), "\n")
  invisible(x)
}

#' @export
print.fmols_panel_fit <- function(x, digits = max(3L, getOption("digits") - 2L), ...) {
  cat("fmols_panel fit\n")
  cat("  panel method:", x$settings$panel_method, "\n")
  cat("  kernel:      ", x$settings$kernel, "\n", sep = "")
  cat("  bandwidth:   ", format(x$settings$bandwidth$number, digits = digits), " (", x$settings$bandwidth$method, ")\n", sep = "")
  cat("\nCoefficients\n")
  print(round(x$coefficients, digits = digits))
  invisible(x)
}

#' @export
summary.fmols_panel_fit <- function(object, ...) {
  coefficient_table <- cbind(
    estimate = object$coefficients,
    std.error = object$stderr,
    t.stat = object$t_stat,
    p.value = object$p_value
  )

  out <- list(
    call = object$call,
    coefficients = coefficient_table,
    settings = object$settings,
    unit_coefficients = object$unit_coefficients
  )

  class(out) <- "summary.fmols_panel_fit"
  out
}

#' @export
print.summary.fmols_panel_fit <- function(x, digits = max(3L, getOption("digits") - 2L), ...) {
  cat("Summary of fmols_panel fit\n\n")
  stats::printCoefmat(x$coefficients, digits = digits, P.values = TRUE, has.Pvalue = TRUE)
  cat("\nPanel method:", x$settings$panel_method, "\n")
  cat("Kernel:", x$settings$kernel, "| Bandwidth:", format(x$settings$bandwidth$number, digits = digits), "\n")
  invisible(x)
}
