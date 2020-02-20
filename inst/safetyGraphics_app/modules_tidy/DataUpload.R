DataUpload <- R6::R6Class(
  "DataUpload", 
  inherit = tidymodules::TidyModule,
  public = list(
    initialize = function(...){
      # mandatory
      super$initialize(...)
      
      self$definePort({

        self$addOutputPort(
          name = "data_selected",
          description = "Selected data",
          sample = data.frame(c(1,2,3)))
        
        self$addOutputPort(
          name = "settings",
          description = "settings object corresponding to selected data",
          sample = list()
        )
        
        self$addOutputPort(
          name = "status",
          description = "Validation status",
          sample = NA
        )
        
      })
      
    },
    ui = function() {
      tagList(
        fluidRow(
          column(3,
                 wellPanel(
                   h3("Data upload"),
                   fileInput(self$ns("datafile"), "Upload a csv or sas7bdat file",accept = c(".sas7bdat", ".csv"), multiple = TRUE),
                   radioButtons(self$ns("select_file"),"Select file for safetyGraphics charts",
                                choiceNames = preload_data_list$display,
                                choiceValues = names(preload_data_list$data))
          )),
          column(6,
                 fluidRow(
                   wellPanel(
                     uiOutput(self$ns("datapreview_header")),
                     div(DT::dataTableOutput(self$ns("data_preview")), style = "font-size: 75%")
                   )
                 )
          )
        )
        )
    },
    server = function(input, output, session){
      # Mandatory
      super$server(input, output, session)
      
 
      # initiate reactive values - list of uploaded data files
      # standard to imitate output of detectStandard.R
      dd <- reactiveValues(data = preload_data_list$data,
                           current = preload_data_list$current,
                           standard = preload_data_list$standard)
      
      
      # modify reactive values when data is uploaded
      observeEvent(input$datafile,{
        
        data_list <- list()
        
        ## data list
        for (i in 1:nrow(input$datafile)){
          if (length(grep(".csv", input$datafile$name[i], ignore.case = TRUE)) > 0){
            data_list[[i]] <- data.frame(read.csv(input$datafile$datapath[i], na.strings=NA))
          }else if(length(grep(".sas7bdat", input$datafile$name[i], ignore.case = TRUE)) > 0){
            data_list[[i]] <- haven::read_sas(input$datafile$datapath[i])
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
        
        standard_list <- lapply(data_list, function(x){ detectStandard(x) })
        
        #standard_list <- lapply(data_list, function(x){ detectStandard(x)$standard })
        
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
        
        for (i in 1:length(dd$data)){
          
          temp_standard <- dd$standard[[i]]$standard
          standard_label <- ifelse(temp_standard=="adam","AdAM",ifelse(temp_standard=="sdtm","SDTM",temp_standard))
          if(temp_standard == "none") {
            names(choices)[i] <- paste0("<p>", names(dd$data)[i], " - <em style='font-size:12px;'>No Standard Detected</em></p>")
          } else if (dd$standard[[i]]$details[[temp_standard]]$match == "full") {
            names(choices)[i] <- paste0("<p>", names(dd$data)[i], " - <em style='color:green; font-size:12px;'>", standard_label, "</em></p>")
            # If partial data spec match - give the fraction of variables matched
          } else {
            
            valid_count <- dd$standard[[i]]$details[[temp_standard]]$valid_count
            total_count <- dd$standard[[i]]$details[[temp_standard]]$invalid_count + valid_count
            
            fraction_cols  <- paste0(valid_count, "/" ,total_count)
            
            names(choices)[i] <- paste0("<p>", names(dd$data)[i], " - <em style='color:green; font-size:12px;'>", "Partial ",
                                        standard_label, " (", fraction_cols, " data settings)",  "</em></p>")
          }
        }
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
        
        current_standard <- standard()$standard
        
        if (! current_standard=="none"){
          partial <- ifelse(standard()$details[[current_standard]]$match == "partial", TRUE, FALSE)
          
          if (partial) {
            partial_keys <- standard()$details[[current_standard]]$checks %>%
              filter(valid==TRUE) %>%
              select(text_key) %>%
              pull()
            
            generateSettings(standard=current_standard, partial=partial, partial_keys = partial_keys)
            
          } else {
            generateSettings(standard=current_standard)
          }
        } else {
          generateSettings(standard=current_standard)
        }
      })
      
      
      # run validateSettings(data, standard, settings) and return a status
      status <- reactive({
        req(data_selected())
        req(settings())
        validateSettings(data_selected(),
                         settings())
      })
      
      
      self$assignPort({
        self$updateOutputPort(
          id = "data_selected",
          output = data_selected
        )
        
        self$updateOutputPort(
          id = "settings",
          output = settings
        )
        
        self$updateOutputPort(
          id = "status",
          output = status
        )
      })
    }
  )
      
)
