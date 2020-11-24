library(shiny)
library(safetyGraphics)
reactlogReset()

ui <- tagList(
  fluidPage(
    h1("Example 1: Labs Only"),
    settingsDataUI("ex1",  list(labs=labs)),
    h2("Example 2: Labs+AES"),
    settingsDataUI("ex2", list(labs=labs,aes=aes)),
    # h2("Example 3: Labs+AEs+Extras"),
    # settingsDataUI("ex3")
  )  
)

server <- function(input,output,session){
  callModule(settingsData, "ex1", domains = list(labs=labs))
  callModule(settingsData, "ex2", domains = list(labs=labs,aes=aes))
  # callModule(settingsData, "ex3", allData = rbind(lab_summary,ae_summary,extra) )
}

options(shiny.reactlog = TRUE)
shinyApp(ui, server)