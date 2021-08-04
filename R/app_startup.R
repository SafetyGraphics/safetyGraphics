#' Startup code for shiny app
#' 
#' Prepare inputs for safetyGraphics app - run before app is initialized. 
#' 
#' @param domainData named list of data.frames to be loaded in to the app. Sample AdAM data from the safetyData package used by default
#' @param meta data frame containing the metadata for use in the app. See the preloaded file (\code{?safetyGraphics::meta}) for more data specifications and details. Defaults to \code{safetyGraphics::meta}. 
#' @param charts list of charts in the format produced by safetyGraphics::makeChartConfig()
#' @param mapping list specifying the initial mapping values for each data mapping for each domain (e.g. list(aes= list(id_col='USUBJID', seq_col='AESEQ')). 
#' @param autoMapping boolean indicating whether the app should attempt to automatically detect data standards and generate mappings for the data provided. Values specified in the `mapping` parameter overwrite automatically generated mappings when both are found. Defaults to true.
#' @param filterDomain domain used for the data/filter tab. Demographics ("`dm`") is used by default. Using a domain that is not one record per participant is not recommended. 
#' @param chartSettingsPaths path(s) where customization functions are saved relative to your working directory. All charts can have itialization (e.g. myChart_Init.R) and static charts can have charting functions (e.g. myGraphic_Chart.R).   All R files in this folder are sourced and files with the correct naming convention are linked to the chart. See the Custom Charts vignette for more details. 
#'
#' 
#' @return List of elements for used to initialize the shiny app with the following parameters
#'  \itemize{
#'  \item{"meta"}{ List of configuration metadata }
#'  \item{"charts"}{ List of charts }
#'  \item{"domainData"}{ List of domain level data sets }
#'  \item{"mapping"}{ Initial Data Mapping  }
#'  \item{"standards"}{ List of domain level data standards }
#' }
#' 
#' @export
app_startup<-function(domainData=NULL, meta=NULL, charts=NULL, mapping=NULL, autoMapping=NULL, filterDomain=NULL, chartSettingsPaths=NULL){
    # Process charts metadata
    if(is.null(charts)){
        if(is.null(chartSettingsPaths)){
            charts <- makeChartConfig()
        }else{
            charts <- makeChartConfig(chartSettingsPaths)
        }
    }

    # Drop charts where order is negative
    orderDrops <- charts[purrr::map_lgl(charts, function(chart) chart$order < 0)]
    if(length(orderDrops)>0){
        message("Dropped ", length(orderDrops), " charts: ",paste(names(orderDrops),collapse=", "))
        message("To display these charts, set the `order` parameter in the chart object or yaml file to a positive number.")
        charts <- charts[purrr::map_lgl(charts, function(chart) chart$order >= 0)]
    }
    
    #Drop charts if data for required domain(s) is not found
    chart_drops <- charts %>% purrr::keep(~(!all(.x$domain %in% names(domainData))))
    if(length(chart_drops)>0){
        message("Dropping ", length(chart_drops), " chart(s) with missing data domains: ", paste(names(chart_drops), collapse=", "))
    }
    charts <- charts %>% purrr::keep(~all(.x$domain %in% names(domainData)))
    
    # Set filterDomain to NULL if specified domain doesn't exist
    if(!is.null(filterDomain)){
        if(!filterDomain %in% names(domainData)){
            message("No data found for specified filter domain of '",filterDomain,"', so filter functionality has been deactivated.")
            filterDomain<-NULL
        }
    }

    # generate mappings and data standards
    mappingObj <- makeMapping(domainData, meta, autoMapping, mapping)

    config<-list(
        meta=meta,
        charts=charts,
        domainData=domainData,
        mapping=mappingObj$mapping,
        standards=mappingObj$standards,
        filterDomain=filterDomain
    ) 
    
    # Check config
    # TODO write some checks to make sure the config is valid. 

    return(config)
}