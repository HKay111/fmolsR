\name{fmols_single}
\alias{fmols_single}
\alias{print.fmols_fit}
\alias{summary.fmols_fit}
\alias{print.summary.fmols_fit}
\title{Transparent implementation of single-equation FMOLS}
\usage{
fmols_single(
  formula,
  data,
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
A readable single-equation FMOLS estimator that exposes deterministic terms,
first-stage innovations, long-run covariance pieces, and transformed data so
you can study and validate the estimator step by step.
}
\arguments{
  \item{formula}{A regression formula such as \code{y ~ x1 + x2}.}
  \item{data}{A data frame containing the variables in \code{formula}.}
  \item{trend}{Deterministic specification for the cointegrating equation.}
  \item{additional_deterministics}{Optional deterministic regressors used only in the first-stage regressors equations.}
  \item{first_stage}{Either \code{"level"} or \code{"difference"}.}
  \item{kernel}{Long-run covariance kernel.}
  \item{bandwidth}{Positive numeric bandwidth or one of \code{"andrews"} or \code{"newey_west"}.}
  \item{demean}{Whether to demean the stacked residual/innovation data before long-run covariance estimation.}
  \item{df_adjust}{Whether to apply a simple finite-sample scaling to the conditional long-run variance used in the coefficient covariance.}
}
\value{
An object of class \code{fmols_fit}. The returned object contains coefficients,
standard errors, long-run covariance pieces, first-stage innovations, and the
transformed FMOLS data used in estimation.
}
\details{
This function is intentionally transparent and supports automatic bandwidth
selection using simple Andrews and Newey-West style rules in addition to fixed
bandwidth values. The transformed FMOLS sample drops one ordered observation to
align the dependent variable with the first-stage innovation process.
}
\examples{
set.seed(42)
n <- 200
v <- rnorm(n)
x <- cumsum(v)
y <- 1 + 0.8 * x + 0.5 * v + rnorm(n, sd = 0.5)
dat <- data.frame(y = y, x = x)

fit <- fmols_single(y ~ x, data = dat, trend = "const", bandwidth = "andrews")
print(fit)
summary(fit)
}
