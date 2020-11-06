#' Startup code for shiny app
#' 
#' Prepare inputs for safetyGraphics app - run before app is initialized. See ?safetyGraphicsApp for parameter definitions
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
app_startup<-function(domainData, meta, charts, mapping, chartSettingsPaths){

    # Process charts metadata
    if(is.null(charts)){
        if(is.null(chartSettingsPaths)){
            charts <- makeChartConfig(chartSettingsPaths)
        }else{
            charts <- makeChartConfig()
        }
        
    }

    # get the data standards
    standards <- names(domainData) %>% lapply(function(domain){
        return(detectStandard(domain=domain, data = domainData[[domain]], meta=meta))
    })
    names(standards)<-names(domainData)

    # attempt to generate a mapping if none is provided by the user
    if(is.null(mapping)){
        mapping_list <- standards %>% lapply(function(standard){
            return(standard[["mapping"]])
        })
        mapping<-bind_rows(mapping_list, .id = "domain")
    }

    config<-list(
        meta=meta,
        charts=charts,
        domainData=domainData,
        mapping=mapping,
        standards=standards
    ) 
    
    # Check config
    # TODO write some checks to make sure the config is valid. 

    return(config)
}