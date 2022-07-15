context("Tests for the makeMapping() function")
library(safetyGraphics)
library(safetyData)
library(stringr)

testData <- list(
  labs = safetyData::adam_adlbc,
  aes = safetyData::adam_adae,
  dm = safetyData::adam_adsl
)

meta <- rbind(
  safetyCharts::meta_labs,
  safetyCharts::meta_aes,
  safetyCharts::meta_dm,
  safetyCharts::meta_hepExplorer
)

myCustomMapping <- list(
  aes = list(id_col = "USUBJID", seq_col = "MY_SEQ"),
  labs = list(id_col = "customID")
)

ex1 <- makeMapping(testData, meta, TRUE, NULL)
ex2 <- makeMapping(testData, meta, FALSE, NULL)
ex3 <- makeMapping(testData, meta, TRUE, myCustomMapping)
ex4 <- makeMapping(testData, meta, FALSE, myCustomMapping)

test_that("object with the correct properties is returned", {
  expect_named(ex1, c("standard", "mapping"))
  expect_named(ex2, c("standard", "mapping"))
  expect_named(ex3, c("standard", "mapping"))
  expect_named(ex4, c("standard", "mapping"))
})

test_that("no standard information returned if autoMapping is false", {
  expect_false(is.null(ex1$standard))
  expect_true(is.null(ex2$standard))
  expect_false(is.null(ex3$standard))
  expect_true(is.null(ex4$standard))
})

test_that("properly formatted standard information is returned if autoMapping is true", {
  expect_named(ex1$standard, c("labs", "aes", "dm"))
  for (domain in names(ex1$standard)) {
    expect_named(ex1$standard[[domain]], c("details", "standard", "label", "standard_percent", "mapping"))
  }
  expect_named(ex3$standard, c("labs", "aes", "dm"))
  for (domain in names(ex3$standard)) {
    expect_named(ex3$standard[[domain]], c("details", "standard", "label", "standard_percent", "mapping"))
  }
})

test_that("when autoMapping is false, only values from customMapping is returned", {
  # Example 4 should only have 3 rows
  expect_equal(nrow(ex4$mapping), myCustomMapping %>% map_int(length) %>% sum())

  # Correct values set
  ae_seq_val <- ex4$mapping %>%
    filter(domain == "aes") %>%
    filter(text_key == "seq_col") %>%
    pull(current)
  expect_equal(ae_seq_val, myCustomMapping$aes$seq_col)
  lab_id_val <- ex4$mapping %>%
    filter(domain == "labs") %>%
    filter(text_key == "id_col") %>%
    pull(current)
  expect_equal(lab_id_val, myCustomMapping$labs$id_col)
  ae_seq_val <- ex4$mapping %>%
    filter(domain == "aes") %>%
    filter(text_key == "seq_col") %>%
    pull(current)
  expect_equal(ae_seq_val, myCustomMapping$aes$seq_col)
})

test_that("customMapping overwrites autoMapping values", {
  # Example 3 should have the same number of rows as ex1 since there are no new mapping values created.
  expect_equal(nrow(ex3$mapping), nrow(ex1$mapping))

  # Example 3 should have overwritten values for aes$seq_col and labs$id_col.
  ae_seq_val <- ex3$mapping %>%
    filter(domain == "aes") %>%
    filter(text_key == "seq_col") %>%
    pull(current)
  expect_equal(ae_seq_val, myCustomMapping$aes$seq_col)
  lab_id_val <- ex3$mapping %>%
    filter(domain == "labs") %>%
    filter(text_key == "id_col") %>%
    pull(current)
  expect_equal(lab_id_val, myCustomMapping$labs$id_col)

  # aes$id_col is the same in customMapping and should be unchanged
  ae_id_val <- ex3$mapping %>%
    filter(domain == "aes") %>%
    filter(text_key == "id_col") %>%
    pull(current)
  expect_equal(ae_id_val, myCustomMapping$aes$id_col)
})

test_that("unique domains in customMapping are added", {
  myCustomMapping2 <- myCustomMapping
  myCustomMapping2$customDomain <- list(id_col = "customID", other_col = "other")
  ex5 <- makeMapping(testData, meta, TRUE, myCustomMapping2)
  expect_equal(unique(ex5$mapping$domain), c("aes", "labs", "customDomain", "dm"))

  # 2 rows added
  expect_equal(nrow(ex5$mapping), nrow(ex1$mapping) + 2)

  # Correct values set in mapping
  custom_id_val <- ex5$mapping %>%
    filter(domain == "customDomain") %>%
    filter(text_key == "id_col") %>%
    pull(current)
  expect_equal(custom_id_val, myCustomMapping2$customDomain$id_col)
  custom_other_val <- ex5$mapping %>%
    filter(domain == "customDomain") %>%
    filter(text_key == "other_col") %>%
    pull(current)
  expect_equal(custom_other_val, myCustomMapping2$customDomain$other_col)
})

test_that("unique mapping values for existing domains in customMapping are added", {
  myCustomMapping3 <- myCustomMapping
  myCustomMapping3$aes$other_col <- "other"
  ex6 <- makeMapping(testData, meta, TRUE, myCustomMapping3)

  # 1 row added
  expect_equal(nrow(ex6$mapping), nrow(ex1$mapping) + 1)
  ae_other_val <- ex6$mapping %>%
    filter(domain == "aes") %>%
    filter(text_key == "other_col") %>%
    pull(current)
  expect_equal(ae_other_val, myCustomMapping3$aes$other_col)
})

test_that("nested values in custom mapping work as expected", {
  myCustomMapping4 <- myCustomMapping
  myCustomMapping4$labs$measure_values$ALT <- "AnotherAlt"
  myCustomMapping4$labs$measure_values$OTHER <- "Other"
  myCustomMapping4$aes$fake_values <- list(other1 = "Other1", other2 = "other2")
  ex7 <- makeMapping(testData, meta, TRUE, myCustomMapping4)

  # 1 row added
  expect_equal(nrow(ex7$mapping), nrow(ex1$mapping) + 3)
  labs_measure_alt_val <- ex7$mapping %>%
    filter(domain == "labs") %>%
    filter(text_key == "measure_values--ALT") %>%
    pull(current)
  expect_equal(labs_measure_alt_val, myCustomMapping4$labs$measure_values$ALT)
  labs_measure_other_val <- ex7$mapping %>%
    filter(domain == "labs") %>%
    filter(text_key == "measure_values--OTHER") %>%
    pull(current)
  expect_equal(labs_measure_other_val, myCustomMapping4$labs$measure_values$OTHER)
  ae_fake1_val <- ex7$mapping %>%
    filter(domain == "aes") %>%
    filter(text_key == "fake_values--other1") %>%
    pull(current)
  expect_equal(ae_fake1_val, myCustomMapping4$aes$fake_values$other1)
  ae_fake2_val <- ex7$mapping %>%
    filter(domain == "aes") %>%
    filter(text_key == "fake_values--other2") %>%
    pull(current)
  expect_equal(ae_fake2_val, myCustomMapping4$aes$fake_values$other2)
})
