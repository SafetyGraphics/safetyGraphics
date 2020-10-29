#' @title Charts Tab
#' @description  Charting module
#'
#' @export

chartsTabUI <- function(id, chart, package, label=chart, type){
  ns <- NS(id)
  chartID <- ifelse(missing(package), chart, paste0(package,"-",chart))
  h2(paste("Chart:",label))
  if(tolower(type=="module")){
    #render the module UI
    
  }else if(tolower(type=="htmlwidget")){
    #render the widget 
    chartsRenderWidgetUI(id=ns(chartID),chart=chart,package=package)
  }else{
    #create the static or plotly chart
    chartsRenderStaticUI(id=ns(chartID), type=type)
  }
}

#' @title  home tab - server
#' @description  server for the display of the chart tab  
#'
#' @param input Input objects from module namespace
#' @param output Output objects from module namespace
#' @param session An environment that can be used to access information and functionality relating to the session
#' @param type type of chart. Must be 'htmlwidget', 'module', 'plot', 'table', 'html' or 'plotly'. See ?mod_chartRenderer* functions for more details about each chart type.
#' @param package  package containing the widget. 
#' @param chart chart name. Should generally match the name of the function/widget/module to be intiated. See specific renderer modules for more details. 
#' @param chartFunction function to generate static chart. 
#' @param initFunction function called before the chart is generated. The function should take `data` and `settings` as inputs and return `params` which should be a list which is then provided to the widget. If domain is specified, only domain-level information is passed to the init function, otherwise named lists containing information for all domains is provided. The mapping is parsed as a list using `generateMappingList()` before being passed to the init function.  By default, init returns an unmodified list of data and settings - possibly subset to the specified domain (e.g. list(data=data, settings=settings))
#' @param domain data domain. Should correspond to a domain in `meta` or be set to "multiple", in which case, named lists for `data` and `mappings` containing all domain data are used.  
#' @param data named list of current data sets [reactive].
#' @param mapping tibble capturing the current data mappings [reactive].
#' 
#' @export

chartsTab <- function(input, output, session, chart, type, package, chartFunction, initFunction, domain, data, mapping){
  ns <- session$ns
  chartID <- ifelse(missing(package), chart, paste0(package,"-",chart))

    params <- reactive({
        
        #convert settings from data frame to list and subset to specified domain (if any)
        settingsList <-  safetyGraphics::generateMappingList(mapping(), domain=domain)
        
        #subset data to specific domain (if specified)
        if(domain=="multiple"){
            domainData <- data()
        }else{
            domainData<- data()[[domain]]
        }

        #customize initial the parameters if desired - otherwise pass through domain level data and mapping)
        params <- initFunction(data=domainData, settings=settingsList)
        
        return(params)
    })
  
  if(tolower(type=="module")){
      #render the module UI
      #call the module server
  }else if(tolower(type=="htmlwidget")){
      callModule(
        chartsRenderWidget,
        chartID,
        chart=chart,
        package=package,
        params=params
      )
  }else{
      #create the static or plotly chart
      callModule(
        chartsRenderStatic,
        chartID,
        chartFunction=chartFunction,
        params=params, 
        type=type
      )
  }
}