context("Tests for the getSettingValue() function")
library(ReDish)

testSettings <- generateSettings(standard="SDTM")

test_that("function throws an error if the settings object isn't a list",{
  expect_error(getSettingValue(key="testKey",settings=c("NotAList")))
  expect_silent(getSettingValue(key="testKey",settings=list(testkey="ABC")))
})

test_that("different data types for `key` parameter work as expected",{
  expect_equal(getSettingValue(key=c("id_col"),settings=testSettings),"USUBJID")
  expect_equal(getSettingValue(key=list("id_col"),settings=testSettings),"USUBJID")
  expect_equal(getSettingValue(key="id_col",settings=testSettings),"USUBJID")
  expect_equal(getSettingValue(key=c("measure_values","ALT"),settings=testSettings),"Aminotransferase, alanine (ALT)")
  expect_equal(getSettingValue(key=list("measure_values","ALT"),settings=testSettings),"Aminotransferase, alanine (ALT)")
  expect_equal(getSettingValue(key=list("measure_values",1),settings=testSettings),"Aminotransferase, alanine (ALT)")
})

test_that("returns null if the setting isn't found",{
  expect_null(getSettingValue(key="testKeyandmore",settings=list(testKey="ABC")))
  expect_null(getSettingValue(key=c("a","b","c"),settings=list(testKey="ABC")))
  expect_null(getSettingValue(key=c("testKey","b","c"),settings=list(testKey="ABC")))
  expect_null(getSettingValue(key=c("a","b","testKey"),settings=list(testKey="ABC")))
  
})