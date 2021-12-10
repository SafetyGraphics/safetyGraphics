context("Tests for the makeMeta() function")
library(safetyGraphics)
library(safetyCharts)

# User Requirements
# [*] Charts with exisiting meta objects are not modified. A message is printed.
# [*] Chart-level metadata (e.g. meta_hepExplorer) is loaded when found
# [ ] If no metadata is found for a chart, a warning message is printed. 
# [ ] If a chart doesn't have name or domain property no metadata is added and a message is printed. 
# [*] Domain-level metadata is loaded for a single domain when found
# [*] Domain-level metadata for multiple domains is loaded when found
# [ ] Domain-level metadata is loaded as expected when chart domain is a named list or a character vector
# [ ] Chart-level takes precedence over domain-level metadata when both are found

testChart <-list(
    env="safetyGraphics",
    name="ageDist",
    label="Age Distribution",
    type="plot",
    domain="dm",
    package="safetyCharts",
    workflow=list(
        main="ageDist"
    )
)

test_that("Charts with exisiting meta objects are not modified. A message is printed.",{
    metaChart <- testChart
    metaChart$meta <- "JustAPlaceholder"
    expect_message(makeMeta(chart=metaChart))
    expect_null(makeMeta(chart=metaChart))
})

test_that("Domain-level metadata is loaded for a single domain when found.",{
    testMeta <- makeMeta(testChart) %>% select(-source)
    expect_equal(testMeta, safetyCharts::meta_dm)
})

test_that("Domain-level metadata for multiple domains is loaded when found",{
    multiDomainChart <- testChart
    multiDomainChart$domain <- c("dm","aes")
    multiDomainMeta <- makeMeta(multiDomainChart) %>% select(-source)
    expect_equal(multiDomainMeta, rbind(safetyCharts::meta_dm, safetyCharts::meta_aes))
})

test_that("Chart-level metadata (e.g. meta_hepExplorer) is loaded when found",{
    testChart <-list(
        env="safetyGraphics",
        name="hepExplorer",
        package="safetyCharts",
        domain="none"
    )
    chartMeta <- makeMeta(testChart) %>% select(-source)
    expect_equal(chartMeta, safetyCharts::meta_hepExplorer)

    #Chart that chart-level and domain-level metadata stack
    testChart$domain="labs"
    chartMeta <- makeMeta(testChart) %>% select(-source)
    expect_equal(chartMeta, rbind(safetyCharts::meta_hepExplorer, safetyCharts::meta_labs))
})

