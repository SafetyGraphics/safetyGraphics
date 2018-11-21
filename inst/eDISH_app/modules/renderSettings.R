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
                     selectInput(ns("id_col"),"Unique subject identifier", choices = NULL),
                     selectInput(ns("value_col"),"Lab result", choices = NULL),
                     selectInput(ns("measure_col"),"Lab measure", choices = NULL),
                     h4("Key measures"),
                     selectInput(ns("measure_values|ALT"),"ALT", choices = NULL),
                     selectInput(ns("measure_values|AST"),"AST", choices = NULL),
                     selectInput(ns("measure_values|TB"),"TB", choices = NULL),
                     selectInput(ns("measure_values|ALP"),"ALP", choices = NULL)
              ) ,
              column(6,
                     br(),
                     br(),
                     br(),
                     selectInput(ns("normal_col_low"),"Lower limit of normal", choices = NULL),
                     selectInput(ns("normal_col_high"),"Upper limit of normal", choices = NULL),
                     selectInput(ns("visit_col"),"Visit", choices = NULL),
                     selectInput(ns("visitn_col"),"Visit number", choices = NULL),
                     selectInput(ns("baseline_visitn"),"Baseline visit number", choices = NULL),
                     selectInput(ns("studyday_col"),"studyday_col", choices = NULL),
                     selectInput(ns("anlyFlag"),"anlyFlag", choices = NULL)
                     
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
    updateSelectInput(session, name, label=paste0("!",originalLabel))         
  }
  
  updateSettingStatus<-function(session, name, originalLabel, status){
    updateSelectInput(session, name, label=paste0(originalLabel,"-",status))         
  }
  
  runCustomObserver<-function(name){
    # Custom observer for measure_col
    if(name=="measure_col"){
      observe({
        req(input$measure_col)
        if (!is.null(settings$measure_col)){
          if (input$measure_col==settings$measure_col){
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
  
    #custom observer for visitn_col
    #ignore for v0.4 since baseline_visitn was deprecated in latest js release
    
    #observe({
    #  req(input$visitn_col)
    #  if (!is.null(settings$visitn_col)){
    #    if (input$visitn_col==settings$visitn_col){
    #      choices <- unique(c(settings$baseline_visitn, data()[,settings$visitn_col]))
    #    } else {
    #      choices <- unique(data()[,input$visitn_col])
    #    }
    #  } else {
    #    choices <- unique(data()[,input$visitn_col])
    #  }
    # updateSelectInput(session, "baseline_visitn", choices = choices)
    #})
  } #end runCustomObserver()
  
  ###########################
  # Make updates to the UI
  ###########################
  ns <- session$ns
  req(data())
  req(settings)
  
  #Columns in the data
  colnames <- reactive({names(data())})
  
  #List of all inputs
  #input_names <- reactive({names(lapply(reactiveValuesToList(input), unclass))}) #TODO: needs update
  input_names <- reactive({c("id_col","measure_col")})
  
  #Setting Status information (from failed checks only)
  status_df <- reactive({
    req(status())
    status()$checkList %>% 
      map(., ~ keep(., names(.) %in% c("text_key","valid","message")) %>% 
            data.frame(., stringsAsFactors = FALSE)) %>% 
      bind_rows %>% 
      mutate(top_key = sub("\\|.*", "", text_key)) # %>% 
    #  filter(valid==FALSE)
  })
  
  #List of required settings
  req_settings <- getRequiredSettings("eDish") %>% unlist  #Indicate required settings
  
  #List of inputs with custom observers
  custom_observer_settings <- c("measure_col") #more to be added later
  
  #Establish observers to update settings UI for all inputs
  #Triggered on update of input_names (e.g. new chart type added, ), 
  observe({
     for (name in input_names()){
       setting_key <- as.list(strsplit(name,"\\|"))
       setting_value <- getSettingValue(key=setting_key,settings=settings)
       setting_label <- setting_key #TODO: get the label!
       
       # 1. Update the options for data-mapping inputs
       if(str_detect(name,"_col")){
         sortedChoices<-NULL
         if(!is.null(setting_value)){
           sortedChoices<-unique(c(setting_value, colnames()))
         }else{
           sortedChoices<-colnames()
         } 
         updateSelectInput(session, name, choices=sortedChoices)         
       }
       
       # 2. Flag the input if it is required
       if(name %in% req_settings){
         flagSetting(session=session, name=name, originalLabel=setting_label)
       }
       
       # 3. Print a warning if the input failed a validation check
       if(name %in% status_df()$text_key){
         current_status<- status_df()[status_df()$text_key==name, "message"]
         if(current_status ==""){current_status = "OK"}
         updateSettingStatus(session=session, name=name, originalLabel=setting_label, status=current_status) # TODO: Create this function
       }
       
       # 4. Check for custom observers and initialize if needed
       if(name %in% custom_observer_settings){
         #runCustomObserver(name=name) #TODO: clean this up!
       }
     }
   })


  ### return all inputs from module to be used in global env.
  return(input)
}