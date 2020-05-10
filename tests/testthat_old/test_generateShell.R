context("Tests for the generateShell() function")
library(safetyGraphics)

default <- generateShell()

test_that("a list with the expected properties and structure is returned by default",{
  expect_type(default, "list")
  expect_equal(default[["id_col"]],NULL)
  expect_equal(default[["measure_values"]][["ALT"]],NULL)
  expect_null(default[["not_a_setting"]])
})

# TODO: Add tests for the charts parameter once multiple charts are added