context("Tests for the mappingSelect R module")
library(safetyGraphics)
library(shinytest)
library(testthat)

app <- ShinyDriver$new("./module_examples/mappingColumn")

test_that("UI function stops with invalid (non-data.frame)",{

})

test_that("the correct number of inputs are created (1 per field/column)",{
  
})

test_that("default values for inputs are set correctly",{
  
})

test_that("output are data frames with the have expected values",{
 
})

test_that("changing column input updates clears the field input values",{

})

test_that("Changing column input updates the field input options",{
  
})


app$stop()

