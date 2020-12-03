#' @title Settings Module - data details
#' @description  Settings Module - sub-module showing details for the data loaded in the app - UI
#' 
#' @param domains named list of the data.frames for each domain
#' 
#' @importFrom DT renderDT

#' @export

settingsDataUI <- function(id){
  ns <- NS(id)
  div(
    h2("Data Domain Previews"),
    uiOutput(ns('previews'))
  )
}

#' @title  Settings Module - data details - server
#' @description  server for the display of the loaded data  
#'
#' @param input Shiny input object
#' @param output  Shiny output object
#' @param session Shiny session object
#' @param domains named list of the data.frames for each domain
#' 
#' @export

settingsData <- function(input, output, session, domains, filtered){
  ns <- session$ns
  #Set up tabs
  output$previews <- renderUI({
    tabs <- lapply(names(domains),function(domain){
        tabPanel(domain,
          div(
            #h3(paste0("Note: Showing filtered data. X of X rows displayed for the X selected participants.")),
            DTOutput(ns(domain))
          )
        )
    })
    do.call(tabsetPanel, tabs)
  })
  
  # Draw the tables
  lapply(names(domains), function(domain){
    output[[domain]] <- renderDT({
      DT::datatable(
        domains[[domain]], 
        rownames = FALSE,
        options = list(),
        class="compact"
      )
    })
  })
}