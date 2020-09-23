# Note: expected to be run from the root package directory
library(tidyverse)
library(usethis)

#Copy metadata to /data
meta<-read_csv("data-raw/meta.csv")
usethis::use_data(meta, overwrite = TRUE)

#Copy charts list to /data
charts<-read_csv("data-raw/charts.csv")
usethis::use_data(charts, overwrite = TRUE)

#copy sample data sets to /data
aes<-read_csv("data-raw/aes.csv")
usethis::use_data(aes, overwrite = TRUE)

labs<-read_csv("data-raw/labs.csv")
usethis::use_data(labs, overwrite = TRUE)

