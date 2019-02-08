context("Tests for the setSettingValue() function")
library(safetyGraphics)

testSettings1<-list(a=list(x="sue",y="sam"), b="hi mom", c=123, unnamed=list("Apples","Oranges"))

test_that("function throws an error if the settings object isn't a list",{
  expect_error(setSettingsValue(key="testKey",value="abc", settings=c("NotAList")))
  expect_silent(setSettingsValue(key="testKey", value="DEF", settings=list(testkey="ABC")))
})

test_that("can set values to/from various types",{
  expect_equal(setSettingsValue("a", 456, testSettings1)[["a"]], 456)
  expect_equal(setSettingsValue(list("a"), 456,testSettings1)[["a"]], 456)
  expect_equal(setSettingsValue(list("a"), "sometext",testSettings1)[["a"]], "sometext")
  expect_equal(setSettingsValue(list("a"), FALSE,testSettings1)[["a"]], FALSE)
  expect_equal(setSettingsValue(list("b"), "hi dad",testSettings1)[["b"]], "hi dad")
  expect_equal(setSettingsValue(list("b"), 123,testSettings1)[["b"]], 123)
  expect_equal(setSettingsValue(list("b"), list(e=1,f=FALSE),testSettings1)[["b"]], list(e=1,f=FALSE))
  expect_equal(setSettingsValue(list("c"), FALSE,testSettings1)[["c"]], FALSE)
})

test_that("can set value that didn't previously exist",{
  expect_equal(setSettingsValue("d", "I'm new here.", testSettings1)[["d"]], "I'm new here.")
  expect_equal(setSettingsValue(list("d"), "I'm new here.", testSettings1)[["d"]], "I'm new here.")
})

test_that("can set nested values",{
  expect_equal(setSettingsValue(list("a","x"), 456, testSettings1)[["a"]][["x"]], 456)
})

test_that("can set nested values that didn't previously exist",{
  expect_equal(setSettingsValue(list("a","z"), 456, testSettings1)[["a"]][["z"]], 456)
})

test_that("but can't set nested values when a parent is missing or isn't a list",{
  expect_error(setSettingsValue(list("d","test"), 456, testSettings1)[["d"]][["test"]]) # d doesn't exist, so this doesn't work. user could set d to list() and then set test to 456 ... 
  expect_error(setSettingsValue(list("b","z"), 456, testSettings1)) # can't replace a scalar (b="hi mom") with a list (b=list(z=456))
})

test_that("can set nested values in an unnamed list",{
  expect_equal(setSettingsValue(list("unnamed",1), 456, testSettings1)[["unnamed"]][[1]], 456) # [[1]] is overwritten
  expect_equal(setSettingsValue(list("unnamed",1), 456, testSettings1)[["unnamed"]][[2]], "Oranges") #original value in [[2]] is unchanged
})

test_that("can set nested values in an unnamed list that didn't previously exist",{
  expect_true(setSettingsValue(list("unnamed",3), TRUE, testSettings1)[["unnamed"]][[3]]) #[[3]] added
  
  expect_true(setSettingsValue(list("unnamed",5), TRUE, testSettings1)[["unnamed"]][[5]]) #this works, [[4]] and [[5]] are Null
  expect_null(setSettingsValue(list("unnamed",5), TRUE, testSettings1)[["unnamed"]][[4]]) #this works, [[4]] and [[5]] are Null
  expect_null(setSettingsValue(list("unnamed",5), TRUE, testSettings1)[["unnamed"]][[4]]) #this works, [[4]] and [[5]] are Null
})


test_that("sanity checks using a real setting object",{
  testSDTM <- generateSettings(standard="SDTM")
  testSDTM <-setSettingsValue(list("id_col"), "customID", testSDTM)
  testSDTM <-setSettingsValue(list("measure_values","ALP"), "Alpine", testSDTM)
  testSDTM <-setSettingsValue(list("filters"), list(), testSDTM)
  testSDTM <-setSettingsValue(list("filters",1), "RACE", testSDTM)
  testSDTM <-setSettingsValue(list("customSetting"), "customized!", testSDTM)
  
  
  expect_equal(testSDTM[["id_col"]],"customID")
  expect_equal(testSDTM[["measure_values"]][["ALP"]],"Alpine")
  expect_equal(testSDTM[["filters"]][[1]],"RACE")
  expect_equal(testSDTM[["customSetting"]],"customized!")
})


  