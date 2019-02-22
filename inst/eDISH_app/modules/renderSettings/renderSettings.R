source("modules/renderSettings/util/createSettingsUI.R")
# source("modules/renderSettings/util/labelSetting.R")
# source("modules/renderSettings/util/flagSetting.R")
source("modules/renderSettings/util/updateSettingStatus.R")

renderSettings <- function(input, output, session, data, settings, status){

  ns <- session$ns
  
  #List of all inputs
  input_names <- reactive({safetyGraphics:::getSettingsMetadata(charts=input$selected_charts, cols="text_key")})

  
  ######################################################################
  # create settings UI
  #   - chart selection -> gather all necessary UI elements
  #   - create elements based on metadata file
  #   - populate using data/settings
  ######################################################################

  output$data_mapping_ui <- renderUI({
    req(input$select_charts)
    tagList(createSettingsUI(data=data(), settings = settings(), setting_cat_val = "data", charts=input$charts, ns=ns))
  })
  outputOptions(output, "data_mapping_ui", suspendWhenHidden = FALSE) 
  
  output$measure_settings_ui <- renderUI({
    req(input$select_charts)
    tagList(createSettingsUI(data=data(), settings = settings(), setting_cat_val = "measure", charts=input$charts, ns=ns))
  })
  outputOptions(output, "measure_settings_ui", suspendWhenHidden = FALSE)
  
  output$appearance_settings_ui <- renderUI({
    req(input$select_charts)
    tagList(createSettingsUI(data=data(), settings = settings(), setting_cat_val = "appearance", charts=input$charts, ns=ns))
  })
  outputOptions(output, "appearance_settings_ui", suspendWhenHidden = FALSE)
  

  ######################################################################
  # Update field level inputs  
  #
  # update field-level inputs if a column level setting changes
  # dependent on change in data, chart selection, or column-level input
  ######################################################################

  observe({
    
    column_keys <- getSettingsMetadata(charts=input$select_charts,
                        filter_expr = field_mapping==TRUE) %>% 
      pull(field_column_key) %>% 
      unique %>% 
      as.list()
    
    lapply(column_keys, function(col){
      
      col_quo <- enquo(col)
      observeEvent(input[[col]],{
     
        field_keys <- getSettingsMetadata(charts=input$select_charts, col = "text_key", 
                                          filter_expr = field_column_key==!!col) 
        
        
        # Toggle field-level inputs:
        #    ON  - if column-level input is selected)
        #    OFF - if column-level input is not yet selected
        for (fk in field_keys){
          toggleState(id = fk, condition = !input[[col]]=="")
        }

          if (is.null(isolate(settings()[[col]])) || ! input[[col]] == isolate(settings()[[col]])){
            if (input[[col]] %in% colnames(data())){
              
              choices <- unique(data()[,input[[col]]]) 
              
              for (key in field_keys){
                  updateSelectizeInput(session, inputId = key, choices = choices,
                                       options = list(placeholder = "Please select a value",
                                                      onInitialize = I('function() {
                                                                       this.setValue("");
                }')))
               }
            } 
          }
      }
    )
  })
  })
 
  
  ######################################################################
  # Fill settings object based on selections
  # require that secondary inputs have been filled in before proceeding
  # update is triggered by any of the input selections changing
  #
  # NOTE: when data selection changes, the inputs are updating 1 by 1
  # Therefore, until the inputs are done updating based on new data, this object will be
  # partially representing the old data, and partially representing the new data.
  # not sure if this is the right place to do it...but can we clear out this object upon a data change and start over??
  ######################################################################
  
  settings_new <- reactive({
    
    
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
      if (! input$`analysisFlag--values`[1]==""){
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
  
  
  ######################################################################
  # validate new settings
  #  the validation is run every time there is a change in data and/or settings.
  #
  #  NOTE: to prevent status updating as loop runs and fills in settings(),
  #   require the very last updated input to be available <- can't do this b/c we will have lots of
  #   null settings to start when no standard detected...
  ######################################################################

  status_new <- reactive({  
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
  
  
  ######################################################################
  # Setting validation status information
  ######################################################################
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
  
  # for shiny tests
  exportTestValues(status_df = { status_df() })
  
  ######################################################################
  # print validation messages
  #
  #  Right now we are re-printing ALL status messages upon validation update.
  #   if we make a module, we have the option of printing ONLY the 
  #  message for input that changed.
  ######################################################################
 observe({
   for (name in isolate(input_names())){

     if(name %in% status_df()$text_key){

       status_short <- status_df()[status_df()$text_key==name, "message_short"]
       status_long <- status_df()[status_df()$text_key==name, "message_long"]

       updateSettingStatus(ns=ns, name=name, status_short=status_short, status_long=status_long)
     }

   }
 })
 
  ### return updated settings and status to global env.
  return(list(settings = reactive(settings_new()),
              status = reactive(status_new())))
  
}
