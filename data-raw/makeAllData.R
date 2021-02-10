# Note: expected to be run from the root package directory
library(tidyverse)
library(usethis)

#Copy metadata to /data
meta<-read_csv("data-raw/meta.csv")
usethis::use_data(meta, overwrite = TRUE)

#copy sample data sets to /data
aes<-read_csv("data-raw/aes.csv")
usethis::use_data(aes, overwrite = TRUE)

labs<-read_csv("data-raw/labs.csv")
usethis::use_data(labs, overwrite = TRUE)

dm<-read_csv("data-raw/dm.csv")
usethis::use_data(dm, overwrite = TRUE)