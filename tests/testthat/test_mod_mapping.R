context("Tests for the mapping R module")
library(safetyGraphics)
library(shinytest)
library(testthat)
library(stringr)

app <- ShinyDriver$new("./module_examples/mapping")
initial<-app$getAllValues()

test_that("mappingTab works as expected",{
  expect_true(TRUE) #todo - add some tests!
})


app$stop()

