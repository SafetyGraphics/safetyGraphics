#' @title  Metadata Mapping UI
#' @description  UI that displays the data mapping metadata. 
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
        DTOutput(ns("metaTable")),
        fileInput(ns("metaFile"),"Upload custom data mappings",accept = c('.csv'))
    )
}

# Metadata Loading module server

#' @param input Shiny input object
#' @param output  Shiny output object
#' @param session Shiny session object
#' @param metaIn Data mapping metadata used for initial loading of app
#' @param mapping data frame representing the current metadata mapping. columns = "domain", "text_id" and "current"
#'
#' @export
metaMapping <- function(input, output, session, metaIn, mapping=NULL){
    ns <- session$ns
  
    ##########################################################################
    # Create reactive containing default or custom data mappings ("metadata")
    ##########################################################################

    # custom loaded data
    metadata <-  eventReactive(input$metaFile, {
      if(is.null(input$metaFile)){
        metaIn
      }else{
        df<-data.frame(
          read.csv(
            input$metaFile$datapath, 
            na.strings=NA, 
            stringsAsFactors=FALSE
          )
        )
        
        if(sort(names(df))==c("domain","text_id","current")){
          df
        }else{
          showNotification("Sorry, not a valid mapping. Load a file with columns for 'domain','text_id' and 'current'.")
          metaIn
        }
      }
    }, ignoreNULL = FALSE)
    
    
    metadata_mapping <- reactive(
      if(is.null(mapping)){
        metadata()%>%mutate(current="")
      }else {
        metadata() %>% left_join(mapping)  
      }
      
    )

    output$metaTable <- renderDT({
        DT::datatable(
            metadata_mapping(), 
            rownames = FALSE,
            options = list(paging=FALSE, ordering=FALSE),
            class="compact"
        )
    })

    return(metadata)
}