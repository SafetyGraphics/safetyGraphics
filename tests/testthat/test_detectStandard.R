context("Tests for the detectStandard() function")
library(safetyGraphics)
library(safetyData)
library(stringr)

test_that("a list with the expected properties and structure is returned", {
  a <- detectStandard(data.frame(), meta = safetyCharts::meta_labs)

  expect_is(a, "list")
  expect_named(a, c("details", "standard", "label", "standard_percent"))

  expect_is(a[["standard"]], "character")
  expect_match(a[["standard"]], "sdtm|adam|none")
  expect_is(a[["details"]], "list")
  expect_named(a[["details"]], c("adam", "sdtm"))

  expect_equal(a[["standard_percent"]], 0)
})

test_that("correct standards are identified", {
  expect_equal(detectStandard(data = safetyData::adam_adlbc, meta = safetyCharts::meta_labs, domain = "labs")[["standard"]], "adam")
  expect_equal(detectStandard(data = safetyData::adam_adlbc, meta = safetyCharts::meta_labs, domain = "labs")[["details"]][["sdtm"]][["match"]], "partial")
  expect_equal(detectStandard(data = safetyData::adam_adlbc, meta = safetyCharts::meta_labs, domain = "labs")[["details"]][["adam"]][["match"]], "full")

  adam_params <- c("Alanine Aminotransferase (U/L)", "Aspartate Aminotransferase (U/L)", "Bilirubin (umol/L)", "Alkaline Phosphatase (U/L)")
  adam_test_data <- data.frame(USUBJID = "001", AVAL = 10, PARAM = adam_params, VISIT = "Visit 1", VISITNUM = 1, ADY = 0, A1LO = 0, A1HI = 20, PARAMCD = "K")
  expect_equal(detectStandard(data = adam_test_data, meta = safetyCharts::meta_labs, domain = "labs")[["standard"]], "adam")
  expect_equal(detectStandard(data = adam_test_data, meta = safetyCharts::meta_labs, domain = "labs")[["details"]][["adam"]][["match"]], "full")
  expect_equal(detectStandard(data = adam_test_data, meta = safetyCharts::meta_labs, domain = "labs")[["details"]][["sdtm"]][["match"]], "partial")

  sdtm_params <- c("Alanine Aminotransferase", "Aspartate Aminotransferase", "Bilirubin", "Alkaline Phosphatase")
  sdtm_test_data <- data.frame(USUBJID = "001", LBSTRESN = 10, LBTEST = sdtm_params, VISIT = "Visit 1", VISITNUM = 1, LBDY = 0, LBSTNRLO = 0, LBSTNRHI = 20, LBSTRESU = "K")
  expect_equal(detectStandard(sdtm_test_data, meta = safetyCharts::meta_labs, domain = "labs")[["standard"]], "sdtm")
  expect_equal(detectStandard(sdtm_test_data, meta = safetyCharts::meta_labs, domain = "labs")[["details"]][["sdtm"]][["match"]], "full")
  expect_equal(detectStandard(sdtm_test_data, meta = safetyCharts::meta_labs, domain = "labs")[["details"]][["adam"]][["match"]], "partial")

  empty_test_data <- data.frame("")
  expect_equal(detectStandard(empty_test_data, meta = safetyCharts::meta_labs)[["standard"]], "none")
  expect_equal(detectStandard(empty_test_data, meta = safetyCharts::meta_labs)[["details"]][["adam"]][["match"]], "none")
  expect_equal(detectStandard(empty_test_data, meta = safetyCharts::meta_labs)[["details"]][["sdtm"]][["match"]], "none")

  case_sensitive_test_data <- data.frame(usubjid = "001", AVAL = 10, PARAM = adam_params, VISIT = "Visit 1", VISITNUM = 1, ADY = 0, A1LO = 0, A1HI = 20, PARAMCD = "K")
  expect_equal(detectStandard(case_sensitive_test_data, meta = safetyCharts::meta_labs, domain = "labs")[["standard"]], "adam")
  expect_equal(detectStandard(case_sensitive_test_data, meta = safetyCharts::meta_labs, domain = "labs")[["details"]][["adam"]][["match"]], "full")
  expect_equal(detectStandard(case_sensitive_test_data, meta = safetyCharts::meta_labs, domain = "labs")[["details"]][["sdtm"]][["match"]], "partial")

  # NOTE: adam takes precedence over sdtm
  sdtm_and_adam_test_data <- cbind(adam_test_data, sdtm_test_data)
  expect_equal(detectStandard(sdtm_and_adam_test_data, meta = safetyCharts::meta_labs, domain = "labs")[["standard"]], "adam")
  expect_equal(detectStandard(sdtm_and_adam_test_data, meta = safetyCharts::meta_labs, domain = "labs")[["details"]][["adam"]][["match"]], "full")
  expect_equal(detectStandard(sdtm_and_adam_test_data, meta = safetyCharts::meta_labs, domain = "labs")[["details"]][["sdtm"]][["match"]], "full")

  # NOTE: adam takes precedence over sdtm in partial matches as well
  sdtm_and_adam_partial_test_data <- data.frame(USUBJID = "001", VISIT = "Visit 1")
  expect_equal(detectStandard(sdtm_and_adam_partial_test_data, meta = safetyCharts::meta_labs, domain = "labs")[["standard"]], "adam")
  expect_equal(detectStandard(sdtm_and_adam_partial_test_data, meta = safetyCharts::meta_labs, domain = "labs")[["details"]][["adam"]][["match"]], "partial")
  expect_equal(detectStandard(sdtm_and_adam_partial_test_data, meta = safetyCharts::meta_labs, domain = "labs")[["details"]][["sdtm"]][["match"]], "partial")
})
