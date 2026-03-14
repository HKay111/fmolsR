.fmols_parse_panel_formula_data <- function(formula, data, id, time = NULL) {
  if (!id %in% names(data)) {
    stop("id must name a column in data.", call. = FALSE)
  }

  keep <- unique(c(all.vars(formula), id, time))
  keep <- keep[!is.na(keep)]
  data_sub <- data[, keep, drop = FALSE]
  data_sub <- stats::na.omit(data_sub)

  if (!is.null(time)) {
    data_sub <- data_sub[order(data_sub[[id]], data_sub[[time]]), , drop = FALSE]
  } else {
    data_sub <- data_sub[order(data_sub[[id]]), , drop = FALSE]
  }

  split(data_sub, data_sub[[id]], drop = TRUE)
}

.fmols_panel_unit_fits <- function(
    formula,
    data,
    id,
    time = NULL,
    trend,
    additional_deterministics,
    first_stage,
    kernel,
    bandwidth,
    demean,
    df_adjust) {
  units <- .fmols_parse_panel_formula_data(formula = formula, data = data, id = id, time = time)

  fits <- lapply(units, function(unit_data) {
    fmols_single(
      formula = formula,
      data = unit_data,
      trend = trend,
      additional_deterministics = additional_deterministics,
      first_stage = first_stage,
      kernel = kernel,
      bandwidth = bandwidth,
      demean = demean,
      df_adjust = df_adjust
    )
  })

  list(
    units = units,
    fits = fits
  )
}

.fmols_panel_common_beta <- function(unit_fits) {
  do.call(rbind, lapply(unit_fits, function(fit) fit$beta))
}

.fmols_panel_common_design <- function(unit_fits) {
  Reduce(`+`, lapply(unit_fits, function(fit) {
    crossprod(fit$transformed$fm_design_matrix[, names(fit$beta), drop = FALSE])
  }))
}

.fmols_panel_common_rhs <- function(unit_fits) {
  Reduce(`+`, lapply(unit_fits, function(fit) {
    x_mat <- fit$transformed$fm_design_matrix[, names(fit$beta), drop = FALSE]
    as.matrix(crossprod(x_mat, fit$transformed$y_plus))
  }))
}

.fmols_panel_unit_terms <- function(unit_fit) {
  x_bar <- as.matrix(unit_fit$detrended$x)
  y_bar <- unit_fit$detrended$y

  list(
    x = x_bar[-1, , drop = FALSE],
    y_fm = y_bar[-1] - unit_fit$transformed$correction_term,
    y_bar = y_bar[-1],
    delta = as.matrix(unit_fit$transformed$delta_vu_plus, ncol = 1),
    n_eff = nrow(x_bar) - 1L
  )
}

.fmols_panel_preliminary_beta <- function(unit_fits) {
  xtx <- NULL
  rhs <- NULL

  for (fit in unit_fits) {
    terms <- .fmols_panel_unit_terms(fit)
    term_xtx <- crossprod(terms$x)
    term_rhs <- crossprod(terms$x, terms$y_bar)

    if (is.null(xtx)) {
      xtx <- term_xtx
      rhs <- term_rhs
    } else {
      xtx <- xtx + term_xtx
      rhs <- rhs + term_rhs
    }
  }

  beta_hat <- drop(.fmols_safe_solve(xtx, "panel preliminary beta") %*% rhs)
  names(beta_hat) <- names(unit_fits[[1]]$beta)
  beta_hat
}

.fmols_matrix_inv_sqrt <- function(mat) {
  eig <- eigen((mat + t(mat)) / 2, symmetric = TRUE)
  vals <- pmax(eig$values, 1e-10)

  eig$vectors %*%
    (diag(1 / sqrt(vals), nrow = length(vals)) %*% t(eig$vectors))
}

.fmols_matrix_inverse <- function(mat) {
  .fmols_safe_solve((mat + t(mat)) / 2, "panel matrix inverse")
}

.fmols_panel_named_variance <- function(beta_mat) {
  if (is.null(dim(beta_mat))) {
    beta_mat <- matrix(beta_mat, ncol = 1)
  }

  stats::var(beta_mat)
}
