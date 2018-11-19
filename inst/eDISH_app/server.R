function(input, output, session){
  
  # initiate reactive values - list of uploaded data files
  dd <- reactiveValues(data = list("Example data" = adlbc), current = 1, standard = "ADaM")
  
  # modify reactive values when data is uploaded
  observeEvent(input$datafile,{
    
    data_list <- list()
    
    ## data list
    for (i in 1:nrow(input$datafile)){
      if (length(grep(".csv", input$datafile$name[i], ignore.case = TRUE)) > 0){
        data_list[[i]] <- data.frame(read.csv(input$datafile$datapath[i], na.strings=NA))
      }else if(length(grep(".sas7bdat", input$datafile$name[i], ignore.case = TRUE)) > 0){
        data_list[[i]] <- data.frame(haven::read_sas(input$datafile$datapath[i]))
      }else{
        data_list[[i]] <- NULL
      }
    }
    # names
    names(data_list) <- input$datafile$name
    
    # append to existing reactiveValues list
    dd$data <- c(dd$data, data_list)  
    
    # set dd$current to FALSE for previous & TRUE for current uploads
    dd$current <- c(rep(FALSE, length(dd$current)), rep(TRUE, length(data_list)))
    
    # run detectStandard on new data and save to dd$standard
    standard_list <- lapply(data_list, function(x){ detectStandard(x)$standard })
    dd$standard <- c(dd$standard, standard_list) 
      
  })
  

  ### make a reactive combining dd$data & standard 
  data_choices <- reactive({

    req(dd$data)
    req(dd$standard)
    
    choices  <- list()
    for (i in 1:length(dd$data)){
      choices[[i]] <- names(dd$data)[i]
    }
    
    names(choices) <- ifelse(dd$standard=="None",
                             paste0("<p>", names(dd$data), " - <em style='font-size:12px;'>No Standard Detected</em></p>"),
                             paste0("<p>", names(dd$data), " - <em style='color:green; font-size:12px;'>", dd$standard, "</em></p>"))
    return(choices)
  })
  
  # update radio buttons to display dataset names and standards for selection
  observeEvent(input$datafile, {
    req(data_choices())
    vals <- data_choices()
    names(vals) <- NULL
    names <- lapply(names(data_choices()), HTML)
    
    prev_sel <- lapply(reactiveValuesToList(input), unclass)$select_file  # retain previous selection

    updateRadioButtons(session, "select_file",
                         choiceNames = names,
                         choiceValues = vals,
                         selected = prev_sel)  

   })

  # get selected dataset when selection changes
  data_selected <- eventReactive(input$select_file, {
      isolate({index <- which(names(dd$data)==input$select_file)[1]})
      dd$data[[index]]
    })
  
 # upon a dataset being uploaded and selected, generate data preview
  output$datapreview_header <- renderUI({
    data_selected()
    isolate(data_name <- input$select_file)
    h3(paste("Data Preview for", data_name))
  })
  
  output$data_preview <- DT::renderDataTable({
      DT::datatable(data = data_selected(),
                    caption = isolate(input$select_file),
                     rownames = FALSE,
                     style="bootstrap",
                     class="compact",
                      extensions = "Scroller", options = list(scrollY=400, scrollX=TRUE))
  })


  # upon a dataset being selected, grab its standard
  standard <- eventReactive(data_selected(), {
    index <- which(names(dd$data)==input$select_file)[1]
    dd$standard[[index]]
  })

  # upon a dataset being selected, use generateSettings() to produce a settings obj
  settings_list <- reactiveValues(settings = NULL)

  observeEvent(c(data_selected(), standard()), {
    settings_list$settings <- generateSettings(standard = standard(), chart = "eDish")
  })

  # run validateSettings(data, standard, settings) and return a status
  status <- reactive({
    req(data_selected())
    req(settings_list$settings)
    req(!standard()=="None")
    validateSettings(data_selected(), settings_list$settings, chart="eDish")$valid
  })

  # based on selected data set & generated/selected settings obj, generate settings page.
  # note that module is being triggered when selected dataset changes OR when settings list changes
  #   this could cause the module to trigger twice unecessarily in some cases because the settings are generated
  #   AFTER the data is changed.  
  settingsUI_list <- reactiveValues()  ### initialize reactive values for the UI inputs
  
   observe({
     print(settings_list$settings)
   })
  inputs <- reactive({
        callModule(renderSettings, "settingsUI", data=data_selected, settings=settings_list$settings) 
  })

 
 # Fill settings object based on selections
  # require that secondary inputs have been filled in before proceeding
  # update is triggered by any of the input selections changing
 observe({
   req(inputs()$ALP)
   req(inputs()$AST)
   req(inputs()$TB)
   req(inputs()$ALT)
   req(inputs()$baseline_visitn)
   inputs()$id_col
   inputs()$value_col
   inputs()$measure_col
   inputs()$normal_col_low
   inputs()$normal_col_high
   inputs()$studyday_col
   inputs()$visit_col
   inputs()$visitn_col
   inputs()$x_options
   inputs()$y_options
   inputs()$visit_window
   inputs()$r_ratio_filter
   inputs()$r_ratio_cut
   inputs()$showTitle
   inputs()$warningText
   isolate({
     settingsUI_list$settings$id_col <- inputs()$id_col
     settingsUI_list$settings$value_col <- inputs()$value_col
     settingsUI_list$settings$measure_col <- inputs()$measure_col
     settingsUI_list$settings$normal_col_low <- inputs()$normal_col_low
     settingsUI_list$settings$normal_col_high <- inputs()$normal_col_high
     settingsUI_list$settings$studyday_col <- inputs()$studyday_col
     settingsUI_list$settings$visit_col <- inputs()$visit_col
     settingsUI_list$settings$visitn_col <- inputs()$visitn_col
     settingsUI_list$settings$baseline_visitn <- inputs()$baseline_visitn
     settingsUI_list$settings$measure_values$ALT <- inputs()$ALT
     settingsUI_list$settings$measure_values$AST <- inputs()$AST
     settingsUI_list$settings$measure_values$TB <- inputs()$TB
     settingsUI_list$settings$measure_values$ALP <- inputs()$ALP
     settingsUI_list$settings$x_options <- inputs()$x_options
     settingsUI_list$settings$y_options <- inputs()$y_options
     settingsUI_list$settings$visit_window <- inputs()$visit_window
     settingsUI_list$settings$r_ratio_filter <- inputs()$r_ratio_filter
     settingsUI_list$settings$r_ratio_cut <- inputs()$r_ratio_cut
     settingsUI_list$settings$showTitle <- inputs()$showTitle
     settingsUI_list$settings$warningText <- inputs()$warningText
   })
 })
 
 observe({
   req(inputs()$filters)
   isolate({
     settingsUI_list$settings$filters <- list()
     
     for (i in 1:length(inputs()$filters)){
       settingsUI_list$settings$filters[[i]] <- list(value_col = inputs()$filters[[i]],
                                                     label = inputs()$filters[[i]])
     }
   })
 })

 observe({
   req(inputs()$group_cols)
   isolate({
     settingsUI_list$settings$group_cols <- list()
     
     for (i in 1:length(inputs()$group_cols)){
       settingsUI_list$settings$group_cols[[i]] <- list(value_col = inputs()$group_cols[[i]],
                                                        label = inputs()$group_cols[[i]])
     }
   })
 })

 # validate new settings 
  status2 <- eventReactive(settingsUI_list$settings,{
    req(data_selected())
    req(settingsUI_list$settings)
    settingsUI_list$settings$id_col
    validateSettings(data_selected(), settingsUI_list$settings, chart="eDish")$valid
   })


  # if status2=="valid", generate chart
  observeEvent(status2()==TRUE, {

     ## future: wrap into module called generateChart()
    output$chart <- renderEDISH({
      req(data_selected())
      req(settingsUI_list$settings)
      eDISH(data = data_selected(), settings = settingsUI_list$settings)
    })
  })

  observeEvent(input$view_chart, {
    updateTabsetPanel(session, "inTabset", selected = "charts")
  })

  
  session$onSessionEnded(stopApp)
  
}