library(shiny)
library(dplyr)
library(shinydashboard)
library(safetyGraphics)

#reactlogReset()

ui <- tagList(
    shinyjs::useShinyjs(),
    tags$head(
        tags$link(
            rel = "stylesheet",
            type = "text/css",
            href = "index.css"
        )
    ),
    navbarPage(
        "Filters",
        id="safetyGraphicsApp",
        tabPanel("Home",
            h2("Example 1: Defaults - Filter Tab enabled"),
            verbatimTextOutput("ex1Out"),  
            h2("Example 2: Labs only + NULL filterDomain - Filter Tab disabled"),
            verbatimTextOutput("ex2Out"),
            h2("Example 3: Default data + Invalid filterDomain - Filter Tab disabled"),
            verbatimTextOutput("ex3Out"),
            h2("Example 4: Default data + id_col for filter domain not defined in meta- Filter Tab disabled"),
            verbatimTextOutput("ex4Out"),
            h2("Example 5: Default data + id_col not found in ae data - Filter Tab disabled"),
            verbatimTextOutput("ex5Out")  
        ),
        tabPanel(
            "Ex1", 
            h2("Example 1: Defaults"),
            filterTabUI("ex1")
        ),
        tabPanel(
            "Ex2", 
            filterTabUI("ex2")
        ),
        tabPanel(
            "Ex3", 
            filterTabUI("ex3")
        ),
        tabPanel(
            "Ex4", 
            filterTabUI("ex4")
        ),
        tabPanel(
            "Ex5", 
            filterTabUI("ex5")
        )
    )
)

server <- function(input,output,session){
    ###################
    #### Example 1 ####
    ###################
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
        tabID="Ex1",
        filterVars="SITEID"
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

    ###################
    #### Example 2 ####
    ###################
    ex2<-callModule(
        filterTab, 
        "ex2", 
        domainData=list(labs=safetyData::adam_adlbc), 
        filterDomain=NULL, 
        current_mapping=reactive({ex1_mapping}),
        tabID="Ex2"
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

    ###################
    #### Example 3 ####
    ###################
    ex3<-callModule(
        filterTab, 
        "ex3", 
        domainData=ex1_data, 
        filterDomain="notADomain", 
        current_mapping=reactive({ex1_mapping}),
        tabID="Ex3"
    )
        
    exportTestValues(ex3_data = { ex3() })

    output$ex3Out<-renderText(
        paste(
            purrr::map2(
                ex3(),
                names(ex3()),
                ~{paste(.y,"-", dim(.x)[1],"x",dim(.x)[2])}
            ),
            collapse="/"
        )
    )

    ###################
    #### Example 4 ####
    ###################
    mapping4<-ex1_mapping
    mapping4[mapping4$domain=="dm" & mapping4$text_key=="id_col","text_key"]<-"Not_id_col"

    ex4<-callModule(
        filterTab, 
        "ex4", 
        domainData=ex1_data, 
        filterDomain="dm", 
        current_mapping=reactive({mapping4}),
        tabID="Ex4"
    )
        
    exportTestValues(ex4_data = { ex4() })

    output$ex4Out<-renderText(
        paste(
            purrr::map2(
                ex4(),
                names(ex4()),
                ~{paste(.y,"-", dim(.x)[1],"x",dim(.x)[2])}
            ),
            collapse="/"
        )
    )

    ###################
    #### Example 5 ####
    ###################
    data5<- list(
        labs=safetyData::adam_adlbc, 
        aes=safetyData::adam_adae %>% rename(OtherID = USUBJID), 
        dm=safetyData::adam_adsl
    )

    ex5<-callModule(
        filterTab, 
        "ex5", 
        domainData=data5, 
        filterDomain="dm", 
        current_mapping=reactive({ex1_mapping}),
        tabID="Ex5"
    )
        
    exportTestValues(ex5_data = { ex5() })

    output$ex5Out<-renderText(
        paste(
            purrr::map2(
                ex5(),
                names(ex5()),
                ~{paste(.y,"-", dim(.x)[1],"x",dim(.x)[2])}
            ),
            collapse="/"
        )
    )
}

#options(shiny.reactlog = TRUE)
shinyApp(ui, server)
