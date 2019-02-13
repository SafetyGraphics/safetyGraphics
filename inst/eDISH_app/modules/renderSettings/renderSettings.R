source("modules/renderSettings/util/labelSetting.R")
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
            
            updateSelectizeInput(session, "measure_values--ALT", choices = choices_alt)
            updateSelectizeInput(session, "measure_values--AST", choices = choices_ast)
            updateSelectizeInput(session, "measure_values--TB",  choices = choices_tb)
            updateSelectizeInput(session, "measure_values--ALP", choices = choices_alp)
          } else {
            choices_ast <- unique(data()[,input$measure_col])
            choices_alt <- unique(data()[,input$measure_col])
            choices_tb  <- unique(data()[,input$measure_col])
            choices_alp <- unique(data()[,input$measure_col])
            
            updateSelectizeInput(session, "measure_values--ALT", choices = choices_alt)
            updateSelectizeInput(session, "measure_values--AST", choices = choices_ast) 
            updateSelectizeInput(session, "measure_values--TB",  choices = choices_tb)
            updateSelectizeInput(session, "measure_values--ALP", choices = choices_alp)
          }
        } else {
          updateSelectizeInput(session, "measure_values--ALT", choices = "")
          updateSelectizeInput(session, "measure_values--AST", choices = "")
          updateSelectizeInput(session, "measure_values--TB", choices = "")
          updateSelectizeInput(session, "measure_values--ALP", choices = "")
        }
        
      })
    }
    
    # Custom observer for baseline
    if(name=="baseline--value_col"){
      observe({
        settings <- settings()
        
        req(input$`baseline--value_col`)
        
        if (input$`baseline--value_col` %in% colnames()){
          if (!is.null(settings$baseline$value_col) && input$`baseline--value_col`==settings$baseline$value_col){
            choices <- unique(c(settings$baseline$values, as.character(data()[,settings$baseline$value_col])))
            choices <- sort(choices)
            
            updateSelectizeInput(session, "baseline--values", choices = choices)
          } else {
            choices <- unique(data()[,input$`baseline--value_col`])
            choices <- sort(choices)
            
            updateSelectizeInput(session, "baseline--values", choices = choices,
                                 options = list(
                                   placeholder = '',
                                   onInitialize = I('function() { this.setValue(""); }')))
          }
        } else {
          updateSelectizeInput(session, "baseline--values", choices = "")
        }
      })
    }
    
    
    # Custom observer for analysis population
    if(name=="analysisFlag--value_col"){
      observe({
        settings <- settings()
        
        req(input$`analysisFlag--value_col`)
        
        if (input$`analysisFlag--value_col` %in% colnames()){
          if (!is.null(settings$analysisFlag$value_col) && input$`analysisFlag--value_col`==settings$analysisFlag$value_col){
            choices <- unique(c(settings$analysisFlag$values, as.character(data()[,settings$analysisFlag$value_col])))
            
            updateSelectizeInput(session, "analysisFlag--values", choices = choices)
          } else {
            choices <- unique(data()[,input$`analysisFlag--value_col`])
            
            updateSelectizeInput(session, "analysisFlag--values", choices = choices,
                                 options = list(
                                   placeholder = '',
                                   onInitialize = I('function() { this.setValue(""); }')))
          }
        } else {
          updateSelectizeInput(session, "analysisFlag--values", choices = "")
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
  #input_names <- reactive({safetyGraphics:::getSettingsMetadata(charts="eDiSH", cols="text_key")})
  input_names <- reactive({names(lapply(reactiveValuesToList(input), unclass))}) 
  #observe({print(input_names())})
  
  # Fill settings object based on selections
  # require that secondary inputs have been filled in before proceeding
  # update is triggered by any of the input selections changing
  #
  # NOTE: when data selection changes, the inputs are updating 1 by 1
  # Therefore, until the inputs are done updating based on new data, this object will be
  # partially representing the old data, and partially representing the new data.
  # not sure if this is the right place to do it...but can we clear out this object upon a data change and start over??
  
  settings_new <- reactive({
    
    #  print(input$id_col)
    
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
    
    if (! is.null(input$`baseline--values`)){
      if (! input$`baseline--values`[1]==""){
        settings$baseline <- list(value_col = input$`baseline--value_col`,
                                  values = input$`baseline--values`)
      }
    }
    
    if (! is.null(input$`analysisFlag--values`)){
      if (! input$`analysisFlag--values`==""){
        settings$analysisFlag <- list(value_col = input$`analysisFlag--value_col`,
                                      values = input$`analysisFlag--values`)
      }
    }
    
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
    
    for (i in names(settings_new)){
      if (!is.null(settings_new[[i]])){
        if (settings_new[[i]][1]==""){
          settings_new[i] <- list(NULL)
        }
      }
    }
    
    validateSettings(data(), settings_new, chart="eDish")
    
  })
  
  
  #Setting Status information (from failed checks only)
  status_df <- reactive({
    req(status_new())

    status_new()$checks %>% 
      group_by(text_key) %>%
      mutate(num_fail = sum(valid==FALSE)) %>%
      mutate(message_long = paste(message, collapse = " ") %>% trimws(),
             message_short = case_when(
               num_fail==0 ~ "OK",
               num_fail==1 ~ "1 failed check.",
               TRUE ~ paste(num_fail, "failed checks.")
             )) %>%
      select(text_key, message_long, message_short, num_fail) %>%
      unique 
  })
  
  
  exportTestValues(status_df = { status_df() })
  
  #List of required settings
  req_settings <- safetyGraphics:::getSettingsMetadata() %>% 
    filter(chart_edish==TRUE & setting_required==TRUE) %>% 
    pull(text_key)
  
  #List of inputs with custom observers
  custom_observer_settings <- c("measure_col", "baseline--value_col","analysisFlag--value_col")
  
  
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
  
  
  # observeEvent(data(), {
  observe({ 
    req(colnames())
    
    for (name in isolate(input_names())){
      #print(name)
      setting_key <- as.list(strsplit(name,"\\-\\-"))
      setting_value <- safetyGraphics:::getSettingValue(key=setting_key, settings=settings())
      setting_label <- safetyGraphics:::getSettingsMetadata(charts="eDiSH", text_keys=name, cols="label") 
      setting_description <- safetyGraphics:::getSettingsMetadata(charts="eDiSH", text_keys=name, cols="description") 
      
      
      column_mapping_ids <- safetyGraphics:::getSettingsMetadata(charts="eDiSH") %>% filter(column_mapping==TRUE) %>% pull(text_key) 
      
      
      if (name %in% column_mapping_ids){
        sortedChoices<-NULL
        if(is.null(setting_value)){
          sortedChoices<-colnames()
          updateSelectizeInput(session, name, choices=sortedChoices,
                               options = list(
                                 onInitialize = I('function() { 
                                                    //console.log("initializing input w/o value")
                                                    //console.log(this)
                                                    this.setValue(""); 
                                                   }')
                               ))
          
          
        }else{
          sortedChoices<-unique(c(setting_value, colnames()))
          updateSelectizeInput(session, name, choices=sortedChoices,
                               options = list (onInitialize = I('function() { 
                                                    //console.log("initializing input with value")
                                                    //console.log(this)
                                                   }')
                               ))
          
        }
      }
      
      # 2. Check for custom observers and initialize if needed
      if(name %in% custom_observer_settings){
        runCustomObserver(name=name) 
      }
      
      # 3. label setting
      labelSetting(ns=ns, name=name, label=setting_label, description=setting_description) 
      
      # 4. Flag the input if it is required
      if(name %in% req_settings){
        flagSetting(session=session, name=name, originalLabel=setting_label)
        
      }
    }
  })
  
  
  observe({
    for (name in isolate(input_names())){
      
      # 5. Print a warning if the input failed a validation check
      if(name %in% status_df()$text_key){
        
        status_short <- status_df()[status_df()$text_key==name, "message_short"]
        status_long <- status_df()[status_df()$text_key==name, "message_long"]
        
        updateSettingStatus(ns=ns, name=name, status_short=status_short, status_long=status_long)
      }
      
    }
  })
  
  observe({print(settings_new()$measure_values)})
  
  ### return updated settings and status to global env.
  return(list(settings = reactive(settings_new()),
              status = reactive(status_new())))
  
}
