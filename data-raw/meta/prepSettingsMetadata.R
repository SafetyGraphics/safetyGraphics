library(dplyr)

### Prepare settingsMetadata and save to /data ###
### working directory should be set to /data-raw/meta/{domain}
prepSettingsMetadata <- function(domain){
    #load core settings metadata
    settingsMetadata <- read.csv("settingsMetadata.csv", stringsAsFactors = FALSE)

    #add the domain
    settingsMetadata$domain <- domain

    #merge defaults on to settingsMetadata
    source('generateSettingsMetadataDefaults.R')
    defaults<-generateSettingsMetadataDefaults()
    settingsMetadata <- dplyr::full_join(settingsMetadata, defaults, by="text_key")

    #merge chart info on to settingsMetadata_defaults
    charts<-read.csv("settingsMetadataCharts.csv", stringsAsFactors = FALSE)%>%
    rename_at(-1, ~paste0("chart_",.))
    settingsMetadata <- dplyr::full_join(settingsMetadata, charts, by="text_key")
    
    return(settingsMetadata)
}

