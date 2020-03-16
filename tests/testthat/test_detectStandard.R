context("Tests for the detectStandard() function")
library(safetyGraphics)

lm <- getMetadata(domain="labs")

test_that("a list with the expected properties and structure is returned",{
  a<- detectStandard(data.frame(), dmeta=lm)
  
  expect_is(a,"list")
  expect_named(a,c("details","standard","standard_percent"))

  expect_is(a[["standard"]],"character")
  expect_match(a[["standard"]],"sdtm|adam|none")
  expect_is(a[["details"]],"list")
  expect_named(a[["details"]],c("sdtm","adam"))
  
  expect_equal(a[["standard_percent"]],0)
})

test_that("correct standards are identified",{
  expect_equal(detectStandard(labs, dmeta=lm)[["standard"]],"adam")
  expect_equal(detectStandard(labs, dmeta=lm)[["details"]][["adam"]][["match"]], "full")
  expect_equal(detectStandard(labs, dmeta=lm)[["details"]][["sdtm"]][["match"]], "partial")
  
  adam_params <- c("Alanine Aminotransferase (U/L)","Aspartate Aminotransferase (U/L)","Bilirubin (umol/L)","Alkaline Phosphatase (U/L)")
  adam_test_data<-data.frame(USUBJID="001",AVAL=10,PARAM=adam_params,VISIT="Visit 1",VISITNUM=1,ADY=0,A1LO=0,A1HI=20,PARAMCD="K")
  expect_equal(detectStandard(adam_test_data, dmeta=lm)[["standard"]],"adam")
  expect_equal(detectStandard(adam_test_data, dmeta=lm)[["details"]][["adam"]][["match"]], "full")
  expect_equal(detectStandard(adam_test_data, dmeta=lm)[["details"]][["sdtm"]][["match"]], "partial")
  
  sdtm_params<-c("Aminotransferase, alanine (ALT)","Aminotransferase, aspartate (AST)","Total Bilirubin","Alkaline phosphatase (ALP)")
  sdtm_test_data<-data.frame(USUBJID="001",STRESN=10,TEST=sdtm_params,VISIT="Visit 1",VISITNUM=1,DY=0,STNRLO=0,STNRHI=20,STRESU="K")
  expect_equal(detectStandard(sdtm_test_data, dmeta=lm)[["standard"]],"sdtm")
  expect_equal(detectStandard(sdtm_test_data, dmeta=lm)[["details"]][["adam"]][["match"]], "partial")
  expect_equal(detectStandard(sdtm_test_data, dmeta=lm)[["details"]][["sdtm"]][["match"]], "full")
  
  empty_test_data<-data.frame("")
  expect_equal(detectStandard(empty_test_data, dmeta=lm)[["standard"]],"none")
  expect_equal(detectStandard(empty_test_data, dmeta=lm)[["details"]][["adam"]][["match"]], "none")
  expect_equal(detectStandard(empty_test_data, dmeta=lm)[["details"]][["sdtm"]][["match"]], "none")
  
  case_sensitive_test_data<-data.frame(usubjid="001",AVAL=10,PARAM=adam_params,VISIT="Visit 1",VISITNUM=1,ADY=0,A1LO=0,A1HI=20,PARAMCD="K")
  expect_equal(detectStandard(case_sensitive_test_data, dmeta=lm)[["standard"]],"adam")
  expect_equal(detectStandard(case_sensitive_test_data, dmeta=lm)[["details"]][["adam"]][["match"]], "full")
  expect_equal(detectStandard(case_sensitive_test_data, dmeta=lm)[["details"]][["sdtm"]][["match"]], "partial")
  
  #NOTE: sdtm takes precedence over adam
  sdtm_and_adam_test_data<-cbind(adam_test_data,sdtm_test_data)
  expect_equal(detectStandard(sdtm_and_adam_test_data, dmeta=lm)[["standard"]],"sdtm")
  expect_equal(detectStandard(sdtm_and_adam_test_data, dmeta=lm)[["details"]][["adam"]][["match"]], "full")
  expect_equal(detectStandard(sdtm_and_adam_test_data, dmeta=lm)[["details"]][["sdtm"]][["match"]], "full")
  
  #NOTE: sdtm takes precedence over adam in partial matches as well
  sdtm_and_adam_partial_test_data<-data.frame(USUBJID="001",VISIT="Visit 1")
  expect_equal(detectStandard(sdtm_and_adam_partial_test_data, dmeta=lm)[["standard"]],"sdtm")
  expect_equal(detectStandard(sdtm_and_adam_partial_test_data, dmeta=lm)[["details"]][["adam"]][["match"]],"partial")
  expect_equal(detectStandard(sdtm_and_adam_partial_test_data, dmeta=lm)[["details"]][["sdtm"]][["match"]],"partial")
  
 
})


test_that("correct standards are identified for ae domain",{
  am <- getMetadata(domain="aes")
  
  expect_equal(detectStandard(safetyGraphics::aes, dmeta=am)[["standard"]],"adam")
  expect_equal(detectStandard(safetyGraphics::aes, dmeta=am)[["details"]][["adam"]][["match"]], "full")
  expect_equal(detectStandard(safetyGraphics::aes, dmeta=am)[["details"]][["sdtm"]][["match"]], "partial")
})

