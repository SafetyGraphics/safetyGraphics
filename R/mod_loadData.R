#' @title   loadDataUI 
#' @description  UI that facilitates the mapping of a column data domain
#'
#' @param id module id
#' @param domains character vector with domains to be loaded
#' 
#' @export

loadDataUI <- function(id, domain=NULL){ 
  ns <- NS(id)
  span(
    strong(paste(domain,"-")),
    textOutput(outputId = ns("name"), inline=TRUE),
    actionButton(ns("load_data"), "Load"),
  )
}

#' @title   loadDataServer
#' @description  UI that facilitates the mapping of a column data domain
#'
#' @param domains List of data domains to be loaded

#' @export
loadData <- function(input, output, session, domain) {
  ns <- session$ns
  fileSummary <- reactiveVal()
  fileSummary("<No Data Loaded>")
  observeEvent(input$load_data, {
    import_modal(
      id = ns("import_modal"),
      from = c("env", "file"),
      title = paste(domain,"data to be used in application")
    )
  })

  imported <- import_server("import_modal", return_class = "tbl_df")

  observe({
    req(imported$name(), imported$data())
    fileSummary(
      paste0(
        imported$name(),
        " (",
        paste(dim(imported$data()),collapse="x"),
        ")"
      )
    )
  })
  
  output$name <- renderText({fileSummary()})

  return(reactive({imported$data()}))
}

