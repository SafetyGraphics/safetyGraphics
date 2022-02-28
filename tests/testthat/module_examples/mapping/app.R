library(shiny)
library(safetyGraphics)
library(dplyr)


meta <- rbind(
  safetyCharts::meta_labs,
  safetyCharts::meta_aes,
  safetyCharts::meta_dm,
  safetyCharts::meta_hepExplorer
)


#reactlogReset()
allData <- list(labs=safetyData::adam_adlbc, aes=safetyData::adam_adae)
labs_default <- meta %>% 
    filter(domain=="labs")%>% 
    mutate(current=standard_sdtm)%>%
    select(domain,text_key,current) 
aes_default <- meta %>% 
    filter(domain=="aes")%>% 
    mutate(current=standard_sdtm)%>%
    select(domain,text_key,current) 
mapping<-rbind(labs_default,aes_default)
meta_sub <- meta %>% filter(domain %in% c("aes","labs"))

ui <- tagList(
    tags$head(
         tags$link(
             rel = "stylesheet",
             type = "text/css",
             href = "index.css"
         )
    ),
    fluidPage(
        h2("Example 1: Labs+AEs - no defaults"),
        mappingTabUI("ex1", meta_sub , allData),
        tableOutput("ex1Out"),  
        h2("Example 2: Labs+AEs - with defaults"),
        mappingTabUI("ex2", meta_sub, allData, mapping),
        tableOutput("ex2Out"),
    )  
)
server <- function(input,output,session){
 ex1<-callModule(mappingTab, "ex1",  meta_sub, allData)
 exportTestValues(ex1_data = { ex1() })
 output$ex1Out<-renderTable(ex1())
    
 ex2<-callModule(mappingTab, "ex2", meta_sub, allData)
 exportTestValues(ex2_data = { ex2() })
 output$ex2Out<-renderTable(ex2())
}

#options(shiny.reactlog = TRUE)
shinyApp(ui, server)