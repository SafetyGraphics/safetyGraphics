library(shiny)
library(safetyGraphics)

partialMapping <- data.frame(
    domain=c("aes","labs","labs"),
    text_key=c("id_col","id_col","measure_col"),
    current=c("ID","myID","measure")
)

fullMapping<-read.csv('custom_mapping.csv')

ui <- tagList(
    tags$head(
    tags$link(
        rel = "stylesheet",
        type = "text/css",
        href = "index.css"
    )
    ),
    fluidPage(
        h1("Example 1: No Mapping"),
        metaMappingUI("NoMapping"),
        h2("Example 2: Partial Mapping"),
        metaMappingUI("PartialMapping"),
        h2("Example 3: Full Mapping"),
        metaMappingUI("FullMapping"),
    )  
)
server <- function(input,output,session){
 callModule(metaMapping, "NoMapping", metaIn = safetyGraphics::meta)
 callModule(metaMapping, "PartialMapping", metaIn = safetyGraphics::meta,  mapping=partialMapping )
 callModule(metaMapping, "FullMapping", metaIn = safetyGraphics::meta,   mapping=fullMapping)
}

shinyApp(ui, server)