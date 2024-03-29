#' @title UI for the data loading module used in safetyGraphicsInit()
#'
#' @param id module id
#' @param domain character vector with domains to be loaded 
#' 
#' @export

loadDataUI <- function(id, domain=NULL){ 
  ns <- NS(id)
  div(
    strong(paste(domain,"-")),
    textOutput(outputId = ns("name"), inline=TRUE),
    actionButton(ns("load_data"), "Load"),
    hidden(
      actionLink(ns("preview_data"), "Preview")
    ),
    id=ns("wrap")
  )
}

#' @title Server for the data loading module used in safetyGraphicsInit()
#'
#' @param domain data domain to be loaded
#' @param input Shiny input object
#' @param output Shiny output object
#' @param session Shiny session object
#' 
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
    shinyjs::show("preview_data")
  })
  
  output$name <- renderText({fileSummary()})

  observeEvent(input$preview_data,{
    req(imported$data())
    showModal(
      modalDialog(
        title=paste("Preview of '",domain,"' domain:", imported$name()),
        DT::renderDataTable({
          DT::datatable(imported$data(), escape = FALSE)
        }),
        size="l"
      )
    )
  })

  return(imported$data)
}

