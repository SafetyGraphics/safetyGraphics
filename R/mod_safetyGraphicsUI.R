#' UI for the core safetyGraphics app including Home, Mapping, Filter, Charts and Settings modules.  
#'
#' @param id module ID
#' @param charts list of charts in the format produced by safetyGraphics::makeChartConfig()
#' @param meta data frame containing the metadata for use in the app. 
#' @param domainData named list of data.frames to be loaded in to the app.
#' @param mapping data.frame specifying the initial values for each data mapping. If no mapping is provided, the app will attempt to generate one via \code{detectStandard()}
#' @param standards a list of information regarding data standards. Each list item should use the format returned by safetyGraphics::detectStandard.
#'
#' @importFrom shinyjs useShinyjs
#' 
#' @export

safetyGraphicsUI <- function(id,
    meta,
    mapping,
    domainData,
    charts,
    standards,
    config
) {
    ns<-NS(id)

    #read css from package
    css_path <- system.file("www","index.css", package = "safetyGraphics")
    app_css <-  HTML(readLines(css_path))

    #script to append population badge nav bar
    participant_badge<-tags$script(
        HTML(paste0(
            "var header = $('.navbar > .container-fluid');",
            "header.append(\"",
            "<div id='population-header' class='badge' title='Selected Participants'>",
            "<span id='header-count'></span>",
            "/",
            "<span id='header-total'></span> participants",
            "</div>",
            "\");"
        ))
    )
    if(isNamespaceLoaded("shinybusy")){
        spinner<-shinybusy::add_busy_spinner(spin = "atom", position="bottom-right")
    }else{
        spinner<-NULL
    }

    #Set up ChartNav
    #trick for navbar menu: https://stackoverflow.com/questions/34846469/for-loops-lapply-navbarpage-within-in-ui-r
    chartList <- charts %>%
        purrr::map(function(chart) {
            chartsNavUI(ns(chart$name), chart)
        }) %>%
        unname

    navParams<-c(
        list(
            title='Charts',
            icon=icon("chart-bar")
        ),
        chartList
    )

    chartNav <- do.call(navbarMenu, navParams)

    #app UI using calls to modules
    ui<-tagList(
        shinyjs::useShinyjs(),
        spinner,
        tags$head(
            tags$style(app_css),
            tags$link(
                rel = "stylesheet",
                type = "text/css",
                href = "https://use.fontawesome.com/releases/v5.8.1/css/all.css"
            )
        ),
        navbarPage(
            config$appName,
            id=ns("safetyGraphicsApp"),
            tabPanel("Home", icon=icon("home"), homeTabUI(ns("home"))),
            tabPanel("Mapping", icon=icon("map"), mappingTabUI(ns("mapping"), meta, domainData, mapping, standards)),
            tabPanel("Filtering", icon=icon("filter"), filterTabUI(ns("filter"))),
            chartNav,
            tabPanel('',icon=icon("cog"), settingsTabUI(ns("settings")))
        ),
        participant_badge
    )
    return(ui)
}
