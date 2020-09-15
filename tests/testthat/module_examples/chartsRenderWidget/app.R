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

dataR <- reactive({domainData})
mappingR <- reactive({mapping})

# Test app code

header <- dashboardHeader(title = span("chartRendererWidget module Test page"))
body<-dashboardBody(
  tabItems(
    tabItem(
      tabName="ex1-tab",
      {
        h2("Example 1 - hepexplorer- called directly from safetyGraphics hepexplorer")
        chartsRenderWidgetUI("ex1",widgetName="hepexplorer")        
      }

    ),
    tabItem(
      tabName="ex2-tab",
      {
        h2("Example 2 - AE Explorer - called from safetyexploreR using custom init function")
        chartsRenderWidgetUI("ex2",widgetName="aeExplorer",widgetPackage="safetyexploreR")  
      }
    ),
    tabItem(
      tabName="ex3-tab",
      {
        h2("Example 3 - Results over time - called from safetyexploreR")
        chartsRenderWidgetUI("ex3",widgetName="safetyResultsOverTime",widgetPackage="safetyexploreR")  
      }
    )
  )
)

sidebar <- shinydashboard::dashboardSidebar(
  shinydashboard::sidebarMenu(
    id = "sidebar_tabs",
    menuItem(text = 'Ex1: hepexplorer', tabName = 'ex1-tab', icon = icon('angle-right')),
    menuItem(text = 'Ex2: aeExplorer', tabName = 'ex2-tab', icon = icon('angle-right')),
    menuItem(text = 'Ex3: safetyResultsOverTime', tabName = 'ex3-tab', icon = icon('angle-right'))
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
     callModule(
        chartsRenderWidget,
        "ex1",
        widgetName="hepexplorer",
        data=dataR,
        mapping=mappingR,
        domain="labs"
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
    
    callModule(
      chartsRenderWidget,
      "ex2",
      widgetName="aeExplorer",
      widgetPackage="safetyexploreR",
      data=dataR,
      mapping=mappingR,
      domain="aes",
      initFunction=initAEE
    )
    
    #Example 3 - results over time
    callModule(
      chartsRenderWidget,
      "ex3",
      widgetName="safetyResultsOverTime",
      widgetPackage="safetyexploreR",
      data=dataR,
      mapping=mappingR,
      domain="labs"
      #initFunction=initAEE
    )
}

shinyApp(ui, server)