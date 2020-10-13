library(shiny)
library(safetyGraphics)
library(ggplot2)
library(dplyr)
library(htmlwidgets)
library(devtools)
library(shinydashboard)
#devtools::install_github('RhoInc/safetyexploreR')
library(safetyexploreR)


domainData <- list(labs=safetyGraphics::labs, aes=safetyGraphics::aes)
standards <- names(domainData) %>% lapply(function(domain){
  return(detectStandard(domain=domain, data = domainData[[domain]], meta=meta))
})
names(standards)<-names(domainData)
mapping_list <- standards %>% lapply(function(standard){
  return(standard[["mapping"]])
})
mapping<-bind_rows(mapping_list, .id = "domain")
mappingLabs <- generateMappingList(mapping,domain="labs", pull=TRUE)
mappingAEs <- generateMappingList(mapping,domain="aes", pull=TRUE)

# Test app code

header <- dashboardHeader(title = span("chartRendererWidget module Test page"))
body<-dashboardBody(
  tabItems(
    tabItem(
      tabName="ex1-tab",
      {
        h2("Example 1 - hepexplorer- called directly from safetyGraphics hepexplorer")
        chartsRenderWidgetUI("ex1",chart="eDISH",package="safetyexploreR")      
      }

    ),
    tabItem(
      tabName="ex2-tab",
      {
        h2("Example 2 - AE Explorer - called from safetyexploreR using custom init function")
        chartsRenderWidgetUI("ex2",chart="aeExplorer",package="safetyexploreR")  
      }
    ),
    tabItem(
      tabName="ex3-tab",
      {
        h2("Example 3 - Results over time - called from safetyexploreR")
        chartsRenderWidgetUI("ex3",chart="safetyResultsOverTime",package="safetyexploreR")  
      }
    )
  )
)

sidebar <- shinydashboard::dashboardSidebar(
  shinydashboard::sidebarMenu(
    id = "sidebar_tabs",
    menuItem(text = 'Ex1: Hepatic explorer', tabName = 'ex1-tab', icon = icon('angle-right')),
    menuItem(text = 'Ex2: AE Explorer', tabName = 'ex2-tab', icon = icon('angle-right')),
    menuItem(text = 'Ex3: Safety Results Over Time', tabName = 'ex3-tab', icon = icon('angle-right'))
  )
)


ui <- tagList(
  tags$head(
    tags$link(
      rel = "stylesheet",
      type = "text/css",
      href = "index.css"
    )
  ),
  dashboardPage(header=header, sidebar=sidebar, body=body) 
)

server <- function(input,output,session){
   # Example 1 - hep explorer
     paramsLabs <- reactive({list(data=domainData[["labs"]],settings=mappingLabs)})
     callModule(
        chartsRenderWidget,
        "ex1",
        chart="eDISH",
        package="safetyexploreR",
        params=paramsLabs
    )
  
    # Example 2 - AE Explorer
    initAEE <- function(data, settings){
      settings$variables=list(
        major=settings[["bodsys_col"]],
        minor=settings[["term_col"]],
        group="STUDYID",
        id=settings[["id_col"]],
        filters=list(),
        details=list()
      )
      return(list(data=data,settings=settings))
    }
    paramsAEs <- reactive({initAEE(data=domainData[["aes"]],settings=mappingAEs)})
    callModule(
      chartsRenderWidget,
      "ex2",
      chart="aeExplorer",
      package="safetyexploreR",
      params=paramsAEs
    )
    
    #Example 3 - results over time
    callModule(
      chartsRenderWidget,
      "ex3",
      chart="safetyResultsOverTime",
      package="safetyexploreR",
      params=paramsLabs
    )
}

shinyApp(ui, server)