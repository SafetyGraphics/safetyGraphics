context("Tests for the renderWidget R module")
library(safetyGraphics)
library(shinytest)
library(testthat)
library(dplyr)

app <- ShinyDriver$new("./module_examples/renderStatic")
initial<-app$getAllValues()
print(initial)

test_that("All 3 charts are drawn and have correct axes",{
  expect_equal(substring(initial$output$`HelloWorld-staticChart`$src,1,14), "data:image/png")
  
  expect_equal(substring(initial$output$`BoxPlot-staticChart`$src,1,14), "data:image/png")
  expect_equal(initial$output$`BoxPlot-staticChart`$coordmap$panels[[1]]$mapping$x, "Measure")
  expect_equal(initial$output$`BoxPlot-staticChart`$coordmap$panels[[1]]$mapping$y, "Value")
  
  expect_equal(substring(initial$output$`BoxPlot2-staticChart`$src,1,14), "data:image/png")
  expect_equal(initial$output$`BoxPlot2-staticChart`$coordmap$panels[[1]]$mapping$x, "Measure")
  expect_equal(initial$output$`BoxPlot2-staticChart`$coordmap$panels[[1]]$mapping$y, "Value")
})

app$stop()

