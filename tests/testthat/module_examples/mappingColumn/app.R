library(shiny)
library(safetyGraphics)
library(dplyr)

reactlogReset()

meta <- rbind(
  safetyCharts::meta_labs,
  safetyCharts::meta_aes,
  safetyCharts::meta_dm,
  safetyCharts::meta_hepExplorer
)


id_meta <- meta%>%filter(domain=="labs")%>%filter(col_key=="id_col")
measure_meta <- meta%>%filter(domain=="labs")%>%filter(col_key=="measure_col")
id_default<-data.frame(
    text_key="id_col",
    current="USUBJID",
    stringsAsFactors=FALSE
)

adam_default<-data.frame(
    text_key = c("measure_col", "measure_values--ALP"), 
    current = c("PARAM","Alkaline Phosphatase (U/L)"),
    stringsAsFactors = FALSE
)

sdtm_default<-data.frame(
    text_key = c("measure_col", "measure_values--ALP"), 
    current = c("LBTEST","Alkaline Phosphatase"),
    stringsAsFactors = FALSE
)


ui <- tagList(
    tags$head(
        tags$link(
            rel = "stylesheet",
            type = "text/css",
            href = "index.css"
        )
    ),
    fluidPage(
        h2("Example 1: labs id_col"),
        mappingColumnUI("ex1", id_meta, safetyData::adam_adlbc),
        tableOutput("ex1Out"),
        h2("Example 2: labs id_col + default"),
        mappingColumnUI("ex2", id_meta, safetyData::adam_adlbc, id_default),
        tableOutput("ex2Out"),
        h2("Example 3: labs measure_col + fields"),
        mappingColumnUI("ex3",measure_meta, safetyData::adam_adlbc),
        tableOutput("ex3Out"),
        h2("Example 4: labs measure_col + fields + defaults"),
        mappingColumnUI("ex4",measure_meta, safetyData::adam_adlbc, adam_default),
        tableOutput("ex4Out"),
        # SDTM Examples
        h2("Example 5: SDTM labs measure_col + fields"),
        mappingColumnUI("ex5",measure_meta, safetyData::sdtm_lb),
        tableOutput("ex5Out"),
        h2("Example 6: SDTM labs measure_col + fields + defaults"),
        mappingColumnUI("ex6",measure_meta, safetyData::sdtm_lb, sdtm_default),
        tableOutput("ex6Out")
    )  
)

server <- function(input,output,session){
    ex1<-callModule(mappingColumn, "ex1", id_meta, safetyData::adam_adlbc)
    exportTestValues(ex1_data = { ex1() })
    output$ex1Out<-renderTable(ex1())

    ex2<-callModule(mappingColumn, "ex2", id_meta, safetyData::adam_adlbc)
    exportTestValues(ex2_data = { ex2() })
    output$ex2Out<-renderTable(ex2())

    ex3<-callModule(mappingColumn, "ex3", measure_meta, safetyData::adam_adlbc)
    exportTestValues(ex3_data = { ex3() })
    output$ex3Out<-renderTable(ex3())

    ex4<-callModule(mappingColumn, "ex4", measure_meta, safetyData::adam_adlbc)
    exportTestValues(ex4_data = {ex4()})
    output$ex4Out<-renderTable(ex4())

    ex5<-callModule(mappingColumn, "ex5", measure_meta, safetyData::sdtm_lb)
    exportTestValues(ex5_data = { ex5() })
    output$ex5Out<-renderTable(ex5())

    ex6<-callModule(mappingColumn, "ex6", measure_meta, safetyData::sdtm_lb)
    exportTestValues(ex6_data = {ex6()})
    output$ex6Out<-renderTable(ex6())
}

# tell shiny to log all reactivity
options(shiny.reactlog = TRUE)
shinyApp(ui, server)
#shiny::showReactLog()
