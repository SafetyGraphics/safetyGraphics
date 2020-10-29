
app_server <- function(input, output, session, meta, mapping, domainData, chartsList){
    server <- function(input, output, session) {
        #Initialize modules
        #TODO: 
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
        callModule(settingsCharts, "chartSettings",charts = chartsList)
        callModule(homeTab, "home")

        #Initialize Chart UI - Adds subtabs to chart menu and initializes chart UIs
        chartsList %>% map(~chartsNav(chart=.x$chart, label=.x$label, type=.x$type, package=.x$package))

        #Initialize Chart Servers
        validDomains <- tolower(names(mapping))
        chartsList %>% map(
            ~callModule(
                chartsTab,
                .x$chart,
                chart=.x$chart,
                chartFunction=.x$chartFunction,
                initFunction=.x$initFunction,
                type=.x$type,
                package=.x$package,
                domain=.x$domain,
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

