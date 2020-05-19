#' @title Settings Module - data details
#' @description  Settings Module - sub-module showing details for the data loaded in the app - UI
#' 
#' @export

settingsDataUI <- function(id){
  ns <- NS(id)

  tagList(
    DTOutput(ns("dataSummaryTable")),
    fileInput(ns("dataFile"),"Upload data file",accept = c('.csv'))
  )
}

#' @title  Settings Module - data details - server
#' @description  server for the display of the loaded data  
#'
#' @param input Shiny input object
#' @param output  Shiny output object
#' @param session Shiny session object
#' @param allData tibble containing the data used in the app. Columns should be c('domain','name','standard','df')
#' 
#' @return dataList - this may include files uploaded by the user. 
#'
#' @export

settingsData <- function(input, output, session, allData){
  ns <- session$ns
  
  # reactive for the current data 
  currentData <-  reactive({allData})
  
  observeEvent(input$dataFile, {
    new<-data.frame(
      read.csv(
        input$metaFile$datapath, 
        na.strings=NA, 
        stringsAsFactors=FALSE
      )
    )
    newSummary<-tibble_row(
      domain="None", 
      name=input$metaFile$name, 
      standard=list(
        standard="None", 
        summary="0/x cols"
        ),
      df=list(new)
    )
    
    currentData<- rbind(currentData(),newSummary)
  })
  
  dataSummary <- reactive({
    currentData() %>% 
      mutate(dims=paste(dim(df[[1]])[1], dim(df[[1]])[2],sep="x")) %>%
      mutate(summary= "coming soon") %>%
      select(domain, name, dims,standard, summary) 
  })
      
  output$dataSummaryTable <- renderDT({
    DT::datatable(
      dataSummary(), 
      rownames = FALSE,
      options = list(paging=FALSE, ordering=FALSE),
      class="compact"
    )
  })
  
  return(currentData)
}