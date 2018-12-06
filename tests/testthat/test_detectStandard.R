context("Tests for the detectStandard() function")
library(safetyGraphics)

test_that("a list with the expected properties and structure is returned",{
  a<- detectStandard(data.frame())
  
  expect_is(a,"list")
  expect_named(a,c("details","standard"))

  expect_is(a[["standard"]],"character")
  expect_match(a[["standard"]],"SDTM|ADaM|None")
  expect_is(a[["details"]],"list")
  expect_named(a[["details"]],c("ADaM","SDTM"))
  
})

test_that("correct standards are identified",{
  expect_equal(detectStandard(adlbc)[["standard"]],"ADaM")
  expect_true(detectStandard(adlbc)[["details"]][["ADaM"]][["match"]])
  expect_false(detectStandard(adlbc)[["details"]][["SDTM"]][["match"]])
  
  adam_test_data<-data.frame(USUBJID="001",AVAL=10,PARAM="HDL",VISIT="Visit 1",VISITNUM=1,ADY=0,A1LO=0,A1HI=20)
  expect_equal(detectStandard(adam_test_data)[["standard"]],"ADaM")
  expect_true(detectStandard(adam_test_data)[["details"]][["ADaM"]][["match"]])
  expect_false(detectStandard(adam_test_data)[["details"]][["SDTM"]][["match"]])
  
  sdtm_test_data<-data.frame(USUBJID="001",STRESN=10,TEST="HDL",VISIT="Visit 1",VISITNUM=1,DY=0,STNRLO=0,STNRHI=20)
  expect_equal(detectStandard(sdtm_test_data)[["standard"]],"SDTM")
  expect_false(detectStandard(sdtm_test_data)[["details"]][["ADaM"]][["match"]])
  expect_true(detectStandard(sdtm_test_data)[["details"]][["SDTM"]][["match"]])
  
  empty_test_data<-data.frame()
  expect_equal(detectStandard(empty_test_data)[["standard"]],"None")
  expect_false(detectStandard(empty_test_data)[["details"]][["ADaM"]][["match"]])
  expect_false(detectStandard(empty_test_data)[["details"]][["SDTM"]][["match"]])
  
  case_sensitive_test_data<-data.frame(usubjid="001",AVAL=10,PARAM="HDL",VISIT="Visit 1",VISITNUM=1,ADY=0,A1LO=0,A1HI=20)
  expect_equal(detectStandard(case_sensitive_test_data)[["standard"]],"None")
  expect_false(detectStandard(case_sensitive_test_data)[["details"]][["ADaM"]][["match"]])
  expect_false(detectStandard(case_sensitive_test_data)[["details"]][["SDTM"]][["match"]])
  
  #NOTE: SDTM takes precedence over ADAM
  sdtm_and_adam_test_data<-cbind(adam_test_data,sdtm_test_data)
  expect_equal(detectStandard(sdtm_and_adam_test_data)[["standard"]],"SDTM")
  expect_true(detectStandard(sdtm_and_adam_test_data)[["details"]][["ADaM"]][["match"]])
  expect_true(detectStandard(sdtm_and_adam_test_data)[["details"]][["SDTM"]][["match"]])
})




