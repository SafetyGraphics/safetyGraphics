library(shiny)
library(safetyGraphics)
library(dplyr)
library(reactlog)

id_meta <- meta%>%filter(domain=="labs")%>%filter(col_key=="id_col")
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
        #h2("Example 1: labs id_col"),
        #mappingColumnUI("ex1", id_meta, labs),
        #verbatimTextOutput("ex1Out"),    
        h2("Example 2: labs measure_col + fields"),
        mappingColumnUI("ex2",measure_meta, labs),
        verbatimTextOutput("ex2Out"),        
       
    )  
)
server <- function(input,output,session){
 ex1<-callModule(mappingColumn, "ex1", id_meta, labs)
 output$ex1Out<-renderPrint(str(ex1()))
 
 ex2<-callModule(mappingColumn, "ex2", measure_meta, labs)
 output$ex2Out<-renderPrint(str(ex2()))
}

# tell shiny to log all reactivity
options(shiny.reactlog = TRUE)
shinyApp(ui, server)
#shiny::showReactLog()
