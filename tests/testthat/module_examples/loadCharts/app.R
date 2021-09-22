
library(shiny)
library(safetyGraphics)
library(shinyjs)
# reactlogReset()
# devtools::load_all()
ui <- tagList(
  useShinyjs(),
  fluidPage(
    h1("App Loader Demo"),
    loadChartsUI("load-charts"),
    textOutput("ex1Out")
  )
)

server <- function(input,output,session){
  charts<-callModule(loadCharts, "ex1") #charts reactive
  output$ex1Out<-renderPrint(ex1_data())
}

# options(shiny.reactlog = TRUE)
# devtools::load_all()
shinyApp(ui, server)
