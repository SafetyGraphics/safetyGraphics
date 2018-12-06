function(input, output, session){
  
  # output$test <- renderUI({
  #   tags$div(title = "hover test")
  # })
  
 #shinyBS::addTooltip(session, "select_file","test the hover!")


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
  settings <- eventReactive(c(data_selected(), standard()), {
    generateSettings(standard=standard(), chart="eDish")
  })

  # run validateSettings(data, standard, settings) and return a status
  status <- reactive({
    req(data_selected())
    req(settings())
    req(!standard()=="None")
    validateSettings(data_selected(), #settings_list$settings,
                     settings(),
                     chart="eDish") #$valid
  })

  # based on selected data set & generated/selected settings obj, generate settings page.
  # 
  #  NOTE:  module is being triggered when selected dataset changes OR when settings list changes
  #   this could cause the module to trigger twice unecessarily in some cases because the settings are generated
  #   AFTER the data is changed.  
  #  THis is a big problem if we switch datasets and the new settings list isn't available yet.  (e.g. if we switch from
  #  the example data (ADAM) to a non-ADAM dataset, the app will bomb)
    settings_new <-   callModule(renderSettings, "settingsUI",
                                 data=isolate(data_selected),
                                 settings=settings,
                                 status=status )


   # if returned status is valid, generate chart
  observeEvent(settings_new$status()$valid==TRUE, {

     ## future: wrap into module called generateChart()
    output$chart <- renderEDISH({
      req(data_selected())
      req(settings_new$settings())
      eDISH(data = data_selected(), settings = settings_new$settings())
    })
  
    
  })

  # if settings are not valid, then remove the download button
  observeEvent(status2()==FALSE, {
    removeUI(selector = "#download")
  })
  
  # if settings are valid, then add the download button
  observeEvent(status2()==TRUE, {
    insertUI (
      selector  = "div.container-fluid",
      where = "beforeEnd",
      ui =  div(id="download", # give the container div an id for easy removal
                style="float: right;", 
                span(class = "navbar-brand", #using one of the default nav bar classes to get css close 
                     style="padding: 8px;",  #then little tweak to ensure vertical alignment
                     downloadButton("reportDL", "Export Chart")))
    )
  })
  
  # Set up report generation on download button click
  output$reportDL <- downloadHandler(
    filename = "safety_report.html",
    content = function(file) {
      # Copy the report file to a temporary directory before processing it, in case we don't
      # have write permissions to the current working dir (which can happen when deployed).
      tempReport <- file.path(tempdir(), "report.Rmd")
      file.copy("template/safetyGraphicReport.Rmd", tempReport, overwrite = TRUE)
      
      params <- list(data = data_selected(), settings = settingsUI_list$settings) 
      
      rmarkdown::render(tempReport,
                        output_file = file,
                        params = params,  ## pass in params
                        envir = new.env(parent = globalenv())  ## eval in child of global env
      )
    }
  )  
  
  observeEvent(input$view_chart, {
    updateTabsetPanel(session, "inTabset", selected = "charts")
  })


  
  # passing parameters for knitting on export button click. Call when chart generated


        
                        
      
  
  session$onSessionEnded(stopApp)
  
}