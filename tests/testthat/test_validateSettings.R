context("Tests for the validateSetting() function")
library(ReDish)
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
  expect_equal(failed2$checkList%>%map_dbl(~!.x[["valid"]])%>%sum,2)
  
  expect_true(passed$checkList%>%keep(~.x[["text_key"]]=="id_col")%>%map_lgl(~.x[["valid"]]))
  expect_false(failed$checkList%>%keep(~.x[["text_key"]]=="id_col")%>%map_lgl(~.x[["valid"]]))
})
