library(shiny)
library(safetyGraphics)

lab_summary<-tibble_row(domain="labs",name="labs",standard="STDM",df=list(labs))
ae_summary<-tibble_row(domain="aes",name="aes",standard="SDTM",df=list(aes))
extra<-tibble_row(domain="none",name="cars",standard='None', df=list(cars))

reactlogReset()

ui <- tagList(

  fluidPage(
    h1("Example 1: Labs Only"),
    settingsDataUI("ex1"),
    h2("Example 2: Labs+AES"),
    settingsDataUI("ex2"),
    h2("Example 3: Labs+AEs+Extras"),
    settingsDataUI("ex3")
  )  
)
server <- function(input,output,session){
  callModule(settingsData, "ex1", allData = lab_summary)
  callModule(settingsData, "ex2", allData = rbind(lab_summary,ae_summary))
  callModule(settingsData, "ex3", allData = rbind(lab_summary,ae_summary,extra) )
}

options(shiny.reactlog = TRUE)
shinyApp(ui, server)