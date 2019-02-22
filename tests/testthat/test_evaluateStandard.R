context("Tests for the evaluateStandard() function")
library(safetyGraphics)

test_that("basic test cases evaluate as expected",{
  expect_equal(evaluateStandard(data=adlbc, standard="adam")[["match"]],"full")
  expect_equal(evaluateStandard(data=adlbc, standard="sdtm")[["match"]],"partial")
  expect_equal(evaluateStandard(data=data.frame(), standard="sdtm")[["match"]],"none")
})

test_that("a list with the expected properties and structure is returned",{
  a<- evaluateStandard(data=data.frame(),standard="adam")

  expect_is(a,"list")
  expect_named(a,c('standard', 'checks', 'total_count','valid_count', 'invalid_count','match_percent', 'match'))
  expect_is(a[["standard"]],"character")
  expect_is(a[["match"]],"character")
  expect_is(a[["checks"]],"tbl")
  expect_is(a[["valid_count"]],"integer")
  expect_is(a[["invalid_count"]],"integer")
})

test_that("expected number of checks (in)valid",{
  expect_equal(evaluateStandard(data=adlbc, standard="sdtm")[["valid_count"]],1)
  expect_equal(evaluateStandard(data=adlbc, standard="sdtm")[["invalid_count"]],9)
  
  adlbc_edit <- adlbc
  adlbc_edit$TEST <- adlbc_edit$PARAM
  a<-evaluateStandard(data=adlbc_edit, standard="sdtm")
  expect_equal(a[["valid_count"]],2)
  expect_equal(a[["invalid_count"]],8)
  expect_true(a[["checks"]]%>%filter(text_key=="measure_col")%>%select(valid)%>%unlist)
})


test_that("field level data is ignored when useFields=false",{
  noFields<-evaluateStandard(data=adlbc, standard="adam", includeFields=FALSE)
  expect_equal(noFields[["match"]],"full")
  expect_equal(noFields[["valid_count"]],6)
})

test_that("invalid options throw errors",{
  expect_error(evaluateStandard(data=list(a=1,b=2), standard="sdtm"))
  expect_error(evaluateStandard(data="notadataframe", standard="sdtm"))
  expect_error(evaluateStandard(data=adlbc, standard=123))
  expect_error(evaluateStandard(data=adlbc, standard="notarealstandard"))
  expect_error(evaluateStandard(data=adlbc, standard="adam", includeFields="yesPlease"))
})