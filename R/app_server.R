#' Server for the default safetyGraphics shiny app
#'
#' This function returns a server function suitable for use in shiny::runApp()
#' 

#' @param meta data frame containing the metadata for use in the app. See the preloaded file (\code{?safetyGraphics::meta}) for more data specifications and details. Defaults to \code{safetyGraphics::meta}. 
#' @param domainData named list of data.frames to be loaded in to the app.
#' @param mapping current mapping
#' @param charts list of charts to include in the app
#' @param filterDomain domain used for the data/filter tab. Demographics ("`dm`") is used by default. Using a domain that is not one record per participant is not recommended. 
#' 
#' @import shiny
#' @import dplyr
#' @importFrom purrr map
#' @importFrom shinyjs html
#' 
#' @export
#' 

app_server <- function(meta, mapping, domainData, charts, filterDomain){
    server <- function(input, output, session) {

        #Initialize modules
        current_mapping<-callModule(mappingTab, "mapping", meta, domainData)
        
        # Initialize the filter tab 
        filtered_data<-callModule(
            filterTab, 
            "filter", 
            domainData=domainData, 
            filterDomain=filterDomain, 
            current_mapping=current_mapping
        )
        

        callModule(settingsData, "dataSettings", domains = domainData)
        callModule(settingsMapping, "metaSettings", metadata=meta, mapping=current_mapping)
        callModule(settingsCharts, "chartSettings", charts = charts)
        callModule(homeTab, "home")

        #Initialize Chart UI - Adds subtabs to chart menu - this initializes initializes chart UIs
        charts %>% purrr::map(chartsNav)

        #Initialize Chart Servers
        validDomains <- tolower(names(mapping))
        charts %>% purrr::map(
            ~callModule(
                module=chartsTab,
                id=.x$name,
                chart=.x,
                data=filtered_data,
                mapping=current_mapping    
            )
        )
        
        # pass all charts, filtered data, and current mappings to reports/export tab
        callModule(reportsTab, "reports", charts = charts, data = filtered_data, mapping = current_mapping)

    }
    return(server)
}

