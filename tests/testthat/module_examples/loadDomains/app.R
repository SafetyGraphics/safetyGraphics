library(shiny)
library(safetyGraphics)
library(shinyjs)
#reactlogReset()
devtools::load_all()
ui <- tagList(
  useShinyjs(),
  fluidPage(
    h1("Example 1: Load one data set - calls mod_loadData directly"),
    loadDataUI("ex1", domain="labs"),
    tableOutput("ex1Out"),
    h1("Example 2: Load 3 domains - calls mod_loadDomains"),
    loadDomainsUI("ex2", domains=c("labs","aes","dm")),
    tableOutput("ex2Out_labs"),
    tableOutput("ex2Out_aes"),
    tableOutput("ex2Out_dm")
  )
)

server <- function(input,output,session){
  ex1_data<-callModule(loadData, "ex1", domain="labs")
  output$ex1Out<-renderTable(ex1_data())
  ex2_data<-callModule(loadDomains, "ex2", domains=c("labs","aes","dm"))
  output$ex2Out_labs<-renderTable(ex2_data()$labs)
  output$ex2Out_aes<-renderTable(ex2_data()$aes)
  output$ex2Out_dm<-renderTable(ex2_data()$dm)
}

#options(shiny.reactlog = TRUE)
devtools::load_all()
shinyApp(ui, server)
