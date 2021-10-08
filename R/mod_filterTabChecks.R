#' @title  Checks for whether the current data and settings support a filter tab
#'
#' @param domainData list of data files for each domain
#' @param filterDomain domain to use for filtering (typically "dm")
#' @param current_mapping current data mapping (REACTIVE)
#' 
#' @return reactive that returns a boolean indicating whether the checks passed and filtering can be initialized
#' 
#' @export

filterTabChecks <- function(domainData, filterDomain, current_mapping){

    # Check to see if data can be filtered using current settings.
    filterCheck<-reactive({
        currentStatus <- TRUE
        filterCheckNote<-NULL
        if(is.null(filterDomain)){
            # Make sure filterDomain exists.
            currentStatus <- FALSE
            filterCheckNote <- "the filter domain is not specified."
        }else if(!(filterDomain %in% names(domainData))){
            # Make sure the filterDomain is found in the data
            currentStatus <- FALSE
            filterCheckNote <- "the specified filter domain is not found in provided data."
        }else{
            # Make sure id_col is specified for filterDomain in the mapping and has 1+ characters          
            filter_data <- current_mapping() %>% 
                filter(.data$domain==filterDomain)  %>%
                filter(.data$text_key=="id_col")          
            id_col_found <- nrow(filter_data)==1 & nchar(filter_data[1,"current"])>0
            
            if(!id_col_found){
                currentStatus <- FALSE
                filterCheckNote <- "id_col is not specified for the filterDomain in the metadata provided."
            }else{
                # Make sure id_col is specified in all domains.
                id_col <- reactive({
                    filter_data <- current_mapping() %>% filter(.data$domain==filterDomain)   
                    id<- filter_data %>% filter(.data$text_key=="id_col")%>%pull(.data$current)
                    return(id)
                })

                id_check <- all(domainData %>% purrr::map_lgl(~{id_col() %in% colnames(.x)}))
                if(!id_check){
                    currentStatus <- FALSE
                    filterCheckNote <- "id_col is not found in one or more data domain. Update mappings and try again. "
                }else if(FALSE){
                    # TODO: Warn, but proceed if id_col is non-unique in filter domain.
                }else if(FALSE){
                    # TODO: Warn, but proceed if id_col differs across domains.
                }
            }
        }
        if(!currentStatus){
            message("Filters not available because ", filterCheckNote)
        }
        return(currentStatus)
    })  
    
    return(filterCheck)
}
