library(safetyGraphics)
library(stringr)

context("Tests for the getSettingKeys() function")
testSettings <- generateSettings(standard="SDTM")

test_that("throws error if patterns or settings aren't specified",{
  expect_error(getSettingKeys())
  expect_error(getSettingKeys(patterns=c("testKey")))
  expect_error(getSettingKeys(settings=testSettings))
})

test_that("function throws an error if the settings object isn't a list",{
  expect_error(getSettingKeys(patterns=c("testKey"),settings=c("NotAList")))
  expect_silent(getSettingKeys(patterns=c("testKey"),settings=list(testkey="ABC")))
})

test_that("function throws an error if patterns isn't character",{
  expect_error(getSettingKeys(patterns=12,settings=testSettings))
  expect_error(getSettingKeys(patterns=list("testKey"),settings=testSettings))
  expect_silent(getSettingKeys(patterns="testKey",settings=testSettings))
  expect_silent(getSettingKeys(patterns=c("testKey"),settings=testSettings))
  expect_silent(getSettingKeys(patterns=c("test","Key"),settings=testSettings))
})

test_that("finds matching keys at top level",{
  testSettings2<-list(id_col=1,my_color=2,anotherSetting=3,somethingelseentirely=4)
  expect_length(getSettingKeys(patterns="_col",settings=testSettings2),2)
  expect_length(getSettingKeys(patterns=c("_col"),settings=testSettings2),2)
  expect_length(getSettingKeys(patterns=c("_col","Setting"),settings=testSettings2),3)
  expect_length(getSettingKeys(patterns=c("_col","Setting","something"),settings=testSettings2),4)
  expect_length(getSettingKeys(patterns="o",settings=testSettings2),4)
  expect_length(getSettingKeys(patterns="nonsense",testSettings2),0)
})

test_that("gets matching keys from embedded named lists",{
  testSettings2<-list(id_col=list(my_col=10,his_col=11),my_color=list(notamatch=20),anotherSetting=3,somethingelseentirely=list(alsonotamatch=40))
  expect_length(getSettingKeys(patterns="_col",settings=testSettings2),2) #only id_col/my_col and id_col/his_col should match. my_color should not. 
  expect_equal(getSettingKeys(patterns="_col",settings=testSettings2)[[1]],list("id_col","my_col")) #should be returning the full path to the parameter
  expect_length(getSettingKeys(patterns=c("_col","Setting"),settings=testSettings2),3) #id_col/my_col and id_col/his_col and anothersetting should  match
  expect_length(getSettingKeys(patterns="o",settings=testSettings2),5) #everything should match 5
})

test_that("gets matching keys from embedded unnamed lists",{
  testSettings3<-list(filters=list(list(value_col="filter1"),list(value_col="filter2")),id_col=1)
  expect_length(getSettingKeys(patterns="_col",settings=testSettings3),3)
  expect_equal(getSettingKeys(patterns="_col",settings=testSettings3)[[1]],list("filters",1,"value_col")) #should be returning the full path to the parameter
  expect_equal(getSettingKeys(patterns="_col",settings=testSettings3)[[2]],list("filters",2,"value_col")) 
  expect_equal(getSettingKeys(patterns="_col",settings=testSettings3)[[3]],list("id_col")) #should be returning the full path to the parameter
})

test_that("function plays nicely with getSettingValue",{
  myKey <- getSettingKeys(patterns="id_col",settings=testSettings)[[1]]
  myValue<-getSettingValue(key=myKey,settings=testSettings)
  expect_equal(myValue,"USUBJID")
  
  myNestedKey <- getSettingKeys(patterns="alt",settings=testSettings)[[1]]
  myNestedValue<-getSettingValue(key=myNestedKey,settings=testSettings)
  expect_equal(myNestedValue,"Aminotransferase, alanine (ALT)")
})