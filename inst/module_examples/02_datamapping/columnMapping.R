library(shiny)
library(safetyGraphics)
library(shinyjs)

ui <- tagList(
    useShinyjs(),
    tags$head(
         tags$link(
             rel = "stylesheet",
             type = "text/css",
             href = "index.css"
         )
    ),
    fluidPage(
        h2("Example 1: Column select - No Default"),
        columnMappingInput("NoDefault","Subject ID", names(aes)),
        verbatimTextOutput("ex1Out"),
        
        h2("Example 2: Column Select - With default"),
        columnMappingInput("WithDefault", "Subject ID", names(aes), "USUBJID"),
        verbatimTextOutput("ex2Out")
        
    )  
)
server <- function(input,output,session){
 ex1<-callModule(columnMapping, "NoDefault")
 output$ex1Out<-renderPrint(paste("Example 1 Select =",ex1()))
 ex2<-callModule(columnMapping, "WithDefault")
 output$ex2Out<-renderPrint(paste("Example 2 Select =",ex2()))
 
 
}

shinyApp(ui, server)