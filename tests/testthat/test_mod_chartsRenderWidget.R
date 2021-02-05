context("Tests for the renderWidget R module")
library(safetyGraphics)
library(htmlwidgets)
library(shinytest)
library(testthat)
library(dplyr)

#setwd('tests/testthat')
app <- ShinyDriver$new("./module_examples/chartsRenderWidget")

## Not working in ShinyDriver for some reason :( - maybe reimplement later
# test_that("the first widget renderers when clicked",{
#   app$setInputs(sidebar_tabs = "ex1-tab")
#   Sys.sleep(1)
#   outputs1<-app$getAllValues()[["output"]]
#   expect_length(outputs1, 2)
#   expect_named(outputs1, "ex2-widgetChart","ex1-widgetChart")
#   chart1<-jsonlite::fromJSON(outputs1[["ex1-widgetChart"]])
#   expect_named(chart1,c("x","evals","jsHooks","deps" )) # names for htmlwidget shiny output
# })

test_that("2nd widget renderers by default",{
  Sys.sleep(5)
  outputs2<-app$getAllValues()[["output"]]
  expect_named(outputs2, c("ex2-widgetChart"))
  chart2<-jsonlite::fromJSON(outputs2[["ex2-widgetChart"]])
  expect_named(chart2,c("x","evals","jsHooks","deps" )) # names for htmlwidget shiny output
})

test_that("3rd widget renderers when sidebar is clicked",{
  app$setInputs(sidebar_tabs = "ex3-tab")
  Sys.sleep(5)
  outputs3<-app$getAllValues()[["output"]]
  expect_named(outputs3, c("ex2-widgetChart","ex3-widgetChart"))
  chart3<-jsonlite::fromJSON(outputs3[["ex3-widgetChart"]])
  expect_named(chart3,c("x","evals","jsHooks","deps" )) # names for htmlwidget shiny output
})
app$stop()

