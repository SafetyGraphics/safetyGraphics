context("Tests for the evaluateStandard() function")
library(safetyGraphics)

test_that("basic test cases evaluate as expected",{
  expect_equal(evaluateStandard(data=adlbc, standard="adam")[["match"]],"Full")
  expect_equal(evaluateStandard(data=adlbc, standard="sdtm")[["match"]],"Partial")
  expect_equal(evaluateStandard(data=data.frame(), standard="sdtm")[["match"]],"None")
})

test_that("a list with the expected properties and structure is returned",{
  a<- evaluateStandard(data=data.frame(),standard="adam")

  expect_is(a,"list")
  expect_named(a,c('standard', 'checks', 'valid_count', 'invalid_count', 'match'))
  expect_is(a[["standard"]],"character")
  expect_is(a[["match"]],"character")
  expect_is(a[["checks"]],"tbl")
  expect_is(a[["valid_count"]],"integer")
  expect_is(a[["invalid_count"]],"integer")
})

test_that("expected checks are marked invalid",{
  expect_true(FALSE)
})


test_that("field level data is ignored when useFields=false",{
  expect_true(FALSE)
})

test_that("invalid options throw errors",{
  expect_true(FALSE)
})