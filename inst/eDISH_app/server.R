function(input, output, session){
  
  # initiate reactive values - list of uploaded data files
  dd <- reactiveValues(data = NULL, current = NULL)
  
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
    
    
    # generate UI elements - 1 for each uploaded dataset - for selecting which one will be used for eDISH plot
    # insertUI(
    #   selector = "#placeholderDataSelect",
    #   where = "beforeEnd",
    #   ui = lapply(which(dd$current==TRUE), function(i){
    #     if (i==1){   # if the VERY FIRST UPLOAD, default to "labs" data
    #       selectInput(inputId = paste0("file_", i), label = names(dd$data)[i], choices=c("labs","other"), selected="labs")
    #     } else {  # all other current uploads default to "other"
    #       selectInput(inputId = paste0("file_", i), label = names(dd$data)[i], choices=c("labs","other"), selected="other")
    #     } 
    #   }) 
    # )
    
    
    updateRadioButtons(session, "select_file", "Select file for eDISH chart",
                              choices = names(dd$data))
    
  })


  # get selected dataset when selection changes
  data_selected <- eventReactive(input$select_file, {
    if (! input$select_file == "No files available"){
      isolate({index <- which(names(dd$data)==input$select_file)[1]})
      dd$data[[index]]
    } else{
      return()
    }
    })

 # upon a dataset being uploaded and selected, generate data preview
  output$data_preview <- DT::renderDataTable({
      DT::datatable(data = data_selected(),
                     rownames = FALSE,
                     style="bootstrap",
                     class="compact",
                      extensions = "Scroller", options = list(scrollY=400, scrollX=TRUE))
  })


  # upon a dataset being selected, run detectStandard() function
  standard <- reactive({
     req(data_selected())
     detectStandard(data_selected())$standard
  })


  # output UI message based on detectStandard() result
   output$detectStandard_msg <- renderUI({
     req(standard())
     if (standard()=="None"){
       HTML("No standard detected. Please use settings tab to configure chart.")
     } else {
       HTML(paste("Matched",standard(),"data standard. eDISH chart available."))
     }
  })

  # upon a dataset being selected, use generateSettings() to produce a settings obj
  settings_list <- reactiveValues(settings = NULL)
  observe({
    req(data_selected())
    standard()
    settings_list$settings <- generateSettings(standard = standard(), chart = "eDish")
  }) 
  

  # run validateSettings(data, standard, settings) and return a status
  # this bombs if standard="none" because we are not yet updating settings obj based on
  #   user input. Once we allow that, run validateSettings under either:
  #     (1) standard is AdAM or SDTM & settings obj generated automatically
  #     (2) user needs to update settings in UI manually (due to standard="none" currently, could be more conditions in future)
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

 inputs <- reactive({
   req(settings_list$settings)
   input <- callModule(renderSettings, "settingsUI", data=data_selected, settings=settings_list$settings) 
 })
 
 # note this is getting triggered every time an input changes - even as the inputs fill in
 #   probably want to change that
 #  for example - (1) when UI created, (2) when main pieces of UI filled, (3) when dependent pieces of UI filled (e.g. ALT, etc)
 observe({
   req(inputs())
   settingsUI_list$settings$id_col <- inputs()$id_col
   settingsUI_list$settings$value_col <- inputs()$value_col
   settingsUI_list$settings$measure_col <- inputs()$measure_col
   settingsUI_list$settings$normal_col_low <- inputs()$normal_col_low
   settingsUI_list$settings$normal_col_high <- inputs()$normal_col_high
   settingsUI_list$settings$studyday_col <- inputs()$studyday_col
   settingsUI_list$settings$visit_col <- inputs()$visit_col
   settingsUI_list$settings$visitn_col <- inputs()$visitn_col
   settingsUI_list$settings$baseline_visitn <- inputs()$baseline_visitn
   settingsUI_list$settings$filters$value_col <- inputs()$filters
   settingsUI_list$settings$filters$label <- inputs()$filters
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