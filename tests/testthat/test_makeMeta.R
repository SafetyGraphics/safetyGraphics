context("Tests for the makeMeta() function")
library(safetyGraphics)
library(safetyCharts)

# User Requirements
# [*] Chart-level metadata (e.g. meta_hepExplorer) is loaded when found
# [*] Domain-level metadata is loaded for a single domain when found
# [*] Domain-level metadata for multiple domains is loaded when found
# [*] Metadata is loaded as expected for multiple charts
# [*] Metadata saved to chart.meta is loaded
# [*] Metadata saved to chart.meta is loaded with chart-level and domain-level metadata.
# [*] Metadata that is not a dataframe is not loaded and a message is printed.
# [*] Metadata with incorrect columns is not loaded and a message is printed.
# [*] If no metadata is found for a chart, a warning message is printed.
# [*] An error is thrown if duplicate rows of metadata are found
# [*] An error is thrown if no metadata is found

testChart <- list(
  env = "safetyGraphics",
  name = "ageDist",
  label = "Age Distribution",
  type = "plot",
  domain = "dm",
  package = "safetyCharts",
  workflow = list(
    main = "ageDist"
  )
)

test_that("Domain-level metadata is loaded for a single domain when found.", {
  testMeta <- makeMeta(list(testChart)) %>% select(-source)
  expect_equal(testMeta, safetyCharts::meta_dm)
})

test_that("Domain-level metadata for multiple domains is loaded when found", {
  multiDomainChart <- testChart
  multiDomainChart$domain <- c("dm", "aes")
  multiDomainMeta <- makeMeta(list(multiDomainChart)) %>% select(-source)
  expect_equal(multiDomainMeta, rbind(safetyCharts::meta_dm, safetyCharts::meta_aes))
})

test_that("Chart-level metadata (e.g. meta_hepExplorer) is loaded when found", {
  testChart <- list(
    env = "safetyGraphics",
    name = "hepExplorer",
    package = "safetyCharts",
    domain = "none"
  )
  chartMeta <- makeMeta(list(testChart)) %>% select(-source)
  expect_equal(chartMeta, safetyCharts::meta_hepExplorer)

  # Chart that chart-level and domain-level metadata stack
  testChart$domain <- "labs"
  chartMeta <- makeMeta(list(testChart)) %>% select(-source)
  expect_equal(chartMeta, rbind(safetyCharts::meta_hepExplorer, safetyCharts::meta_labs))
})

test_that("metadata for multiple charts loads when found", {
  testCharts <- list(
    list(name = "chart1", domain = c("aes", "dm"), package = "safetyCharts"),
    list(name = "chart2", domain = c("labs", "dm")) # package defaults to safetyCharts if not specified
  )
  chartMeta <- makeMeta(testCharts) %>% select(-source)
  expect_equal(chartMeta, rbind(safetyCharts::meta_aes, safetyCharts::meta_dm, safetyCharts::meta_labs))
})

helloMeta <- tribble(
  ~text_key, ~domain, ~label, ~description,
  "x_col", "hello", "x position", "x position for points in hello world chart",
  "y_col", "hello", "y position", "y position for points in hello world chart"
) %>% mutate(
  col_key = text_key,
  type = "column"
)
helloChart <- list(name = "hello", meta = helloMeta)

test_that("metadata saved to chart.meta is loaded", {
  chartMeta <- makeMeta(list(helloChart)) %>% select(-source)
  expect_equal(chartMeta, helloMeta)
})

test_that("Metadata saved to chart.meta is loaded with chart-level and domain-level metadata.", {
  hepChart <- list(
    env = "safetyGraphics",
    name = "hepExplorer",
    package = "safetyCharts",
    domain = "labs"
  )
  charts <- list(helloChart, hepChart)
  chartMeta <- makeMeta(charts) %>% select(-source)
  expect_equal(chartMeta, bind_rows(safetyCharts::meta_hepExplorer, safetyCharts::meta_labs, helloMeta))
})

test_that("chart.meta that is not a dataframe is not loaded and a message is printed.", {
  badHello <- list(
    list(name = "hello", meta = "not-a-df"),
    list(name = "labChart", domain = "labs")
  )
  expect_warning(makeMeta(badHello))
  expect_equal(suppressWarnings(makeMeta(badHello)) %>% select(-source), safetyCharts::meta_labs)
})

test_that("Metadata with incorrect columns is not loaded and a message is printed.", {
  badHello2 <- list(
    list(name = "hello", meta = helloMeta %>% rename(id = text_key)),
    list(name = "labChart", domain = "labs")
  )
  expect_warning(makeMeta(badHello2))
  expect_equal(suppressWarnings(makeMeta(badHello2)) %>% select(-source), safetyCharts::meta_labs)
})

test_that("An error is thrown if duplicate rows of metadata are found", {
  dupLabMeta <- tribble(
    ~text_key, ~domain, ~label, ~description,
    "id_col", "labs", "ID", "ID"
  ) %>% mutate(
    col_key = text_key,
    type = "column"
  )
  dupTest <- list(
    list(name = "myLabChart", meta = dupLabMeta),
    list(name = "thierLabChart", domain = "labs")
  )
  expect_error(makeMeta(dupTest))

  helloDupMeta <- tribble(
    ~text_key, ~domain, ~label, ~description,
    "x_col", "hello", "x position", "x position for points in hello world chart",
    "x_col", "hello", "x position (again)", "x position for points in hello world chart"
  ) %>% mutate(
    col_key = text_key,
    type = "column"
  )
  helloDup <- list(list(name = "helloDup", meta = helloDupMeta))
  expect_error(makeMeta(helloDup))
})

test_that("An error is thrown if no metadata is found", {
  noMetaTest <- list(
    list(name = "myLabChart", domain = "slabs"),
    list(name = "thierLabChart", domain = "crabs")
  )
  expect_error(makeMeta(noMetaTest))
})
