context("Tests for the hasColumn() function")
library(safetyGraphics)

test_that("columns are found when expected",{
  # simple test case works
  expect_true(hasColumn(columnName="PARAM",data=adlbc))
  expect_true(hasColumn(columnName="SUBJID",data=adlbc))

  #doesn't care about case
  expect_true(hasColumn(columnName="param",data=adlbc))
  expect_true(hasColumn(columnName="SuBjId",data=adlbc))

  # returns false when fieldValue isn't there or there is a type mismatch
  expect_false(hasColumn(columnName="PARAMETER",data=adlbc))
  expect_false(hasColumn(columnName="SUBJID2",data=adlbc))
  
  # returns false for null columnName
  expect_false(hasColumn(columnName=NULL,data=adlbc))
  
  # fails with invalid parameters
  expect_error(hasColumn(columnName=123,data=adlbc))
  expect_error(hasColumn(columnName=c("PARAM","SUBJID"),data=adlbc))
  expect_error(hasColumn(columnName="PARAM",data=list(adlbc)))
})
