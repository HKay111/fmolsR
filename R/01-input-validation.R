.fmols_as_numeric_matrix <- function(x, name, allow_null = FALSE) {
  if (allow_null && is.null(x)) {
    return(NULL)
  }

  if (is.data.frame(x)) {
    x <- as.matrix(x)
  } else if (is.vector(x) && !is.list(x)) {
    x <- matrix(x, ncol = 1)
  }

  if (!is.matrix(x)) {
    stop(name, " must be a numeric vector, matrix, or data.frame.", call. = FALSE)
  }

  storage.mode(x) <- "double"

  if (!all(is.finite(x))) {
    stop(name, " must contain only finite numeric values.", call. = FALSE)
  }

  x
}

.fmols_safe_solve <- function(x, name, tol = 1e-10) {
  # Check if matrix is invertible using eigenvalue decomposition
  eig <- eigen(x, symmetric = TRUE)
  min_eig <- min(eig$values)
  
  if (min_eig < tol) {
    # Matrix is singular or near-singular
    # Try using QR decomposition first (more stable)
    qr_obj <- qr(x)
    if (qr_obj$rank < ncol(x)) {
      # Try generalized inverse via QR
      tryCatch({
        out <- MASS::ginv(x)
        return(out)
      }, error = function(e) {
        stop(name, " is singular and cannot be inverted.", call. = FALSE)
      })
    }
  }
  
  out <- tryCatch(
    solve(x),
    error = function(e) {
      tryCatch(
        qr.solve(x),
        error = function(e2) {
          tryCatch({
            MASS::ginv(x)
          }, error = function(e3) {
            stop(name, " is singular or numerically unstable.", call. = FALSE)
          })
        }
      )
    }
  )

  out
}

.fmols_parse_formula_data <- function(formula, data) {
  mf <- stats::model.frame(formula, data = data, na.action = stats::na.omit)
  y <- stats::model.response(mf)
  x <- stats::model.matrix(stats::delete.response(stats::terms(mf)), data = mf)

  intercept_col <- colnames(x) %in% "(Intercept)"

  if (any(intercept_col)) {
    x <- x[, !intercept_col, drop = FALSE]
  }

  if (ncol(x) == 0) {
    stop("formula must contain at least one stochastic regressor.", call. = FALSE)
  }

  list(
    y = .fmols_as_numeric_matrix(y, "response"),
    x = .fmols_as_numeric_matrix(x, "regressors"),
    data = mf
  )
}

.fmols_resolve_additional_deterministics <- function(additional_deterministics, data, n_obs) {
  if (is.null(additional_deterministics)) {
    return(NULL)
  }

  if (is.character(additional_deterministics)) {
    if (!all(additional_deterministics %in% names(data))) {
      stop(
        "all additional_deterministics names must exist in data.",
        call. = FALSE
      )
    }

    out <- as.matrix(data[, additional_deterministics, drop = FALSE])
  } else {
    out <- .fmols_as_numeric_matrix(additional_deterministics, "additional_deterministics")
  }

  out <- .fmols_as_numeric_matrix(out, "additional_deterministics")

  if (nrow(out) != n_obs) {
    stop("additional_deterministics must have the same number of rows as the estimation sample.", call. = FALSE)
  }

  if (is.null(colnames(out))) {
    colnames(out) <- paste0("z2_", seq_len(ncol(out)))
  }

  out
}
