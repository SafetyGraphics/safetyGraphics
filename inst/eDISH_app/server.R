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

 
  # upon a dataset being uploaded and set to "labs", generate data preview
  # NOTE - data preview is rendering after every upload - need to fix
  output$data_preview <- DT::renderDataTable({
    index <- which(names(dd$data)==input$select_file)[1]
    if (!is.na(index)){
      DT::datatable(dd$data[[index]],
                    rownames = FALSE,
                    style="bootstrap",
                    class="compact",
                    extensions = "Scroller", options = list(scrollY=500, scrollX=TRUE)) 
    }
      })


  # temporarily force adlbc to be our selected data
  # need to write code to:
  #  - only allow 1 dataset to be set to LABS
  #  - detect which data is set to labs
  # placeholder:
  data_temp <- reactive({ReDish::adlbc})


  # upon a dataset being set to "labs", run detectStandard() function
  # temporarily only look at first uploaded dataset until we can:
  #    - only allow 1 dataset to be set to "labs"
  #    - look thru dynamically generated UI elements to see WHICH is being set to labs, and run detectStandard() on that
  standard <- eventReactive(! input$select_file =="No files available", {
    # ds <- detectStandard(dd$data[1])
    # return(ds$standard)
      "AdAM"
  }, ignoreInit = TRUE)

  # output UI message based on detectStandard() result
   output$detectStandard_msg <- renderUI({
     req(standard())
     if (standard()=="None"){
       HTML("No standard detected. Please use settings tab to configure chart.")
     } else {
       HTML(paste("Matched",standard(),"data standard. eDISH chart available."))
     }
  })


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
  # trigger this event EITHER from press of button (if selecting standard manually),
  #     or based on the automatic standard detection
  observeEvent(input$generateSettings, {

    # note that UI for renderSettings module defines all the inputs. but maybe we want to do that in general
    #  ui function outside of module?? A little confused about the module UI showing up pror to obeserving button click...
    settingsUI_inputs <-  callModule(renderSettings, "settingsUI", data=data_temp, standard=standard, settings=settings)

  },
  ignoreInit = TRUE)


  # update settings object as user changes settings selections


  # run validateSettings(data, standard, settings) and return a status
  # placeholder status here:
  status <- reactive("valid")

  # if status=="valid", generate chart
  observeEvent(status()=="valid", {

    ## future: wrap into module called generateChart()
    output$chart <- renderEDISH({
      eDISH(data = data_temp(),
            settings = settings())
    })
  })

  observeEvent(input$view_chart, {
    updateTabsetPanel(session, "inTabset", selected = "charts")
  })

  
  session$onSessionEnded(stopApp)
  
}