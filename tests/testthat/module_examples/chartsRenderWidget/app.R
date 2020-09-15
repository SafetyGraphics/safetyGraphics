library(shiny)
library(safetyGraphics)
library(ggplot2)
library(dplyr)
library(htmlwidgets)

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
ui <- tagList(
    tags$head(
    tags$link(
        rel = "stylesheet",
        type = "text/css",
        href = "index.css"
    )
    ),
    fluidPage(
        h2("Example 1: Hep explorer"),
        chartsRenderWidgetUI("ex1",widgetName="hepexplorer"),
    )  
)

server <- function(input,output,session){
        callModule(
        chartsRenderWidget, 
        "ex1", 
        widgetName="hepexplorer", 
        data=dataR, 
        mapping=mappingR,
        domain="labs"
    )
}

shinyApp(ui, server)