context("Tests for the filterTab R module")
library(safetyGraphics)
library(shiny)
library(shinytest)
library(testthat)
library(stringr)

skip_on_cran()
app <- ShinyDriver$new("./module_examples/filterTab")
initial <- app$getAllValues()
defaults <- list(
  labs = safetyData::adam_adlbc,
  aes = safetyData::adam_adae,
  dm = safetyData::adam_adsl
)

domains <- c("labs", "aes", "dm")

test_that("the correct number of dataframes are returned by the outputs ", {
  skip_on_cran()
  expect_length(initial$export$ex1_data, 3)
  expect_named(initial$export$ex1_data, domains)
  expect_length(initial$export$ex2_data, 1)
  expect_named(initial$export$ex2_data, "labs")
  expect_length(initial$export$ex3_data, 3)
  expect_named(initial$export$ex3_data, domains)
  expect_length(initial$export$ex4_data, 3)
  expect_named(initial$export$ex4_data, domains)
  expect_length(initial$export$ex5_data, 3)
  expect_named(initial$export$ex5_data, domains)
})

test_that("all examples return raw data by default", {
  skip_on_cran()
  for (ex in initial$export) {
    for (dom in domains) {
      if (hasName(ex, dom)) {
        expect_equal(nrow(ex[[dom]]), nrow(defaults[[dom]]))
      }
    }
  }
})

test_that("changing a filter in ex1 updates the returned value", {
  skip_on_cran()
  firstFilter <- names(initial$input)[[1]]
  app$setValue(firstFilter, "701")
  app$waitForValue("ex1_data", iotype = "export", ignore = list(NULL, defaults))
  updated <- app$getAllValues()
  expect_lt(nrow(updated$export$ex1_data$labs), nrow(defaults$labs))
  expect_lt(nrow(updated$export$ex1_data$aes), nrow(defaults$aes))
  expect_lt(nrow(updated$export$ex1_data$dm), nrow(defaults$dm))
})

app$finalize()
