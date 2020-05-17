library(shiny)
library(safetyGraphics)
library(dplyr)

reactlogReset()
measure_meta <- meta%>%filter(domain=="labs")%>%filter(col_key=="measure_col")
mm_default<-data.frame(
    text_key = c("measure_col", "measure_col--ALP"), 
    current = c("PARAM","Alkaline Phosphatase (U/L)"),
    stringsAsFactors = FALSE
)
labs_default <- meta %>% 
    filter(domain=="labs")%>% 
    mutate(current=standard_sdtm)%>%
    select(text_key,current) 

aes_default <- meta %>% 
    filter(domain=="aes")%>% 
    mutate(current=standard_sdtm)%>%
    select(text_key,current) 

ui <- tagList(
    tags$head(
         tags$link(
             rel = "stylesheet",
             type = "text/css",
             href = "index.css"
         )
    ),
    fluidPage(
        h2("Example 1: Labs Domain - measure only - no defaults"),
        mappingDomainUI("labs_one_col",measure_meta,labs),
        tableOutput("ex1Out"),  
        h2("Example 2: Labs Domain - measure only - with defaults"),
        mappingDomainUI("labs_one_col_defaults",measure_meta,labs,mm_default),
        tableOutput("ex2Out"),  
        h2("Example 3: AE Domain - no defaults"),
        mappingDomainUI("ae_NoDefault",meta%>%filter(domain=="aes"),aes),
        tableOutput("ex3Out"),    
        h2("Example 4: AE Domain - with defaults"),
        mappingDomainUI("ae_default",meta%>%filter(domain=="aes"),aes, aes_default),
        tableOutput("ex4Out"),    
        h2("Example 5: Labs Domain - no defaults"),
        mappingDomainUI("labs_NoDefault",meta%>%filter(domain=="labs"),labs),
        tableOutput("ex5Out"),   
        h2("Example 6: Labs Domain - with defaults"),
        mappingDomainUI("labs_default",meta%>%filter(domain=="labs"),labs,labs_default),
        tableOutput("ex6Out"),   
    )  
)
server <- function(input,output,session){
 ex1<-callModule(mappingDomain, "labs_one_col", measure_meta, labs)
 exportTestValues(ex1_data = { ex1() })
 output$ex1Out<-renderTable(ex1())
    
 ex2<-callModule(mappingDomain, "labs_one_col_defaults", measure_meta, labs)
 exportTestValues(ex2_data = { ex2() })
 output$ex2Out<-renderTable(ex2())
 
 ex3<-callModule(mappingDomain, "ae_NoDefault", meta%>%filter(domain=="aes"), aes)
 exportTestValues(ex3_data = { ex3() })
 output$ex3Out<-renderTable(ex3())
 
 ex4<-callModule(mappingDomain, "ae_default", meta%>%filter(domain=="aes"), aes)
 exportTestValues(ex4_data = { ex4() })
 output$ex4Out<-renderTable(ex4())
 
 ex5<-callModule(mappingDomain, "labs_NoDefault", meta%>%filter(domain=="labs"), labs)
 exportTestValues(ex5_data = { ex5() })
 output$ex5Out<-renderTable(ex5())

 ex6<-callModule(mappingDomain, "labs_default", meta%>%filter(domain=="labs"), labs)
 output$ex6Out<-renderTable(ex6())
 
}

options(shiny.reactlog = TRUE)
shinyApp(ui, server)