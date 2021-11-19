#' Make Chart Config
#' 
#' Converts YAML chart configuration files to an R list and binds workflow functions. See the vignette about creating custom charts for more details.
#' 
#' @param dirs path to one or more directories containing yaml config files (relative to working directory)
#' @param packages installed packages names containing yaml config files in the /inst/{packageLocation} folder
#' @param packageLocation inst folder where yaml config files (and possibly R functions referenced in yaml workflow) are located in `packages`
#' @param sourceFiles boolean indicating whether to source all R files found in dirs.
#'
#' @import yaml
#' @import purrr
#' 
#' @return returns a named list of charts derived from YAML files. Each element of the list contains information about a single chart, and has the following parameters:
#' \itemize{
#'  \item{"env"}{ Environment for the chart. Must be set to "safetyGraphics" or the chart is dropped.}
#'  \item{"name"}{ Name of the chart. Also the name of the element in the list - e.g. charts$aeExplorer$name is "aeExplorer"}
#'  \item{"label"}{ Short description of the chart }
#'  \item{"type"}{ Type of chart; options are: 'htmlwidget', 'module', 'plot', 'table', 'html' or 'plotly'.}
#'  \item{"domain"}{ Data domain. Should correspond to one or more domains in `meta` }
#'  \item{"package"}{ Primary package (if any). Other packages can be loaded directly in workflow functions. }
#'  \item{"order"}{ Integer order in which to display the chart. If order is a negative number, the chart is dropped. }
#'  \item{"export"}{ Logical flag indicating whether the chart can be exported to an html report. True by default, except for when type is module. }
#'  \item{"path"}{ Path to YAML file}
#'  \item{"links"}{ Named list of link names/urls to be shown in the chart header. }
#'  \item{"workflow"}{ List of functions names used to render chart. See vignette for details. }
#'  \item{"functions"}{ List of functions for use in chart renderering. These functions must be located in the global environment or `package` field of the YAML config. Function names must include either the `name` or `workflow` fields of the YAML config. }
#' }
#' @export

makeChartConfig <- function(dirs, packages="safetyCharts", packageLocation="config", sourceFiles=FALSE){
    if(missing(dirs)) dirs<-NULL

    # add local package installation to dirs if specified in packages
    if(!is.null(packages)){
        for(package in packages){
            packageFound<-FALSE
            for(lib in .libPaths()){
                
                packageDir<-paste(lib,package,packageLocation, sep="/")               
                if(file.exists(packageDir)) {
                    loaded <- do.call(require,list(package))
                    if(!loaded) do.call(library,list(package)) #Attach the library to the search list if it is installed
                    message("- Found the {",package,"} package and added ", packageDir," to list of chart locations.")
                    packageFound<-TRUE   
                    dirs<-c(dirs, packageDir)
                    break               
                }
            }
            if(!packageFound){
                message("{",package, "} package not found or '",packageLocation,"' folder does not exist, please install package and confirm that specified folder is found.")
            }
        }
    }

    # Source all files in specified directories if requested
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

    #copied from tools package
    file_path_sans_ext <-function (x) {
        sub("([^.]+)\\.[[:alnum:]]+$", "\\1", x)
    }
    
    # Create chart objects from YAML files in specified location
    yaml_files<-list.files(
        dirs,
        pattern = "yaml", 
        recursive = TRUE,
        full.names = TRUE
    )
    
    charts_raw <- yaml_files %>% 
        map(function(path){
            chart<-read_yaml(path)
            chart$path <- path
            if(!hasName(chart,"name")){
                chart$name <- path %>% file_path_sans_ext %>% basename        
            }
            return(chart)
        })

    charts <- charts_raw %>% map(prepareChart)
    names(charts) <- charts %>% map_chr(~.x$name)

    message(
        "- Found ", 
        length(charts), 
        " charts in the following location(s): ", 
        paste(dirs,collapse="; "),
        "\n  * ",
        paste(names(charts),collapse="\n  * ")
        )

    return(charts) 
}
