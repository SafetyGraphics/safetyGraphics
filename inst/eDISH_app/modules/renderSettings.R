renderSettingsUI <- function(id){
  
  ns <- NS(id)
  
  tagList(
    fluidRow(
      splitLayout(
        tagList(
          wellPanel(
            fluidRow(
              column(6,
                     h3("Data Mapping"),
                     div(
                         tags$label(id=ns("label_id_col"), "Unique subject identifier"),
                         selectInput(ns("id_col"),NULL, choices = NULL)
                     ),
                     div(
                       tags$label(id=ns("label_value_col"),"Lab Result"),
                       selectInput(ns("value_col"),NULL, choices = NULL)                   
                       ),
                     div(
                       tags$label(id=ns("label_measure_col"),"Lab measure"),
                       selectInput(ns("measure_col"),NULL, choices = NULL)                   
                     ),
                     h4("Key measures"),
                     div(
                       tags$label(id=ns("label_measure_values|ALT"),"ALT"),
                       selectInput(ns("measure_values|ALT"),NULL, choices = NULL)                   
                     ),
                     div(
                       tags$label(id=ns("label_measure_values|AST"),"AST"),
                       selectInput(ns("measure_values|AST"),NULL, choices = NULL)                   
                     ),
                     div(
                       tags$label(id=ns("label_measure_values|TB"),"TB"),
                       selectInput(ns("measure_values|TB"),NULL, choices = NULL)                   
                     ),
                     div(
                       tags$label(id=ns("label_measure_values|ALP"),"ALP"),
                       selectInput(ns("measure_values|ALP"),NULL, choices = NULL)                   
                     )
              ) ,
              column(6,
                     br(),
                     br(),
                     br(),
                     div(
                       tags$label(id=ns("label_normal_col_low"),"Lower limit of normal"),
                       selectInput(ns("normal_col_low"),NULL, choices = NULL)                   
                     ),
                     div(
                       tags$label(id=ns("label_normal_col_high"),"Upper limit of normal"),
                       selectInput(ns("normal_col_high"),NULL, choices = NULL)                   
                     ),
                     div(
                       tags$label(id=ns("label_visit_col"),"Visit"),
                       selectInput(ns("visit_col"),NULL, choices = NULL)                   
                     ),
                     div(
                       tags$label(id=ns("label_visitn_col"),"Visit number"),
                       selectInput(ns("visitn_col"),NULL, choices = NULL)                   
                     ),
                     div(
                       tags$label(id=ns("label_studyday_col"),"Study day"),
                       selectInput(ns("studyday_col"),NULL, choices = NULL)                   
                     ),
                     div(
                       tags$label(id=ns("label_anlyFlag"),"Use flagged analysis pop"),
                       selectInput(ns("anlyFlag"),NULL, choices = NULL)                   
                     )
              ))
          )
        ),
        tagList(
          column(6, 
                 wellPanel(
                   h3("Measure Settings"),
                   selectInput(ns("filters"),"Filters", choices = NULL, selected = NULL, multiple = TRUE),
                   selectInput(ns("group_cols"),"Groups", choices = NULL, multiple = TRUE),
                   selectInput(ns("x_options"),"x_options", choices = c("ALT", "AST", "ALP"), selected = c("ALT", "AST", "ALP"), multiple = TRUE),
                   selectInput(ns("y_options"),"y_options", choices = c("ALT", "AST", "ALP"), selected = c("TB","ALP"), multiple = TRUE)
                 )
          ),
          column(6, 
                 wellPanel(
                     h3("Appearance Settings"),
                         sliderInput(ns("visit_window"),"visit_window", value = 30, min=0, max=50),
                         checkboxInput(ns("r_ratio_filter"),"r_ratio_filter", value = TRUE),
                         conditionalPanel(
                           condition="input.r_ratio_filter==true", ns=ns,
                           sliderInput(ns("r_ratio_cut"),"r_ratio_cut", value = 0, min=0, max =1)
                         ),
                         checkboxInput(ns("showTitle"),"showTitle", value = TRUE),
                         textAreaInput (ns("warningText"),"warningText", 
                                        value = "Caution: This interactive graphic is not validated. Any clinical recommendations based on this tool should be confirmed using your organizations standard operating procedures.")
                     )
        )
      ))
  )
  )
  
}

