context("Tests for the trimSettings() function")
library(safetyGraphics)

testsettings<-generateSettings(standard="sdtm")

test_that("returns a list with settings from all charts",{
  expect_is(trimSettings(settings=testsettings),"list")
  expect_equal(length(trimSettings(settings=testsettings)),length(testsettings))
})

test_that("subsets vector appropriately",{
  expect_equal(length(trimSettings(settings=testsettings, charts=c("edish","safetyhistogram"))),24)
})

test_that("subsets single chart appropriately",{
  expect_equal(length(trimSettings(settings=testsettings, charts=c("safetyhistogram"))),10)
})
