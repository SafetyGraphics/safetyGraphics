library(usethis)

ablbc <- read.csv("data-raw/adlbc.csv")
usethis::use_data(adlbc, overwrite = TRUE)

settingsMetadata <- read.csv("data-raw/settingsMetadata.csv")

#merge defaults on to settingsMetadata
defaults <- readRDS("data-raw/defaults.rda") #why is this not working... grrrr 

# from https://gist.github.com/aammd/9ae2f5cce9afd799bafb
defaults_df <- list(default = defaults)
class(defaults_df) <- c("tbl_df", "data.frame")
attr(defaults_df, "row.names") <- .set_row_names(length(defaults))
if (!is.null(names(defaults))) {
  defaults_df$name <- names(defaults)
}

fullSettingsMetadata <- merge(settingsMetadata, defaults_df, by.x=c("text_key"),
                              by.y=c("name"))

usethis::use_data(fullSettingsMetadata, overwrite = TRUE)


standardsMetadata <- read.csv("data-raw/standardsMetadata.csv")
usethis::use_data(standardsMetadata, overwrite = TRUE)
