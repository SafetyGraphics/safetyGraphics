#' @title Home Tab
#' @description  Home Tab - sub-module showing details for the data loaded in the app - UI
#'
#' @param id module id
#' 
#' @export

homeTabUI <- function(id){
  ns <- NS(id)
  fluidRow(
    column(width=8, style='font-size:20px', uiOutput(outputId = ns("about"))),
    column(width=4, imageOutput(outputId = ns("hex")))
  )  
}

#' @title  home tab - server
#' @description  server for the display of the home tab  
#'
#' @param input mod input
#' @param output mod output
#' @param session mod session
#' 
#' @export

homeTab <- function(input, output, session){
  ns <- session$ns
  output$about <- renderUI({
    HTML('
    <h1> <b> Welcome to the Safety Graphics Shiny App  </b> </h1>
    <p> The Safety Graphics Shiny app is an interactive tool for evaluating clinical trial safety using a flexible data pipeline. This application and corresponding <a href="https://cran.r-project.org/web/packages/safetyGraphics/index.html">{safetyGraphics}</a> R package have been developed as part of the <a href="https://safetygraphics.github.io/">Interactive Safety Graphics (ISG) workstream</a> of the ASA Biopharm-DIA Safety Working Group. </p>
    <h3><i> Using the app</i></h3>
    <p>Detailed instructions about using the app can be found in our <a href="https://cran.r-project.org/web/packages/safetyGraphics/vignettes/shinyUserGuide.html">vignette</a>. In short, the user will initialize the app with thier data, adjust settings as needed and view the interactive charts. Finally, the user may export a self-contained, fully reproducible snapshot of the charts that can be easily shared with others.</p>
    <h3><i> Charts </i></h3>
    <p> The app is built to support a wide variety of chart types including static plots (e.g. from {ggplot2}), shiny modules, {htmlwidgets} and even static outputs like rtfs. Several pre-configured charts are included in the companion <a href="https://www.github.com/safetyGraphics/safetyCharts">{safetyCharts}</a> R Package, and are available by default in the app. Other charts can be added using the process descibed in this <a href="https://cran.r-project.org/web/packages/safetyGraphics/vignettes/shinyUserGuide.html">vignette</a>. 
    
    <p> For more information about {safetyGraphics}, please visit our <a href="https://github.com/SafetyGraphics/safetyGraphics">GitHub repository</a>.  We also welcome your suggestions in our <a href="https://github.com/SafetyGraphics/safetyGraphics/issues">issue tracker</a>.
    </p>')
  })
  
  output$hex <- renderImage({
    list(
      src = system.file("safetyGraphicsHex/safetyGraphicsHex.png", package = "safetyGraphics"), width="60%")
  }, deleteFile = FALSE
  )
}