library(shiny)
library(safetyGraphics)
library(dplyr)

ui <- tagList(
    tags$head(
         tags$link(
             rel = "stylesheet",
             type = "text/css",
             href = "index.css"
         )
    ),
    fluidPage(
        h2("Example 1: AE Domain - no defaults"),
        mappingDomainUI("NoDefault",meta%>%filter(domain=="aes"),aes),
        dataTableOutput("ex1Out"),      
       
    )  
)
server <- function(input,output,session){
 ex1<-callModule(mappingDomain, "NoDefault", meta%>%filter(domain=="aes"))
 output$ex1Out<-renderDataTable(ex1())
}

shinyApp(ui, server)