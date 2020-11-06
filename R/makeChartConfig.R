#' Make Chart Config
#' 
#' Converts YAML chart configuration files to an R list and binds workflow functions. See the vignette about creating custom charts for more details.
#' 
#' @param dirs path to one or more directories containing yaml files (relative to working directory)
#' @param sourceFiles boolean indicating whether to source all R files found in dirs.
#'
#' @import magrittr
#' @import tools
#' @import yaml
#' @import clisymbols
#' 
#' @return returns a named list of charts derived from YAML files. Each element of the list contains information about a single chart, and has the following parameters:
#' \itemize{
#'  \item{"name"}{ Name of the chart. Also the name of the element in the list - e.g. charts$aeExplorer$name is "aeExplorer"}
#'  \item{"label"}{ short description of the chart }
#'  \item{"type"}{ type of chart; options are: 'htmlwidget', 'module', 'plot', 'table', 'html' or 'plotly'.}
#'  \item{"domain"}{ data domain. Should correspond to a domain in `meta` or be set to "multiple" }
#'  \item{"package"}{ primary package (if any). Other packages can be loaded directly in workflow functions. }
#'  \item{"path"}{ Path to YAML file}
#'  \item{"workflow"}{ List of functions names used to render chart. See vignette for details. }
#'  \item{"functions"}{ List of functions for use in chart renderering. }
#' }
#' @export

makeChartConfig <- function(dirs, sourceFiles=TRUE){
    # Use the charts settings saved in safetycharts if no path is provided. 
    if(missing(dirs) || is.null(dirs)){
        #dirs<-paste(.libPaths(),'safetycharts','chartSettings', sep="/")
        dirs<-paste(.libPaths(),'safetygraphics','config','charts', sep="/")
    }

    if(sourceFiles){
        r_files<-list.files(
            dirs, pattern = "\\.R$", 
            ignore.case=TRUE, 
            full.names=TRUE, 
            recursive=TRUE
        )  
        sapply(r_files, source)
    }

    yaml_files<-list.files(
        dirs,
        pattern = "yaml", 
        recursive = TRUE,
        full.names = TRUE
    )
    
    charts<-lapply(yaml_files, function(path){
        chart <- read_yaml(path)
        chart$path <- path
        chart$name <- path %>% file_path_sans_ext %>% basename
        return(chart)
    })

    names(charts) <- yaml_files %>% file_path_sans_ext %>% basename

    message("Found ", length(yaml_files), " config files: ",paste(names(charts),collapse=", "))

    # Bind workflow functions to chart object
    all_functions <- lsf.str(pos=1)
    charts <- lapply(charts, function(chart){
        function_names <- all_functions[grep(chart$name,all_functions)]
        chart$functions <- lapply(function_names, match.fun)
        names(chart$functions) <- function_names

        # check that functions exist for specified workflows
        workflow_found <- sum(unlist(chart$workflow) %in% function_names)
        workflow_total <- length(unlist(chart$workflow)[names(unlist(chart$workflow))!="widget"])
        message<-paste0(chart$name,": Found ", workflow_found, " of ",workflow_total, " workflow functions, and ", length(chart$functions)-workflow_found ," other functions.")
        if(workflow_found == workflow_total){ 
            message(symbol$tick," ",message)
        }else{
            message(symbol$cross," ", message)
        }

        return(chart)
    })

    return(charts) 
}
