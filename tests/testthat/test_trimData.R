context("Tests for the trimData() function")
library(safetyGraphics)

settings <-generateSettings(standard="AdAM")

baseline_settings <- settings
settings[['baseline']][['value_col']] <- 'TRTA'
settings[['baseline']][['values']] <- list("Placebo","Xanomeline High Dose")

analysisFlag_settings <- settings
settings[['analysisFlag']][['value_col']] <- 'ADY'
settings[['analysisFlag']][['values']] <- list("-7","15")

test_that("columns are removed",{
  # simple test case works
  expect_length(trimData(adlbc, settings), 6)
  expect_length(trimData(adlbc, baseline_settings), 7)
  expect_length(trimData(adlbc, analysisFlag_settings), 7)
})

test_that("rows are removed",{
  # simple test case works
  expect_equal(nrows(trimData(adlbc, settings)), 10288) # none removed
  expect_equal(nrows(trimData(adlbc, baseline_settings)), 7148)
  expect_equal(nrows(trimData(adlbc, analysisFlag_settings)), 7148)
})

