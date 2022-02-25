context("Tests for the makeMeta() function")
library(safetyGraphics)
library(safetyCharts)

# User Requirements
# [ ] Chart-level metadata (e.g. meta_hepExplorer) is loaded when found
# [ ] Domain-level metadata is loaded for a single domain when found
# [ ] Domain-level metadata for multiple domains is loaded when found
# [ ] If no metadata is found for a chart, a warning message is printed.
# [ ] An error is thrown if duplicate rows of metadata are found


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

test_that("Domain-level metadata is loaded for a single domain when found.",{
    testMeta <- makeMeta(list(testChart)) %>% select(-source)
    expect_equal(testMeta, safetyCharts::meta_dm)
})

test_that("Domain-level metadata for multiple domains is loaded when found",{
    multiDomainChart <- testChart
    multiDomainChart$domain <- c("dm","aes")
    multiDomainMeta <- makeMeta(list(multiDomainChart)) %>% select(-source)
    expect_equal(multiDomainMeta, rbind(safetyCharts::meta_dm, safetyCharts::meta_aes))
})

test_that("Chart-level metadata (e.g. meta_hepExplorer) is loaded when found",{
    testChart <-list(
        env="safetyGraphics",
        name="hepExplorer",
        package="safetyCharts",
        domain="none"
    )
    chartMeta <- makeMeta(list(testChart)) %>% select(-source)
    expect_equal(chartMeta, safetyCharts::meta_hepExplorer)

    #Chart that chart-level and domain-level metadata stack
    testChart$domain="labs"
    chartMeta <- makeMeta(list(testChart)) %>% select(-source)
    expect_equal(chartMeta, rbind(safetyCharts::meta_hepExplorer, safetyCharts::meta_labs))
})

test_that("metadata for multiple charts loads when found",{
    testCharts <-list(
        list(name='chart1', domain=c('aes','dm'),package='safetyCharts'),
        list(name='chart2', domain=c('labs','dm')) #package defaults to safetyCharts if not specified
    )
    chartMeta <- makeMeta(testCharts) %>% select(-source)
    expect_equal(chartMeta, rbind(safetyCharts::meta_aes, safetyCharts::meta_dm, safetyCharts::meta_labs))
})

