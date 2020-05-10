context("Tests for the mappingSelect R module")
library(safetyGraphics)
library(shinytest)
library(testthat)

app <- ShinyDriver$new("./module_examples/mappingSelect")

test_that("Inputs have expected values",{
  expect_equal(app$getValue("NoDefault-colSelect"),"") 
  expect_equal(app$getValue("WithDefault-colSelect"),"USUBJID") 
  expect_equal(app$getValue("NoDefaultField-colSelect"),"") 
  expect_equal(app$getValue("WithDefaultField-colSelect"), "CARDIAC DISORDERS") 
  expect_equal(app$getValue("WithInvalidDefault-colSelect"), "") 
  
})

test_that("Outputs have expected values",{
  empty<-'\"\"' #output value for empty string
  expect_match(app$getValue("ex1"),empty) 
  expect_match(app$getValue("ex2"),"USUBJID") 
  expect_match(app$getValue("ex3"),empty) 
  expect_match(app$getValue("ex4"), "CARDIAC DISORDERS") 
  expect_match(app$getValue("ex5"),empty)
})

#print(app$getAllValues())
app$stop()

