library(usethis)

ablbc <- read.csv("data-raw/adlbc.csv")
usethis::use_data(adlbc, overwrite = TRUE)

settingsMetadata <- read.csv("data-raw/settingsMetadata.csv")

#merge defaults on to settingsMetadata
defaults <- readRDS(file="data/defaults.rda") #why is this not working... grrrr 

fullSettingsMetadata <- merge(settingsMetadata, defaults_df, by="text_key")

usethis::use_data(fullSettingsMetadata, overwrite = TRUE)


standardsMetadata <- read.csv("data-raw/standardsMetadata.csv")
usethis::use_data(standardsMetadata, overwrite = TRUE)
