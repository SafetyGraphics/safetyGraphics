context("Core App Functionality")
# This file is for testing the applications in the inst/ directory.

library(shinytest)

test_that("chart is drawn and settings are valid by default", {
  # Don't run these tests on the CRAN build servers
  skip_on_cran()
  
  appdir <- system.file(package = "shinytestPackageExample", "sampleapp")
  expect_pass(testApp("inst/eDISH_app", "defaultPath.R"))
})

test_that("chart is not drawn and settings are invalid when non standard data uploaded", {
  # Don't run these tests on the CRAN build servers
  skip_on_cran()
  
  appdir <- system.file(package = "shinytestPackageExample", "sampleapp")
  expect_pass(testApp("inst/eDISH_app", "invalidPath.R"))
})