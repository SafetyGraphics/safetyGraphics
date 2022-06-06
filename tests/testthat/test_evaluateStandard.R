context("Tests for the evaluateStandard() function")
library(safetyGraphics)

test_that("basic test cases evaluate as expected",{
  expect_equal(evaluateStandard(data=safetyData::adam_adlbc, domain="labs", meta= safetyCharts::meta_labs, standard="sdtm")[["match"]],"partial")
  expect_equal(evaluateStandard(data=safetyData::adam_adlbc,  domain="labs", meta= safetyCharts::meta_labs, standard="adam")[["match"]],"full")
  expect_equal(evaluateStandard(data=safetyData::adam_adae, domain="aes", meta= safetyCharts::meta_aes, standard="sdtm")[["match"]],"partial") 
  expect_equal(evaluateStandard(data=safetyData::adam_adae,  domain="aes", meta= safetyCharts::meta_aes, standard="adam")[["match"]],"full")
  expect_equal(evaluateStandard(data=data.frame(),  domain="labs", meta= safetyCharts::meta_labs, standard="sdtm")[["match"]],"none")
})

test_that("a list with the expected properties and structure is returned",{
  a<- evaluateStandard(data=data.frame(),domain="labs", meta=safetyCharts::meta_labs, standard="adam")
  expect_is(a,"list")
  expect_named(a,c('standard', 'mapping', 'total_count','valid_count', 'invalid_count','match_percent', 'match',"label"))
  expect_is(a[["standard"]],"character")
  expect_is(a[["match"]],"character")
  expect_is(a[["mapping"]],"tbl")
  expect_is(a[["valid_count"]],"integer")
  expect_is(a[["invalid_count"]],"integer")
})

test_that("expected number of checks (in)valid",{
  expect_equal(evaluateStandard(data=safetyData::adam_adlbc, domain="labs", meta=safetyCharts::meta_labs, standard="sdtm")[["valid_count"]],4)
  expect_equal(evaluateStandard(data=safetyData::adam_adlbc, domain="labs", meta=safetyCharts::meta_labs, standard="sdtm")[["invalid_count"]],5)
  
  labs_edit <- safetyData::adam_adlbc

  labs_edit$LBTEST <- labs_edit$PARAM
  a<-evaluateStandard(data=labs_edit, domain="labs", meta=safetyCharts::meta_labs, standard="sdtm")
  expect_equal(a[["valid_count"]],5)
  expect_equal(a[["invalid_count"]],4)
  expect_equal(a[["total_count"]],9)
  expect_equal(a[["match_percent"]], 5/9)
  expect_true(a[["mapping"]]%>%filter(text_key=="measure_col")%>%select(valid)%>%unlist)
})

test_that("invalid options throw errors",{
  expect_error(evaluateStandard(data=list(a=1,b=2), domain="labs", meta=safetyCharts::meta_labs, standard="sdtm"))
  expect_error(evaluateStandard(data="notadataframe",domain="labs", meta=safetyCharts::meta_labs, standard="sdtm"))
  expect_error(evaluateStandard(data=safetyData::adam_adlbc,domain="labs", meta=safetyCharts::meta_labs, standard="notarealstandard"))
  expect_error(evaluateStandard(data=safetyData::adam_adlbc,domain="labs", meta=safetyCharts::meta_labs, standard="adam", includeFieldsIsNotAnOptionNow="yesPlease"))
  expect_error(evaluateStandard(data=safetyData::adam_adlbc,domain="labs", meta=list(), standard="sdtm"))
  expect_error(evaluateStandard(data=safetyData::adam_adlbc,domain="labs", meta=safetyData::adam_adlbc, standard="sdtm"))
})


test_that("upper case domain names are supported",{
  uppermeta <- safetyCharts::meta_labs %>% mutate(domain="LaBs")
  expect_equal(evaluateStandard(data=safetyData::adam_adlbc,  domain="lAbS", meta= uppermeta, standard="adam")[["match"]],"full")
})