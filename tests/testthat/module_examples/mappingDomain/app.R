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
        verbatimTextOutput("ex1Out"),  
        h2("Example 2: Labs Domain - measure only - with defaults"),
        mappingDomainUI("labs_one_col_defaults",measure_meta,labs,mm_default),
        verbatimTextOutput("ex2Out"),  
        h2("Example 3: AE Domain - no defaults"),
        mappingDomainUI("ae_NoDefault",meta%>%filter(domain=="aes"),aes),
        verbatimTextOutput("ex3Out"),    
        h2("Example 4: AE Domain - with defaults"),
        mappingDomainUI("ae_default",meta%>%filter(domain=="aes"),aes, aes_default),
        verbatimTextOutput("ex4Out"),    
        h2("Example 5: Labs Domain - no defaults"),
        mappingDomainUI("labs_NoDefault",meta%>%filter(domain=="labs"),labs),
        verbatimTextOutput("ex5Out"),   
        h2("Example 6: Labs Domain - with defaults"),
        mappingDomainUI("labs_default",meta%>%filter(domain=="labs"),labs,labs_default),
        verbatimTextOutput("ex6Out"),   
    )  
)
server <- function(input,output,session){
 ex1<-callModule(mappingDomain, "labs_one_col", measure_meta, labs)
 output$ex1Out<-renderPrint(str(ex1()))
    
 ex2<-callModule(mappingDomain, "labs_one_col_defaults", measure_meta, labs)
 output$ex2Out<-renderPrint(str(ex2()))
 
 ex3<-callModule(mappingDomain, "ae_NoDefault", meta%>%filter(domain=="aes"), aes)
 output$ex3Out<-renderPrint(str(ex3()))
 
 ex4<-callModule(mappingDomain, "ae_default", meta%>%filter(domain=="aes"), aes)
 output$ex4Out<-renderPrint(str(ex4()))
 
 ex5<-callModule(mappingDomain, "labs_NoDefault", meta%>%filter(domain=="labs"), labs)
 output$ex5Out<-renderPrint(str(ex5()))

 ex6<-callModule(mappingDomain, "labs_default", meta%>%filter(domain=="labs"), labs)
 output$ex6Out<-renderPrint(str(ex6()))
 
}

options(shiny.reactlog = TRUE)
shinyApp(ui, server)