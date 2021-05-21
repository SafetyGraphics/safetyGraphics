#' @title   loadDataUI 
#' @description  UI that facilitates the mapping of a column data domain
#'
#' @param id module id
#' @param domains character vector with domains to be loaded
#' 
#' @export

loadDomainsUI <- function(id, domain=NULL){ 
  ns <- NS(id)
  # span(
  #   strong(domain),
  #   textOutput(outputId = ns("name"), inline=TRUE),
  #   actionButton(ns("load_data"), "Load"),
  # )
}

#' @title   loadDataServer
#' @description  UI that facilitates the mapping of a column data domain
#'
#' @param domains List of data domains to be loaded

#' @export
loadDomains <- function(input, output, session, domain) {
  ns <- session$ns
  # fileSummary <- reactiveValues()
  # fileSummary$text <- "Load Files"
  # observeEvent(input$load_data, {
  #   import_modal(
  #     id = ns("import_modal"),
  #     from = c("env", "file"),
  #     title = paste(domain,"data to be used in application")
  #   )
  #   fileSummary$text <- paste(
  #       imported$name(),
  #       paste(dim(imported$data()),collapse="x")
  #     )
  # })

  # imported <- import_server("import_modal", return_class = "tbl_df")
  # output$name <- renderPrint({fileSummary()})

  # return(reactive({imported$data()}))
}
