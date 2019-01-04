context("Tests for the getSettingsMetadata() function")
library(safetyGraphics)

test_that("function returns the correct values with various parameters",{
  
  expect_is(getSettingsMetadata(),"data.frame")

})