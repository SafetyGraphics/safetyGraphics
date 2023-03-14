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

safetyGraphicsServer <- function(input, output, session,
    meta,
    mapping,
    domainData,
    charts,
    filterDomain,
    config
) {
    # Initialize the Home tab.
    callModule(
        homeTab,
        "home",
        config
    )

    # Initialize the Mapping tab: returns the current mapping as a reactive.
    current_mapping<-callModule(
        mappingTab,
        "mapping",
        meta,
        domainData
    )

    # Initialize the Filter tab: returns a list of filtered data as a reactive.
    filtered_data<-callModule(
        filterTab, 
        "filter", 
        domainData=domainData, 
        filterDomain=filterDomain, 
        current_mapping=current_mapping
    )

    #Initialize Chart Servers
    module_outputs <- reactiveValues()
    charts %>%
        purrr::walk(function(chart) {
            module_output <- callModule(
                module=chartsNav,
                id=chart$name,
                chart=chart,
                data=filtered_data,
                mapping=current_mapping,
                module_outputs=module_outputs
            )

            module_outputs[[ chart$name ]] <- module_output

            return(module_output)
        })

    # Initialize the Setting tab.
    callModule(
        settingsTab,
        "settings",
        domains = domainData,
        metadata=meta,
        mapping=current_mapping,
        charts = charts
    )
}

