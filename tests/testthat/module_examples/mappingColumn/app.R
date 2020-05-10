library(shiny)
library(safetyGraphics)
library(dplyr)
library(reactlog)

id_meta <- meta%>%filter(domain=="labs")%>%filter(col_key=="id_col")
measure_meta <- meta%>%filter(domain=="labs")%>%filter(col_key=="measure_col")
mm_default<-list(measure_col="PARAM")
mm_default[["measure_col--ALT"]]<-"Alkaline Phosphatase (U/L)"

ui <- tagList(
    tags$head(
         tags$link(
             rel = "stylesheet",
             type = "text/css",
             href = "index.css"
         )
    ),
    fluidPage(
        # h2("Example 1: labs id_col"),
        # mappingColumnUI("ex1", id_meta, labs),
        # verbatimTextOutput("ex1Out"),
        # h2("Example 2: labs id_col + default"),
        # mappingColumnUI("ex2", id_meta, labs, list(id_col="USUBJID")),
        # verbatimTextOutput("ex2Out"),
        # h2("Example 3: labs measure_col + fields"),
        # mappingColumnUI("ex3",measure_meta, labs),
        # verbatimTextOutput("ex3Out"),
        h2("Example 4: labs measure_col + fields + defaults"),
        mappingColumnUI("ex4",measure_meta, labs, mm_default),
        verbatimTextOutput("ex4Out")
    )  
)

server <- function(input,output,session){
 # ex1<-callModule(mappingColumn, "ex1", id_meta, labs)
 # output$ex1Out<-renderPrint(str(ex1()))
 # 
 # ex2<-callModule(mappingColumn, "ex2", id_meta, labs)
 # output$ex2Out<-renderPrint(str(ex2()))
 # 
 # ex3<-callModule(mappingColumn, "ex3", measure_meta, labs)
 # output$ex3Out<-renderPrint(str(ex3()))
 
 ex4<-callModule(mappingColumn, "ex4", measure_meta, labs)
 output$ex4Out<-renderPrint(str(ex4()))
}

# tell shiny to log all reactivity
options(shiny.reactlog = TRUE)
shinyApp(ui, server)
#shiny::showReactLog()
