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
        mappingDomainUI("ae_NoDefault",meta%>%filter(domain=="aes"),aes),
        verbatimTextOutput("ex1Out"),    
        h2("Example 2: Labs Domain - no defaults"),
        mappingDomainUI("labs_NoDefault",meta%>%filter(domain=="labs"),labs),
        verbatimTextOutput("ex2Out"),   
    )  
)
server <- function(input,output,session){
 ex1<-callModule(mappingDomain, "ae_NoDefault", meta%>%filter(domain=="aes"), aes)
 output$ex1Out<-renderPrint(str(ex1()))
 
 ex2<-callModule(mappingDomain, "labs_NoDefault", meta%>%filter(domain=="labs"), labs)
 output$ex2Out<-renderPrint(str(ex2()))
 
}

shinyApp(ui, server)