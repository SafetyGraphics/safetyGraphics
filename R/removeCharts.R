#' Remove a chart from the safetyGraphics shiny app
#'
#' This function updates settings objects to remove chart from the safetyGraphics shiny app
#'
#' This function makes it easy for remove a chart from the safetyGraphics shiny app by making updates to the underlying metadata used by the package. 
#'
#' @param domain domain of the chart
#' @param charts Name of the chart(s) to remove - one word, all lower case
#' @param metadataLocation Path where the custom settings will be loaded/saved. 
#'
#' @export

removeCharts <- function(domain, charts, metadataLocation=getwd()){
  # load metadata
  metadataPath <- paste(settingsLocation,"metadata.Rds",sep="/")
  metadata<- getMetadata(path=metadataPath)
  
  #delete rows for the specified chart(s)
  metadata$charts <- metadata$charts %>% 
    filter(!(.data$chart %in% !!charts & .data$domain== !!domain))
 
  #save updated metadata file
  saveRDS(metadata, metadataPath)
}