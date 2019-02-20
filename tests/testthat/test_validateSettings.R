context("Tests for the validateSetting() function")
library(safetyGraphics)
library(purrr)
library(dplyr)
library(tibble)

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
  expect_named(passed,c("checks","valid","status"))
  expect_named(failed,c("checks","valid","status"))
  expect_true(is_tibble(passed$checks))
  expect_type(passed$valid,"logical")
  expect_type(passed$status,"character")
  expect_equal(colnames(passed$checks),c("key","text_key","type","description","value","valid","message"))
})

test_that("our examples have the correct number of failed checks",{
  invalidSettings2<-invalidSettings
  invalidSettings2$measure_col<-"not_a_measure_id"
  failed2<-validateSettings(data=adlbc,settings=invalidSettings2)

  expect_equal(passed$checks%>%filter(!valid)%>%nrow,0)
  expect_equal(failed$checks%>%filter(!valid)%>%nrow,1)
  expect_equal(failed2$checks%>%filter(!valid)%>%nrow,6) #2 columns and 4 fields

  expect_true(passed$checks%>%filter(text_key=="id_col")%>%select(valid)%>%unlist%>%all)
  expect_false(failed$checks%>%filter(text_key=="id_col")%>%select(valid)%>%unlist%>%all)
})

test_that("field checks fail when expected",{
  invalidFieldSettings <- validSettings
  invalidFieldSettings[["measure_values"]][["ALP"]]<-"not a field value :("
  fieldFailed<-validateSettings(data=adlbc,settings=invalidFieldSettings)
  expect_false(fieldFailed[["valid"]])

  failedChecks <- fieldFailed$checks%>%filter(!valid)
  expect_equal(nrow(failedChecks), 1)
  expect_equal(failedChecks[1,"description"]%>%as.character,"field value from setting found in data")
  expect_equal(failedChecks[1,'text_key']%>%as.character,"measure_values--ALP")

  # TODO: support vectorized fields/columns #170
  # a vector of values are each checked independently. 
  # invalidFieldSettings$baseline[["values"]] <- c("not a filter",test2="still not a filter")
  # fieldFailed2<-validateSettings(data=adlbc,settings=invalidFieldSettings)
  # failedChecks2 = fieldFailed2[["checkList"]]%>%keep(~!.x[["valid"]])
  # expect_false(fieldFailed[["valid"]])
  # expect_length(failedChecks2, 3)
})

test_that("required setting checks fail when expected",{
  invalidRequiredSettings <- validSettings
  invalidRequiredSettings[["id_col"]]<-NULL
  requiredFailed<-validateSettings(data=adlbc,settings=invalidRequiredSettings)
  expect_false(requiredFailed[["valid"]])

  failedChecks <- requiredFailed$checks%>%filter(!valid)
  expect_equal(nrow(failedChecks), 1)
  expect_equal(failedChecks[1,'description']%>%as.character,"value for specified key found in settings?")
  expect_equal(failedChecks[1,'text_key']%>%as.character,"id_col")
})

test_that("numeric column checks fail when no numeric values are found",{
  invalidNumericSettings <- validSettings
  invalidNumericSettings[["value_col"]]<-"USUBJID"
  numericFailed<-validateSettings(data=adlbc,settings=invalidNumericSettings)
  expect_false(numericFailed[["valid"]])
  
  failedChecks <- numericFailed$checks%>%filter(!valid)
  expect_equal(nrow(failedChecks), 1)
  expect_equal(failedChecks[1,'description']%>%as.character,"specified column is numeric?")
  expect_equal(failedChecks[1,'text_key']%>%as.character,"value_col")
})

test_that("numeric column checks still fails when more than half of the values are not numeric ",{
  validNumericSettings <- validSettings
  validNumericSettings[["value_col"]]<-"someNumbers"
  adlbc_edit<-adlbc
  adlbc_edit$someNumbers <- c("10","11",rep("sometext", dim(adlbc_edit)[1]-2))
  numericFailedAgain<-validateSettings(data=adlbc_edit,settings=validNumericSettings)
  expect_false(numericFailedAgain[["valid"]])
  partialNumericCheck <- numericFailedAgain$checks %>% filter(description=="specified column is numeric?" & text_key=="value_col")
  expect_equal(partialNumericCheck[1,"message"]%>%as.character,"10286 of 10288 values were not numeric. Records with non-numeric values may not appear in the graphic.")
  
})

test_that("numeric column checks pass when more than half of the values are numeric ",{
  validNumericSettings <- validSettings
  validNumericSettings[["value_col"]]<-"someStrings"
  adlbc_edit<-adlbc
  adlbc_edit$someStrings <- c("b","a",rep("10", dim(adlbc_edit)[1]-2))
  numericPassed<-validateSettings(data=adlbc_edit,settings=validNumericSettings)
  expect_true(numericPassed[["valid"]])
  partialNumericCheck <- numericPassed$checks%>%filter(description=="specified column is numeric?" & text_key=="value_col")
  expect_equal(partialNumericCheck[1,"message"]%>%as.character,"2 of 10288 values were not numeric. Records with non-numeric values may not appear in the graphic.")
})


test_that("validateSettings works with filters and group_cols ",{
  groupFilterSettings <- validSettings
  groupFilterSettings$filters <- list()
  groupFilterSettings$filters[[1]] <- list(value_col = "RACE",
                                label = "RACE")
  groupFilterSettings$group_cols <- list()
  groupFilterSettings$group_cols[[1]] <- list(value_col = "SEX",
                                     label = "SEX")
  Passed<-validateSettings(data=adlbc,settings=groupFilterSettings)
  expect_true(Passed[["valid"]])
})


