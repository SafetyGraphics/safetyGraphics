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
    insertUI(
      selector = "#placeholderDataSelect",
      where = "beforeEnd",
      ui = lapply(which(dd$current==TRUE), function(i){
        if (i==1){   # if the VERY FIRST UPLOAD, default to "labs" data
          selectInput(inputId = paste0("file_", i), label = names(dd$data)[i], choices=c("labs","other"), selected="labs")
        } else {  # all other current uploads default to "other"
          selectInput(inputId = paste0("file_", i), label = names(dd$data)[i], choices=c("labs","other"), selected="other")
        } 
      }) 
    )
    
  })
  
  observe({print(names(dd$data))})
  
  # upon a dataset being uploaded and set to "labs", generate data preview
  observeEvent(input$file_1=="labs",{
    output$data_preview <- DT::renderDataTable(DT::datatable(dd$data[[1]]))
  }, ignoreInit = TRUE)
  
  # upon a dataset being set to "labs", run detectStandard() function
  # temporarily only look at first uploaded dataset until we can:
  #    - only allow 1 dataset to be set to "labs"
  #    - look thru dynamically generated UI elements to see WHICH is being set to labs, and run detectStandard() on that
  standard <- eventReactive(input$file_1=="labs", {
    # ds <- detectStandard(dd$data[1])
    # return(ds$standard)
      "AdAM"    
  }, ignoreInit = TRUE)
  
  # output UI message based on detectStandard() result 
  observe({
    if (is.null(standard())){
      return()
    } else if (standard()=="None") {
      output$detectStandard_msg <- renderUI({
        HTML("No standard detected. Please use settings tab to configure chart.")
        })
    } else {
      output$detectStandard_msg <- renderUI({
        HTML(paste("Matched",standard(),"data standard. eDISH chart available."))
      })
    }
  })
  
  # temporarily force adlbc to be our selected data
  # need to write code to:
  #  - only allow 1 dataset to be set to LABS
  #  - detect which data is set to labs
  # placeholder:
  data <- reactive({ReDish::adlbc})
  
  # upon a dropdown being set to LABS, run the detectDataStandard() function to detect standard & generate msg
  # i believe we will use eventReactive() to capture the return value
  # will have to code this to look thru all the dropdowns, but currently only looking at first dropdown
  # placeholder:
 # standard <- reactive({"ADaM"})
  
  # use generateSettings() to produce a settings obj
  # placeholder:
  settings <- reactive({
    settingsl <- list(id_col = "USUBJID",
                      value_col = "AVAL", 
                      measure_col = "PARAM", 
                      visitn_col = "VISITNUM", 
                      normal_col_low = "A1LO", 
                      normal_col_high = "A1HI", 
                      group_cols = NULL,
                      filters = NULL,
                      measure_values = list(ALT = "Alanine Aminotransferase (U/L)",
                                            AST = "Aspartate Aminotransferase (U/L)",
                                            TB = "Bilirubin (umol/L)",
                                            ALP = "Alkaline Phosphatase (U/L)"))
  })
  

  # based on selected data set, and given a data standard/settings obj, generate settings page.
  observeEvent(input$generateSettings, {

    settingsUI_inputs <-  callModule(renderSettings, "settingsUI", data=data, standard=standard, settings=settings)

  },
  ignoreInit = TRUE)

  
  # Call data upload module
  # callModule(dataUpload, 'dataUpload')
  
}