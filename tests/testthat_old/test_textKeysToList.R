context("Tests for the textKeysToList() function")
library(safetyGraphics)


test_that("function returns the expected values",{
  expect_equal(safetyGraphics:::textKeysToList(textKeys="id_col"), list(list("id_col")))
  expect_equal(safetyGraphics:::textKeysToList(textKeys=list("id_col","filter")), list(list("id_col"),list("filter")))
  expect_equal(safetyGraphics:::textKeysToList(textKeys=c("id_col","filter--label")), list(list("id_col"),list("filter","label")))
})
