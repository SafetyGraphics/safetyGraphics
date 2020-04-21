# Note: expected to be run from the root pacakge directory
library(tidyverse)
library(usethis)

setwd("data-raw") 
usethis::use_data(settingsMetadata, overwrite = TRUE)

#create sample data sets
meta<-read_csv("meta.csv")
usethis::use_data(meta, overwrite = TRUE)

setwd("sample")
aes<-read_csv("aes.csv")
usethis::use_data(aes, overwrite = TRUE)

labs<-read_csv("labs.csv")
usethis::use_data(labs, overwrite = TRUE)

setwd("../..") # pacakge dir
