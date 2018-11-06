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

  observe({print(is.null(settings_list$settings$id_col))})

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
  settingsUI_list <- reactiveValues()  ### initialize reactive values for the UI inputs
 # observeEvent(status()==TRUE, {
 observe({
   req(status())
   input <- callModule(renderSettings, "settingsUI", data=data_selected, settings=settings_list$settings)
   isolate({settingsUI_list$settings <- input})
  })


  # validate new settings
  # note - originally thought we'd work w/ one settings object. However, if we update the reactive settings values using
  # user selections, the settings UI module above will invalidate and the whole thing will re-execute. 
  # As a solution, I moved to having a second settings object that comes from the user dropdowns for 
  # downstream server-side stuff..
  #
  # ALSO there is not a direct mapping between the Shiny UI and the settings obj.  (e.g. measure_values are input$ALT, etc) 
  # so we need to deal w/ that conversion
  status2 <- reactive({
    req(data_selected())
    req(settingsUI_list$settings) 
    validateSettings(data_selected(), settingsUI_list$settings, chart="eDish")$valid
  })
  
  observe({
    print(settingsUI_list$settings$measure_col)
    print(settingsUI_list$settings$ALT)
  })
  
  # if status2=="valid", generate chart
  observeEvent(status2()==TRUE, {

     ## future: wrap into module called generateChart()
    output$chart <- renderEDISH({
      req(data_selected())
      req(settingsUI_list$settings)
      eDISH(data = data_selected(),
            settings = reactiveValuesToList(settingsUI_list$settings))
    })
  })

  observeEvent(input$view_chart, {
    updateTabsetPanel(session, "inTabset", selected = "charts")
  })

  
  session$onSessionEnded(stopApp)
  
}