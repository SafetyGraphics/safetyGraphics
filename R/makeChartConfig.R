#' Make Chart Config
#' 
#' Converts YAML chart configuration files to an R list and binds workflow functions. See the vignette about creating custom charts for more details.
#' 
#' @param dirs path to one or more directories containing yaml files (relative to working directory)
#' @param sourceFiles boolean indicating whether to source all R files found in dirs.
#'
#' @import yaml
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
#'  \item{"functions"}{ List of functions for use in chart renderering. These functions must be located in the global environment or `package` field of the YAML config. Function names must include either the `name` or `workflow` fields of the YAML config. }
#' }
#' @export

makeChartConfig <- function(dirs, sourceFiles=TRUE){
    # Use the charts settings saved in safetycharts if no path is provided. 
    if(missing(dirs) || is.null(dirs)){
        safetyChartsFound<-FALSE
        for(lib in .libPaths()){
            print(lib)
            dirs<-paste(lib,'safetyCharts','config', sep="/")               
            if(file.exists(dirs)) {
                print("found configs")
                print(dirs)
                safetyChartsFound<-TRUE   
                break               
            }
        }

        if(!safetyChartsFound){
            message("safetyCharts library not found, please install safetyCharts or provide a path to custom chart configuration files. See safetyGraphics vignettes for details.")
        }
    }

    if(sourceFiles){
        r_files<-list.files(
            dirs, 
            pattern = "\\.R$", 
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
    
    #copied from tools package
    file_path_sans_ext <-function (x) {
        sub("([^.]+)\\.[[:alnum:]]+$", "\\1", x)
    }

    charts<-lapply(yaml_files, function(path){
        chart <- read_yaml(path)
        chart$path <- path
        chart$name <- path %>% file_path_sans_ext %>% basename
        chart$order <- ifelse(
            is.null(chart$order),
            length(yaml_files) + 1,
            chart$order
        ) %>% as.numeric

        return(chart)
    })

    names(charts) <- yaml_files %>% file_path_sans_ext %>% basename
    charts <- charts[order(purrr::map_dbl(charts, function(chart) chart$order))]

    message("Found ", length(yaml_files), " config files: ",paste(names(charts),collapse=", "))

    # Bind workflow functions to chart object
    all_functions <- as.character(utils::lsf.str(".GlobalEnv"))
    message("Global Functions: ",all_functions)
    charts <- lapply(charts, 
        function(chart){
            if(utils::hasName(chart, "package")){
                package_functions <- as.character(utils::lsf.str(paste0("package:",chart$package)))
                all_functions<-c(all_functions,package_functions)
            }

            #search functions that include the charts name or the workflow function names
            chart_function_names <- c()
            for(query in c(chart$name, unlist(chart$workflow)) ){
                matches<-all_functions[str_detect(query, all_functions)]
                chart_function_names <- c(chart_function_names, matches)
            }

            chart$functions <- lapply(chart_function_names, match.fun)
            names(chart$functions) <- chart_function_names

            # check that functions exist for specified workflows
            workflow_found <- sum(unlist(chart$workflow) %in% chart_function_names)
            workflow_total <- length(unlist(chart$workflow)[names(unlist(chart$workflow))!="widget"])
            message<-paste0(chart$name,": Found ", workflow_found, " of ",workflow_total, " workflow functions, and ", length(chart$functions)-workflow_found ," other functions.")
            if(workflow_found == workflow_total){ 
                message("+ ",message)
            }else{
                message("x ", message)
            }

            return(chart)
        }
    )
    return(charts) 
}
