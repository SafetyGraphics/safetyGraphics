context("Tests for the getSettingsMetadata() function")
library(safetyGraphics)
library(dplyr)
library(magrittr)

#Preload the raw, custom metadata
rawMetadata <- read.csv("../../data-raw/settingsMetadata.csv")

customMetadata<- data.frame(
  chart_linechart = c(TRUE, FALSE), 
  chart_barchart = c(FALSE,TRUE), 
  text_key = c("line_col","bar_col"),
  label=c("label1","label2"),
  description=c("desc1","desc2"),
  setting_type="character",
  column_mapping=TRUE,
  column_type="character",
  column_required=TRUE,
  field_mapping=FALSE
)

mergedMetadata = suppressWarnings(bind_rows(
  rawMetadata%>%mutate(chart_linechart= FALSE)%>%mutate(chart_barchart= FALSE), 
  customMetadata%>%mutate(chart_edish= FALSE)
))

test_that("Default function copies the whole metadata dataframe",{
  default<-safetyGraphics:::getSettingsMetadata()
  expect_is(default,"data.frame")
  expect_equal(dim(default), dim(rawMetadata))
})

test_that("Pulling from a custom metadata file works as expected",{
  custom<-safetyGraphics:::getSettingsMetadata(metadata=customMetadata)
  expect_is(custom,"data.frame")
  expect_equal(dim(custom), dim(customMetadata))
  
  merged<-safetyGraphics:::getSettingsMetadata(metadata=customMetadata)
  expect_is(custom,"data.frame")
  expect_equal(dim(custom), dim(customMetadata))
})

test_that("charts parameter works as expected",{
  expect_error(safetyGraphics:::getSettingsMetadata(charts=123))
  
  #return a dataframe for valid input
  expect_is(safetyGraphics:::getSettingsMetadata(charts=c("edish")),"data.frame")
  
  #return null if no valid charts are passed
  expect_true(is.null(safetyGraphics:::getSettingsMetadata(charts=c(""))))
  expect_true(is.null(safetyGraphics:::getSettingsMetadata(charts="abc")))
  expect_true(is.null(safetyGraphics:::getSettingsMetadata(charts=c("notachart"))))
  expect_true(is.null(safetyGraphics:::getSettingsMetadata(charts=c("notachart","stillnotachart"))))
  
  #return a dataframe if at least one valid chart type is passed
  expect_is(safetyGraphics:::getSettingsMetadata(charts=c("notachart","edish")),"data.frame")
  
  #get the right number of records with various combinations
  lineonly <- safetyGraphics:::getSettingsMetadata(charts=c("linechart"),metadata=mergedMetadata)
  expect_equal(dim(lineonly)[1],1)
  
  linesandbars <- safetyGraphics:::getSettingsMetadata(charts=c("linechart","barchart"),metadata=mergedMetadata)
  expect_equal(dim(linesandbars)[1],2)
})