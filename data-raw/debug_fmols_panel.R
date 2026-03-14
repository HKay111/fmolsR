library(fmolsR)

set.seed(123)
n_id <- 5
n_t <- 80

build_unit <- function(n) {
  v1 <- rnorm(n, sd = 0.7)
  v2 <- rnorm(n, sd = 0.5)
  x1 <- cumsum(v1)
  x2 <- cumsum(v2)
  y <- 0.8 * x1 - 0.4 * x2 + 0.3 * v1 + rnorm(n, sd = 0.4)
  data.frame(y = y, x1 = x1, x2 = x2)
}

dat <- do.call(rbind, lapply(seq_len(n_id), function(i) {
  out <- build_unit(n_t)
  out$id <- sprintf("id_%02d", i)
  out$time <- seq_len(n_t)
  out
}))

cat("=== WEIGHTED ===\n")
fit <- try(fmols_panel(
  y ~ x1 + x2,
  data = dat,
  id = "id",
  time = "time",
  panel_method = "weighted",
  bandwidth = "andrews",
  trend = "const"
))

if (inherits(fit, "try-error")) {
  cat("ERROR:", fit[1], "\n")
} else {
  print(coef(fit))
}

cat("\n=== GROUP MEAN ===\n")
fit2 <- fmols_panel(
  y ~ x1 + x2,
  data = dat,
  id = "id",
  time = "time",
  panel_method = "group_mean",
  bandwidth = "andrews",
  trend = "const"
)
print(coef(fit2))
