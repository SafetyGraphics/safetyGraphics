#' Run the interactive safety graphics app
#'
#' @param maxFileSize maximum file size in MB allowed for file upload
#' @param meta data frame containing the metadata for use in the app. See the preloaded file (\code{?safetyGraphics::meta}) for more data specifications and details. Defaults to \code{safetyGraphics::meta}. 
#' @param domainData named list of data.frames to be loaded in to the app.
#' @param charts list of charts to be included in the app. 
#' @param mapping data.frame specifying the initial values for each data mapping. If no mapping is provided, the app will attempt to generate one via \code{detectStandard()}
#'
#' @import shiny
#' @importFrom shinyjs useShinyjs
#' @importFrom DT DTOutput renderDT
#' @importFrom purrr map keep
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
  charts=list("Test1","Test2"),
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
  
  app <- shinyApp(
    ui =  tagList(
      useShinyjs(),
      #add_busy_spinner(spin = "fading-circle", position = "bottom-left", timeout=3000),
       tags$head(
        tags$style(HTML(readLines("inst/safetyGraphics_app/www/index.css"))),
        tags$link(
          rel = "stylesheet",
          type = "text/css",
          href = "https://use.fontawesome.com/releases/v5.8.1/css/all.css"
        )
      ),
      navbarPage(
        "safetyGraphics",
        id="nav_id",
        tabPanel("Home", icon=icon("home"),homeTabUI("home")),
        tabPanel("Mapping", icon=icon("map"), mappingTabUI("mapping", meta, domainData, mapping, standards)),
        navbarMenu('Charts', icon=icon("chart-bar")),
        tabPanel("Reports", icon=icon("file-alt")),
        navbarMenu('Config',icon=icon("cog"),
          tabPanel(title = "Metadata", settingsMappingUI("metaSettings")),
          tabPanel(title = "Domain Data", settingsDataUI("dataSettings", domains=domainData))
        )
      )
    ),
    server = function(input, output) {
      #initialize the chart tabs in the nav
      for(chart in charts){
        appendTab(
          inputId = "nav_id",
          tab = tabPanel(title = chart, value = chart, div(paste0(chart," is coming soon"))),
          menuName = "Charts"
        )    
      }
      
     #Initialize modules
     current_mapping<-callModule(mappingTab, "mapping", meta, domainData)
     callModule(chartsTab, "charts", charts=charts)
     callModule(settingsData, "dataSettings", domains = domainData)
     callModule(settingsMapping, "metaSettings", metaIn=meta, mapping=current_mapping)
     callModule(homeTab, "home")
    }
    
  )
  runApp(app, launch.browser = TRUE)
}
