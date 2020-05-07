library(shiny)
library(safetyGraphics)
library(dplyr)

reactlogReset()
measure_meta <- meta%>%filter(domain=="labs")%>%filter(col_key=="measure_col")
ui <- tagList(
    tags$head(
         tags$link(
             rel = "stylesheet",
             type = "text/css",
             href = "index.css"
         )
    ),
    fluidPage(
        h2("Example 1: Labs Domain - measure only - no defaults"),
        mappingDomainUI("labs_one_col",measure_meta,labs),
        verbatimTextOutput("ex1Out"),  
        h2("Example 2: AE Domain - no defaults"),
        mappingDomainUI("ae_NoDefault",meta%>%filter(domain=="aes"),aes),
        verbatimTextOutput("ex2Out"),    
        h2("Example 3: Labs Domain - no defaults"),
        mappingDomainUI("labs_NoDefault",meta%>%filter(domain=="labs"),labs),
        verbatimTextOutput("ex3Out"),   
    )  
)
server <- function(input,output,session){
 ex1<-callModule(mappingDomain, "labs_one_col", measure_meta, labs)
 output$ex1Out<-renderPrint(str(ex1()))
    
 ex2<-callModule(mappingDomain, "ae_NoDefault", meta%>%filter(domain=="aes"), aes)
 output$ex2Out<-renderPrint(str(ex2()))
 
 ex3<-callModule(mappingDomain, "labs_NoDefault", meta%>%filter(domain=="labs"), labs)
 output$ex3Out<-renderPrint(str(ex3()))
 
}

options(shiny.reactlog = TRUE)
shinyApp(ui, server)