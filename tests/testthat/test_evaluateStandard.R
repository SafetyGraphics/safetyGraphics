context("Tests for the evaluateStandard() function")
library(safetyGraphics)

lm <- getMetadata(domain="labs")
test_that("basic test cases evaluate as expected",{
  expect_equal(evaluateStandard(data=labs, standard="adam", dmeta=lm)[["match"]],"full")
  expect_equal(evaluateStandard(data=labs, standard="sdtm", dmeta=lm)[["match"]],"partial")
  expect_equal(evaluateStandard(data=data.frame(), standard="sdtm", dmeta=lm)[["match"]],"none")
})

test_that("a list with the expected properties and structure is returned",{
  a<- evaluateStandard(data=data.frame(),standard="adam", dmeta=lm)

  expect_is(a,"list")
  expect_named(a,c('standard', 'checks', 'total_count','valid_count', 'invalid_count','match_percent', 'match'))
  expect_is(a[["standard"]],"character")
  expect_is(a[["match"]],"character")
  expect_is(a[["checks"]],"tbl")
  expect_is(a[["valid_count"]],"integer")
  expect_is(a[["invalid_count"]],"integer")
})

test_that("expected number of checks (in)valid",{
  expect_equal(evaluateStandard(data=labs, standard="sdtm",dmeta=lm)[["valid_count"]],3)
  expect_equal(evaluateStandard(data=labs, standard="sdtm",dmeta=lm)[["invalid_count"]],9)
  
  labs_edit <- labs
  labs_edit$TEST <- labs_edit$PARAM
  a<-evaluateStandard(data=labs_edit, standard="sdtm",dmeta=lm)
  expect_equal(a[["valid_count"]],4)
  expect_equal(a[["invalid_count"]],8)
  expect_equal(a[["total_count"]],12)
  expect_equal(round(a[["match_percent"]],3), .333)
  expect_true(a[["checks"]]%>%filter(text_key=="measure_col")%>%select(valid)%>%unlist)
})


test_that("field level data is ignored when useFields=false",{
  noFields<-evaluateStandard(data=labs, standard="adam", includeFields=FALSE, dmeta=lm)
  expect_equal(noFields[["match"]],"full")
  expect_equal(noFields[["match_percent"]],1)
  expect_equal(noFields[["valid_count"]],8)
})

test_that("invalid options throw errors",{
  expect_error(evaluateStandard(data=labs, standard="adam")) #no metadata
  expect_error(evaluateStandard(data=list(a=1,b=2), standard="sdtm", dmeta=lm))
  expect_error(evaluateStandard(data="notadataframe", standard="sdtm", dmeta=lm))
  expect_error(evaluateStandard(data=labs, standard=123, dmeta=lm))
  expect_error(evaluateStandard(data=labs, standard="notarealstandard", dmeta=lm))
  expect_error(evaluateStandard(data=labs, standard="adam", includeFields="yesPlease", dmeta=lm))
})