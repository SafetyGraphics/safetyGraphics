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
        h3("Module Output"),
        verbatimTextOutput("ex1"),
        
        h2("Example 2: Column Select - With default"),
        mappingSelectUI("WithDefault", "Subject ID", names(aes), "USUBJID"),
        h3("Module Output"),
        verbatimTextOutput("ex2"),
        
        h2("Example 3: Field select - No Default"),
        mappingSelectUI("NoDefaultField","Body System - Cardiac Disorders", unique(aes$AEBODSYS)),
        h3("Module Output"),
        verbatimTextOutput("ex3"),
        
        h2("Example 4: Field Select - With default"),
        mappingSelectUI("WithDefaultField", "Body System - Cardiac Disorders", unique(aes$AEBODSYS), "CARDIAC DISORDERS"),
        verbatimTextOutput("ex4")
    )  
)
server <- function(input,output,session){
 ex1<-callModule(mappingSelect, "NoDefault")
 output$ex1<-renderPrint(ex1())
 ex2<-callModule(mappingSelect, "WithDefault")
 output$ex2<-renderPrint(ex2())
 ex3<-callModule(mappingSelect, "NoDefaultField")
 output$ex3<-renderPrint(ex3())
 ex4<-callModule(mappingSelect, "WithDefaultField")
 output$ex4<-renderPrint(ex4())
}

shinyApp(ui, server)