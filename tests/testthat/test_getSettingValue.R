context("Tests for the getSettingValue() function")
library(safetyGraphics)

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

test_that("can get a specific item out of a vector if desired",{
  filter_vector = list(filters=c("SEX","AGE","RACE"))
  filter_list = list(filters=list("SEX","AGE","RACE"))
  expect_equal(getSettingValue(key=list("filters"),settings=filter_vector),c("SEX","AGE","RACE"))
  expect_equal(getSettingValue(key=list("filters",2),settings=filter_vector),"AGE")
  expect_null(getSettingValue(key=list("filters",2,"test"),settings=filter_vector))
  expect_null(getSettingValue(key=list("filters",4),settings=filter_vector))
  expect_null(getSettingValue(key=list("filters","4"),settings=filter_vector)) 
  
  
  
  expect_equal(getSettingValue(key=list("filters"),settings=filter_list),list("SEX","AGE","RACE"))
  expect_equal(getSettingValue(key=list("filters",2),settings=filter_list),"AGE")

  
})

test_that("returns null if the setting isn't found",{
  expect_null(getSettingValue(key="testKeyandmore",settings=list(testKey="ABC")))
  expect_null(getSettingValue(key=c("a","b","c"),settings=list(testKey="ABC")))
  expect_null(getSettingValue(key=c("testKey","b","c"),settings=list(testKey="ABC")))
  expect_null(getSettingValue(key=c("a","b","testKey"),settings=list(testKey="ABC")))
  
})