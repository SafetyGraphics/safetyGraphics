#' Check the status of a chart based on the current mapping
#'
#' Checks a chart's status when column-level chart specifications are provided in chart$dataSpec.
#' Note that safetyGraphicsApp() does not allow a `mapping` value that is not found in `domainData`,
#' so this function only needs to check that an expected parameter exists in `mapping` (not that the
#' specified column is found in the loaded data). 
#' 
#' @param chart `list` chart object
#' @param mapping `data.frame` current mapping
#' 
#' @return `list` Named list with properties:
#' - status `logical`
#' - domains `list` list specifying whether all columns are specified in each domain
#' - columns `list`  list that matches the structure of chart$dataSpec and indicates which variables are available. 
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
#' check <- safetyGraphics:::getChartStatus(chart=sample_chart, mapping=sample_mapping) 
#' # check$status=TRUE
#'
#' # Add data spec to each chart.
#' charts <- makeChartConfig() %>%
#'     map(function(chart) {
#'         chart$mapping <- chart$domain %>%
#'             map_dfr(function(domain) {
#'                 do.call(
#'                     `::`,
#'                     list(
#'                         'safetyCharts',
#'                         paste0('meta_', domain)
#'                     )
#'                 )
#'             }) %>%
#'             distinct(domain, col_key, current = standard_adam) %>%
#'             filter(!is.na(current)) %>%
#'             select(domain, text_key = col_key, current)
#' 
#'         chart$dataSpec <- chart$domain %>%
#'             map(function(domain) {
#'                 chart$mapping %>%
#'                     filter(.data$domain == !!domain) %>%
#'                     pull(text_key) %>%
#'                     unique()
#'             }) %>%
#'             set_names(chart$domain)
#' 
#'         chart
#'     })
#'
#' checks <- map(charts, ~getChartStatus(.x, .x$mapping))
#' 
#' @importFrom purrr imap map
#' @importFrom rlang set_names
#'
#' @keywords internal
getChartStatus <- function(chart, mapping){
    stopifnot(
        "Can't get status since chart does not have dataSpec associated."=hasName(chart, 'dataSpec')
    )

    # check to see whether each individual column has a mapping defined
    missingCols<-c()
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

    # make a text summary
    if(status){
        summary <- "All required mappings found"
    }else{
        missingCols <- colStatus %>% imap(function(cols,domain){
            missingDomainCols <- cols %>% imap(function(status, col){
                if(status){
                    return(NULL)
                }else{
                    return(paste0(domain,"$",col))
                }
            })
            return(missingDomainCols)
        })
        print(missingCols)
        summary<- paste0("Missing Mappings: ",paste(unlist(missingCols),collapse=","))
    }

    return(list(chart=chart$name, columns=colStatus, domains=domainStatus, status=status, summary=summary))
}
