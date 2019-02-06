context("Tests for the getSettingsMetadata() function")
library(safetyGraphics)
library(dplyr)
library(magrittr)

#Preload the raw, custom metadata
rawMetadata <- safetyGraphics::settingsMetadata

customMetadata<- data.frame(
  chart_linechart = c(TRUE, FALSE), 
  chart_barchart = c(FALSE,TRUE), 
  text_key = c("line_col","value_col"),
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
  
  #return a dataframe for valid input
  expect_is(safetyGraphics:::getSettingsMetadata(charts=c("edish")),"data.frame")
  expect_is(safetyGraphics:::getSettingsMetadata(charts="edish"),"data.frame")
  
  #error if charts isn't a character
  expect_error(safetyGraphics:::getSettingsMetadata(charts=123))
  expect_error(safetyGraphics:::getSettingsMetadata(charts=list("edish")))
  
  #return null if no valid charts are passed
  expect_true(is.null(safetyGraphics:::getSettingsMetadata(charts=c(""))))
  expect_true(is.null(safetyGraphics:::getSettingsMetadata(charts="abc")))
  expect_true(is.null(safetyGraphics:::getSettingsMetadata(charts=c("notachart"))))
  expect_true(is.null(safetyGraphics:::getSettingsMetadata(charts=c("notachart","stillnotachart"))))
  
  #no partial matches supported
  expect_true(is.null(safetyGraphics:::getSettingsMetadata(charts=c("edi")))) 
  
  #return a dataframe if at least one valid chart type is passed
  expect_is(safetyGraphics:::getSettingsMetadata(charts=c("notachart","edish")),"data.frame")
  
  #capitalization doesn't matter
  expect_is(safetyGraphics:::getSettingsMetadata(charts=c("EdIsH")),"data.frame")
  
  #get the right number of records with various combinations
  lineonly <- safetyGraphics:::getSettingsMetadata(charts=c("linechart"),metadata=mergedMetadata)
  expect_equal(dim(lineonly)[1],1)
  
  linesandbars <- safetyGraphics:::getSettingsMetadata(charts=c("linechart","barchart"),metadata=mergedMetadata)
  expect_equal(dim(linesandbars)[1],2)
  
  allcharts <- safetyGraphics:::getSettingsMetadata(charts=c("linechart","barchart","edish"),metadata=mergedMetadata)
  expect_equal(dim(allcharts)[1],dim(mergedMetadata)[1])
})

test_that("text_keys parameter works as expected",{
  #return a dataframe for valid input
  expect_is(safetyGraphics:::getSettingsMetadata(text_keys=c("id_col")),"data.frame")
  
  #error if text_keys isn't a character
  expect_error(safetyGraphics:::getSettingsMetadata(text_keys=123))
  expect_error(safetyGraphics:::getSettingsMetadata(text_keys=list("id_col")))
  
  #return null if no valid text_keys are passed
  expect_true(is.null(safetyGraphics:::getSettingsMetadata(text_keys=c(""))))
  expect_true(is.null(safetyGraphics:::getSettingsMetadata(text_keys="abc")))
  expect_true(is.null(safetyGraphics:::getSettingsMetadata(text_keys=c("notakey"))))
  expect_true(is.null(safetyGraphics:::getSettingsMetadata(text_keys=c("notakey","stillnotakey"))))
  
  #no partial matches supported
  expect_true(is.null(safetyGraphics:::getSettingsMetadata(text_keys=c("id_")))) 
  
  #return a dataframe if at least one valid chart type is passed
  expect_is(safetyGraphics:::getSettingsMetadata(text_keys=c("notachart","id_col")),"data.frame")
  
  #capitalization doesn't matter
  expect_is(safetyGraphics:::getSettingsMetadata(text_keys=c("Id_COl")),"data.frame")
  
  #get the right number of records with various combinations
  expect_equal(dim(safetyGraphics:::getSettingsMetadata(text_keys=c("id_col"),metadata=mergedMetadata))[1],1)
  expect_equal(dim(safetyGraphics:::getSettingsMetadata(text_keys=c("value_col"),metadata=mergedMetadata))[1],2)
  expect_equal(dim(safetyGraphics:::getSettingsMetadata(text_keys=c("id_col","measure_col"),metadata=mergedMetadata))[1],2)
  expect_equal(dim(safetyGraphics:::getSettingsMetadata(text_keys=c("id_col","measure_col","value_col"),metadata=mergedMetadata))[1],4)
})

test_that("cols parameter works as expected",{
  
  #returns a data frame if multiple columns are requested
  expect_is(safetyGraphics:::getSettingsMetadata(cols=c("label","text_key")),"data.frame")
  
  #returns a vector if a single column is specified
  one_col <- safetyGraphics:::getSettingsMetadata(cols=c("label"))
  expect_is(one_col,"character")
  expect_equal(length(one_col),dim(rawMetadata)[1])
  
  #returns an atomic value if a single value is specified
  one_val <- safetyGraphics:::getSettingsMetadata(cols=c("label"), text_keys="line_col", metadata= mergedMetadata)
  expect_is(one_val,"character")
  expect_equal(length(one_val),1)
  expect_equal(one_val,"label1")
  expect_true(safetyGraphics:::getSettingsMetadata(cols=c("column_mapping"), text_keys="line_col", metadata= mergedMetadata))
  expect_false(safetyGraphics:::getSettingsMetadata(cols=c("field_mapping"), text_keys="line_col", metadata= mergedMetadata))
  
  #returns null if no valid columns are requested
  expect_true(is.null(safetyGraphics:::getSettingsMetadata(cols=c("asda123"))))
})

test_that("filter_expr parameters works as expected",{
  expect_equal(
    safetyGraphics:::getSettingsMetadata(filter_expr=text_key=="id_col"), 
    safetyGraphics:::getSettingsMetadata(text_key="id_col")
  )
  expect_equal(safetyGraphics:::getSettingsMetadata(filter_expr=text_key=="id_col",cols="description"),"Unique subject identifier variable name.")
  expect_length(safetyGraphics:::getSettingsMetadata(filter_expr=column_type=="numeric",cols="text_key",chart="edish"),5)
  expect_length(safetyGraphics:::getSettingsMetadata(filter_expr=setting_required,cols="text_key",chart="edish"),10)
  })