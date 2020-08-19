#' Run the interactive safety graphics builder
#'
#' @param maxFileSize maximum file size in MB allowed for file upload
#' @param meta data frame containing the metadata for use in the app. See the preloaded file (\code{?safetyGraphics::meta}) for more data specifications and details. Defaults to \code{safetyGraphics::meta}. 
#' @param domainData mamed list of data.frames to be loaded in to the app.
#' @param mapping data.frame specifying the initial values for each data mapping. If no mapping is provided, the app will attempt to generate one via \code{detectStandard()}
#'
#' @importFrom shiny runApp shinyOptions
#' @import shinyjs
#' @import dplyr
#' @import DT
#' @importFrom purrr map keep
#' @importFrom magrittr "%>%"
#' @import rmarkdown
#' @importFrom haven read_sas
#' @importFrom shinyWidgets materialSwitch
#' @importFrom tidyr gather
#'
#' @export
#'
safetyGraphicsApp <- function(
  maxFileSize = NULL, 
  meta = safetyGraphics::meta, 
  domainData=list(labs=safetyGraphics::labs, aes=safetyGraphics::aes),
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
  
  # attempt to detect the data standard and generate a mapping if none is provided by the user
  if(is.null(mapping)){
    mapping_list <- standards %>% lapply(function(standard){
      return(standard[["mapping"]])
    })
    mapping<-bind_rows(mapping_list, .id = "domain")
  }
  
  # Run a Shiny app object
  
  css_text<-"
.selectize-input.not-full{
  border-color:red;
}

.selectize-input.full{
  border-color:green;
}


.field-wrap{
  padding-left:1em;
}

.mapping-domain{
padding:0.5em;
border:1px solid black;
border-radius:0.2em;
margin-bottom:1em;
max-width:45%;
}

table.dataTable tr > td:last-of-type, table.dataTable tr > th:last-of-type {
  border-left:2px solid black;
  background:#d0d1e6;
}
"

  app <- shinyApp(
    ui =  tagList(
      useShinyjs(),
      #add_busy_spinner(spin = "fading-circle", position = "bottom-left", timeout=3000),
      tags$head(
        tags$style(HTML(css_text)),
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
        tabPanel("Charts",  icon=icon("chart-bar")),
        tabPanel("Reports", icon=icon("file-alt")),
        navbarMenu('Config',icon=icon("cog"),
          tabPanel(title = "Metadata", settingsMappingUI("metaSettings")),
          tabPanel(title = "Domain Data", settingsDataUI("dataSettings", domains=domainData))
        )
      )
    ),
    server = function(input, output) {
      current_mapping<-callModule(mappingTab, "mapping", meta, domainData)
      callModule(settingsData, "dataSettings", domains = domainData)
      callModule(settingsMapping, "metaSettings", metaIn=meta, mapping=current_mapping())
      callModule(homeTab, "home")
    }
    
  )
  runApp(app, launch.browser = TRUE)
}
