context("Tests for the setSettingValue() function")
library(safetyGraphics)

testSettings1<-list(a=list(x="sue",y="sam"), b="hi mom", c=123)
testSDTM <- generateSettings(standard="SDTM")

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
  expect_equal(setSettingsValue(list("a","z"), 456, testSettings1)[["a"]][["x"]], 456)
  expect_equal(setSettingsValue(list("d","test"), 456, testSettings1)[["a"]][["x"]], 456)
})

test_that("can't set nested values when a parent isn't a list",{
  expect_false(TRUE)
})
  