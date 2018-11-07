renderSettingsUI <- function(id){
  
  ns <- NS(id)
  
  tagList(
    fluidRow(
      splitLayout(
        tagList(
          wellPanel(
            fluidRow(
              column(6,  
                     h3("Data Mapping"),
                     selectInput(ns("id_col"),"Unique subject identifier", choices = NULL),
                     selectInput(ns("value_col"),"Lab result", choices = NULL),
                     selectInput(ns("measure_col"),"Lab measure", choices = NULL),
                     h4("Key measures"),
                     selectInput(ns("ALT"),"ALT", choices = NULL),
                     selectInput(ns("AST"),"AST", choices = NULL),
                     selectInput(ns("TB"),"TB", choices = NULL),
                     selectInput(ns("ALP"),"ALP", choices = NULL)
              ) ,
              column(6,
                     br(),
                     br(),
                     br(),
                     selectInput(ns("normal_col_low"),"Lower limit of normal", choices = NULL),
                     selectInput(ns("normal_col_high"),"Upper limit of normal", choices = NULL),
                     selectInput(ns("visit_col"),"Visit", choices = NULL),
                     selectInput(ns("visitn_col"),"Visit number", choices = NULL),
                     selectInput(ns("baseline_visitn"),"Baseline visit number", choices = NULL),
                     selectInput(ns("studyday_col"),"studyday_col", choices = NULL),
                     selectInput(ns("anlyFlag"),"anlyFlag", choices = NULL)
                     
              ))
          )
        ),
        tagList(
          column(6, 
                 wellPanel(
                   h3("Measure Settings"),
                #   selectInput(ns("filters"),"Filters", choices = NULL, multiple = TRUE),
                #   selectInput(ns("group_cols"),"Group columns", choices = NULL, multiple = TRUE),
                   selectInput(ns("x_options"),"x_options", choices = c("ALT", "AST", "ALP"), selected = c("ALT", "AST", "ALP"), multiple = TRUE),
                   selectInput(ns("y_options"),"y_options", choices = c("ALT", "AST", "ALP"), selected = c("TB","ALP"), multiple = TRUE)
                 )
          ),
          column(6, 
                 wellPanel(
                     h3("Appearance Settings"),
                         sliderInput(ns("visit_window"),"visit_window", value = 30, min=0, max=50),
                         checkboxInput(ns("r_ratio_filter"),"r_ratio_filter", value = TRUE),
                         conditionalPanel(
                           condition="input.r_ratio_filter==true", ns=ns,
                           sliderInput(ns("r_ratio_cut"),"r_ratio_cut", value = 0, min=0, max =1)
                         ),
                         checkboxInput(ns("showTitle"),"showTitle", value = TRUE),
                         textAreaInput (ns("warningText"),"warningText", 
                                        value = "Caution: This interactive graphic is not validated. Any clinical recommendations based on this tool should be confirmed using your organizations standard operating procedures.")
                     )
        )
      ))
  )
  )
  
}


