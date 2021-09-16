context("Tests for the mapping R module")
library(safetyGraphics)
library(shinytest)
library(testthat)
library(stringr)

skip_on_cran()
app <- ShinyDriver$new("./module_examples/mapping")
initial<-app$getAllValues()

test_that("mappingTab works as expected",{
  skip_on_cran()
  expect_true(TRUE) #TODO - Add some real tests :/
})


app$stop()

