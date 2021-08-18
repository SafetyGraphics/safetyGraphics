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
      downloadButton(ns("appDownload"), "Download", style="display:inline-block"),
    ),
    checkboxInput(ns("toggleDataDL"), "Download Domain Data?", TRUE),
    div(
      icon("info-circle"),
      HTML("sg_app.zip contains 3 or 4 files: 
        <ul> 
          <li><code>mapping.yaml</code></li>
          <li><code>charts.yaml</code></li>
          <li><code>initApp.R</code></li>
          <li><code>domainData.RDS</code> (if selected)</li> 
        </ul>
        To re-initialize the app with your current settings. Download <code>sg_app.zip</code>, unzip it in your R working directory, and then run <code>initApp.R</code> after review in the notes in the code. Note that these files update in real-time when mappings are updated in the app, so make sure to download new copies if you make changes to the mapping.
      "
      ), class="info"
    ),

    # domainData.RDA
    h4(
      "domainData.RDS  ",
      downloadButton(ns("dataDownload"), "Download", style="display:inline-block")
    ),
    div(
      icon("info-circle"),
      HTML("domainData.RDS contains the (unfiltered) domain data loaded in the app. The data can be loaded using `readRDS()` and passed to the `domainData` parameter in `safetyGraphicsApp()`. WARNING: Exported data files may be quite large, so it may be better to simply re-load your data directly (e.g. using the `{rio}` package)"
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
#' @param domainData data list
#' 
#' @importFrom utils zip
#' 
#' @export

settingsCode <- function(input, output, session, mapping, charts, domainData){
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
    "#####################################################################################################################",
    "# Initialize the safetyGraphics Shiny App using exported settings and data",
    "#",
    "# This code was generated in the safetyGraphics Shiny App to help re-initialize the app with the current settings.",
    "# The code assumes that `mapping.yaml`, `charts.yaml` and `domainData.RDS` were downloaded from the app and saved ",
    "# in you working directory. It also assumes that the default meta data included in the app is used. However, there ",
    "# are likely many use cases where this workflow is not ideal and some customization is needed.  See ?safetyGraphicsApp ",
    "# and the pacakge vignettes for more details and customization options.",
    "#",
    "#####################################################################################################################",
    "",
    "library(safetyGraphics)",
    "library(yaml)",
    "mapping <- read_yaml('mapping.yaml')", 
    "charts <- read_yaml('charts.yaml', eval.expr=TRUE)", 
    "domainData <- readRDS('domainData.RDS')",
    "safetyGraphicsApp(domainData=domainData, mapping=mapping, charts=charts)",
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

  # domainData.RDS
  output$dataDownload <- downloadHandler(
    filename = "domainData.RDS",
    content = function(fname) {
      saveRDS(domainData,fname)
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
      allFiles <- c(chartsPath, mappingPath, initPath)

      if(input$toggleDataDL){
        dataPath <- file.path(tmpdir, "domainData.RDS")
        saveRDS(domainData,dataPath)
        allFiles <- c(allFiles, dataPath)
      } 

      zip(zipfile=fname, files=allFiles ,extras = '-j')
    },
    contentType = "application/zip"
  )
}