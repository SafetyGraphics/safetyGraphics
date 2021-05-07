#' Run the interactive safety graphics app
#'
#' @param meta data frame containing the metadata for use in the app. See the preloaded file (\code{?safetyGraphics::meta}) for more data specifications and details. Defaults to \code{safetyGraphics::meta}. 
#' @param domainData named list of data.frames to be loaded in to the app. Sample AdAM data from the safetyData package used by default
#' @param charts data.frame of charts to be used in the app
#' @param mapping data.frame specifying the initial values for each data mapping. If no mapping is provided, the app will attempt to generate one via \code{detectStandard()}
#' @param filterDomain domain used for the data/filter tab. Demographics ("`dm`") is used by default. Using a domain that is not one record per participant is not recommended. 
#' @param chartSettingsPaths path(s) where customization functions are saved relative to your working directory. All charts can have itialization (e.g. myChart_Init.R) and static charts can have charting functions (e.g. myGraphic_Chart.R).   All R files in this folder are sourced and files with the correct naming convention are linked to the chart. See the Custom Charts vignette for more details. 
#'
#' @import shiny
#' @import safetyData
#' 
#' @export

safetyGraphicsApp <- function(
  domainData=list(
    labs=safetyData::adam_adlbc, 
    aes=safetyData::adam_adae, 
    dm=safetyData::adam_adsl
  ),
  meta = safetyGraphics::meta, 
  charts=NULL,
  mapping=NULL,
  filterDomain="dm",
  chartSettingsPaths = NULL
){
  config <- app_startup(domainData, meta, charts, mapping, filterDomain, chartSettingsPaths)

  app <- shinyApp(
    ui =  app_ui(config$meta, config$domainData, config$mapping, config$standards),
    server = app_server(config$meta, config$mapping, config$domainData, config$charts, config$filterDomain)
  )
  runApp(app, launch.browser = TRUE)
}
