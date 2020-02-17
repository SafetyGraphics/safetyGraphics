library(usethis)
library(dplyr)
library(Hmisc)

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
standardsMetadata <- read.csv("data-raw/standardsMetadata.csv", stringsAsFactors = FALSE)
usethis::use_data(standardsMetadata, overwrite = TRUE)

### Save chart info to /data ###
# This is used to provide chart info and links in the app
chartsMetadata <- read.csv("data-raw/chartsMetadata.csv", stringsAsFactors = FALSE)
usethis::use_data(chartsMetadata, overwrite = TRUE)

### Save sample data set to /data ###
# This is loaded by default in the app and used for testing
adlbc <- read.csv("data-raw/adlbc.csv", stringsAsFactors = FALSE)

### Add labels to sample data set
adlbc_labels <- c("STUDYID" = "Study Identifier", 
                  "SUBJID" = "Subject Identifier for the Study",
                  "USUBJID" = "Unique Subject Identifier",
                  "TRTP" = "Planned Treatment",
                  "TRTPN" = "Planned Treatment (N)",
                  "TRTA" = "Actual Treatment",
                  "TRTAN" = "Actual Treatment (N)",
                  "TRTSDT" = "Date of First Exposure to Treatment",
                  "TRTEDT" = "Date of Last Exposure to Treatment",
                  "AGE" = "Age",
                  "AGEGR1" = "Age Group",
                  "AGEGR1N" = "Age Group (N)",
                  "RACE" = "Race",
                  "RACEN" = "Race (N)",
                  "SEX" = "Sex",
                  "COMP24FL" = "Completers Flag",
                  "DSRAEFL" = "Discontinued due to AE?",
                  "SAFFL" = "Safety Population Flag",
                  "AVISIT" = "Analysis Visit",
                  "AVISITN" = "Analysis Visit (N)",
                  "ADY" = "Analysis Relative Day",
                  "ADT" = "Analysis Relative Date",
                  "VISIT" = "Visit",
                  "VISITNUM" = "Visit (N)",
                  "PARAM" = "Parameter",
                  "PARAMCD" = "Parameter Code",
                  "PARAMN" = "Parameter (N)",
                  "PARCAT1" = "Parameter Category",
                  "AVAL" = "Analysis Value",
                  "BASE" = "Baseline Value",
                  "CHG" = "Change from Baseline",
                  "A1LO" = "Analysis Normal Range Lower Limit",
                  "A1HI" = "Analysis Normal Range Upper Limit",
                  "R2A1LO" = "Ratio to Low limit of Analysis Range",
                  "R2A1HI" = "Ratio to High limit of Analysis Range",
                  "BR2A1LO" = "Base Ratio to Analysis Range 1 Lower Lim",
                  "BR2A1HI" = "Base Ratio to Analysis Range 1 Upper Lim",
                  "ANL01FL" = "Analysis Population Flag",
                  "ALBTRVAL" = "Amount Threshold Range",
                  "ANRIND" = "Analysis Reference Range Indicator",
                  "BNRIND" = "Baseline Reference Range Indicator",
                  "ABLFL" = "Baseline Record Flag",
                  "AENTMTFL" = "Analysis End Date Flag",
                  "LBSEQ" = "Lab Sequence Number",
                  "LBNRIND" = "Reference Range Indicator",
                  "LBSTRESN" = "Numeric Result/Finding in Std Units")

label(adlbc) = as.list(adlbc_labels[match(names(adlbc), names(adlbc_labels))])

usethis::use_data(adlbc, overwrite = TRUE)
