library(usethis)
library(dplyr)
library(Hmisc)

### Prepare settingsMetadata and save to /data ###

#merge defaults on to settingsMetadata
settingsMetadata <- read.csv("data-raw/aes/settingsMetadata.csv", stringsAsFactors = FALSE)
settingsMetadata$field_column_key <- ""
defaults <- readRDS("data-raw/aes/settingsMetadataDefaults.Rds")
settingsMetadata <- dplyr::full_join(settingsMetadata, defaults, by="text_key")

#merge chart info on to settingsMetadata_defaults
charts<-read.csv("data-raw/aes/settingsMetadataCharts.csv", stringsAsFactors = FALSE)%>%
rename_at(-1, ~paste0("chart_",.))
settingsMetadata <- dplyr::full_join(settingsMetadata, charts, by="text_key")

#Save merged settingsMetadata to /data
usethis::use_data(settingsMetadata, overwrite = TRUE)

### Save standards info to /data ###
# This is merged to settingsMetadata in generateSettings())
standardsMetadata <- read.csv("data-raw/aes/standardsMetadata.csv", stringsAsFactors = FALSE)
usethis::use_data(standardsMetadata, overwrite = TRUE)

### Save chart info to /data ###
# This is used to provide chart info and links in the app
chartsMetadata <- read.csv("data-raw/aes/chartsMetadata.csv", stringsAsFactors = FALSE)
usethis::use_data(chartsMetadata, overwrite = TRUE)

### Save sample data set to /data ###
# This is loaded by default in the app and used for testing
ae <- read.csv("data-raw/ae.csv", stringsAsFactors = FALSE)
usethis::use_data(ae, overwrite = TRUE)
