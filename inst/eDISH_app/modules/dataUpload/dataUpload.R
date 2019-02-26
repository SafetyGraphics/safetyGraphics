#' Data upload module - server code
#'
#' This module creates the Data tab for the Shiny app. 
#' 
#' Workflow:
#' (1) A reactiveValues() list is created with example dataset as first entry. 
#'     The following information is included in list:
#'        - dataset and name
#'        - current (whether the dataset came from most recent upload)
#'        - data standard / quality of match
#' (2) Upon user data upload:
#'        - reactiveValues list is updated with information about new data.
#'        - radio buttons are updated with new data choices
#' (3) When a new dataset is selected, the data preview output is invalidated
#' (4) When a new dataset is selected OR the standard changes (since these don't update at the same time), the
#'     the settings object ("settings()") is invalidated.
#' (5) When a new dataset is selected OR the settings object is updated, the settings validation ("status()") is 
#'     invalidated.
#' 
#' @param input Input objects from module namespace
#' @param output Output objects from module namespace
#' @param session An environment that can be used to access information and functionality relating to the session
#'
#' @return A list of reactive values, including: 
#' \itemize{
#' \item{"data_selected"}{A data frame selected by the user}
#' \item{"settings"}{Result from generateSettings() for data_selected}
#' \item{"status"}{Result from validateSettings() for data_selected and settings}
#'  
dataUpload <- function(input, output, session){

  ns <- session$ns

  # initiate reactive values - list of uploaded data files
  # standard to imitate output of detectStandard.R
  dd <- reactiveValues(data = list("Example data" = adlbc), current = 1, standard = list(list("standard" = "adam", "details" = list("adam"=list("match"="full")))))

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

    # run detectStandard on new data and save to dd$standard

    standard_list <- lapply(data_list, function(x){ detectStandard(x) })

     #standard_list <- lapply(data_list, function(x){ detectStandard(x)$standard })

    dd$standard <- c(dd$standard, standard_list)

  })


  ### make a reactive combining dd$data & standard
  data_choices <- reactive({

    req(dd$data)
    req(dd$standard)

    choices  <- list()
    for (i in 1:length(dd$data)){
      choices[[i]] <- names(dd$data)[i]
    }

    for (i in 1:length(dd$data)){

      temp_standard <- dd$standard[[i]]$standard
      standard_label <- ifelse(temp_standard=="adam","AdAM",ifelse(temp_standard=="sdtm","SDTM",temp_standard))
      if(temp_standard == "none") {
        names(choices)[i] <- paste0("<p>", names(dd$data)[i], " - <em style='font-size:12px;'>No Standard Detected</em></p>")
      } else if (dd$standard[[i]]$details[[temp_standard]]$match == "full") {
        names(choices)[i] <- paste0("<p>", names(dd$data)[i], " - <em style='color:green; font-size:12px;'>", standard_label, "</em></p>")
        # If partial data spec match - give the fraction of variables matched
      } else {

        valid_count <- dd$standard[[i]]$details[[temp_standard]]$valid_count
        total_count <- dd$standard[[i]]$details[[temp_standard]]$invalid_count + valid_count

        fraction_cols  <- paste0(valid_count, "/" ,total_count)

        names(choices)[i] <- paste0("<p>", names(dd$data)[i], " - <em style='color:green; font-size:12px;'>", "Partial ",
                                    standard_label, " (", fraction_cols, " data settings)",  "</em></p>")
      }
    }
    return(choices)
  })

  # update radio buttons to display dataset names and standards for selection
  observeEvent(input$datafile, {
    req(data_choices())
    vals <- data_choices()
    names(vals) <- NULL
    names <- lapply(names(data_choices()), HTML)

    prev_sel <- lapply(reactiveValuesToList(input), unclass)$select_file  # retain previous selection

    updateRadioButtons(session, "select_file",
                       choiceNames = names,
                       choiceValues = vals,
                       selected = prev_sel)

  })

  # get selected dataset when selection changes
  data_selected <- eventReactive(input$select_file, {
    isolate({index <- which(names(dd$data)==input$select_file)[1]})
    dd$data[[index]]
  })

  # upon a dataset being uploaded and selected, generate data preview
  output$datapreview_header <- renderUI({
    data_selected()
    isolate(data_name <- input$select_file)
    h3(paste("Data Preview for", data_name))
  })

  output$data_preview <- DT::renderDataTable({
    DT::datatable(data = data_selected(),
                  caption = isolate(input$select_file),
                  rownames = FALSE,
                  style="bootstrap",
                  class="compact",
                  extensions = "Scroller", options = list(scrollY=400, scrollX=TRUE))
  })


  # upon a dataset being selected, grab its standard
  standard <- eventReactive(data_selected(), {
    index <- which(names(dd$data)==input$select_file)[1]
    dd$standard[[index]]
  })


  # upon a dataset being selected, use generateSettings() to produce a settings obj
  settings <- eventReactive(c(data_selected(), standard()), {

    current_standard <- standard()$standard

    if (! current_standard=="none"){
      partial <- ifelse(standard()$details[[current_standard]]$match == "partial", TRUE, FALSE)

      if (partial) {
        partial_keys <- standard()$details[[current_standard]]$checks %>%
          filter(valid==TRUE) %>%
          select(text_key) %>%
          pull()

        generateSettings(standard=current_standard, chart="eDish", partial=partial, partial_keys = partial_keys)

      } else {
        generateSettings(standard=current_standard, chart="eDish")
      }
    } else {
      generateSettings(standard=current_standard, chart="eDish")
    }
  })


  # run validateSettings(data, standard, settings) and return a status
  status <- reactive({
    req(data_selected())
    req(settings())
    validateSettings(data_selected(),
                     settings(),
                     chart="eDish")
  })

  exportTestValues(status = { status() })

  ### return selected data, settings, and status to server
  return(list(data_selected = reactive(data_selected()),
              settings = reactive(settings()),
              status = reactive(status())))

}
