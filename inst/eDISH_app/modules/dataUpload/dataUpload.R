dataUpload <- function(input, output, session){
  
  ns <- session$ns
  
  
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
  
  print(settings)
  
  # run validateSettings(data, standard, settings) and return a status
  status <- reactive({
    req(data_selected())
    req(settings())
    validateSettings(data_selected(), 
                     settings(),
                     chart="eDish")  
  })
  
  print(status)
  
  ### return selected data, settings, and status to server
  return(list(data_selected = reactive(data_selected()),
              settings = reactive(settings()),
              status = reactive(status())))
  
}