context("Tests for the getChartStatus() function")
library(safetyGraphics)
library(safetyCharts)

# Functional Specification
# [*] chart with no data spec throws error
# [*] status returned correctly for valid chart
# [*] status returned correctly when mapping values for a column are '' and NA
# [*] status returned correctly when dataSpec is not found in mapping

test_that("chart with no data spec throws error",{
    expect_error(chart=list(domains=c("ae","dm")))
})

test_that("status returned correctly for valid chart",{
    ae_chart <- list(
        domains=c("aes","dm"),
        dataSpec=list(
            aes=c("id_col","custom_col"),
            dm=c("id_col","test_col")
        )
    )

    mapping <- data.frame(
        domain=c("aes","aes","dm","dm"),
        text_key=c("id_col","custom_col","id_col","test_col"),
        current=c("myID","AEcol","myID","dmCol")
    )

    status<-getChartStatus(chart=ae_chart, mapping=mapping)
    expect_true(status$status)
    expect_true(status$domains$aes)
    expect_true(status$domains$dm)
    expect_true(status$columns$aes$id_col)
    expect_true(status$columns$aes$custom_col)
    expect_true(status$columns$dm$id_col)
    expect_true(status$columns$dm$test_col)
})


test_that("status returned correctly for invalid chart",{
    ae_chart <- list(
        domains=c("aes","dm"),
        dataSpec=list(
            aes=c("id_col","custom_col"),
            dm=c("id_col","test_col")
        )
    )

    mapping <- data.frame(
        domain=c("aes","aes","dm","dm"),
        text_key=c("id_col","custom_col","id_col","test_col"),
        current=c(NA,"","myID","dmCol")
    )

    status<-getChartStatus(chart=ae_chart, mapping=mapping)
    expect_false(status$status)
    expect_false(status$domains$aes)
    expect_true(status$domains$dm)
    expect_false(status$columns$aes$id_col)
    expect_false(status$columns$aes$custom_col)
    expect_true(status$columns$dm$id_col)
    expect_true(status$columns$dm$test_col)
})


test_that("status returned correctly for invalid chart",{
    ae_chart <- list(
        domains=c("aes","dm"),
        dataSpec=list(
            aes=c("id_col","custom_col","another_col"),
            dm=c("id_col","test_col")
        )
    )

    mapping <- data.frame(
        domain=c("aes","aes","dm","dm"),
        text_key=c("id_col","custom_col","id_col","test_col"),
        current=c("myID","aesCol","myID","dmCol")
    )
    ml<-generateMappingList(settingsDF=mapping, domain='aes')
    expect_false(hasName(ml,"another_col"))
    status<-getChartStatus(chart=ae_chart, mapping=mapping)
    expect_false(status$status)
    expect_false(status$domains$aes)
    expect_true(status$domains$dm)
    expect_true(status$columns$aes$id_col)
    expect_true(status$columns$aes$custom_col)
    expect_false(status$columns$aes$another_col)
    expect_true(status$columns$dm$id_col)
    expect_true(status$columns$dm$test_col)
})
