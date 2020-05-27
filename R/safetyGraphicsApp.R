#' Run the interactive safety graphics builder
#'
#' @param maxFileSize maximum file size in MB allowed for file upload
#' @param meta data frame containing the metadata for use in the app. See the preloaded file (\code{?metadata}) for more data specifications and details. Defaults to \code{safetygraphics::metadata}. 
#' @param domainData list of data.frames to be loaded in to the app - 
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
"

  app <- shinyApp(
    ui =  fluidPage(
      tags$head(
        tags$style(HTML(css_text))
      ),
      h2("Data Mapping"),
      mappingTabUI("ex1", meta, domainData, mapping, standards),
      tableOutput("ex1Out")
    ),
    server = function(input, output) {
      ex1<-callModule(mappingTab, "ex1", meta, domainData)
      output$ex1Out<-renderTable(ex1())    
      }
  )
  runApp(app, launch.browser = TRUE)
}
