# Functions to include
source("modules/renderSettings/util/createSettingsSection.R")
source("modules/renderSettings/util/createSettingLabel.R")
source("modules/renderSettings/util/createControl.R")
source("modules/renderSettings/util/createSettingsUI.R")
source("modules/renderSettings/util/updateSettingStatus.R")

#' Render Settings module - Server code
#' 
#' This module creates the Settings tab for the Shiny app. 
#'  
#' Workflow:
#' (1) Reactive input_names() contains names of settings related to selected charts.  When a user changes
#'     chart selections, input_names() is invalidated.
#' (2) A change in input_names(), `data`, or `settings` invalidates the following:
#'      - renderUI associated with data mapping settings
#'      - renderUI associated with measure settings
#'      - renderUI associated with appearance settings
#' (3) These renderUI's call upon the createSettingsUI() function and will update
#'     even when settings tab not in view.  They will create and populate the UI for all related settings.
#' (4) Field-level inputs are updated upon any of the following events:
#'      - a change in selected data
#'      - change in selected chart(s)
#'      - change in column-level input selection
#'     update includes:
#'      - Deactivate/activate field-level selector based on whether column-level input has been selected
#'      - Data choices for field-level inputs based on selected column-level input
#'  (5) A reactive representing the new settings object (settings_new()) is created based on UI selections. This object is invalidated
#'      when ANY input changes.
#'  (6) A reactive representing the new data/settings validation (status_new()) is created based on data and updated settings object.  
#'      A change in data OR updated settings object invalidated this reactive.
#'  (7) Upon a change in the new validation (status_new() and derived status_df()), updated status messages are 
#'      printed on UI by calling updateSettingStatus().  ALL messages are re-printed at once.
#'     
#' @param input Input objects from module namespace
#' @param output Output objects from module namespace
#' @param session An environment that can be used to access information and functionality relating to the session
#' @param data A data frame
#' @param settings Settings object that corresponds to data's standard - result of generateSettings().
#' @param status A list describing the validation state for data/settings - result of validateSettings().
#'
#' @return A list of reactive values, including: 
#' \itemize{
#' \item{"charts"}{A vector of chart(s) selected by the user}
#' \item{"settings"}{Upadted settings object based on UI/user selections}
#' \item{"status"}{Result from validateSettings() for originally selected data + updated settings object}
#' 
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
    req(input$charts)
    tagList(createSettingsUI(data=data(), settings = settings(), setting_cat_val = "data", charts=input$charts, ns=ns))
  })
  outputOptions(output, "data_mapping_ui", suspendWhenHidden = FALSE) 
  
  output$measure_settings_ui <- renderUI({
    req(input$charts)
    tagList(createSettingsUI(data=data(), settings = settings(), setting_cat_val = "measure", charts=input$charts, ns=ns))
  })
  outputOptions(output, "measure_settings_ui", suspendWhenHidden = FALSE)
  
  output$appearance_settings_ui <- renderUI({
    req(input$charts)
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
    
    field_rows <- getSettingsMetadata(charts=input$charts,
                                      filter_expr = field_mapping==TRUE) 
    
    if(!is.null(field_rows)){
    column_keys <- field_rows %>% 
      pull(field_column_key) %>% 
      unique %>% 
      as.list()
    
    lapply(column_keys, function(col){
      
      col_quo <- enquo(col)
      observeEvent(input[[col]],{
     
        field_keys <- getSettingsMetadata(charts=input$charts, col = "text_key", 
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
    }
  })
 
  
  ######################################################################
  # Fill settings object based on selections
  #  
  # update is triggered by any of the input selections changing
  ######################################################################
  
  settings_new <- reactive({
   
    keys<-input_names() %>% as.character()
    values<- keys %>% map(~ifelse(is.null(input[[.x]]) , "", input[[.x]])) #Only capturing the first value in vectors ... 
    inputDF <- tibble(text_key=keys, customValue=values) %>% mutate(customValue= unlist(customValue))
    
    #print(inputDF)
    settings <- generateSettings(custom_settings=inputDF) #need to add charts paramater
    #print(settings)
    
    # Need to reevaluate custom mappings below. 
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
    
    return(settings)
  })
  
  
  ######################################################################
  # validate new settings
  #  the validation is run every time there is a change in data and/or settings.
  #
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
    
    out <- list()
    
    charts <- isolate(input$charts)
    for (chart in charts){
      out[[chart]] <- validateSettings(data(), settings_new, chart=chart)
    }
    
    return(out)
  })
  
  
  ######################################################################
  # Setting validation status information
  ######################################################################
  status_df <- reactive({
    req(status_new())
    
    #status_new()$checks %>% 
    flatten(status_new()) %>%
      keep(., names(.)=="checks") %>% 
      bind_rows() %>% 
      unique  %>% 
      group_by(text_key) %>%
      mutate(num_fail = sum(valid==FALSE)) %>%
      mutate(icon = ifelse(num_fail==0, "<i class='glyphicon glyphicon-ok'></i>","<i class='glyphicon glyphicon-remove'></i>"))%>%
      mutate(message_long = paste(message, collapse = " ") %>% trimws(),
             message_short = case_when(
               num_fail==0 ~ "OK",
               num_fail==1 ~ "1 failed check.",
               TRUE ~ paste(num_fail, "failed checks.")
             )) %>%
      select(text_key, icon, message_long, message_short, num_fail) %>%
      unique 
  })
  
  # for shiny tests
  exportTestValues(status_df = { status_df() })
  
  ######################################################################
  # print validation messages
  ######################################################################
 observe({
   for (key in isolate(input_names())){

     if(key %in% status_df()$text_key){

       status_short <- status_df()[status_df()$text_key==key, "message_short"]
       status_long <- status_df()[status_df()$text_key==key, "message_long"]
       icon <- status_df()[status_df()$text_key==key, "icon"]
       updateSettingStatus(ns=ns, key=key, status_short=status_short, status_long=status_long, icon=icon)
     }

   }
 })
 
  ### return updated settings and status to global env.
  return(list(charts = reactive(input$charts),
              settings = reactive(settings_new()),
              status = reactive(status_new())))
  
}
