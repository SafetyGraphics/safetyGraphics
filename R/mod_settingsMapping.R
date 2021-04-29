#' @title  Settings view of Metadata/Mapping - UI
#' @description  UI that displays the data mapping metadata. 
#'
#' @param id module id
#' 
#' @import rclipboard
#' 
#' @export

settingsMappingUI <- function(id){
  ns <- NS(id)
  tabsetPanel(
    tabPanel("Summary",
      tagList(
        rclipboard::rclipboardSetup(),
        DT::DTOutput(ns("metaTable"))
      )      
    ),
    tabPanel(
      "Code",
      HTML("The code below creates an R object that can be passed to the <code>mapping</code> parameter of <code>safetyGraphicsApp()</code> to regenerate the current mapping."),
      code(
        verbatimTextOutput(ns("mappingCode"))
      ),
      uiOutput(ns("copyMapping"))
    ),
    type="pills"
  )
}  

#' @title  Settings view of Metadata/Mapping - server
#' @description  server for the display of the data mapping metadata. 
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

    #Show code to recreate current mapping
    codeString<-reactive({
      paste(
        "# Code for current data mapping\n",
        "customMapping<-\n",
        paste(deparse(mapping()), collapse="\n"),
        "# call `safetyGraphics(mapping=customMapping)` to restart the app using this mapping"
      )
      
    })
    output$mappingCode <- renderText({codeString()})
    output$copyMapping <- renderUI({
      rclipboard::rclipButton("clipbtn", "Copy to Clipboard", codeString(), icon("clipboard"))
    })
    return(metadata)
}