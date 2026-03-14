testthat::test_that("benchmark scaffold files exist", {
  root <- benchmark_root()
  readme_path <- file.path(root, "README.md")
  registry_path <- file.path(root, "registry_template.csv")

  testthat::expect_true(nzchar(root))
  testthat::expect_true(file.exists(readme_path))
  testthat::expect_true(file.exists(registry_path))
})
