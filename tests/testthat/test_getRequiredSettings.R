context("Tests for the getRequiredSettings() function")
library(safetyGraphics)
library(testthat)

defaultRequiredSettings <- list(
  list("id_col"),
  list("value_col"),
  list("measure_col"),
  list("measure_values","ALT"),
  list("measure_values","AST"),
  list("measure_values","TB"),
  list("measure_values","ALP"),
  list("normal_col_low"),
  list("normal_col_high"),
  list("studyday_col"),
  list("visit_col"),
  list("visitn_col")
)


customMetadata<- data.frame(
  chart_linechart = c(TRUE, FALSE),
  chart_barchart = c(FALSE,TRUE),
  text_key = c("line_col","value_col--label"),
  label=c("label1","label2"),
  description=c("desc1","desc2"),
  setting_type="character",
  setting_required=TRUE,
  column_mapping=TRUE,
  column_type="character",
  field_mapping=FALSE
)


test_that("default function call works as expected",{
  a<- safetyGraphics::getRequiredSettings()
  expect_is(a,"list")
  expect_equal(a,defaultRequiredSettings)
})

test_that("options work as expected",{
  custom<-safetyGraphics::getRequiredSettings(chart="linechart",metadata=customMetadata)
  expect_is(custom,"list")
  expect_equal(custom,list(list("line_col")))
})

test_that("nested keys are supported",{
  custom2<-safetyGraphics::getRequiredSettings(chart="barchart",metadata=customMetadata)
  expect_is(custom2,"list")
  expect_equal(custom2,list(list("value_col","label")))
})

test_that("invalid options return null",{
  expect_null(safetyGraphics::getRequiredSettings(chart="notachart"))
})
