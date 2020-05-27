library(shiny)
library(safetyGraphics)

domains <- list(labs=labs, aes=aes)
reactlogReset()

ui <- tagList(

  fluidPage(
    h1("Example 1: Labs Only"),
    settingsDataUI("ex1", domains),
    # h2("Example 2: Labs+AES"),
    # settingsDataUI("ex2"),
    # h2("Example 3: Labs+AEs+Extras"),
    # settingsDataUI("ex3")
  )  
)

server <- function(input,output,session){
  callModule(settingsData, "ex1", domains = domains)
  # callModule(settingsData, "ex2", allData = rbind(lab_summary,ae_summary))
  # callModule(settingsData, "ex3", allData = rbind(lab_summary,ae_summary,extra) )
}

options(shiny.reactlog = TRUE)
shinyApp(ui, server)