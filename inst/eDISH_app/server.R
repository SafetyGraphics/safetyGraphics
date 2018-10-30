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
                      extensions = "Scroller", options = list(scrollY=500, scrollX=TRUE))
  })


  # temporarily force adlbc to be our selected data
  data_temp <- reactive({ReDish::adlbc})


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
  settings <- reactive({
    req(data_selected())
    generateSettings(standard = standard(), chart = "eDish")
  })
  


  # based on selected data set, and given a data standard/settings obj, generate settings page.
  # trigger this event EITHER from press of button (if selecting standard manually),
  #     or based on the automatic standard detection
  observeEvent(input$generateSettings, {

    # note that UI for renderSettings module defines all the inputs. but maybe we want to do that in general
    #  ui function outside of module?? A little confused about the module UI showing up pror to obeserving button click...
    settingsUI_inputs <-  callModule(renderSettings, "settingsUI", data=data_selected, standard=standard, settings=settings)

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