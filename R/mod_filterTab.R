#' @title  filterTabUI 
#' @description  UI that facilitates the filtering data with datamods::filter_data_ui
#'
#' @param id module id
#' 
#' @import datamods
#' @importFrom shiny dataTableOutput
#' 
#' @export

filterTabUI <- function(id){  
    ns <- NS(id)

    filter_ui<-list(
        h1(paste("Participant Selector")),
        span("This page dynamically filters participants across all data domains. Only the selected participants are included in charts."),
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
#' @param current_mapping current data mapping
#' @param tabID ID for the tab containing the filter UI (used for testing)
#' 
#' @return filtered data set
#'
#' @import datamods
#' @importFrom shinyWidgets progressBar updateProgressBar
#' @importFrom shiny renderDataTable
#' 
#' @export

filterTab <- function(input, output, session, domainData, filterDomain, current_mapping, tabID="Filtering"){

    # Check to see if data can be filtered using current settings.
    filterCheck<-filterTabChecks(domainData, filterDomain, current_mapping)
    raw <- reactive({
        req(filterCheck())
        domainData[[filterDomain]]
    })
    
    res_filter <- filter_data_server(
        id = "filtering", 
        data = raw,
        name = reactive({filterDomain})
    )  
    

    observeEvent(res_filter$filtered(), {
        updateProgressBar(
            session = session, id = "pbar", 
            value = nrow(res_filter$filtered()), total = nrow(raw)
        )
    })

    observe({
        req(res_filter$filtered())
        
        output$table <- DT::renderDataTable({
            res_filter$filtered()
        }, options = list(pageLength = 5))
        
        
        output$code_dplyr <- renderPrint({
            res_filter$code
        })
        output$code <- renderPrint({
            res_filter$expr
        })
        
        output$res_str <- renderPrint({
            utils::str(res_filter$filtered())
        }) 
    })


    # Set up filtering UI
    filteredDomains<- reactive({
        if(filterCheck()){
            print("checks passed")
            id_col <- reactive({
                filter_data <- current_mapping() %>% filter(.data$domain==filterDomain)   
                id<- filter_data %>% filter(.data$text_key=="id_col")%>%pull(.data$current)
                return(id)
            })

            current_ids <- unique(res_filter$filtered()[[id_col()]])
            filteredDomains = list()
            for(domain in names(domainData)){  
                filteredDomains[[domain]] <- domainData[[domain]] %>% filter(!!sym(id_col()) %in% current_ids)
            }
            return(filteredDomains)
        }else{
            print("checks failed")
            # Return the raw data and disable the UI Tab
            #message(filterCheckNote)
            hideTab(inputId = "safetyGraphicsApp", target = tabID) #hide filter tab
            return(domainData)
        }
    })
    return(filteredDomains)
}
