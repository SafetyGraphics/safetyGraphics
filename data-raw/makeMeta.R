# Note: expected to be run from the root package directory
library(tidyverse)
library(usethis)

#Copy metadata to /data
meta<-read_csv("data-raw/meta.csv")
usethis::use_data(meta, overwrite = TRUE)
