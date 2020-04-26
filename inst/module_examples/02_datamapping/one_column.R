library(shiny)
library(safetyGraphics)

ui <- tagList(
    # tags$head(
    #     tags$link(
    #         rel = "stylesheet",
    #         type = "text/css",
    #         href = "index.css"
    #     )
    # ),
    fluidPage(
        h2("Example 1: Column select - No Default"),
        columnMappingInput("NoDefault","Subject ID", names(aes)),
        #textOutput("ex1Out"),
        
        h2("Example 2: Column Select - With default"),
        columnMappingInput("WithDefault", "Subject ID", names(aes), "USUBJID"),
        #textOutput("ex2Out")
        
    )  
)
server <- function(input,output,session){
 ex1<-callModule(columnMapping, "NoDefault")
 #renderText("ex1Out",{paste("Example 1 Select =")})
 ex2<-callModule(columnMapping, "WithDefault")
 #renderText("ex2Out",{paste("Example 2 Select =")})
 
 
}

shinyApp(ui, server)