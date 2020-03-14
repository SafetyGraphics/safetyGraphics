#' Remove a setting from the safetyGraphics shiny app
#'
#' This function updates settings objects to remove a setting parameter from the safetyGraphics shiny app
#'
#' This function makes it easy for remove a setting from the safetyGraphics shiny app by making updates to the underlying metadata used by the package. 
#'
#' @param domain domain of the chart
#' @param text_keys Text keys indicating the setting names to be removed.
#' @param metadataLocation Path where the custom settings will be loaded/saved. 
#'
#' @export

removeSettings <- function(domain, text_keys, settingsLocation=getwd()){
  # load metadata
  metadataPath <- paste(settingsLocation,"metadata.Rds",sep="/")
  metadata<- getMetadata(path=metadataPath)
  
  #delete rows for the specified chart
  metadata$settings <- metadata$settings %>%
    filter(!(.data$text_key %in% !!text_keys & .data$domain== !!domain))
  
  #save updated metadata file
  saveRDS(metadata, metadataPath)
}