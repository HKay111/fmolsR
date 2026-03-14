if (!"package:fmolsR" %in% search() && requireNamespace("fmolsR", quietly = TRUE)) {
  library(fmolsR)
}

benchmark_root <- function() {
  installed_path <- system.file("extdata", "eviews_benchmarks", package = "fmolsR")

  if (nzchar(installed_path) && dir.exists(installed_path)) {
    return(installed_path)
  }

  source_candidates <- c(
    file.path("inst", "extdata", "eviews_benchmarks"),
    file.path("..", "..", "inst", "extdata", "eviews_benchmarks")
  )

  for (source_path in source_candidates) {
    if (dir.exists(source_path)) {
      return(source_path)
    }
  }

  ""
}

benchmark_registry <- function() {
  path <- file.path(benchmark_root(), "registry_template.csv")
  utils::read.csv(path, stringsAsFactors = FALSE)
}

benchmark_path <- function(benchmark_id) {
  file.path(benchmark_root(), benchmark_id)
}

skip_if_benchmark_missing <- function(benchmark_id) {
  path <- benchmark_path(benchmark_id)

  if (!dir.exists(path)) {
    testthat::skip(
      paste0(
        "Benchmark '",
        benchmark_id,
        "' is not present yet in inst/extdata/eviews_benchmarks/."
      )
    )
  }
}
