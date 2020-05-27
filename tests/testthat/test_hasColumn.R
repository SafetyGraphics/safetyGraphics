context("Tests for the hasColumn() function")
library(safetyGraphics)

test_that("columns are found when expected",{
  # simple test case works
  expect_true(hasColumn(columnName="PARAM",data=labs))
  expect_true(hasColumn(columnName="SUBJID",data=labs))

  #doesn't care about case
  expect_true(hasColumn(columnName="param",data=labs))
  expect_true(hasColumn(columnName="SuBjId",data=labs))

  # returns false when fieldValue isn't there or there is a type mismatch
  expect_false(hasColumn(columnName="PARAMETER",data=labs))
  expect_false(hasColumn(columnName="SUBJID2",data=labs))
  
  # returns false for null columnName
  expect_false(hasColumn(columnName=NULL,data=labs))
  
  # fails with invalid parameters
  expect_error(hasColumn(columnName=123,data=labs))
  expect_error(hasColumn(columnName=c("PARAM","SUBJID"),data=labs))
  expect_error(hasColumn(columnName="PARAM",data=list(labs)))
})
