context("Tests for the renderWidget R module")
library(safetyGraphics)
library(htmlwidgets)
library(shinytest)
library(testthat)
library(dplyr)

app <- ShinyDriver$new("./module_examples/chartsRenderWidget")
initial<-app$getAllValues()

test_that("All 3 charts are drawn and have correct axes",{
  expect_true(FALSE) #Add some tests!
  #expect_equal(substring(initial$output$`HelloWorld-staticChart`$src,1,14), "data:image/png")
  
  #expect_equal(substring(initial$output$`BoxPlot-staticChart`$src,1,14), "data:image/png")
  #expect_equal(initial$output$`BoxPlot-staticChart`$coordmap$panels[[1]]$mapping$x, "CustomMeasure")
  #expect_equal(initial$output$`BoxPlot-staticChart`$coordmap$panels[[1]]$mapping$y, "CustomValue")
  
  #expect_equal(substring(initial$output$`BoxPlot2-staticChart`$src,1,14), "data:image/png")
  #expect_equal(initial$output$`BoxPlot2-staticChart`$coordmap$panels[[1]]$mapping$x, "Measure")
  #expect_equal(initial$output$`BoxPlot2-staticChart`$coordmap$panels[[1]]$mapping$y, "Value")
})

app$stop()

