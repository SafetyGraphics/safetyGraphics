context("Tests for the validateSetting() function")
library(safetyGraphics)
library(purrr)
library(dplyr)
library(tibble)

validSettings<-generateSettings(standard="adam")
passed<-validateSettings(data=labs,settings=validSettings)

invalidSettings<-validSettings
invalidSettings$id_col<-"not_my_id"
failed<-validateSettings(data=labs,settings=invalidSettings)

test_that("our basic example is valid (until we break it)",{
  expect_true(passed[["valid"]])
  expect_false(failed[["valid"]])
})

test_that("function returns a list with the expected structure",{
  expect_named(passed,c("checks","valid","charts","status"))
  expect_named(failed,c("checks","valid","charts","status"))
  expect_true(is_tibble(passed$checks))
  expect_type(passed$valid,"logical")
  expect_type(passed$status,"character")
  expect_equal(colnames(passed$checks),c("key","text_key","type","description","value","valid","message"))
})

test_that("our examples have the correct number of failed checks",{
  invalidSettings2<-invalidSettings
  invalidSettings2$measure_col<-"not_a_measure_id"
  failed2<-validateSettings(data=labs,settings=invalidSettings2)

  expect_equal(passed$checks%>%filter(!valid)%>%nrow,0)
  expect_equal(failed$checks%>%filter(!valid)%>%nrow,1)
  expect_equal(failed2$checks%>%filter(!valid)%>%nrow,6) #2 columns and 4 fields

  expect_true(passed$checks%>%filter(text_key=="id_col")%>%select(valid)%>%unlist%>%all)
  expect_false(failed$checks%>%filter(text_key=="id_col")%>%select(valid)%>%unlist%>%all)
})

test_that("field checks fail when expected",{
  invalidFieldSettings <- validSettings
  invalidFieldSettings[["measure_values"]][["ALP"]]<-"not a field value :("
  fieldFailed<-validateSettings(data=labs,settings=invalidFieldSettings)
  expect_false(fieldFailed[["valid"]])

  failedChecks <- fieldFailed$checks%>%filter(!valid)
  expect_equal(nrow(failedChecks), 1)
  expect_equal(failedChecks[1,"description"]%>%as.character,"field value from setting found in data")
  expect_equal(failedChecks[1,'text_key']%>%as.character,"measure_values--ALP")
  

   # a vector of values are each checked independently.
   invalidFieldSettings <- validSettings
   invalidFieldSettings$baseline[["value_col"]]<- "PARAM"
   invalidFieldSettings$baseline[["values"]] <- list("not a filter","still not a filter")
   
   expect_false(safetyGraphics:::checkField(list("baseline","values",1),  settings=invalidFieldSettings, data=labs )$valid)
   
   fieldFailed2<-validateSettings(data=labs,settings=invalidFieldSettings)
   expect_false(fieldFailed2[["valid"]])
   expect_equal(fieldFailed2$checks%>%filter(!valid)%>%nrow,2) #2 fields fail
})

test_that("required setting checks fail when expected",{
  invalidRequiredSettings <- validSettings
  invalidRequiredSettings[["id_col"]]<-NULL
  requiredFailed<-validateSettings(data=labs,settings=invalidRequiredSettings)
  expect_false(requiredFailed[["valid"]])

  failedChecks <- requiredFailed$checks%>%filter(!valid)
  expect_equal(nrow(failedChecks), 1)
  expect_equal(failedChecks[1,'description']%>%as.character,"value for specified key found in settings?")
  expect_equal(failedChecks[1,'text_key']%>%as.character,"id_col")
})

test_that("numeric column checks fail when no numeric values are found",{
  invalidNumericSettings <- validSettings
  invalidNumericSettings[["value_col"]]<-"USUBJID"
  numericFailed<-validateSettings(data=labs,settings=invalidNumericSettings)
  expect_false(numericFailed[["valid"]])
  
  failedChecks <- numericFailed$checks%>%filter(!valid)
  expect_equal(nrow(failedChecks), 1)
  expect_equal(failedChecks[1,'description']%>%as.character,"specified column is numeric?")
  expect_equal(failedChecks[1,'text_key']%>%as.character,"value_col")
})

test_that("numeric column checks still fails when more than half of the values are not numeric ",{
  validNumericSettings <- validSettings
  validNumericSettings[["value_col"]]<-"someNumbers"
  labs_edit<-labs
  labs_edit$someNumbers <- c("10","11",rep("sometext", dim(labs_edit)[1]-2))
  numericFailedAgain<-validateSettings(data=labs_edit,settings=validNumericSettings)
  expect_false(numericFailedAgain[["valid"]])
  partialNumericCheck <- numericFailedAgain$checks %>% filter(description=="specified column is numeric?" & text_key=="value_col")
  expect_equal(partialNumericCheck[1,"message"]%>%as.character,"10286 of 10288 values were not numeric. Records with non-numeric values may not appear in the graphic.")
  
})

test_that("numeric column checks pass when more than half of the values are numeric ",{
  validNumericSettings <- validSettings
  validNumericSettings[["value_col"]]<-"someStrings"
  labs_edit<-labs
  labs_edit$someStrings <- c("b","a",rep("10", dim(labs_edit)[1]-2))
  numericPassed<-validateSettings(data=labs_edit,settings=validNumericSettings)
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
  Passed<-validateSettings(data=labs,settings=groupFilterSettings)
  expect_true(Passed[["valid"]])
})

test_that("validateSettings returns the expected charts object",{
  # All charts are valid if overall status is valid
  expect_true(passed[["charts"]]%>%map_lgl(~.x)%>%all)
  
  # At least one chart is invalid when overal status is invalid
  expect_false(failed[["charts"]]%>%map_lgl(~.x)%>%all)
  
  # hepexplorer is the only invalid chart when a measure value is invalidated
  hepexplorerFail_settings <- validSettings
  hepexplorerFail_settings[["measure_values"]][["AST"]]<-"INVALID!"
  hepexplorerFail_validation<-validateSettings(data=labs, settings=hepexplorerFail_settings)
  expect_false(hepexplorerFail_validation$valid)
  expect_false(hepexplorerFail_validation$charts%>%map_lgl(~.x)%>%all)
  expect_false(hepexplorerFail_validation[["charts"]][["hepexplorer"]]) #hepexplorer is invalid
  hepexplorerFail_validation[["charts"]][["hepexplorer"]]<-NULL
  expect_true(hepexplorerFail_validation$charts%>%map_lgl(~.x)%>%all) #all other charts are valid
})
