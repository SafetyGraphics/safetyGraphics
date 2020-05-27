#' @title Settings Module - data details
#' @description  Settings Module - sub-module showing details for the data loaded in the app - UI
#' 
#' @param domains named list of the data.frames for each domain

#' @export

settingsDataUI <- function(id, domains){
  ns <- NS(id)
  names(domains) %>% map(function(domain){
    return(
      list(
        h1(paste0("Domain: ", domain)),
        DTOutput(ns(domain))
      )
    )
    
  })
}

#' @title  Settings Module - data details - server
#' @description  server for the display of the loaded data  
#'
#' @param input Shiny input object
#' @param output  Shiny output object
#' @param session Shiny session object
#' @param domains named list of the data.frames for each domain
#' #'
#' @export

settingsData <- function(input, output, session, domains){
  ns <- session$ns
  for(domain in  names(domains)){
    output[[domain]] <- renderDT({
      DT::datatable(
        domains[[domain]], 
        rownames = FALSE,
        options = list(),
        class="compact"
      )
    })
  }
}