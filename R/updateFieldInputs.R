
######################################################################
# Update field level inputs
#
# update field-level inputs if a column level setting changes
# dependent on change in data, chart selection, or column-level input
######################################################################

observe({
  field_rows <- getSettingsMetadata(
    charts=input$charts,
    filter_expr = field_mapping==TRUE,
    metadata = metadata
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
            filter_expr = field_column_key==!!col,
            metadata = metadata
          )
          
          ### SET UP CHOICES/PLACEHOLDERS FOR SELECT INPUT UPDATES
          # If it is the default column - populate standards
          if(input[[col]] == isolate(settings()[[col]]) && !is.null(isolate(settings()[[col]])))  {
            choices <- unique(data()[,input[[col]]])
            placeholder <- list (onInitialize = I('function() { }'))
            
            # If it's another column display placeholder message and set to empty
          } else if(input[[col]] %in% colnames(data())) {
            choices <- unique(data()[,input[[col]]])
            placeholder <- list(
              placeholder = "Please select a value",
              onInitialize = I('function() {
                       this.setValue("");}')
            )
            # If empty display different placeholder message
          } else {
            choices <- NULL
            placeholder <- list(
              placeholder =  paste0("Please select a ", getSettingsMetadata(col="label", text_key=col,
                                                                            metadata = metadata )),
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
            if(input[[col]] == isolate(settings()[[col]]) && !is.null(isolate(settings()[[col]])))  {
              setting_key <- as.list(strsplit(key,"\\-\\-"))
              setting_value <- safetyGraphics:::getSettingValue(key=setting_key, settings= isolate(settings()))
              choices <- unique(c(setting_value, choices))
            }
            if (is.null(names(choices))){
              names(choices) <- choices
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
