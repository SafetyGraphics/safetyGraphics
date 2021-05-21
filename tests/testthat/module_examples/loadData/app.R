library(shiny)
library(safetyGraphics)
#reactlogReset()
devtools::load_all()
ui <- tagList(
  fluidPage(
    h1("Example 1: Labs Only"),
    loadDataUI("ex1", domain="labs"),
    tableOutput("ex1Out")
  )
)

server <- function(input,output,session){
  ex1_data<-callModule(loadData, "ex1", domain="labs")
  output$ex1Out<-renderTable(ex1_data())
}

#options(shiny.reactlog = TRUE)
devtools::load_all()
shinyApp(ui, server)
