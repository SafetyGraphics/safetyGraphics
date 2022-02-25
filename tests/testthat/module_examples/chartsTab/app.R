library(shiny)
library(safetyGraphics)
library(ggplot2)
library(dplyr)
library(htmlwidgets)
library(shinydashboard)
library(safetyexploreR)


# Prep sample mapping and data objects
domainData <- list(
  labs=safetyData::adam_adlbc, 
  aes=safetyData::adam_adae,
  dm=safetyData::adam_adsl
)


meta <- meta <- rbind(
  safetyCharts::meta_labs,
  safetyCharts::meta_aes,
  safetyCharts::meta_dm,
  safetyCharts::meta_hepExplorer
)

mapping <- makeMapping(domainData, meta=meta, autoMapping=TRUE, customMapping=NULL)
dataR<-reactive({domainData})
mappingR<-reactive({mapping$mapping})

# Import safetyCharts chart objects and activate a module and static graphic
charts <- makeChartConfig()

# Custom charts
# Example 4 - hello world
helloWorld <- function(data,settings){
  plot(-1:1, -1:1)
  text(runif(20, -1,1),runif(20, -1,1),"Hello World")
}

helloworld_chart<-list(
  name="HelloWorld",
  label="Hello World!",
  type="plot",
  domain="aes",
  workflow=list(
    main="helloWorld"
  )
)
helloworld_chart <- makeChartConfigFunctions(helloworld_chart)

# Example 5 - box plot
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
  
box1_chart<-list(
  name="Box1",
  label="Standard Box plot",
  type="plot",
  domain="labs",
  workflow=list(
    main="boxPlot"
  )
)
box1_chart <- makeChartConfigFunctions(box1_chart)

# Example 6 - custom boxplot
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
box2_chart<-list(
  name="Box2",
  label="Custom Box plot",
  type="plot",
  domain="labs",
  workflow=list(
    main="boxPlot2",
    init="dataInit"
  )
)
box2_chart <- makeChartConfigFunctions(box2_chart)

# Test app code
header <- dashboardHeader(title = span("chartRendererWidget module Test page"))
body<-dashboardBody(
  tabItems(
    tabItem(
      tabName="ex1-tab",
      {
        h2("Example 1 - hepexplorer- called directly from safetyCharts")
        chartsTabUI("ex1",chart=charts[["hepExplorer"]])        
      }
     ),
    tabItem(
      tabName="ex2-tab",
      {
        h2("Example 2 - AE Explorer - called from safetyCharts with custom init")
        chartsTabUI("ex2",chart=charts[["aeExplorer"]])
      }
    ),
    tabItem(
      tabName="ex3-tab",
      {
        h2("Example 3 - Results over time - called from safetyCharts")
        chartsTabUI("ex3",chart=charts[["safetyResultsOverTime"]])  
      }
    ),
    tabItem(
      tabName="ex4-tab",
      {
        h2("Example 4 - Helloworld static chart")
        chartsTabUI("ex4",chart=helloworld_chart)  
      }
    ),
    tabItem(
      tabName="ex5-tab",
      {
        h2("Example 5 - Box plot")
        chartsTabUI("ex5",chart=box1_chart)  
      }
    ),
    tabItem(
      tabName="ex6-tab",
      {
        h2("Example 6 - Custom Box plot")
        chartsTabUI("ex6",chart=box2_chart)  
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
  callModule(
    chartsTab,
    "ex1",
    chart=charts[["hepExplorer"]],
    data=dataR,
    mapping=mappingR
  )
  
  # Example 2 - AE Explorer
  callModule(
    chartsTab,
    "ex2",
    chart=charts$aeExplorer,
    mapping=mappingR,
    data=dataR
  )
    
  #Example 3 - results over time
  callModule(
    chartsTab,
    "ex3",
    chart=charts$safetyResultsOverTime,
    data=dataR,
    mapping=mappingR
  )
  
  #Example 4 - hello world
  callModule(
    chartsTab,
    "ex4",
    chart=helloworld_chart,
    data=dataR,
    mapping=mappingR
  )
  
  #Example 5
  callModule(
    chartsTab,
    "ex5",
    chart=box1_chart,
    data=dataR,
    mapping=mappingR
  )
  
  #Example 6
  callModule(
    chartsTab,
    "ex6",
    chart=box2_chart,
    data=dataR,
    mapping=mappingR
  )
}

shinyApp(ui, server)
