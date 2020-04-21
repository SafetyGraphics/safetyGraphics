# Note: expected to be run from the root pacakge directory
library(tidyverse)
library(usethis)


#Copy metadata to /data
setwd("data-raw") 
meta<-read_csv("meta.csv")
usethis::use_data(meta, overwrite = TRUE)

#copy sample data sets to /data
setwd("sample")
aes<-read_csv("aes.csv")
usethis::use_data(aes, overwrite = TRUE)

labs<-read_csv("labs.csv")
usethis::use_data(labs, overwrite = TRUE)

setwd("../..") # pacakge dir
