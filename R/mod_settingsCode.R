#' UI for the settings page
#'
#' @param id module ID
#'  
#' @export

settingsCodeUI <- function(id){
  ns <- NS(id)
  list(
    rclipboard::rclipboardSetup(),
    br(),
    p(
      icon("info-circle"),
      HTML("Code to Restart app with current settings is shown below. Save <code>mapping.yaml</code> to your working directory, and then run <code>initApp.R</code>."),
      class="info"
    ),
    h4(
      "mapping.yaml  ",
      uiOutput(ns("yamlCopy"), style="display:inline-block"),
      downloadButton(ns("yamlDownload"), "Download", style="display:inline-block")
    ),
    verbatimTextOutput(ns("yamlMapping")),
    h4(
      "initApp.R  ",
      uiOutput(ns("initCopy"), style="display:inline-block"),
      downloadButton(ns("initDownload"), "Download", style="display:inline-block")
    ),      
    verbatimTextOutput(ns("initCode"))
  )
  
}


#' @title  Server for the setting code page
#'
#' @param input Shiny input object
#' @param output  Shiny output object
#' @param session Shiny session object
#' @param domains domains
#' @param metadata metadata
#' @param mapping mapping
#' @param charts charts
#' 
#' @export

settingsCode <- function(input, output, session, mapping){
  if(missing(mapping)){
    mapping<-reactive({data.frame(domain=character(0),text_id=character(0),current=character(0))})
  }
  
  # mapping.yaml for current mapping
  yamlString <- reactive({
    as.yaml(generateMappingList(mapping()))
  })
  output$yamlMapping <- renderText({yamlString()})
  output$yamlCopy <- renderUI({
    rclipboard::rclipButton("clipbtn", "Copy to Clipboard", yamlString(), icon("clipboard"))
  })
  output$yamlDownload <- downloadHandler(
    filename = "mapping.yaml",
    content = function(file) {
      writeLines(yamlString(), file)
    }
  )

  # initApp.R
  initCode<- paste(
    "library(safetyGraphics)",
    "#Initialize safetyGraphics App",
    "#Load mapping",
    "#!!!!-- Update path if mapping.yaml isn't saved in working directory --!!!! ",
    "mapping <- read_yaml('mapping.yaml')", 
    "",
    "#Load Data",
    "#!!!!-- Demo data from safetyData should be updated by user --!!!!",
    "dataList <- list(",
    "  labs=safetyData::adam_adlbc,", 
    "  aes=safetyData::adam_adae,",
    "  dm=safetyData::adam_adsl",
    ")",
    "#Initialize app",
    "safetyGraphicsApp(data=dataList, mapping=mapping)",
    sep="\n"
  ) 
  output$initCode <- renderText(initCode)
  output$initCopy <- renderUI({
    rclipboard::rclipButton("clipbtn2", "Copy to Clipboard", initCode, icon("clipboard"))
  })
  output$yamlDownload <- downloadHandler(
    filename = "initApp.R",
    content = function(file) {
      writeLines(initCode, file)
    }
  )
}