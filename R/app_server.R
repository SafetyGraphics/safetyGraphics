#' Server for the default safetyGraphics shiny app
#'
#' This function returns a server function suitable for use in shiny::runApp()
#' 
#' @param input app input 
#' @param output app output
#' @param session app session
#' @param meta data frame containing the metadata for use in the app. See the preloaded file (\code{?safetyGraphics::meta}) for more data specifications and details. Defaults to \code{safetyGraphics::meta}. 
#' @param domainData named list of data.frames to be loaded in to the app.
#' @param chartsList list of charts to include in the app
#' 
#' @export
app_server <- function(input, output, session, meta, mapping, domainData, charts){
    server <- function(input, output, session) {
        #Initialize modules
        

        #TODO: add mapping to function call. 
        current_mapping<-callModule(mappingTab, "mapping", meta, domainData)

        id_col <- reactive({
            dm<-current_mapping()%>%filter(domain=="dm")   
            id<-dm %>%filter(text_key=="id_col")%>%pull(current)
            return(id)
        })

        filtered_data<-callModule(
            filterTab, 
            "filter", 
            domainData=domainData, 
            filterDomain="dm", 
            id_col=id_col
        )

        callModule(settingsData, "dataSettings", domains = domainData, filtered=filtered_data)
        callModule(settingsMapping, "metaSettings", metaIn=meta, mapping=current_mapping)
        callModule(settingsCharts, "chartSettings",charts = charts)
        callModule(homeTab, "home")

        #Initialize Chart UI - Adds subtabs to chart menu - this initializes initializes chart UIs
        charts %>% map(~chartsNav(name=.x$name, label=.x$label, type=.x$type, package=.x$package))

        #Initialize Chart Servers
        validDomains <- tolower(names(mapping))
        charts %>% map(
            ~callModule(
                module=chartsTab,
                id=.x$name,
                chart=.x,
                data=filtered_data,
                mapping=current_mapping    
            )
        )

        #participant count in header
        shinyjs::html("header-count", paste(dim(domainData[["dm"]])[1]))
        shinyjs::html("header-total", paste(dim(domainData[["dm"]])[1]))
        observe({
            req(filtered_data)
            shinyjs::html("header-count", paste0(dim(filtered_data()[["dm"]])[1]))
        })
    }
    return(server)
}

