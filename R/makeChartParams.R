#' @title Make Chart Parameters
#' @description Updates raw data and mapping for use with a specific chart
#'
#' @param dataDomains list of domain-level data
#' @param chart list containing chart specifications
#' @param mapping data frame with current mapping
#' 
#' @export

makeChartParams <- function(data, chart, mapping){
  settingsList <-  safetyGraphics::generateMappingList(mapping, domain=chart$domain)
  
  #subset data to specific domain (if specified)
  if(length(chart$domain)>1){
    domainData <- data
  }else{
    domainData<- data[[chart$domain]]
  }
  params <- list(data=domainData, settings=settingsList)

  #customize initial the parameters if desired - otherwise pass through domain level data and mapping)
  if(utils::hasName(chart,"functions")){
    if(utils::hasName(chart$workflow,"init")){
      message(chart$name, " has an init.")
      params <- do.call(chart$functions[[chart$workflow$init]], params)
    }
  }

  # format parameters for htmlwidget
  if(chart$type == "htmlwidget"){
    widgetParams <- list(
      name=chart$workflow$widget, 
      package=chart$package,
      sizingPolicy = htmlwidgets::sizingPolicy(viewer.suppress=TRUE, browser.external = TRUE),
      x=list()
    )
    widgetParams$x$data <- params$data
    widgetParams$x$rSettings <- params$settings
    widgetParams$x$settings <- jsonlite::toJSON(
      params$settings,
      auto_unbox = TRUE,
      null = "null",  
    )
    params <- widgetParams
  }

  return(params)
}