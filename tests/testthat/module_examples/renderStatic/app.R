library(shiny)
library(safetyGraphics)
library(ggplot2)
library(dplyr)

dataR <- reactive({list(labs=safetyGraphics::labs, aes=safetyGraphics::aes)})
mappingR <- reactive({list(measure_col="PARAM", value_col="AVAL")})





# Test app code
ui <- tagList(
    tags$head(
    tags$link(
        rel = "stylesheet",
        type = "text/css",
        href = "index.css"
    )
    ),
    fluidPage(
        h2("Example 1: Basic Chart - Hello world"),
        chartsRenderStaticUI("HelloWorld"),
        h2("Example 2: Boxplot using data and settings"),
        chartsRenderStaticUI("BoxPlot"),
        h2("Example 3: Boxplot using custom init"),
        chartsRenderStaticUI("BoxPlot2"),
    )  
)

server <- function(input,output,session){
    
    #Example 1
    helloWorld <- function(data,settings){
        plot(-1:1, -1:1)
        text(runif(20, -1,1),runif(20, -1,1),"Hello World")
    }
    
    callModule(
        chartsRenderStatic, 
        "HelloWorld", 
        chartFunction=helloWorld, 
        data=reactive({}), 
        mapping=reactive({})
    )
    
    #Example 2
    boxPlot <- function(data,settings){
        mapped_data <- data[['labs']] %>%
            select(Value = settings[["value_col"]], Measure = settings[["measure_col"]])%>%
            filter(!is.na(Value))
        ggplot(data = mapped_data, aes(x = Measure, y = Value)) + 
            geom_boxplot() +
            scale_y_log10() +
            theme_bw() + 
            theme(axis.text.x = element_text(angle = 25, hjust = 1),
                  axis.text = element_text(size = 12),
                  axis.title = element_text(size = 12))
    }

    callModule(
        chartsRenderStatic, 
        "BoxPlot", 
        chartFunction=boxPlot, 
        data=dataR, 
        mapping=mappingR
    )
    
    #Example 3
    dataInit <- function(data,settings){
        mapped_data <- data[['labs']] %>%
            select(Value = settings[["value_col"]], Measure = settings[["measure_col"]])%>%
            filter(!is.na(Value))
        settings$boxcolor="blue"
        return(list(data=mapped_data,settings=settings))
    }
    
    boxPlot2 <- function(data,settings){
        ggplot(data = data, aes(x = Measure, y = Value)) + 
            geom_boxplot(fill = settings[["boxcolor"]]) +
            scale_y_log10() +
            theme_bw() + 
            theme(axis.text.x = element_text(angle = 25, hjust = 1),
                  axis.text = element_text(size = 12),
                  axis.title = element_text(size = 12))
    }
    
    callModule(
        chartsRenderStatic, 
        "BoxPlot2", 
        initFunction=dataInit,
        chartFunction=boxPlot2, 
        data=dataR, 
        mapping=mappingR
    )
}

shinyApp(ui, server)