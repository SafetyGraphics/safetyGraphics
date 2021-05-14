context("Tests for the renderStatic R module")
library(safetyGraphics)
library(shiny)
library(shinytest)
library(testthat)
library(dplyr)


app <- ShinyDriver$new("./module_examples/chartsRenderStatic")
initial<-app$getAllValues()

test_that("All 3 charts are drawn and have correct axes",{
  expect_equal(substring(initial$output$`HelloWorld-staticPlot`$src,1,14), "data:image/png")
  
  expect_equal(substring(initial$output$`BoxPlot-staticPlot`$src,1,14), "data:image/png")
  expect_equal(initial$output$`BoxPlot-staticPlot`$coordmap$panels[[1]]$mapping$x, "CustomMeasure")
  expect_equal(initial$output$`BoxPlot-staticPlot`$coordmap$panels[[1]]$mapping$y, "CustomValue")
  
  expect_equal(substring(initial$output$`BoxPlot2-staticPlot`$src,1,14), "data:image/png")
  expect_equal(initial$output$`BoxPlot2-staticPlot`$coordmap$panels[[1]]$mapping$x, "Measure")
  expect_equal(initial$output$`BoxPlot2-staticPlot`$coordmap$panels[[1]]$mapping$y, "Value")
})

app$stop()

