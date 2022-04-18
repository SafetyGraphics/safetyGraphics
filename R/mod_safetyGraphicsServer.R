#' Server for core safetyGraphics app including Home, Mapping, Filter, Charts and Settings modules.  
#'
#' This function returns a server function suitable for use in shiny::runApp()
#' 
#' @param input Shiny input object
#' @param output Shiny output object
#' @param session Shiny session object
#' @param meta data frame containing the metadata for use in the app.
#' @param domainData named list of data.frames to be loaded in to the app.
#' @param mapping current mapping
#' @param charts list of charts to include in the app
#' @param filterDomain domain used for the data/filter tab. Demographics ("`dm`") is used by default. Using a domain that is not one record per participant is not recommended. 
#' 
#' @import shiny
#' @import dplyr
#' @importFrom purrr map
#' @importFrom shinyjs html toggleClass
#' 
#' @export

safetyGraphicsServer <- function(input, output, session, meta, mapping, domainData, charts, filterDomain){
    # Initialize the Home tab
    callModule(homeTab, "home")
    
    # Initialize the Filter tab - returns list of filtered data as a reactive
    filtered_data<-callModule(
        filterTab, 
        "filter", 
        domainData=domainData, 
        filterDomain=filterDomain, 
        current_mapping=current_mapping
    )

    # Initialize the Mapping tab - returns the current mapping as a reactive
    current_mapping<-callModule(mappingTab, "mapping", meta, domainData)

    # Initialize Charts tab
    # Initialize Chart UI - adds subtabs to chart menu and initializes the chart UIs
    charts %>% purrr::map(~chartsNav(.x,session$ns))

    # Initialize Chart Servers
    charts %>% purrr::map(
        ~callModule(
            module=chartsTab,
            id=.x$name,
            chart=.x,
            data=filtered_data,
            mapping=current_mapping    
        )
    )

    # Keep chart status updated
    charts_status <- reactive({
        charts %>% purrr::map(function(chart){
            if(hasName(chart, 'dataSpec')){
                getChartStatus(chart,current_mapping())
            }else{
                list(chart=chart$name,status="missing")
            }
        })
    })

    observeEvent(charts_status(),{
        for (check in charts_status()){
            ## code to toggle css for chart-specific tab here
            shinyjs::toggleClass(selector= paste0("#sg-safetyGraphicsApp li.dropdown ul li a[data-value='", check$chart, "']"), class="valid", condition=check$status=="valid")
            shinyjs::toggleClass(selector= paste0("#sg-safetyGraphicsApp li.dropdown ul li a[data-value='", check$chart, "']"), class="invalid", condition=check$status=="invalid")
            shinyjs::toggleClass(selector= paste0("#sg-safetyGraphicsApp li.dropdown ul li a[data-value='", check$chart, "']"), class="missing", condition=check$status=="missing")

        }
    })

    # Initialize the Setting tab
    callModule(settingsTab, "settings", domains = domainData,  metadata=meta, mapping=current_mapping, charts = charts)
}

