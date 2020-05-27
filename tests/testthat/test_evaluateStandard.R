context("Tests for the evaluateStandard() function")
library(safetyGraphics)

test_that("basic test cases evaluate as expected",{
  expect_equal(evaluateStandard(data=labs, domain="labs", meta= meta, standard="sdtm")[["match"]],"partial")
  expect_equal(evaluateStandard(data=labs,  domain="labs", meta= meta, standard="adam")[["match"]],"full")
  expect_equal(evaluateStandard(data=aes, domain="aes", meta= meta, standard="sdtm")[["match"]],"partial") 
  #todo add treatment to AE data and change previous test to "full"
  expect_equal(evaluateStandard(data=aes,  domain="aes", meta= meta, standard="adam")[["match"]],"partial")
  expect_equal(evaluateStandard(data=data.frame(),  domain="labs", meta= meta, standard="sdtm")[["match"]],"none")
})

test_that("a list with the expected properties and structure is returned",{
  a<- evaluateStandard(data=data.frame(),domain="labs", meta=meta, standard="adam")

  expect_is(a,"list")
  expect_named(a,c('standard', 'mapping', 'total_count','valid_count', 'invalid_count','match_percent', 'match',"label"))
  expect_is(a[["standard"]],"character")
  expect_is(a[["match"]],"character")
  expect_is(a[["mapping"]],"tbl")
  expect_is(a[["valid_count"]],"integer")
  expect_is(a[["invalid_count"]],"integer")
})

test_that("expected number of checks (in)valid",{
  expect_equal(evaluateStandard(data=labs, domain="labs", meta=meta, standard="sdtm")[["valid_count"]],3)
  expect_equal(evaluateStandard(data=labs, domain="labs", meta=meta, standard="sdtm")[["invalid_count"]],10)
  
  labs_edit <- labs
  labs_edit$TEST <- labs_edit$PARAM
  a<-evaluateStandard(data=labs_edit, domain="labs", meta=meta, standard="sdtm")
  expect_equal(a[["valid_count"]],4)
  expect_equal(a[["invalid_count"]],9)
  expect_equal(a[["total_count"]],13)
  expect_equal(round(a[["match_percent"]],3), .308)
  expect_true(a[["mapping"]]%>%filter(text_key=="measure_col")%>%select(valid)%>%unlist)
})

test_that("invalid options throw errors",{
  expect_error(evaluateStandard(data=list(a=1,b=2), domain="labs", meta=meta, standard="sdtm"))
  expect_error(evaluateStandard(data="notadataframe",domain="labs", meta=meta, standard="sdtm"))
  expect_error(evaluateStandard(data=labs,domain="labs", meta=meta, standard=123))
  expect_error(evaluateStandard(data=labs,domain="labs", meta=meta, standard="notarealstandard"))
  expect_error(evaluateStandard(data=labs,domain="labs", meta=meta, standard="adam", includeFieldsIsNotAnOptionNow="yesPlease"))
  expect_error(evaluateStandard(data=labs,domain="labs", meta=list(), standard="sdtm"))
  expect_error(evaluateStandard(data=labs,domain="labs", meta=labs, standard="sdtm"))
})