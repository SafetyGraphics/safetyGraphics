#' Run the interactive safety graphics app
#'
#' @param maxFileSize maximum file size in MB allowed for file upload
#' @param meta data frame containing the metadata for use in the app. See the preloaded file (\code{?safetyGraphics::meta}) for more data specifications and details. Defaults to \code{safetyGraphics::meta}. 
#' @param domainData named list of data.frames to be loaded in to the app.
#' @param charts data.frame of charts to be used in the app
#' @param mapping data.frame specifying the initial values for each data mapping. If no mapping is provided, the app will attempt to generate one via \code{detectStandard()}
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
  mapping=NULL
){

  #increase maximum file upload limit
  if(!is.null(maxFileSize)){
    options(shiny.maxRequestSize=(maxFileSize*1024^2))
  }
  
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

  chartsList <- setNames(transpose(charts), charts$chart)
  
  app <- shinyApp(
    ui =  app_ui(meta, domainData, mapping, standards),
    server = function(input, output) {

      #Initialize modules
      current_mapping<-callModule(mappingTab, "mapping", meta, domainData)
      current_data<-callModule(settingsData, "dataSettings", domains = domainData)
      callModule(settingsMapping, "metaSettings", metaIn=meta, mapping=current_mapping)
      callModule(homeTab, "home")
      
      chartsList %>% lapply(chartsNav, chart, label, data, type)

      # charts %>% invoke_rows(
      #   callModule(
      #     chartsTab,
      #     chart,
      #     chart=chart,
      #     #chartFunction=chart$chartFunction,
      #     #initFunction=chart$initFunction,
      #     type=type,
      #     package=package,
      #     domain=domain,
      #     data=current_data,
      #     mapping=current_mapping    
      #   )
      # )
    }
  )
  runApp(app, launch.browser = TRUE)
}
