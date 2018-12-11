
source("modules/renderSettings/util/flagSetting.R")
source("modules/renderSettings/util/updateSettingStatus.R")

renderSettings <- function(input, output, session, data, settings, status){

  #TODO: Save to separate file - probably needs to be a module.
  runCustomObserver<-function(name){

    # Custom observer for measure_col
    if(name=="measure_col"){
      observe({
        settings <- settings()

        req(input$measure_col)

        if (input$measure_col %in% colnames()){
          if (!is.null(settings$measure_col) && input$measure_col==settings$measure_col){
            choices_ast <- unique(c(settings$measure_values$AST, as.character(data()[,settings$measure_col])))
            choices_alt <- unique(c(settings$measure_values$ALT, as.character(data()[,settings$measure_col])))
            choices_tb  <- unique(c(settings$measure_values$TB,  as.character(data()[,settings$measure_col])))
            choices_alp <- unique(c(settings$measure_values$ALP, as.character(data()[,settings$measure_col])))

            updateSelectizeInput(session, "measure_values--ALT", choices = choices_ast)
            updateSelectizeInput(session, "measure_values--AST", choices = choices_alt)
            updateSelectizeInput(session, "measure_values--TB",  choices = choices_tb)
            updateSelectizeInput(session, "measure_values--ALP", choices = choices_alp)
          } else {
            choices_ast <- unique(data()[,input$measure_col])
            choices_alt <- unique(data()[,input$measure_col])
            choices_tb  <- unique(data()[,input$measure_col])
            choices_alp <- unique(data()[,input$measure_col])

            updateSelectizeInput(session, "measure_values--ALT", choices = choices_ast,
                                 options = list(
                                   placeholder = '',
                                   onInitialize = I('function() { this.setValue(""); }')))
            updateSelectizeInput(session, "measure_values--AST", choices = choices_alt,
                                 options = list(
                                   placeholder = '',
                                   onInitialize = I('function() { this.setValue(""); }')))
            updateSelectizeInput(session, "measure_values--TB",  choices = choices_tb,
                                 options = list(
                                   placeholder = '',
                                   onInitialize = I('function() { this.setValue(""); }')))
            updateSelectizeInput(session, "measure_values--ALP", choices = choices_alp,
                                 options = list(
                                   placeholder = '',
                                   onInitialize = I('function() { this.setValue(""); }')))
          }
        } else {
          updateSelectizeInput(session, "measure_values--ALT", choices = "")
          updateSelectizeInput(session, "measure_values--AST", choices = "")
          updateSelectizeInput(session, "measure_values--TB", choices = "")
          updateSelectizeInput(session, "measure_values--ALP", choices = "")
        }

      })
    }
  } #end runCustomObserver()


  ###########################
  # Make updates to the UI
  ###########################
  ns <- session$ns

  #Columns in the data
  colnames <- reactive({names(data())})

  #List of all inputs
  input_names <- reactive({names(lapply(reactiveValuesToList(input), unclass))}) #TODO: needs update

  # Fill settings object based on selections
  # require that secondary inputs have been filled in before proceeding
  # update is triggered by any of the input selections changing
  #
  # NOTE: when data selection changes, the inputs are updating 1 by 1
  # Therefore, until the inputs are done updating based on new data, this object will be
  # partially representing the old data, and partially representing the new data.
  # not sure if this is the right place to do it...but can we clear out this object upon a data change and start over??

  settings_new <- reactive({
    # req(input$`measure_values--ALP`)
    # req(input$`measure_values--AST`)
    # req(input$`measure_values--TB`)
    # req(input$`measure_values--ALT`)

    settings <- list(id_col = input$id_col,
                     value_col = input$value_col,
                     measure_col = input$measure_col,
                     normal_col_low = input$normal_col_low,
                     normal_col_high = input$normal_col_high,
                     studyday_col = input$studyday_col,
                     visit_col = input$visit_col,
                     visitn_col = input$visitn_col,
                     measure_values = list(ALT = input$`measure_values--ALT`,
                                           AST = input$`measure_values--AST`,
                                           TB = input$`measure_values--TB`,
                                           ALP = input$`measure_values--ALP`),
                     x_options = input$x_options,
                     y_options = input$y_options,
                     visit_window = input$visit_window,
                     r_ratio_filter = input$r_ratio_filter,
                     r_ratio_cut = input$r_ratio_cut,
                     showTitle = input$showTitle,
                     warningText = input$warningText)

    if (!is.null(input$filters)){
          for (i in 1:length(input$filters)){
            settings$filters[[i]] <- list(value_col = input$filters[[i]],
                                          label = input$filters[[i]])
          }
    }
    if (!is.null(input$group_cols)){
      for (i in 1:length(input$group_cols)){
        settings$group_cols[[i]] <- list(value_col = input$group_cols[[i]],
                                      label = input$group_cols[[i]])
      }
    }

    # for (i in names(settings)){
    #   if (!is.null(settings[[i]])){
    #     if (settings[[i]][1]==""){
    #       settings[[i]] <- NULL
    #     }
    #   }
    # }

    return(settings)
  })


  # validate new settings
  #  the validation is run every time there is a change in data and/or settings.
  #
  #  NOTE: to prevent status updating as loop runs and fills in settings(),
  #   require the very last updated input to be available <- can't do this b/c we will have lots of
  #   null settings to start when no standard detected...
  status_new <- reactive({ #eventReactive(settingsUI_list$settings,{
    req(data())
    req(settings_new())
     name <- rev(isolate(input_names()))[1]
     settings_new <- settings_new()


   # if (!is.null(settings_new[[name]])) {

      for (i in names(settings_new)){
        if (!is.null(settings_new[[i]])){
          if (settings_new[[i]][1]==""){
            settings_new[i] <- list(NULL)
          }
        }
      }

       validateSettings(data(), settings_new, chart="eDish")
    # }
  })


  #Setting Status information (from failed checks only)
   status_df <- reactive({
    req(status_new())
     status_new()$checkList %>%
      map(., ~ keep(., names(.) %in% c("text_key","valid","message")) %>%
            data.frame(., stringsAsFactors = FALSE)) %>%
      bind_rows %>%
     # mutate(top_key = sub("\\|.*", "", text_key))  %>%
      group_by(text_key) %>%
      mutate(num_fail = sum(valid==FALSE)) %>%
      mutate(message = paste(message, collapse = " ") %>% trimws()) %>%
       select(text_key, message, num_fail) %>%
       unique %>%
       mutate(message = ifelse(message=="", "OK", message))
     # slice(1) #%>%   # get first set of checks
     # filter(valid==FALSE)
  })


  #List of required settings
  req_settings <- getRequiredSettings("eDish") %>% unlist  #Indicate required settings

    #List of inputs with custom observers
  custom_observer_settings <- c("measure_col") #more to be added later



  #Establish observers to update settings UI for all inputs
  #  Different observers:
  #     (1a) update UI based on data selection & original settings object
  #            - dependent on: colnames()
  #            - populate all UI inputs
  #            - flag required settings
  #     (1b) Do 1a for the custom settings (e.g. measure_values options).  These contained nested observers
  #            - dependent on: parent input$xxx
  #     (2) append status messages to UI
  #            - after UI is filled, we generate a NEW settings object & status
  #            - dependent on: the new settings/status, which will update after every user selection



  observeEvent(data(), {
    req(colnames())

     for (name in isolate(input_names())){
       #print(name)
       setting_key <- as.list(strsplit(name,"\\-\\-"))
       setting_value <- getSettingValue(key=setting_key, settings=settings())

       setting_label <- name ##TO DO: get the label!

       # 1. Update the options for data-mapping inputs
       if(str_detect(name,"_col") | name %in% c("filters", "group_cols")){
         sortedChoices<-NULL
         if(is.null(setting_value)){
           sortedChoices<-colnames()
           updateSelectizeInput(session, name, choices=sortedChoices,
                                options = list(
                                  placeholder = '',
                                  onInitialize = I('function() { this.setValue(""); }')
                                ))

         }else{
           sortedChoices<-unique(c(setting_value, colnames()))
           updateSelectizeInput(session, name, choices=sortedChoices)

         }
       #  updateSelectInput(session, name, choices=sortedChoices)
       }

       # 2. Check for custom observers and initialize if needed
       if(name %in% custom_observer_settings){
         runCustomObserver(name=name) #TODO: clean this up!
       }
     }
     })

  observe({
    for (name in isolate(input_names())){

      setting_label <- name

      # 3. Flag the input if it is required
      if(name %in% req_settings){
        flagSetting(session=session, name=name, originalLabel=setting_label)
        setting_label <- paste0(setting_label,"*")  #  <- this line is the reason why I'm including the flagging in
                                                    #        this observer vs. the one prior

        }

        # 4. Print a warning if the input failed a validation check
              # require that input has been selected
        if(name %in% status_df()$text_key){

          current_status <- status_df()[status_df()$text_key==name, "message"]
          current_status <- ifelse(current_status=="","OK",current_status)
          updateSettingStatus(session=session, name=name,
                              originalLabel=setting_label,
                              status=current_status)
        }

    }
   })


  ### return updated settings and status to global env.
  return(list(settings = reactive(settings_new()),
              status = reactive(status_new())))

}
