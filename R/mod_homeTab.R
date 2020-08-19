#' @title Home Tab
#' @description  Home Tab - sub-module showing details for the data loaded in the app - UI
#'
#' @export

homeTabUI <- function(id){
  ns <- NS(id)
  tabsetPanel(
    tabPanel("About",
             fluidRow(
               column(width=8, style='font-size:20px', uiOutput(outputId = ns("about"))),
               column(width=4, imageOutput(outputId = ns("hex")))
             )
    ),
    tabPanel(
      "Shiny App User Guide",
      tags$iframe(
        style="height:800px; width:100%; scrolling=yes;",  
        `data-type`="iframe",
        src = "https://cran.r-project.org/web/packages/safetyGraphics/vignettes/shinyUserGuide.html"
      )
    ),
    tabPanel(
      "Hep Explorer workflow",
      tags$iframe(
        style="height:800px; width:100%; scrolling=yes;",  
        `data-type`="iframe",
        src = "https://cdn.jsdelivr.net/gh/SafetyGraphics/SafetyGraphics.github.io/guide/HepExplorerWorkflow_v1_1.pdf"
      )
    )
  ) 
}

#' @title  home tab - server
#' @description  server for the display of the home tab  
#'
#' @export

homeTab <- function(input, output, session){
  ns <- session$ns
  output$about <- renderUI({
    HTML('<h1> <b> Welcome to the Safety Graphics Shiny App  </b> </h1>
         <p> The Safety Graphics Shiny app is an interactive tool for evaluating clinical trial safety using
         a flexible data pipeline. This application and corresponding
    <a href="https://cran.r-project.org/web/packages/safetyGraphics/index.html">safetyGraphics</a>
         R package have been developed as part of the <a href="https://safetygraphics.github.io/">Interactive Safety Graphics (ISG) workstream</a>
        of the ASA Biopharm-DIA Safety Working Group. </p>
         <h3><i> Using the app</i></h3>
        <p>Detailed instructions about using the app can be found in our
        <a href="https://cran.r-project.org/web/packages/safetyGraphics/vignettes/shinyUserGuide.html">vignette</a>. In short,
        the user will begin by loading a data file, adjust settings as needed and view the interactive charts.
        Finally, the user may export a self-contained, fully reproducible snapshot of the charts that can be easily shared with others.</p>
        <h3><i> Clinical Workflow </i></h3>
        This shiny app has been developed in parallel with a well-documented <a href="https://github.com/SafetyGraphics/SafetyGraphics.github.io/raw/master/guide/HepExplorerWorkflow_v1_1.pdf">clinical workflow</a>
 for monitoring hepatotoxicity. The workflow, written by expert physicians, provides a detailed description of how the interactive graphics can be used as part of a safety clinician’s monitoring practice.
        <h3><i> Interactive Charts </i></h3>
        <p> The included interactive charts are built using the <code>htmlwidgets</code> framework in R. The code libraries
        and configuration details for the underlying JavaScript charts are located below.
        <ul>
        <li>Hepatic Safety Explorer -
<a href="https://github.com/SafetyGraphics/hep-explorer">Library</a>,
<a href="https://github.com/SafetyGraphics/hep-explorer/wiki/Configuration">Configuration</a>
        </li>
        <li>Histogram -
<a href="https://github.com/RhoInc/safety-histogram">Library</a>,
<a href="https://github.com/RhoInc/safety-histogram/wiki/Configuration">Configuration</a></li>
        <li>Outlier Explorer -
<a href="https://github.com/RhoInc/safety-outlier-explorer">Library</a>,
<a href="https://github.com/RhoInc/safety-outlier-explorer/wiki/Configuration">Configuration</a></li>
        <li>Shift Plot -
<a href="https://github.com/RhoInc/safety-shift-plot">Library</a>,
<a href="https://github.com/RhoInc/safety-shift-plot/wiki/Configuration">Configuration</a></li>
        <li>Results Over Time -
<a href="https://github.com/RhoInc/safety-results-over-time">Library</a>,
<a href="https://github.com/RhoInc/safety-results-over-time/wiki/Configuration">Configuration</a></li>
        <li>Paneled Outlier Explorer -
<a href="https://github.com/RhoInc/paneled-outlier-explorer">Library</a>,
<a href="https://github.com/RhoInc/paneled-outlier-explorer/wiki/Configuration">Configuration</a></li></ul>
        </p>
<br>
         <p>For more information about <code>safetyGraphics</code>, please visit our
<a href="https://github.com/SafetyGraphics/safetyGraphics">GitHub repository</a>.  We also welcome your suggestions in our
<a href="https://github.com/SafetyGraphics/safetyGraphics/issues">issue tracker</a>.
         </p>')
    
  })
  
  output$hex <- renderImage({
    list(src = system.file("safetyGraphicsHex/safetyGraphicsHex.png", package = "safetyGraphics"), width="60%")
  }, deleteFile = FALSE)
}