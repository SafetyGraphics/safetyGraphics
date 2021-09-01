#' @title UI for settings tab showing current mapping
#' 
#' @param id module id
#' 
#' @import rclipboard
#' 
#' @export

settingsMappingUI <- function(id){
  ns <- NS(id)
  tagList(
    p(
      icon("info-circle"), 
      span("The table below shows details related to data mapping. Full metadata for each data domain is shown along with the current mapping in the last column in blue). Both metadata and the current mapping can be exported for re-use on the settings/code tab."),
      class="info"
    ),
    DT::DTOutput(ns("metaTable"))
  ) 
}  

#' @title Server for settings tab showing current mapping
#'
#' @param input Shiny input object
#' @param output  Shiny output object
#' @param session Shiny session object
#' @param metadata Data mapping metadata used for initial loading of app
#' @param mapping reactive data frame representing the current metadata mapping. columns = "domain", "text_id" and "current"
#'
#' @import rclipboard
#' @import yaml
#' 
#' @export

settingsMapping <- function(input, output, session, metadata, mapping){
  ns <- session$ns

  #use an empty mapping if none is provided
  if(missing(mapping)){
    mapping<-reactive({data.frame(domain=character(0),text_id=character(0),current=character(0))})
  }
  
  ##########################################################################
  # Create reactive containing default or custom data mappings ("metadata")
  #########################################################################

  metadata_mapping <- reactive(
      metadata %>% left_join(mapping())  
  )

  output$metaTable <- renderDT({
      DT::datatable(
          metadata_mapping(), 
          rownames = FALSE,
          options = list(paging=FALSE, ordering=FALSE),
          class="compact metatable"
      )
  })

}