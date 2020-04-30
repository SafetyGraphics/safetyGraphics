library(shiny)
library(safetyGraphics)

ui <- tagList(
    tags$head(
         tags$link(
             rel = "stylesheet",
             type = "text/css",
             href = "index.css"
         )
    ),
    fluidPage(
        h2("Example 1: Column select - No Default"),
        mappingSelectUI("NoDefault","Subject ID", names(aes)),
        verbatimTextOutput("ex1Out"),
        
        h2("Example 2: Column Select - With default"),
        mappingSelectUI("WithDefault", "Subject ID", names(aes), "USUBJID"),
        verbatimTextOutput("ex2Out"),
        
        h2("Example 3: Field select - No Default"),
        mappingSelectUI("NoDefaultField","Body System - Cardiac Disorders", unique(aes$AEBODSYS)),
        verbatimTextOutput("ex3Out"),
        
        h2("Example 4: Field Select - With default"),
        mappingSelectUI("WithDefaultField", "Body System - Cardiac Disorders", unique(aes$AEBODSYS), "CARDIAC DISORDERS"),
        verbatimTextOutput("ex4Out")
    )  
)
server <- function(input,output,session){
 ex1<-callModule(mappingSelect, "NoDefault")
 output$ex1Out<-renderPrint(paste("Example 1 Select =",ex1()))
 ex2<-callModule(mappingSelect, "WithDefault")
 output$ex2Out<-renderPrint(paste("Example 2 Select =",ex2()))
 ex3<-callModule(mappingSelect, "NoDefaultField")
 output$ex3Out<-renderPrint(paste("Example 3 Select =",ex3()))
 ex4<-callModule(mappingSelect, "WithDefaultField")
 output$ex4Out<-renderPrint(paste("Example 4 Select =",ex4()))
}

shinyApp(ui, server)