# Run this script manually from the package root when you want to create a new
# benchmark folder for an EViews run.

benchmark_id <- "replace_me"

root <- file.path("inst", "extdata", "eviews_benchmarks", benchmark_id)
dir.create(root, recursive = TRUE, showWarnings = FALSE)

files_to_create <- c(
  "data.csv",
  "settings.txt",
  "coefficients.csv",
  "vcov.csv",
  "lrcov.csv",
  "notes.md"
)

created_paths <- file.path(root, files_to_create)

for (path in created_paths) {
  if (!file.exists(path)) {
    file.create(path)
  }
}

created_paths
