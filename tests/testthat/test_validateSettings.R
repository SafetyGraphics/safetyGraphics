context("Tests for the validateSetting() function")
library(safetyGraphics)
library(purrr)
library(dplyr)

validSettings<-generateSettings(standard="adam")
passed<-validateSettings(data=adlbc,settings=validSettings)

invalidSettings<-validSettings
invalidSettings$id_col<-"not_my_id"
failed<-validateSettings(data=adlbc,settings=invalidSettings)

test_that("our basic example is valid (until we break it)",{
  expect_true(passed[["valid"]])
  expect_false(failed[["valid"]])
})

test_that("function returns a list with the expected structure",{
  expect_named(passed,c("checkList","valid","status"))
  expect_named(failed,c("checkList","valid","status"))
  expect_type(passed$checkList,"list")
  expect_type(passed$valid,"logical")
  expect_type(passed$status,"character")
  for(item in passed[["checkList"]]){
    expect_named(item,c("key","text_key","check","value","valid","message"))
  }
})

test_that("our examples have the correct number of failed checks",{
  invalidSettings2<-invalidSettings
  invalidSettings2$measure_col<-"not_a_measure_id"
  failed2<-validateSettings(data=adlbc,settings=invalidSettings2)

  expect_equal(passed$checkList%>%map_dbl(~!.x[["valid"]])%>%sum,0)
  expect_equal(failed$checkList%>%map_dbl(~!.x[["valid"]])%>%sum,1)
  expect_equal(failed2$checkList%>%map_dbl(~!.x[["valid"]])%>%sum,6) #2 columns and 4 fields

  expect_true(all(passed$checkList%>%keep(~.x[["text_key"]]=="id_col")%>%map_lgl(~.x[["valid"]])))
  expect_false(all(failed$checkList%>%keep(~.x[["text_key"]]=="id_col")%>%map_lgl(~.x[["valid"]])))
})

test_that("field checks fail when expected",{
  invalidFieldSettings <- validSettings
  invalidFieldSettings[["measure_values"]][["ALP"]]<-"not a field value :("
  fieldFailed<-validateSettings(data=adlbc,settings=invalidFieldSettings)
  expect_false(fieldFailed[["valid"]])

  failedChecks = fieldFailed[["checkList"]]%>%keep(~!.x[["valid"]])
  expect_length(failedChecks, 1)
  expect_equal(failedChecks[[1]][['check']],"'_values' field from setting found in data?")
  expect_equal(failedChecks[[1]][['text_key']],"measure_values--ALP")

  invalidFieldSettings$visit_values <- list(test="not a visit",test2="still not a visit")
  fieldFailed2<-validateSettings(data=adlbc,settings=invalidFieldSettings)
  failedChecks2 = fieldFailed2[["checkList"]]%>%keep(~!.x[["valid"]])
  expect_false(fieldFailed[["valid"]])
  expect_length(failedChecks2, 3)
})

test_that("required setting checks fail when expected",{
  invalidRequiredSettings <- validSettings
  invalidRequiredSettings[["id_col"]]<-NULL
  requiredFailed<-validateSettings(data=adlbc,settings=invalidRequiredSettings)
  expect_false(requiredFailed[["valid"]])

  failedChecks <- requiredFailed[["checkList"]]%>%keep(~!.x[["valid"]])
  expect_length(failedChecks, 1)
  expect_equal(failedChecks[[1]][['check']],"value for specified key found in settings?")
  expect_equal(failedChecks[[1]][['text_key']],"id_col")
})

test_that("numeric column checks fail when no numeric values are found",{
  invalidNumericSettings <- validSettings
  invalidNumericSettings[["value_col"]]<-"USUBJID"
  numericFailed<-validateSettings(data=adlbc,settings=invalidNumericSettings)
  expect_false(numericFailed[["valid"]])
  
  failedChecks <- numericFailed[["checkList"]]%>%keep(~!.x[["valid"]])
  expect_length(failedChecks, 1)
  expect_equal(failedChecks[[1]][['check']],"specified column is numeric?")
  expect_equal(failedChecks[[1]][['text_key']],"value_col")
})

test_that("numeric column checks still fails when more than half of the values are not numeric ",{
  validNumericSettings <- validSettings
  validNumericSettings[["value_col"]]<-"someNumbers"
  adlbc_edit<-adlbc
  adlbc_edit$someNumbers <- c("10","11",rep("sometext", dim(adlbc_edit)[1]-2))
  numericPassed<-validateSettings(data=adlbc_edit,settings=validNumericSettings)
  expect_false(numericPassed[["valid"]])
  partialNumericCheck <- numericPassed[["checkList"]]%>%keep(~.x$check=="specified column is numeric?" & .x$text_key=="value_col")
  expect_equal(partialNumericCheck[[1]][["message"]],"10286 of 10288 values were not numeric. Records with non-numeric values may not appear in the graphic.")
  
})

test_that("numeric column checks pass when more than half of the values are numeric ",{
  validNumericSettings <- validSettings
  validNumericSettings[["value_col"]]<-"someStrings"
  adlbc_edit<-adlbc
  adlbc_edit$someStrings <- c("b","a",rep("10", dim(adlbc_edit)[1]-2))
  numericPassed<-validateSettings(data=adlbc_edit,settings=validNumericSettings)
  expect_true(numericPassed[["valid"]])
  partialNumericCheck <- numericPassed[["checkList"]]%>%keep(~.x$check=="specified column is numeric?" & .x$text_key=="value_col")
  expect_equal(partialNumericCheck[[1]][["message"]],"2 of 10288 values were not numeric. Records with non-numeric values may not appear in the graphic.")
})

