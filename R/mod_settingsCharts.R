#' @title Settings Module - chart details
#' @description  Settings Module - sub-module showing details for the charts loaded in the app - UI
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
      tabPanel("DT format", DT::DTOutput(ns("chartMetaDT"))),
      tabPanel("Verbatim", verbatimTextOutput(ns("chartList"))),
      tabPanel("YAML", verbatimTextOutput(ns("chartYAML"))) 
    )
  )
}

#' @title  Settings Module - charts details - server
#' @description  server for the display of the charts
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
  
  
  tblMeta <- function(charts){
    #TODO move this function to a helper file and fix warning messages
    bbb <- purrr::map(charts, ~{
      bb <- dplyr::as_tibble(t(dplyr::tibble(.x)), .name_repair="unique")
      names(bb) <- names(.x)
      bb
    })
    
    bbbb<- do.call(bind_rows,  bbb)
    
  }
  
  
  # DT for charts meta data
  output$chartMetaDT <- DT::renderDT({
    DT::datatable( tblMeta(charts) )
  })

  output$chartYAML <- renderText({
    as.yaml(charts)
  })

  # Script to load YAML with expressions/functions: `read_yaml("charts.yaml", eval.expr=TRUE)`

}