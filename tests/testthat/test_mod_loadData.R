context("Tests for the loadData R module")
library(safetyGraphics)
library(shiny)
library(shinytest)
library(testthat)
library(stringr)

app <- ShinyDriver$new("./module_examples/loadData")
initial<-app$getAllValues()


test_that("the correct number of dataframes are returned by the outputs ",{
    expect_length(initial$export$ex1_data,3)
    expect_named(initial$export$ex1_data,domains)
    expect_length(initial$export$ex2_data,1)
    expect_named(initial$export$ex2_data,"labs")
    expect_length(initial$export$ex3_data,3)
    expect_named(initial$export$ex3_data,domains)
    expect_length(initial$export$ex4_data,3)
    expect_named(initial$export$ex4_data,domains)
    expect_length(initial$export$ex5_data,3)
    expect_named(initial$export$ex5_data,domains)
})

app$finalize()
