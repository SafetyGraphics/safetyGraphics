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
dataR<-reactive({domainData})
mappingR<-reactive({mapping})

# Test app code
header <- dashboardHeader(title = span("chartRendererWidget module Test page"))
body<-dashboardBody(
  tabItems(
    tabItem(
      tabName="ex1-tab",
      {
        h2("Example 1 - hepexplorer- called directly from safetyGraphics hepexplorer")
        chartsTabUI("ex1",chart="hepexplorer",package="safetyGraphics",label="Hepatic Explorer",type="htmlwidget")        
      }

    ),
    tabItem(
      tabName="ex2-tab",
      {
        h2("Example 2 - AE Explorer - called from safetyexploreR using custom init function")
        chartsTabUI("ex2",chart="aeExplorer",package="safetyexploreR",label="AE Explorer",type="htmlwidget")  
      }
    ),
    tabItem(
      tabName="ex3-tab",
      {
        h2("Example 3 - Results over time - called from safetyexploreR")
        chartsTabUI("ex3",chart="safetyResultsOverTime",label="Lab Results Over Time", package="safetyexploreR",type="htmlwidget")  
      }
    ),
    tabItem(
      tabName="ex4-tab",
      {
        h2("Example 4 - Helloworld static chart")
        chartsTabUI("ex4",chart="HelloWorld",label="Hello World",type="static")  
      }
    ),
    tabItem(
      tabName="ex5-tab",
      {
        h2("Example 5 - Helloworld static chart")
        chartsTabUI("ex5",chart="Boxplot1",label="Box Plot 1",type="static")  
      }
    ),
    tabItem(
      tabName="ex6-tab",
      {
        h2("Example 6 - Helloworld static chart")
        chartsTabUI("ex6",chart="Boxplot2",label="Custom Box Plot",type="static")  
      }
    )
  )
)

sidebar <- shinydashboard::dashboardSidebar(
  shinydashboard::sidebarMenu(
    id = "sidebar_tabs",
    menuItem(text = 'Ex1: hepexplorer', tabName = 'ex1-tab', icon = icon('angle-right')),
    menuItem(text = 'Ex2: aeExplorer', tabName = 'ex2-tab', icon = icon('angle-right')),
    menuItem(text = 'Ex3: safetyResultsOverTime', tabName = 'ex3-tab', icon = icon('angle-right')),
    menuItem(text = 'Ex4: static hello world', tabName = 'ex4-tab', icon = icon('angle-right')),
    menuItem(text = 'Ex5: static box plot', tabName = 'ex5-tab', icon = icon('angle-right')),
    menuItem(text = 'Ex6: custom box plot', tabName = 'ex6-tab', icon = icon('angle-right'))
    
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
        chartsTab,
        "ex1",
        chart="hepexplorer",
        type="htmlwidget",
        package="safetyGraphics",
        domain="labs",
        data=dataR,
        mapping=mappingR
        
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
      chartsTab,
      "ex2",
      chart="aeExplorer",
      package="safetyexploreR",
      type="htmlwidget",
      domain="aes",
      data=dataR,
      mapping=mappingR,
      initFunction=initAEE
    )
    
    #Example 3 - results over time
    callModule(
      chartsTab,
      "ex3",
      chart="safetyResultsOverTime",
      package="safetyexploreR",
      domain="labs",
      type="htmlwidget",
      data=dataR,
      mapping=mappingR
    )
    
    #Example 4 - hello world
    helloWorld <- function(data,settings){
      plot(-1:1, -1:1)
      text(runif(20, -1,1),runif(20, -1,1),"Hello World")
    }
    
    callModule(
      chartsTab,
      "ex4",
      chart="HelloWorld",
      data=dataR,
      mapping=mappingR,
      type="static",
      chartFunction=helloWorld
    )
    
    #Example 5
    boxPlot <- function(data,settings){
      mapped_data <- data %>%
        select(CustomValue = settings$value_col, CustomMeasure = settings$measure_col)%>%
        filter(!is.na(CustomValue))
      ggplot(data = mapped_data, aes(x = CustomMeasure, y = CustomValue)) + 
        geom_boxplot() +
        scale_y_log10() +
        theme_bw() + 
        theme(axis.text.x = element_text(angle = 25, hjust = 1),
              axis.text = element_text(size = 12),
              axis.title = element_text(size = 12))
    }
    
    callModule(
      chartsTab,
      "ex5",
      chart="Boxplot1",
      chartFunction=boxPlot,
      type="static",
      domain="labs",
      data=dataR,
      mapping=mappingR
    )
    
    #Example 3
    dataInit <- function(data,settings){
      mapped_data <- data %>%
        select(Value = settings[["value_col"]], Measure = settings[["measure_col"]])%>%
        filter(!is.na(Value))
      settings$boxcolor="blue"
      return(list(data=mapped_data,settings=settings))
    }
    
    boxPlot2 <- function(data,settings){
      ggplot(data = data, aes(x = Measure, y = Value)) + 
        geom_boxplot(fill = settings[["boxcolor"]]) +
        scale_y_log10() +
        theme_bw() + 
        theme(axis.text.x = element_text(angle = 25, hjust = 1),
              axis.text = element_text(size = 12),
              axis.title = element_text(size = 12))
    }
    
    callModule(
      chartsTab,
      "ex6",
      chartFunction=boxPlot2,
      chart="Boxplot2",
      data=dataR,
      domain="labs",
      mapping=mappingR,
      initFunction=dataInit,
      type="static"
    )
}

shinyApp(ui, server)