renderSettings <- function(input, output, session, data, settings){
  
  ns <- session$ns
  

  req(data())
  req(settings)
  
  colnames <- reactive({names(data())})
  
  observe({
    if (! is.null(settings$id_col)){
      updateSelectInput(session, "id_col", choices = unique(c(settings$id_col,colnames())))
    } else {
      updateSelectInput(session, "id_col", choices = colnames())
    } 

    if (! is.null(settings$value_col)){
      updateSelectInput(session, "value_col", choices = unique(c(settings$value_col,colnames())))
    } else {
      updateSelectInput(session, "value_col", choices = colnames())
    } 

    if (! is.null(settings$measure_col)){
      updateSelectInput(session, "measure_col", choices = unique(c(settings$measure_col,colnames())))
    } else {
      updateSelectInput(session, "measure_col", choices = colnames())
    } 

    if (! is.null(settings$normal_col_low)){
      updateSelectInput(session, "normal_col_low", choices = unique(c(settings$normal_col_low,colnames())))
    } else {
      updateSelectInput(session, "normal_col_low", choices = colnames())
    } 

    if (! is.null(settings$normal_col_high)){
      updateSelectInput(session, "normal_col_high", choices = unique(c(settings$normal_col_high,colnames())))
    } else {
      updateSelectInput(session, "normal_col_high", choices = colnames())
    } 

    if (! is.null(settings$visit_col)){
      updateSelectInput(session, "visit_col", choices = unique(c(settings$visit_col,colnames())))
    } else {
      updateSelectInput(session, "visit_col", choices = colnames())
    } 

    if (! is.null(settings$visitn_col)){
      updateSelectInput(session, "visitn_col", choices = unique(c(settings$visitn_col,colnames())))
    } else {
      updateSelectInput(session, "visitn_col", choices = colnames())
    } 

    if (! is.null(settings$studyday_col)){
      updateSelectInput(session, "studyday_col", choices = unique(c(settings$studyday_col,colnames())))
    } else {
      updateSelectInput(session, "studyday_col", choices = colnames())
    } 
    
    if (! is.null(settings$anlyFlag)){
      updateSelectInput(session, "anlyFlag", choices = unique(c(settings$anlyFlag,colnames())))
    } else {
      updateSelectInput(session, "anlyFlag", choices = colnames())
    } 
    
    # if (! is.null(settings$filters$value_col)){
    #   updateSelectInput(session, "filters", choices = unique(c(settings$filters$value_col,colnames())))
    # } else {
    #   updateSelectInput(session, "filters", choices = colnames())
    # }
    
    # suppressing until we merge with updated JS which allows group_cols length 1
    # if (! is.null(settings$group_cols)){
    #   updateSelectInput(session, "group_cols", choices = unique(c(settings$group_cols,colnames())))
    # } else {
    #   updateSelectInput(session, "group_cols", choices = colnames())
    # }
  })

  
  observe({
    req(input$measure_col)
    if (!is.null(settings$measure_col)){
      if (input$measure_col==settings$measure_col){
          choices <- unique(c(settings$measure_values$ALT, as.character(data()[,settings$measure_col])))
      } else {
        choices <- unique(data()[,input$measure_col])
      }
    } else {
      choices <- unique(data()[,input$measure_col])
    }
    updateSelectInput(session, "ALT", choices = choices)
  })

  observe({
    req(input$measure_col)
    if (!is.null(settings$measure_col)){
      if (input$measure_col==settings$measure_col){
        choices <- unique(c(settings$measure_values$AST, as.character(data()[,settings$measure_col])))
      } else {
        choices <- unique(data()[,input$measure_col])
      }
    } else {
      choices <- unique(data()[,input$measure_col])
    }
    updateSelectInput(session, "AST", choices = choices)
  })

  observe({
    req(input$measure_col)
    if (!is.null(settings$measure_col)){
      if (input$measure_col==settings$measure_col){
        choices <- unique(c(settings$measure_values$TB, as.character(data()[,settings$measure_col])))
      } else {
        choices <- unique(data()[,input$measure_col])
      }
    } else {
      choices <- unique(data()[,input$measure_col])
    }
    updateSelectInput(session, "TB", choices = choices)
  })

  observe({
    req(input$measure_col)
    if (!is.null(settings$measure_col)){
      if (input$measure_col==settings$measure_col){
        choices <- unique(c(settings$measure_values$ALP, as.character(data()[,settings$measure_col])))
      } else {
        choices <- unique(data()[,input$measure_col])
      }
    } else {
      choices <- unique(data()[,input$measure_col])
    }
    updateSelectInput(session, "ALP", choices = choices)
  })

  observe({
    req(input$visitn_col)
    if (!is.null(settings$visitn_col)){
      if (input$visitn_col==settings$visitn_col){
        choices <- unique(c(settings$baseline_visitn, data()[,settings$visitn_col]))
      } else {
        choices <- unique(data()[,input$visitn_col])
      }
    } else {
      choices <- unique(data()[,input$visitn_col])
    }
    updateSelectInput(session, "baseline_visitn", choices = choices)
  })


  ### return all inputs from module to be used in global env.
  return(input)
}