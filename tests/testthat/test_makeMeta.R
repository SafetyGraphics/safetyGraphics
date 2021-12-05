context("Tests for the makeMeta() function")
library(safetyGraphics)
library(safetyCharts)

# User Requirements
# -
# - Chart-level metadata (e.g. meta_AEexplorer) is loaded when found
# - If no metadata is found for a chart, a warning message is printed. 
# - If a chart doesn't have name or domain property no metadata is added and a message is printed. 
# - Domain-level metadata is loaded for a single domain when found
# - Domain-level metadata for multiple domains is loaded when found
# - Domain-level metadata is loaded as expected when chart.domain is a named list or a character vector
# - Chart-level takes precedence over domain-level metadata when both are found

testChart <-list(
    env="safetyGraphics",
    name="ageDist",
    label="Age Distribution",
    type="plot",
    domain="dm",
    workflow=list(
        main="ageDist"
    )
)

test_that("Charts with exisitng meta objects are not modified. A message is printed.",{
    metaChart <- testChart
    metaChart$meta <- "JustAPlaceholder"
    expect_message(makeMeta(chart=metaChart))
    expect_equal(metaChart$Meta, "JustAPlaceholder")
})
