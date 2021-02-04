#' @title  Settings view of Metadata/Mapping - UI
#' @description  UI that displays the data mapping metadata. 
#'
#' @param id module id
#' 
#' @section Output:
#' \describe{
#' \item{\code{mappingMeta}}{Reactive containing the metadata to be used in the app.}
#' }
#' 
#' @export

settingsMappingUI <- function(id){
    ns <- NS(id)
    tagList(
        DTOutput(ns("metaTable")),
        fileInput(ns("metaFile"),"Upload custom data mappings",accept = c('.csv'))
    )
}

#' @title  Settings view of Metadata/Mapping - server
#' @description  server for the display of the data mapping metadata. 
#'
#' @param input Shiny input object
#' @param output  Shiny output object
#' @param session Shiny session object
#' @param metaIn Data mapping metadata used for initial loading of app
#' @param mapping reactive data frame representing the current metadata mapping. columns = "domain", "text_id" and "current"
#'
#' @export

settingsMapping <- function(input, output, session, metaIn, mapping){
    ns <- session$ns

    #use an empty mapping if none is provided
    if(missing(mapping)){
      mapping<-reactive({data.frame(domain=character(0),text_id=character(0),current=character(0))})
    }
    
    ##########################################################################
    # Create reactive containing default or custom data mappings ("metadata")
    ##########################################################################

    # custom loaded data
    metadata <-  eventReactive(input$metaFile, {
      if(is.null(input$metaFile)){
        metaIn
      }else{
        df<-data.frame(
          utils::read.csv(
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
        metadata() %>% left_join(mapping())  
    )

    output$metaTable <- renderDT({
        DT::datatable(
            metadata_mapping(), 
            rownames = FALSE,
            options = list(paging=FALSE, ordering=FALSE),
            class="compact metatable"
        )
    })

    return(metadata)
}