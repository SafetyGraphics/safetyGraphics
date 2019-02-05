context("Tests for the hasField() function")
library(safetyGraphics)

test_that("fields are found when expected",{
  # simple test case works
  expect_true(hasField(fieldValue="Bilirubin (umol/L)",columnName="PARAM",data=adlbc))
  expect_true(hasField(fieldValue=1015,columnName="SUBJID",data=adlbc))

  # returns false when fieldValue isn't there or there is a type mismatch
  expect_false(hasField(fieldValue="Not_a_real_value",columnName="PARAM",data=adlbc))
  expect_false(hasField(fieldValue="1015",columnName="SUBJID",data=adlbc))

  # fails with invalid parameters
  expect_error(hasField(fieldValue=c("a","b"),columnName="PARAM",data=adlbc))
  expect_error(hasField(fieldValue=12,columnName="PARAM",data=adlbc))
  expect_error(hasField(fieldValue="Bilirubin (umol/L)",columnName=c("PARAM","ID"),data=adlbc))
  expect_error(hasField(fieldValue=,columnName="PARAM",data=list(adlbc)))
})