renderSettings <- function(input, output, session, data, settings, status){


  ####################
  #Helper functions 
  ###################
  #TODO: Save to separate file
  
  flagSetting<-function(session, name, originalLabel){
    shinyjs::html(id = paste0("label_", name), 
                  html = paste0(originalLabel, "<strong>*</strong>"), 
                  add = FALSE)      
  }
  
  updateSettingStatus<-function(session, name, originalLabel, status){
    shinyjs::html(id = paste0("label_", name), 
                    html = paste0(originalLabel, "   <em style='color:red; font-size:12px;'>", status,"</em>")) 
    
  }

  
  runCustomObserver<-function(name){
    settings <- settings()
    
    # Custom observer for measure_col
    if(name=="measure_col"){
      observe({
        req(input$measure_col)
        if (!is.null(settings$measure_col) & input$measure_col==settings$measure_col){
            choices_ast <- unique(c(settings$measure_values$AST, as.character(data()[,settings$measure_col])))
            choices_alt <- unique(c(settings$measure_values$ALT, as.character(data()[,settings$measure_col])))
            choices_tb  <- unique(c(settings$measure_values$TB,  as.character(data()[,settings$measure_col])))
            choices_alp <- unique(c(settings$measure_values$ALP, as.character(data()[,settings$measure_col])))
          } else {
            choices_ast <- unique(data()[,input$measure_col])
            choices_alt <- unique(data()[,input$measure_col])
            choices_tb  <- unique(data()[,input$measure_col])
            choices_alp <- unique(data()[,input$measure_col])
          }

        updateSelectInput(session, "measure_values|ALT", choices = choices_ast)
        updateSelectInput(session, "measure_values|AST", choices = choices_alt)
        updateSelectInput(session, "measure_values|TB",  choices = choices_tb)
        updateSelectInput(session, "measure_values|ALP", choices = choices_alp)
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
  settingsUI_list <- reactive({
    req(input$`measure_values|ALP`)
    req(input$`measure_values|AST`)
    req(input$`measure_values|TB`)
    req(input$`measure_values|ALT`)
    
    settings <- list(id_col = input$id_col,
                     value_col = input$value_col,
                     measure_col = isolate(input$measure_col),  # avoid updating on measure_col - just update on downstream depends
                     normal_col_low = input$normal_col_low,
                     normal_col_high = input$normal_col_high,
                     studyday_col = input$studyday_col,
                     visit_col = input$visit_col,
                     visitn_col = input$visitn_col,
                     baseline_visitn = input$baseline_visitn,
                     measure_values = list(ALT = input$`measure_values|ALT`,
                                           AST = input$`measure_values|AST`,
                                           TB = input$`measure_values|TB`,
                                           ALP = input$`measure_values|ALP`),
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
    
    return(settings)
  })
 
  # validate new settings
  #  the validation is run every time there is a change in settings.   
  #
  #  NOTE: to prevent status updating as loop runs and fills in settings(), 
  #   require the very last updated input to be available

  status_new <- reactive({ #eventReactive(settingsUI_list$settings,{
    req(data())
     name <- rev(isolate(input_names()))[1]
     if (!is.null(settings()[[name]])) {
       validateSettings(data(), settings(), chart="eDish")
     }
   #  req(settingsUI_list$settings[[name]])
  })

 
  # #Setting Status information (from failed checks only)
   status_df <- reactive({
    req(status_new())
     status_new()$checkList %>%
      map(., ~ keep(., names(.) %in% c("text_key","valid","message")) %>%
            data.frame(., stringsAsFactors = FALSE)) %>%
      bind_rows %>%
      mutate(top_key = sub("\\|.*", "", text_key))  %>%
      group_by(text_key) %>%
      slice(1) %>%   # get first set of checks
      filter(valid==FALSE)
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
  
  observe({
    req(colnames())

     for (name in isolate(input_names())){
 
       setting_key <- as.list(strsplit(name,"\\|"))
       setting_value <- getSettingValue(key=setting_key, settings=settings())
       
       setting_label <- name ##TO DO: get the label!

       # 1. Update the options for data-mapping inputs
       if(str_detect(name,"_col") | name %in% c("filters", "group_cols")){
         sortedChoices<-NULL
         if(is.null(setting_value)){
           sortedChoices<-colnames()
         }else{
           sortedChoices<-unique(c(setting_value, colnames()))
         } 
         updateSelectInput(session, name, choices=sortedChoices)
       }

       # 2. Check for custom observers and initialize if needed
       if(name %in% custom_observer_settings){
         runCustomObserver(name=name) #TODO: clean this up!
       }
     }
     })

  # observe({
  #   for (name in isolate(input_names())){
  # 
  #     setting_label <- name
  # 
  #     # 3. Flag the input if it is required
  #     if(name %in% req_settings){
  #       flagSetting(session=session, name=name, originalLabel=setting_label)
  #       setting_label <- paste0(setting_label,"*")  #  <- this line is the reason why I'm including the flagging in
  #                                                   #        this observer vs. the one prior
  # 
  #       }
  # 
  #       # 4. Print a warning if the input failed a validation check
  #       if(name %in% status_df()$text_key){
  #         current_status <- status_df()[status_df()$text_key==name, "message"]
  #         current_status <- ifelse(current_status=="","OK",current_status)
  #         updateSettingStatus(session=session, name=name,
  #                             originalLabel=setting_label,
  #                             status=current_status) # TODO: Create this function
  #       }
  # 
  #   }
  #  })

 
  ### return updated settings and status to global env.
  return(list(settings = reactive(settingsUI_list()),
              status = reactive(status_new())))

}