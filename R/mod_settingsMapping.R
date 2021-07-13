#' @title  Settings view of Metadata/Mapping - UI
#' @description  UI that displays the data mapping metadata. 
#'
#' @param id module id
#' 
#' @import rclipboard
#' 
#' @export

settingsMappingUI <- function(id){
  ns <- NS(id)
  tabsetPanel(
    tabPanel("Summary",
      tagList(
        rclipboard::rclipboardSetup(),
        DT::DTOutput(ns("metaTable"))
      )      
    ),
    tabPanel(
      "Code",
      h3("Code to Reproduce Current Mapping"),
      HTML("Save <code>mapping.yaml</code> to your working directory, and then run <code>initApp.R</code>."),
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
      verbatimTextOutput(ns("initCode")),
    ),
    type="pills"
  )
}  

#' @title  Settings view of Metadata/Mapping - server
#' @description  server for the display of the data mapping metadata. 
#'
#' @param input Shiny input object
#' @param output  Shiny output object
#' @param session Shiny session object
#' @param metadata Data mapping metadata used for initial loading of app
#' @param mapping reactive data frame representing the current metadata mapping. columns = "domain", "text_id" and "current"
#'
#' @import rclipboard
#' @import yaml
#' 
#' @export

settingsMapping <- function(input, output, session, metadata, mapping){
  ns <- session$ns

  #use an empty mapping if none is provided
  if(missing(mapping)){
    mapping<-reactive({data.frame(domain=character(0),text_id=character(0),current=character(0))})
  }
  
  ##########################################################################
  # Create reactive containing default or custom data mappings ("metadata")
  #########################################################################

  metadata_mapping <- reactive(
      metadata %>% left_join(mapping())  
  )

  output$metaTable <- renderDT({
      DT::datatable(
          metadata_mapping(), 
          rownames = FALSE,
          options = list(paging=FALSE, ordering=FALSE),
          class="compact metatable"
      )
  })

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

  return(metadata)
}