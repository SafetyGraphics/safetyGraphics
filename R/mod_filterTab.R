#' @title UI for the filter module in datamods::filter_data_ui
#'
#' @param id module id
#' 
#' @import datamods
#' @importFrom shiny dataTableOutput
#' 
#' @export

filterTabUI <- function(id){  
    ns <- NS(id)
    if(isNamespaceLoaded("shinyWidgets")){
        countObj<-  shinyWidgets::progressBar(
            id = ns("pbar"), value = 100, 
            total = 100, display_pct = TRUE
        )
    }
    
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
                countObj,
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


#' @title Server for the filter module in datamods::filter_data_ui
#'
#' @param input Shiny input object
#' @param output  Shiny output object
#' @param session Shiny session object
#' @param domainData list of data files for each domain
#' @param filterDomain domain to use for filtering (typically "dm")
#' @param current_mapping current data mapping
#' @param filterVars Variables to use for filtering (used for testing)
#' @param tabID ID for the tab containing the filter UI (used for testing)
#' 
#' @return filtered data set
#'
#' @import datamods
#' @importFrom shinyjs show hide
#' @importFrom shiny renderDataTable
#' 
#' @export

filterTab <- function(input, output, session, domainData, filterDomain, current_mapping, tabID="Filtering", filterVars=NULL){

    # Check to see if data can be filtered using current settings.
    filterCheck<-filterTabChecks(domainData, filterDomain, current_mapping)
    
    # Calculate raw data and show filter tab if checks pass
    raw <- reactive({
        req(filterCheck())
        shinyjs::show(selector = paste0(".navbar li a[data-value=",tabID,"]"))
        shinyjs::show(selector = paste0(".navbar #population-header"))
        domainData[[filterDomain]]
    })
    
    # Hide filter tab if checks fail
    observeEvent(!filterCheck(), {
        shinyjs::hide(selector = paste0(".navbar li a[data-value=",tabID,"]"))
        shinyjs::hide(selector = paste0(".navbar #population-header"))
    })

    res_filter <- filter_data_server(
        id = "filtering", 
        data = raw,
        name = reactive({filterDomain}),
        vars = reactive({filterVars})
    )  

    observeEvent(res_filter$filtered(), {
        if(isNamespaceLoaded("shinyWidgets")){
            shinyWidgets::updateProgressBar(
                session = session, 
                id = "pbar", 
                value = nrow(res_filter$filtered()), total = nrow(raw())
            )
        }

        shinyjs::html(
            "header-count", 
            nrow(res_filter$filtered()),
            asis=TRUE    
        )

        shinyjs::html(
            "header-total", 
            nrow(raw()),
            asis=TRUE
        )

    })

    observe({
        req(res_filter$filtered())
        
        output$table <- DT::renderDataTable({
            res_filter$filtered()
        }, options = list(pageLength = 5))
        
        
        output$code_dplyr <- renderPrint({
            res_filter$code()
        })
        output$code <- renderPrint({
            res_filter$expr()
        })
        
        output$res_str <- renderPrint({
            utils::str(res_filter$filtered())
        }) 
    })


    # Set up filtering UI
    filteredDomains<- reactive({
        if(filterCheck()){
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
            return(domainData)
        }
    })
    return(filteredDomains)
}
