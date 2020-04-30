library(shiny)
library(safetyGraphics)
library(dplyr)

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
        h2("Example 1: labs id_col"),
        mappingColumnUI("id_col",id_meta,labs),
        dataTableOutput("ex1Out"),    
        h2("Example 2: labs measure_col + fields"),
        mappingColumnUI("measure_col",measure_meta,labs),
        dataTableOutput("ex2Out"),        
       
    )  
)
server <- function(input,output,session){
 ex1<-callModule(mappingColumn, "id_col", id_meta)
 #output$ex1Out<-renderDataTable(ex1())
 #ex2<-callModule(mappingColumn, "measure_col", measure_meta)
 #output$ex2Out<-renderDataTable(ex2())
}

shinyApp(ui, server)
