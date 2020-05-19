library(shiny)
library(safetyGraphics)

lab_summary<-tibble_row(domain="labs",name="labs",standard="STDM",df=list(labs))
ae_summary<-tibble_row(domain="aes",name="aes",standard="SDTM",df=list(aes))
extra<-tibble_row(domain="none",name="cars",standard='None', df=list(cars))


ui <- tagList(

  fluidPage(
    h1("Example 1: Labs Only"),
    dataMappingUI("ex1"),
    h2("Example 2: Labs+AES"),
    dataMappingUI("ex2"),
    h2("Example 3: Labs+AEs+Extras"),
    dataMappingUI("ex3")
  )  
)
server <- function(input,output,session){
  callModule(dataMapping, "ex1", allData = lab_summary)
  callModule(dataMapping, "ex2", allData = rbind(lab_summary,ae_summary))
  callModule(dataMapping, "ex3", allData = rbind(lab_summary,ae_summary,extra) )
}

shinyApp(ui, server)