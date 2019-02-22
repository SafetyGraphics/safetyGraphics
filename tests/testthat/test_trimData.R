context("Tests for the trimData() function")
library(safetyGraphics)

settings <-generateSettings(standard="AdAM")

baseline_settings <- settings
baseline_settings[['baseline']][['value_col']] <- 'ADY'
baseline_settings[['baseline']][['values']] <-  list("-7","15")

analysisFlag_settings <- settings
analysisFlag_settings[['analysisFlag']][['value_col']] <- 'TRTA'
analysisFlag_settings[['analysisFlag']][['values']] <- list("Placebo","Xanomeline High Dose")

filter_settings <- settings
filter_settings[['filters']]<-list("SEX", "AGEGR1")

both_settings <- baseline_settings
both_settings[['analysisFlag']][['value_col']] <- 'TRTA'
both_settings[['analysisFlag']][['values']] <- list("Placebo","Xanomeline High Dose")

test_that("columns are removed",{
  # simple test case works
  expect_length(trimData(adlbc, settings), 6)
  expect_length(trimData(adlbc, baseline_settings), 6)
  expect_length(trimData(adlbc, analysisFlag_settings), 7)
  expect_length(trimData(adlbc, both_settings), 7)
  expect_length(trimData(adlbc, filter_settings), 8)
 
})

test_that("rows are removed",{
  # simple test case works
  expect_equal(nrow(trimData(adlbc, settings)), 10288) # none removed
  expect_equal(nrow(trimData(adlbc, baseline_settings)), 714)
  expect_equal(nrow(trimData(adlbc, analysisFlag_settings)), 7148)
  expect_equal(nrow(trimData(adlbc, both_settings)), 7378)
})

