library(shiny)
library(safetyGraphics)

ui <- fluidPage(  
  metaMappingUI("mm1")
)

server <- function(input,output,session){
 callModule(metaMapping, "mm1", metaIn = safetyGraphics::meta)
}

shinyApp(ui, server)