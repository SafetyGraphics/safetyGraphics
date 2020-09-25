#' @title Get Chart Functions
#' @description Function to get functions associated with charts 
#'
#' @param chartsList List of charts and thier parameters
#' @param chartSettingsPath path for custom files. 
#' 
#' @return an updated chartsList object with initFunction and chartFunction parameters added as appropriate
#' 
#' @export
#' 
getChartFunctions <- function(chartsList, chartSettingsPaths){
 #source all R files in specified settings paths
 for(path in chartSettingsPaths){
    print(getwd())
    print(path)
    chartSettingsSources <- list.files(path, pattern = "\\Chart.R$", ignore.case=TRUE, full.names=TRUE)
    print(chartSettingsSources)
    sapply(chartSettingsSources, source)
 }

  for(chartID in names(chartsList)){    
    #set default to NULL until function is found
    chartsList[[chartID]][["initFunction"]]<-function(data,settings){
        return(list(data=data,settings=settings))
    } 

    # add init function

    if(exists(paste0(chartID,"_init"))){
        chartsList[[chartID]][["initFunction"]] <- match.fun(paste0(chartID,"_init"))
    }

    # add chart function (type == static only)
    chartsList[[chartID]][["chartFunction"]]<-function(data,settings){
        plot(-1:1, -1:1)
        text(0,0,"Charting Function Not Found")
        text(runif(20, -1,1),runif(20, -1,1),":(")
    }
    if(tolower(chartsList[[chartID]][["type"]])=="static"){
        if(exists(chartID)){
            chartsList[[chartID]][["chartFunction"]] <- match.fun(paste0(chartID))
        }else if(exists(paste0(chartID,"_chart"))){
            chartsList[[chartID]][["chartFunction"]] <- match.fun(paste0(chartID,"_chart"))
        }  
    }
    #TODO: Add some checks to make sure matches are in fact functions
  }
  return(chartsList)
}
