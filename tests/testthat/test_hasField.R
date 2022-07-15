context("Tests for the hasField() function")
library(safetyGraphics)

test_that("fields are found when expected", {
  # simple test case works
  expect_true(hasField(fieldValue = "Bilirubin (umol/L)", columnName = "PARAM", data = safetyData::adam_adlbc))

  # flexible regarding type
  expect_true(hasField(fieldValue = 1015, columnName = "SUBJID", data = safetyData::adam_adlbc))
  expect_true(hasField(fieldValue = "1015", columnName = "SUBJID", data = safetyData::adam_adlbc))
  expect_true(hasField(fieldValue = list(1015), columnName = "SUBJID", data = safetyData::adam_adlbc))
  expect_true(hasField(fieldValue = list(1015), columnName = "SUBJID", data = safetyData::adam_adlbc))

  # but not regarding length
  expect_error(hasField(fieldValue = list(1015, 1023), columnName = "SUBJID", data = safetyData::adam_adlbc))
  expect_error(hasField(fieldValue = c("a", "b"), columnName = "PARAM", data = safetyData::adam_adlbc))


  # returns false when fieldValue isn't there or there is a type mismatch
  expect_false(hasField(fieldValue = "Not_a_real_value", columnName = "PARAM", data = safetyData::adam_adlbc))
  expect_false(hasField(fieldValue = 12, columnName = "PARAM", data = safetyData::adam_adlbc))

  # returns false for null columnName
  expect_false(hasField(fieldValue = "Bilirubin (umol/L)", columnName = NULL, data = safetyData::adam_adlbc))

  # fails with invalid parameters
  expect_error(hasField(fieldValue = "Bilirubin (umol/L)", columnName = c("PARAM", "ID"), data = safetyData::adam_adlbc))
  expect_error(hasField(columnName = "PARAM", data = list(safetyData::adam_adlbc))) # fieldValue missing
})
