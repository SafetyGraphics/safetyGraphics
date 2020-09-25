#' Run the interactive safety graphics app
#'
#' @param maxFileSize maximum file size in MB allowed for file upload
#' @param meta data frame containing the metadata for use in the app. See the preloaded file (\code{?safetyGraphics::meta}) for more data specifications and details. Defaults to \code{safetyGraphics::meta}. 
#' @param domainData named list of data.frames to be loaded in to the app.
#' @param charts data.frame of charts to be used in the app
#' @param mapping data.frame specifying the initial values for each data mapping. If no mapping is provided, the app will attempt to generate one via \code{detectStandard()}
#' @param settingsPath path where customization functions are saved relative to your working directory. All charts can have itialization (e.g. [chart]Init.R) and static charts can have charting functions (e.g. [chart]Chart.R).   All R files in this folder are sourced and files with the correct naming convention are linked to the chart. See the Custom Charts vignette for more details. 
#'
#' @import shiny
#' @importFrom shinyjs useShinyjs
#' @importFrom DT DTOutput renderDT
#' @importFrom purrr map keep transpose
#' @importFrom magrittr "%>%"
#' @importFrom haven read_sas
#' @importFrom shinyWidgets materialSwitch
#' @importFrom tidyr gather
#'
#' @export

safetyGraphicsApp <- function(
  maxFileSize = NULL, 
  meta = safetyGraphics::meta, 
  domainData=list(labs=safetyGraphics::labs, aes=safetyGraphics::aes),
  charts=safetyGraphics::charts,
  mapping=NULL,
  chartSettingsPaths = NULL
){

  #increase maximum file upload limit
  if(!is.null(maxFileSize)){
    options(shiny.maxRequestSize=(maxFileSize*1024^2))
  }

  # load files from default location in the package (for default charts) 
  defaultPath <- paste(.libPaths(),'safetygraphics','chartSettings', sep="/")
  if(!is.null(chartSettingsPaths)){
    chartSettingsPaths <- paste(getwd(),chartSettingsPaths,sep="/")
  }
  chartSettingPaths <- c(defaultPath, chartSettingsPaths) 
  
  # get the data standards
  standards <- names(domainData) %>% lapply(function(domain){
    return(detectStandard(domain=domain, data = domainData[[domain]], meta=meta))
  })
  names(standards)<-names(domainData)
  
  # attempt to generate a mapping if none is provided by the user
  if(is.null(mapping)){
    mapping_list <- standards %>% lapply(function(standard){
      return(standard[["mapping"]])
    })
    mapping<-bind_rows(mapping_list, .id = "domain")
  }

  #convert charts data frame to a list and bind functions
  chartsList <- setNames(transpose(charts), charts$chart)
  chartsList <- getChartFunctions(chartsList, chartSettingsPaths)
   
  app <- shinyApp(
    ui =  app_ui(meta, domainData, mapping, standards),
    server = function(input, output) {

      #Initialize modules
      current_mapping<-callModule(mappingTab, "mapping", meta, domainData)
      callModule(settingsData, "dataSettings", domains = domainData)
      callModule(settingsMapping, "metaSettings", metaIn=meta, mapping=current_mapping)
      callModule(homeTab, "home")
      
      #Initialize Chart UI - Adds subtabs to chart menu and initializes chart UIs
      chartsList %>% map(~chartsNav(chart=.x$chart, label=.x$label, type=.x$type, package=.x$package))

      #Initialize Chart Servers
      chartsList %>% map(
        ~callModule(
          chartsTab,
          .x$chart,
          chart=.x$chart,
          chartFunction=.x$chartFunction,
          initFunction=.x$initFunction,
          type=.x$type,
          package=.x$package,
          domain=.x$domain,
          data=domainData,
          mapping=current_mapping    
        )
      )
    }
  )
  runApp(app, launch.browser = TRUE)
}
