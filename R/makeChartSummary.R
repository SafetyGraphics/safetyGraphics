#' @title html chart summary
#' @description  makes a nicely formatted html summary for a chart object
#'
#' @param chart list containing chart specifications
#' @param status (optional) chart status from `getChartStatus`. Default is NULL. 
#' @param showLinks boolean indicating whether to include links
#' @param class character to include as class
#' 
#' @export

makeChartSummary<- function(chart, status=NULL, showLinks=TRUE, class="chart-header"){

    if(!is.null(status)){
        print(status)
        if(status$status){
            status <- div(class="status", tags$small("Status"), tags$i(class="fa fa-check-circle", style="color: green"),title=status$summary)
        }else{
            status <- div(class="status", tags$small("Status"), tags$i(class="fa fa-times-circle", style="color: red"),title=status$summary)
        }
    }else{
        status <- NULL
    }
    
    if(utils::hasName(chart,"links")){
        links<-purrr::map2(
            chart$links, 
            names(chart$links), 
            ~a(
                .y, 
                href=.x,
                class="chart-link",
                target='_blank'
            )
        )
        links<-div(tags$small("Links"), links)
    }else{
        links<-NULL
    }

    labelDiv<-div(class="name", tags$small("Chart"),chart$label)
    typeDiv<-div(class="type", tags$small("Type"), chart$type)
    dataDiv<-div(class="domain", tags$small("Data Domain"), paste(chart$domain,collapse=" "))

    class <- c('chart-summary',class)
    
    if(showLinks){
        summary<-div(
            labelDiv,
            typeDiv,
            dataDiv, 
            links,
            status,
            class=class
        )
    } else {
        summary<-div(
            labelDiv,
            typeDiv,
            dataDiv, 
            status,
            class=class
        )
    }
    return(summary)
}
