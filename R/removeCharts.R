#' Remove a chart from the safetyGraphics shiny app
#'
#' This function updates settings objects to remove chart from the safetyGraphics shiny app
#'
#' This function makes it easy for remove a chart from the safetyGraphics shiny app by making updates to the underlying metadata used by the package. 
#'
#' @param settings_location path where the custom settings will be loaded/saved. If metadata is not found in that location, it will be read from the package (e.g. safetyGraphics::settingsMetadata), and then written to the specified location once the chart has been removed
#' @param charts Name of the chart(s) to remove - one word, all lower case
#'
#' @export

removeCharts <- function(charts, settingsLocation=getwd()){
  chartsMetaPath <- paste(settingsLocation,"chartsMetadata.Rds",sep="/")
  if(file.exists(chartsMetaPath)){
    chartsMeta <- readRDS(chartsMetaPath)
  }else{
    chartsMeta <- safetyGraphics::chartsMetadata
  }
  
  #delete rows for the specified chart(s)
  chartsMeta <- chartsMeta %>% filter(!(.data$chart %in% !!charts))
 
  #save updated metadata file
  saveRDS(chartsMeta, chartsMetaPath)
}