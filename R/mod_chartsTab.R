#' @title Charts Tab
#' @description  Charting module
#'
#' @param id module id
#' @param chart list containing chart specifications
#' 
#' @importFrom stringr str_to_title
#' @importFrom purrr map2
#' 
#' @export

chartsTabUI <- function(id, chart){
  ns <- shiny::NS(id)    
  header<-div(class=ns("header"), makeChartSummary(chart))
  chartWrap<-chart$functions$ui(ns("chart-wrap"))

  return(list(header, chartWrap))
}

#' @title  home tab - server
#' @description  server for the display of the chart tab  
#'
#' @param input Input objects from module namespace
#' @param output Output objects from module namespace
#' @param session An environment that can be used to access information and functionality relating to the session
#' @param chart list containing a safetyGraphics chart object. see custom chart vignette for details. 
#' @param data named list of current data sets (Reactive).
#' @param mapping tibble capturing the current data mappings (Reactive).
#' 
#' @export

chartsTab <- function(input, output, session, chart, data, mapping){  
  ns <- session$ns
  message("chartsTab() starting for ",chart$name)

  # Initialize chart-specific parameters  
  params <- reactive({ 
    makeChartParams(
      data = data(),
      mapping = mapping(),
      chart = chart
    )
  })

  # Draw the chart
  if(chart$type=="module"){
    callModule(chart$functions$main, "chart-wrap", params)
  }else{
    output[["chart-wrap"]] <- chart$functions$server(
      do.call(
        chart$functions$main,
        params()
      )
    )
  
    # Downolad R script
    insertUI(
      paste0(".",ns("header"), " .chart-header"), 
      where="beforeEnd",
      ui=downloadButton(ns("scriptDL"), "R script", class="pull-right btn-xs dl-btn")
    )
    
    mapping_list<-reactive({
      mapping_list <- generateMappingList(mapping() %>% filter(domain %in% chart$domain))
      if(length(mapping_list)==1){
        mapping_list <- mapping_list[[1]]
      }
      return(mapping_list)
    })

    output$scriptDL <- downloadHandler(
      filename = paste0("sg-",chart$name,".R"),
      content = function(file) {
        writeLines(makeChartExport(chart, mapping_list()), file)
      }
    )

    # Set up chart export button
    insertUI(
      paste0(".",ns("header"), " .chart-header"), 
      where="beforeEnd",
      ui=downloadButton(ns("reportDL"), "html report", class="pull-right btn-primary btn-xs")
    )

    output$reportDL <- downloadHandler(
      filename = paste0("sg-",chart$name,".html"),
      content = function(file) {
        # Copy the report file to a temporary directory before processing it, in case we don't
        # have write permissions to the current working dir (which can happen when deployed).
        templateReport <- system.file("report","safetyGraphicsReport.Rmd", package = "safetyGraphics")
        tempReport <- file.path(tempdir(), "report.Rmd")
        file.copy(templateReport, tempReport, overwrite = TRUE)
        report_params <- list(
          data = data(), 
          mapping = mapping(), 
          chart = chart
        )
        
        rmarkdown::render(
          tempReport,
          output_file = file,
          params = report_params,  ## pass in params
          envir = new.env(parent = globalenv())  ## eval in child of global env
        )
      }
    )
  }
}
