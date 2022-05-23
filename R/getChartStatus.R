#' Check the status of a chart based on the current mapping
#'
#' Checks a chart's status when column-level chart specifications are provided in chart$dataSpec. Note that safetyGraphicsApp() does not allow a `mapping` value that is not found in `domainData`, so this function only needs to check that an expected parameter exists in `mapping` (not that the specified column is found in the loaded data). 
#' 
#' Returns a list, with:
#' - `status` (TRUE, FALSE)
#' - `domains` a list specifying wheter all columns are specified in each domain
#' - `columns`  a list that matches the structure of chart$dataSpec and indicates which variables are available. 
#'
#' @param chart chart object
#' @param mapping the current mapping data.frame 
#' 
#' @return a list with `status`, `domains` and `columns` properties
#'
#' @examples
#' sample_chart <- list(
#'     domains=c("aes","dm"),
#'     dataSpec=list(
#'         aes=c("id_col","custom_col"),
#'         dm=c("id_col","test_col")
#'     )
#' )
#' 
#' sample_mapping <- data.frame(
#'     domain=c("aes","aes","dm","dm"),
#'     text_key=c("id_col","custom_col","id_col","test_col"),
#'     current=c("myID","AEcol","myID","dmCol")
#' )
#' 
#' check <- getChartStatus(chart=ae_chart, mapping=mapping) 
#' # check$status=TRUE
#'
#' @importFrom purrr map_lgl set_names
#' @keywords internal

getChartStatus <- function(chart, mapping){
    stopifnot(
        "Can't get status since chart does not have dataSpec associated."=hasName(chart, 'dataSpec')
    )

    # check to see whether each individual column has a mapping defined
    colStatus <- names(chart$dataSpec) %>% map(function(domain){
        domainMapping <- generateMappingList(settingsDF=mapping, domain=domain)
        requiredCols <- chart$dataSpec[[domain]]
        colStatus <- requiredCols %>% map(function(col){
            if(hasName(domainMapping,col)){
                status<-case_when(
                    domainMapping[[col]]=='' ~ FALSE,
                    is.na(domainMapping[[col]]) ~ FALSE,
                    is.character(domainMapping[[col]]) ~ TRUE
                )
            } else{
                status<-FALSE
            }
            return(status)
        }) %>% set_names(requiredCols)
        return(colStatus)    
    })%>% set_names(names(chart$dataSpec))

    # check to see whether all columns in a domain were valid
    domainStatus <- colStatus %>%
        map(~all(unlist(.x))) %>%
        set_names(names(colStatus))

    # check to see whether all columns in all domains were valid
    status <- ifelse(all(unlist(domainStatus)),TRUE, FALSE)

    return(list(chart=chart$name, columns=colStatus, domains=domainStatus, status=status))
}