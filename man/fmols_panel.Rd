\name{fmols_panel}
\alias{fmols_panel}
\alias{print.fmols_panel_fit}
\alias{summary.fmols_panel_fit}
\alias{print.summary.fmols_panel_fit}
\title{Transparent implementation of panel FMOLS}
\usage{
fmols_panel(
  formula,
  data,
  id,
  time = NULL,
  panel_method = c("pooled", "weighted", "group_mean"),
  trend = c("const", "none", "trend", "quadratic"),
  additional_deterministics = NULL,
  first_stage = c("level", "difference"),
  kernel = c("bartlett", "parzen", "quadratic_spectral", "truncated"),
  bandwidth = 6,
  demean = FALSE,
  df_adjust = TRUE
)
}
\description{
A transparent implementation of pooled, weighted, and group-mean panel FMOLS
estimators built on top of the single-equation FMOLS machinery.
}
\arguments{
  \item{formula}{A regression formula such as \code{y ~ x1 + x2}.}
  \item{data}{A data frame containing the variables.}
  \item{id}{Name of the cross-section identifier column.}
  \item{time}{Optional name of the time identifier column.}
  \item{panel_method}{One of \code{"pooled"}, \code{"weighted"}, or \code{"group_mean"}.}
  \item{trend}{Deterministic specification.}
  \item{additional_deterministics}{Optional additional deterministic regressors.}
  \item{first_stage}{Either \code{"level"} or \code{"difference"}.}
  \item{kernel}{Long-run covariance kernel.}
  \item{bandwidth}{Positive numeric bandwidth or one of \code{"andrews"} or \code{"newey_west"}.}
  \item{demean}{Whether to demean before long-run covariance estimation.}
  \item{df_adjust}{Finite-sample adjustment flag.}
}
\value{
An object of class \code{fmols_panel_fit} containing panel coefficients,
standard errors, unit-level fits, and inspectable intermediate objects.
}
\details{
This implementation exposes unit-level fits, long-run covariance objects, and
transformed FMOLS quantities so you can validate each stage of the estimator.
The \code{"group_mean"} method is currently the safest panel release path,
while \code{"weighted"} should still be benchmarked against your target
software output before being treated as production-validated.
}
\examples{
set.seed(1)
n_id <- 4
n_t <- 80
id <- rep(seq_len(n_id), each = n_t)
time <- rep(seq_len(n_t), times = n_id)
x <- ave(rnorm(n_id * n_t), id, FUN = cumsum)
y <- 1 + 0.9 * x + rnorm(n_id * n_t)
dat <- data.frame(id = id, time = time, y = y, x = x)

fit <- fmols_panel(y ~ x, data = dat, id = "id", time = "time", panel_method = "group_mean")
print(fit)
summary(fit)
}
