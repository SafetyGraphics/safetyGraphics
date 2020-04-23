# Mapping Metadata Summary Module

#' @title   mappingMetaUI and mappingMeta
#' @description  Module that displays the data mapping metadata. 
#'
#' @section Output:
#' \describe{
#' \item{\code{mappingMeta}}{Reactive containing the metadata to be used in the app.}
#' }
#' 
#' @export

metaMappingUI <- function(id){
    ns <- NS(id)
    tagList(
        div(DTOutput(ns("metaViewUI")), style = "font-size: 75%"),
        fileInput(ns("metadata_file"),"Upload custom data mappings",accept = c('.csv'))
    )
}

# Metadata Loading module server

#' @param input Shiny input object
#' @param output  Shiny output object
#' @param session Shiny session object
#' @param metaIn Data mapping metadata used for initial loading of app
#' @param mapping Current metadata mapping in the app
#'
#' @export
metaMapping <- function(input, output, session, metaIn){
    ns <- session$ns
  
    ##########################################################################
    # Create reactive containing default or custom data mappings ("metadata")
    ##########################################################################

    # custom loaded data
    metadata <-  eventReactive(input$metadata_file, {
      if(is.null(input$metadata_file)){
        metaIn
      }else{
        data.frame(
          read.csv(
            input$metadata_file$datapath, 
            na.strings=NA, 
            stringsAsFactors=FALSE
          )
        )
      }
    }, ignoreNULL = FALSE)
    
    output$metaViewUI <- renderDT({
        DT::datatable(
            metadata(), 
            rownames = FALSE,
            class="compact",

        )
    })

    return(metadata)
}