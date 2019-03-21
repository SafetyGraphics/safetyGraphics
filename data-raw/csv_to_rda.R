library(usethis)
library(dplyr)

ablbc <- read.csv("data-raw/adlbc.csv")
usethis::use_data(adlbc, overwrite = TRUE)

partialSettingsMetadata <- read.csv("data-raw/settingsMetadata.csv", stringsAsFactors = FALSE)

#merge defaults on to settingsMetadata
defaults <- readRDS("data-raw/defaults.Rds") #why is this not working... grrrr 


settingsMetadata <- dplyr::full_join(partialSettingsMetadata, defaults, by="text_key")
#settingsMetadata <- merge(partialSettingsMetadata, defaults, by="text_key")

usethis::use_data(settingsMetadata, overwrite = TRUE)

standardsMetadata <- read.csv("data-raw/standardsMetadata.csv")
usethis::use_data(standardsMetadata, overwrite = TRUE)
