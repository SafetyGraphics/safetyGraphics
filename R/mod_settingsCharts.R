#' @title UI for settings tab showing details for the charts loaded in the app 
#'
#' @param id module id
#' 
#' @importFrom listviewer jsoneditOutput
#' @export

settingsChartsUI <- function(id){
  ns <- NS(id)
  list(
    br(),
    p(
      icon("info-circle"),
      "Full details regarding the charts are shown below. Charts specifications are saved in an R list, and can be exported for re-use on the settings/code tab. ",
      class="info"
    ),
    tabsetPanel(
      tabPanel("jsonedit View", listviewer::jsoneditOutput(ns("chartObj"), height = "800px") ),
      tabPanel("Verbatim", verbatimTextOutput(ns("chartList"))),
      tabPanel("YAML", verbatimTextOutput(ns("chartYAML"))) 
    )
  )
}

#' @title Server for settings tab showing details for the charts loaded in the app 
#'
#' @param input Shiny input object
#' @param output  Shiny output object
#' @param session Shiny session object
#' @param charts list data frame summarizing the charts
#' 
#' @importFrom listviewer renderJsonedit jsonedit 
#' @import dplyr
#' 
#' @export

settingsCharts <- function(input, output, session, charts){
  ns <- session$ns
  
  output$chartObj <- listviewer::renderJsonedit({
    listviewer::jsonedit(charts)
  })

  output$chartList <- renderPrint({
    print(charts)
  })

  output$chartYAML <- renderText({
    as.yaml(charts)
  })

  

}