#' @title  filterTabUI 
#' @description  UI that facilitates the filtering data with datamods::filter_data_ui
#'
#' @param id module id
#' @param filterDomain data set for the domain
#' 
#' @import datamods
#' @importFrom shiny dataTableOutput
#' 
#' @export

filterTabUI <- function(id){  
    ns <- NS(id)

    filter_ui<-list(
        h1(paste("Participant Selector")),
        span("This page dynamically filters the participants in the demographics (dm) data set. Only the selected participants are included in charts."),
        fluidRow(
            column(
                width = 3,
                filter_data_ui(ns("filtering"))
            ),
            column(
                width = 9,
                progressBar(
                    id = ns("pbar"), value = 100, 
                    total = 100, display_pct = TRUE
                ),
                DT::dataTableOutput(outputId = ns("table")),
                tags$p("Code dplyr:"),
                verbatimTextOutput(outputId = ns("code_dplyr")),
                tags$p("Expression:"),
                verbatimTextOutput(outputId = ns("code")),
                tags$p("Filtered data:"),
                verbatimTextOutput(outputId = ns("res_str"))
            )
        )
    )
  return(filter_ui)
}


#' @title  filter module server
#' @description  server function that facilitates the data filtering with the datamods::filter_data_server module
#'
#' @param input Shiny input object
#' @param output  Shiny output object
#' @param session Shiny session object
#' @param domainData list of data files for each domain
#' @param filterDomain domain to use for filtering (typically "dm")
#' @param id_col name of id column. should be found in every data domain
#' 
#' @return filtered data set
#'
#' @import datamods
#' @importFrom shinyWidgets progressBar updateProgressBar
#' @importFrom shiny renderDataTable
#' 
#' @export

filterTab <- function(input, output, session, domainData, filterDomain, id_col){
    
    raw <-  domainData[[filterDomain]]

    res_filter <- filter_data_server(
      id = "filtering", 
      data = reactive({
          return(as.data.frame(raw))
      }),
      name = reactive({
          return(filterDomain)
      })
    )

    observeEvent(res_filter$filtered(), {
      updateProgressBar(
        session = session, id = "pbar", 
        value = nrow(res_filter$filtered()), total = nrow(raw)
      )
    })
    
    output$table <- DT::renderDataTable({
      res_filter$filtered()
    }, options = list(pageLength = 5))
    
    
    output$code_dplyr <- renderPrint({
      res_filter$code$dplyr
    })
    output$code <- renderPrint({
      res_filter$code$expr
    })
    
    output$res_str <- renderPrint({
      utils::str(res_filter$filtered())
    })
    
    filteredDomains <- reactive({
        #TODO add check to make sure id_col exists in all data sets. 
        current_ids <- unique(res_filter$filtered()[[id_col()]])

        filteredDomains = list()
        id_col <- id_col()
        for(domain in names(domainData)){  
            filteredDomains[[domain]] <- domainData[[domain]] %>% filter(!!sym(id_col) %in% current_ids)
        }
        #filteredDomains <- domainData %>% map(~filter(.x , !!id_col() %in% current_ids))
        return(filteredDomains)
    })
    return(filteredDomains)
}
