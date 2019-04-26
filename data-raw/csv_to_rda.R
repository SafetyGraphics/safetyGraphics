library(usethis)
library(dplyr)

### Prepare settingsMetadata and save to /data ###

#merge defaults on to settingsMetadata
settingsMetadata <- read.csv("data-raw/settingsMetadata.csv", stringsAsFactors = FALSE)
defaults <- readRDS("data-raw/settingsMetadataDefaults.Rds")
settingsMetadata <- dplyr::full_join(settingsMetadata, defaults, by="text_key")

#merge chart info on to settingsMetadata_defaults
charts<-read.csv("data-raw/settingsMetadataCharts.csv", stringsAsFactors = FALSE)%>%
rename_at(-1, ~paste0("chart_",.))
settingsMetadata <- dplyr::full_join(settingsMetadata, charts, by="text_key")

#Save merged settingsMetadata to /data
usethis::use_data(settingsMetadata, overwrite = TRUE)

### Save standards info to /data ###
# This is merged to settingsMetadata in generateSettings())
standardsMetadata <- read.csv("data-raw/standardsMetadata.csv")
usethis::use_data(standardsMetadata, overwrite = TRUE)

### Save chart info to /data ###
# This is used to provide chart info and links in the app
chartsMetadata <- read.csv("data-raw/chartsMetadata.csv")
usethis::use_data(chartsMetadata, overwrite = TRUE)

### Save sample data set to /data ###
# This is loaded by default in the app and used for testing
adlbc <- read.csv("data-raw/adlbc.csv")
usethis::use_data(adlbc, overwrite = TRUE)
