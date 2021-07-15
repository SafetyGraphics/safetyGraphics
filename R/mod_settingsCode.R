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
    # Info
    p(
      icon("info-circle"),
      HTML("Code and metadata objects to restart app with current settings are provided in a file zip below. Stand-alone `charts.yaml` and `mapping.yaml` files are also provided for advanced users."),
      class="info"
    ),

    # app.zip
    h4(
      "sg_app.zip  ",
      downloadButton(ns("appDownload"), "Download", style="display:inline-block")
    ),
    div(
      icon("info-circle"),
      HTML("sg_app.zip contains 3 files: 
        <ul> 
          <li><code>mapping.yaml</code></li>
          <li><code>charts.yaml</code></li>
          <li><code>initApp.R</code></li>
        </ul>
        To re-initialize the app with your current settings. Download <code>sg_app.zip</code>, unzip it in your R working directory, and then run <code>initApp.R</code> after review in the notes in the code. Note that these files update in real-time when mappings are updated in the app, so make sure to download new copies if you make changes to the mapping.
      "
      ), class="info"
    ),

    # Mapping.yaml
    h4(
      "mapping.yaml  ",
      uiOutput(ns("mappingCopy"), style="display:inline-block"),
      downloadButton(ns("mappingDownload"), "Download", style="display:inline-block")
    ),
    p(
      icon("info-circle"),
      HTML("Data mapping formatted as a YAML file. Use <code>read_yaml()</code> and the pass to the <code>mapping</code> parameter of <code>safetyGraphicsApp()</code>"),
      class="info"
    ),
    span("File Content:"),
    verbatimTextOutput(ns("mappingText")),

    # Charts.yaml
    h4(
      "charts.yaml  ",
      uiOutput(ns("chartsCopy"), style="display:inline-block"),
      downloadButton(ns("chartsDownload"), "Download", style="display:inline-block")
    ),
    p(
      icon("info-circle"),
      HTML("Charts metatdata formatted as a YAML file. Use <code>read_yaml()</code> and the pass to the <code>charts</code> parameter of <code>safetyGraphicsApp()</code>"),
      class="info"
    ),
    span("File Content:"),
    verbatimTextOutput(ns("chartsText")),

    #initApp.R
    h4(
      "initApp.R  ",
      uiOutput(ns("initCopy"), style="display:inline-block"),
      downloadButton(ns("initDownload"), "Download", style="display:inline-block")
    ),     
    p(
      icon("info-circle"),
      HTML("Shell of an R script to initialize the safetyGraphics app with pre-specified charts and/or metadata. Additional details provided in code comments."),
      class="info"
    ), 
    span("File Content:"),
    verbatimTextOutput(ns("initText"))
  )
  
}

#' @title  Server for the setting code page
#'
#' @param input Shiny input object
#' @param output  Shiny output object
#' @param session Shiny session object
#' @param mapping mapping
#' @param charts charts
#' 
#' @export

settingsCode <- function(input, output, session, mapping, charts){
  if(missing(mapping)){
    mapping<-reactive({data.frame(domain=character(0),text_id=character(0),current=character(0))})
  }
  
  # mapping.yaml for current mapping
  mappingString <- reactive({
    as.yaml(generateMappingList(mapping()))
  })
  output$mappingText <- renderText({mappingString()})
  output$mappingCopy <- renderUI({
    rclipboard::rclipButton("clipbtn", "Copy to Clipboard", mappingString(), icon("clipboard"))
  })
  output$mappingDownload <- downloadHandler(
    filename = "mapping.yaml",
    content = function(file) {
      writeLines(mappingString(), file)
    }
  )

  # charts.yaml for current charts
  chartsString <- as.yaml(charts)
  output$chartsText <- renderText({chartsString})
  output$chartsCopy <- renderUI({
    rclipboard::rclipButton("clipbtn", "Copy to Clipboard", chartsString, icon("clipboard"))
  })
  output$chartsDownload <- downloadHandler(
    filename = "charts.yaml",
    content = function(file) {
      writeLines(chartsString, file)
    }
  )

  # initApp.R
  initString<- paste(
    "library(safetyGraphics)",
    "#Initialize safetyGraphics App",
    "#Load mapping",
    "#NOTE: Update path if mapping.yaml isn't saved in working directory --!!!! ",
    "mapping <- read_yaml('mapping.yaml')", 
    "",
    "#Load Charts",
    "#NOTE: Update path if charts.yaml isn't saved in working directory. --!!!! ",
    "#NOTE: This can be removed if default charts from `safetyCharts` are being used --!!!! ",
    "charts <- read_yaml('charts.yaml', eval.expr=TRUE)", 
    "",
    "#Load Data",
    "#NOTE: Demo data from safetyData should be updated by user --!!!!",
    "dataList <- list(",
    "  labs=safetyData::adam_adlbc,", 
    "  aes=safetyData::adam_adae,",
    "  dm=safetyData::adam_adsl",
    ")",
    "",
    "#Initialize app",
    "#NOTE: This assumes the default meta data is used. See ?safetyGraphicsApp for more details and customization options.",
    "safetyGraphicsApp(data=dataList, mapping=mapping, charts=charts)",
    sep="\n"
  ) 
  output$initText <- renderText(initString)
  output$initCopy <- renderUI({
    rclipboard::rclipButton("clipbtn2", "Copy to Clipboard", initString, icon("clipboard"))
  })
  output$initDownload <- downloadHandler(
    filename = "initApp.R",
    content = function(file) {
      writeLines(initString, file)
    }
  )

  

  # sg_app.zip
  output$appDownload <- downloadHandler(
    filename = "sg_app.zip",
    content = function(fname) {
      tmpdir <- tempdir()
    
      chartsPath <- file.path(tmpdir, "charts.yaml")
      mappingPath <- file.path(tmpdir, "mapping.yaml")
      initPath <- file.path(tmpdir, "initApp.R")

      writeLines(chartsString, chartsPath)
      writeLines(mappingString(), mappingPath)
      writeLines(initString, initPath)
    
      zip(zipfile=fname, files=c(chartsPath, mappingPath, initPath),extras = '-j')
    },
    contentType = "application/zip"
  )

}