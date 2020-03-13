# prep metadata for each domain
# Note: expected to be run from the root pacakge directory
library(tidyverse)
library(usethis)

setwd("data-raw") 

#get list of domains (ignore /template)
domains <- list.dirs(path = "meta", full.names = FALSE, recursive = FALSE)
domains <- domains[!str_detect(domains,"template")]

#get types of metadata
metaTypes <- c("charts","settings","standards")

# create stacked metadata files
setwd("meta")
source("prepSettingsMetadata.R")
for(meta in metaTypes){
    print(paste0(meta," stacking"))
    #Create shell from meta/templates
    allMetadata <- data.frame()
    for(domain in domains){
        setwd(domain)
        if(meta == "settings"){
             domainMetadata<-prepSettingsMetadata(domain)
        }else{
            file <- paste0(meta,"Metadata.csv")
            domainMetadata<-read_csv(file)
            domainMetadata$domain <- domain
        }
        allMetadata<-bind_rows(allMetadata,domainMetadata)
        setwd("..") #/meta
    }
    dfName <- paste0(meta,"Metadata")
    assign(dfName,allMetadata)
}
setwd("..") #/data-raw

metadata<-list(settings=settingsMetadata, charts=chartsMetadata, standards=standardsMetadata)
usethis::use_data(metadata, overwrite = TRUE)

#usethis::use_data(standardsMetadata, overwrite = TRUE)
#usethis::use_data(chartsMetadata, overwrite = TRUE)
#usethis::use_data(settingsMetadata, overwrite = TRUE)

#create sample data sets
setwd("sample")

aes<-read_csv("aes.csv")
usethis::use_data(aes, overwrite = TRUE)

labs<-read_csv("labs.csv")
usethis::use_data(labs, overwrite = TRUE)

setwd("../..") # pacakge dir
