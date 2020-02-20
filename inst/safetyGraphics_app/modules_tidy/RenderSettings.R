RenderSettings <- R6::R6Class(
  "RenderSettings", 
  inherit = tidymodules::TidyModule,
  public = list(
    initialize = function(...){
      # mandatory
      super$initialize(...)
      
      source("modules/renderSettings/util/createSettingsSection.R")
      source("modules/renderSettings/util/createSettingLabel.R")
      source("modules/renderSettings/util/createControl.R")
      source("modules/renderSettings/util/createSettingsUI.R")
      source("modules/renderSettings/util/updateSettingStatus.R")
      
      self$definePort({
        
        self$addInputPort(
          name = "data",
          description = "Input data",
          sample = data.frame(c(1,2,3)))
        
        self$addInputPort(
          name = "settings",
          description = "settings object corresponding to selected data",
          sample = list()
        )
        
        self$addInputPort(
          name = "status",
          description = "Validation status",
          sample = NA
        )
        
        
        self$addOutputPort(
          name = "charts",
          description = "Selected charts",
          sample = "charts")
        
        self$addOutputPort(
          name = "settings",
          description = "COnfigured settings object",
          sample = list()
        )
        
        self$addOutputPort(
          name = "status",
          description = "Validation status for configured settings object",
          sample = NA
        )
        
      })
      
    },
    ui = function() {
      fluidRow(
        createSettingsSection("charts_wrap", "Charts",12,self$ns),
        createSettingsSection("data_mapping", "Data Mappings",6,self$ns),
        createSettingsSection("measure_settings", "Measure Settings",6,self$ns),
        createSettingsSection("appearance_settings", "Appearance Settings",6,self$ns)
      )
    },
    server = function(input, output, session) {
      # Mandatory
      super$server(input, output, session)
      
      ns <- self$ns
      
      charts<-as.vector(filter(chartsMetadata, chart %in% all_charts)[["chart"]])
      labels<-as.vector(filter(chartsMetadata, chart %in% all_charts)[["label"]])
      names(charts)<-labels
      
      output$charts_wrap_ui <- renderUI({
        checkboxGroupButtons(
          ns("charts"),
          label = NULL,
          choices = charts,
          selected = charts,
          checkIcon = list(
            yes = icon("ok-circle", lib = "glyphicon"),
            no = icon("remove-circle",lib = "glyphicon")
          ),
          status="primary"
        )
      })
      
      #List of all inputs
      # Null if no charts are selected
      input_names <- reactive({
        if(!is.null(input$charts)){
          safetyGraphics:::getSettingsMetadata(charts=input$charts, cols="text_key")
        } else{
          NULL
        }
        
      })
      
      
      ######################################################################
      # create settings UI
      #   - chart selection -> gather all necessary UI elements
      #   - create elements based on metadata file
      #   - populate using data/settings
      ######################################################################
      
      output$data_mapping_ui <- renderUI({
        req(self$getInput("data"))
        req(self$getInput("settings"))
        
        charts <- isolate(input$charts)
        tagList(
          createSettingsUI(
            data=self$getInput("data")(),
            settings = self$getInput("settings")(),
            setting_cat_val = "data",
            charts=charts,
            ns=ns
          )
        )
      })
      
      
      output$measure_settings_ui <- renderUI({
        charts <- isolate(input$charts)
        req(self$getInput("data"))
        req(self$getInput("settings"))
        tagList(
          createSettingsUI(
            data=self$getInput("data")(),
            settings = self$getInput("settings")(),
            setting_cat_val = "measure",
            charts=charts,
            ns=ns
          )
        )
      })

      output$appearance_settings_ui <- renderUI({
        charts <- isolate(input$charts)
        req(self$getInput("data"))
        req(self$getInput("settings"))
        tagList(
          createSettingsUI(
            data=self$getInput("data")(),
            settings = self$getInput("settings")(),
            setting_cat_val = "appearance",
            charts=charts,
            ns=ns
          )
        )
      })
       
      ######### Hide Settings that are not relevant to selected charts ########
      observeEvent(input$charts,{

        input_names <- isolate(input_names())

        # Make sure all relevant settings are showing
        if (!is.null(input_names)){
          for (setting in input_names) {
            shinyjs::show(id=paste0("ctl_",setting))
          }
        }

        # Get all possible metadata (input_names always reflects the current chart selections and is already filtered)
        # so I'm grabbing all of these options so I can determine which should be hidden
        all_settings <- getSettingsMetadata(
          cols=c("text_key")
        )

        # Identify which settings in input_names() are not relevant
        settings_to_drop <- setdiff(all_settings,input_names)

        # Use shinyJS::hide() to hide these inputs
        for (setting in settings_to_drop) {
          shinyjs::hide(id=paste0("ctl_",setting))
        }

      }, ignoreNULL=FALSE)  ## input$charts = NULL if none are selected

      # ensure outputs update upon app startup
      outputOptions(output, "charts_wrap_ui", suspendWhenHidden = FALSE)
      outputOptions(output, "data_mapping_ui", suspendWhenHidden = FALSE)
      outputOptions(output, "measure_settings_ui", suspendWhenHidden = FALSE)
      outputOptions(output, "appearance_settings_ui", suspendWhenHidden = FALSE)

      ######################################################################
      # Update field level inputs
      #
      # update field-level inputs if a column level setting changes
      # dependent on change in data, chart selection, or column-level input
      ######################################################################

      observe({
        field_rows <- getSettingsMetadata(
          charts=input$charts,
          filter_expr = field_mapping==TRUE
        )

        if(!is.null(field_rows)){
          column_keys <- field_rows %>%
            pull(field_column_key) %>%
            unique %>%
            as.list()

          lapply(column_keys, function(col){
            col_quo <- enquo(col)
            observeEvent(
              input[[col]],
              {
                field_keys <- getSettingsMetadata(
                  charts=input$charts,
                  col = "text_key",
                  filter_expr = field_column_key==!!col
                )

                ### SET UP CHOICES/PLACEHOLDERS FOR SELECT INPUT UPDATES
                # If it is the default column - populate standards
                if(input[[col]] == isolate(self$getInput("settings")()[[col]]) && !is.null(isolate(self$getInput("settings")()[[col]])))  {
                  choices <- unique(self$getInput("data")()[,input[[col]]])
                  placeholder <- list (onInitialize = I('function() { }'))

                  # If it's another column display placeholder message and set to empty
                } else if(input[[col]] %in% colnames(self$getInput("data")())) {
                  choices <- unique(self$getInput("data")()[,input[[col]]])
                  placeholder <- list(
                    placeholder = "Please select a value",
                    onInitialize = I('function() {
                       this.setValue("");}')
                  )
                  # If empty display different placeholder message
                } else {
                  choices <- NULL
                  placeholder <- list(
                    placeholder =  paste0("Please select a ", getSettingsMetadata(col="label", text_key=col)),
                    onInitialize = I('function() {
                       this.setValue("");}')
                  )
                }

                # update selectInput for each field value
                for (key in field_keys){
                  # Toggle field-level inputs:
                  #    ON  - if column-level input is selected)
                  #    OFF - if column-level input is not yet selected
                  toggleState(id = key, condition = !input[[col]]=="")

                  # if specified in original settings object - append value to choices
                  if(input[[col]] == isolate(self$getInput("settings")()[[col]]) && !is.null(isolate(self$getInput("settings")()[[col]])))  {
                    setting_key <- as.list(strsplit(key,"\\-\\-"))
                    setting_value <- safetyGraphics:::getSettingValue(key=setting_key, settings= isolate(self$getInput("settings")()))
                    choices <- unique(c(setting_value, choices))
                  }

                  updateSelectizeInput(
                    session,
                    inputId = key,
                    choices = choices,
                    options = placeholder
                  ) #update SelectizeInput
                } #for loop
              } #observeEvent (inner)
            ) #observeEvent (outer)
          }) #lapply
        } #if(!is.null)
      }) #observe

      ######################################################################
      # Fill settings object based on selections
      #
      # update is triggered by any of the input selections changing
      ######################################################################

      settings_new <- reactive({

        getValues <- function(x){
          if (is.null(input[[x]])){
            return(NULL)
          } else{
            return(input[[x]])
          }
        }

        req(input_names())
        keys <- input_names()
        values<- keys %>% map(~getValues(.x))

        inputDF <- tibble(text_key=keys, customValue=values)%>%
          rowwise %>%
          filter(!is.null(customValue[[1]]))

        if(nrow(inputDF)>0){
          settings <- generateSettings(custom_settings=inputDF, charts=input$charts)
        }else{
          settings<- generateSettings(charts=input$charts)
        }

        return(settings)
      })


      ######################################################################
      # validate new settings
      #  the validation is run every time there is a change in data and/or settings.
      #
      ######################################################################

      status_new <- reactive({
        req(self$getInput("data"))
        req(settings_new())

        name <- rev(isolate(input_names()))[1]
        settings_new <- settings_new()
        charts <- isolate(input$charts)
        out<-validateSettings(self$getInput("data")(), settings_new, charts=charts)

        return(out)
      })


      ######################################################################
      # Setting validation status information
      ######################################################################
      status_df <- reactive({
        req(status_new())
        status_new()[["checks"]] %>%
          group_by(text_key) %>%
          mutate(num_fail = sum(valid==FALSE)) %>%
          mutate(icon = ifelse(num_fail==0, "<i class='fa fa-check'></i>","<i class='fa fa-times'></i>"))%>%
          mutate(
            message_long = paste(message, collapse = " ") %>% trimws(),
            message_short = case_when(
              num_fail==0 ~ "OK",
              num_fail==1 ~ "1 failed check.",
              TRUE ~ paste(num_fail, "failed checks.")
            )
          ) %>%
          select(text_key, icon, message_long, message_short, num_fail) %>%
          unique
      })

      ######################################################################
      # print validation messages
      ######################################################################
      observeEvent(status_df(), {
        for (key in isolate(input_names())){
          if(key %in% status_df()$text_key){
            status_short <- status_df()[status_df()$text_key==key, "message_short"]
            status_long <- status_df()[status_df()$text_key==key, "message_long"]
            icon <- status_df()[status_df()$text_key==key, "icon"]
            updateSettingStatus(
              ns=ns,
              key=key,
              status_short=status_short,
              status_long=status_long,
              icon=icon
            )
          }
        }
      })


      self$assignPort({
        self$updateOutputPort(
          id = "charts",
          output = reactive(input$charts)
        )

        self$updateOutputPort(
          id = "settings",
          output = settings_new
        )

        self$updateOutputPort(
          id = "status",
          output = status_new
        )
      })

    }
    
  )
)
      
      
      
      
      