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

  # convert settings to json for widgets
  if(chart$type == "htmlwidget"){
    params$rSettings <- params$settings
    params$settings <- jsonlite::toJSON(
      params$settings,
      auto_unbox = TRUE,
      null = "null",  
    )
  }

  return(params)
}