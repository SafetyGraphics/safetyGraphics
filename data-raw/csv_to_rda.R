library(usethis)

ablbc <- read.csv("data-raw/adlbc.csv")
usethis::use_data(adlbc, overwrite = TRUE)

settingsMetadata <- read.csv("data-raw/settingsMetadata.csv")
usethis::use_data(settingsMetadata, overwrite = TRUE)

standardsMetadata <- read.csv("data-raw/standardsMetadata.csv")
usethis::use_data(standardsMetadata, overwrite = TRUE)