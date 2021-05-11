library(shiny)
library(dplyr)
#library(safetyGraphics)
devtools::load_all()

#reactlogReset()

ui <- tagList(
    tags$head(
        tags$link(
            rel = "stylesheet",
            type = "text/css",
            href = "index.css"
        )
    ),
    navbarPage(
        "safetyGraphics",
        tabPanel(
            "Example 1", 
            h2("Example 1: Defaults"),
            verbatimTextOutput("ex1Out"),  
            filterTabUI("ex1")
        ),
        tabPanel(
            "Example 2", 
            h2("Example 2: Labs only (Filters disabled)"),
            verbatimTextOutput("ex2Out"),  
            filterTabUI("ex2")
        )
    )
)

server <- function(input,output,session){

    ex1_data <- list(
        labs=safetyData::adam_adlbc, 
        aes=safetyData::adam_adae, 
        dm=safetyData::adam_adsl
    )

    ex1_mapping <- meta %>% 
        mutate(current=standard_adam)%>%
        select(domain, text_key,current) 

    ex1<-callModule(
        filterTab, 
        "ex1", 
        domainData=ex1_data, 
        filterDomain="dm", 
        current_mapping=reactive({ex1_mapping}),
        tabID="Example 1"
    )
        
    exportTestValues(ex1_data = { ex1() })
    output$ex1Out<-renderText(
        paste(
            purrr::map2(
                ex1(),
                names(ex1()),
                ~{paste(.y,"-", dim(.x)[1],"x",dim(.x)[2])}
            ),
            collapse="/"
        )
    )

    ex2<-callModule(
        filterTab, 
        "ex2", 
        domainData=list(labs=safetyData::adam_adlbc), 
        filterDomain=NULL, 
        current_mapping=reactive({mapping}),
        tabID="Example 2"
    )
        
    exportTestValues(ex2_data = { ex2() })

    
    output$ex2Out<-renderText(
        paste(
            purrr::map2(
                ex2(),
                names(ex2()),
                ~{paste(.y,"-", dim(.x)[1],"x",dim(.x)[2])}
            ),
            collapse="/"
        )
    )
}

#options(shiny.reactlog = TRUE)
devtools::load_all()
shinyApp(ui, server)
