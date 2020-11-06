#####################################################################
# Step 1 - Write custom chart module code
#####################################################################
mod_labdist_UI <- function(id) {
    ns <- NS(id) 
    tagList(
        checkboxInput(ns("show_points"), "Show points?", value=FALSE),
        checkboxInput(ns("show_outliers"), "Show outliers?", value=TRUE),
        selectInput(ns("scale"), "Scale Transform", choices=c("Log-10","None")),
        plotOutput(ns("labdist"), width = "1000px")
    )
}

mod_labdist_server <- function(input, output, session, data, settings) {

    ns <- session$ns

    mapped_data <- reactive({
        data() %>%
            select(
                Value = settings()[["value_col"]],
                Measure = settings()[["measure_col"]]
            )%>%
            filter(!is.na(Value)) 
    })

    output$labdist <- renderPlot({
    
        req(mapped_data())
    
        # set up the plot
        p <- ggplot(data = mapped_data(), aes(x = Measure, y = Value)) +
            theme_bw() +
            theme(
                axis.text.x = element_text(angle = 25, hjust = 1),
                axis.text=element_text(size=12),
                axis.title = element_text(size = 12)
            )
    
        # add/remove outliers
        if (input$show_outliers){
            p <- p + geom_boxplot(fill = "orange") 
        } else {
            p <- p + geom_boxplot(fill = "orange", outlier.shape = NA) 
        }
    
        # log-transform scale
        if (input$scale=="Log-10"){
            p <- p + scale_y_log10()
        }
    
        # show individual data points
        if (input$show_points){
            p <- p + geom_jitter(width = 0.2)
        }  
    
        p
    })
}