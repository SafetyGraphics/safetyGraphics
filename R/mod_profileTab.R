#' @title UI for the profile module in safetyProfile::profile_ui
#'
#' @param id module id
#' 
#' @import safetyProfile
#' 
#' @export

profileTabUI <- function(id){  
    ns <- NS(id)
    
    profile_ui<-list(
        h1(paste("Participant Profile")),
        span("This page shows details for a selected participant."),
        profile_ui(ns("profile"))
    )
    
    return(profile_ui) 
}


#' @title Server for the filter module in safetyProfile::profile_server
#'
#' @param input Shiny input object
#' @param output  Shiny output object
#' @param session Shiny session object
#' @param params reactive containing mapping and data
#' @param current_id reactive containing currently selected participant
#' 
#' @return current_id
#'
#' @import datamods
#' @importFrom shinyjs show hide
#' @importFrom shiny renderDataTable
#' 
#' @export

profileTab <- function(input, output, session, params){
    observe({
        print(names(params()$data))
        print(names(params()$settings))
    })

    callModule(safetyProfile::profile_server, "profile", params)
}
