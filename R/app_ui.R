#' UI for the default safetyGraphics shiny app
#'
#' @param meta data frame containing the metadata for use in the app. See the preloaded file (\code{?safetyGraphics::meta}) for more data specifications and details. Defaults to \code{safetyGraphics::meta}. 
#' @param domainData named list of data.frames to be loaded in to the app.
#' @param mapping data.frame specifying the initial values for each data mapping. If no mapping is provided, the app will attempt to generate one via \code{detectStandard()}
#' @param standards a list of information regarding data standards. Each list item should use the format returned by safetyGraphics::detectStandard.
#' 
#' @export

app_ui <- function(meta, domainData, mapping, standards){
    #read css from pacakge
    app_css <-  HTML(readLines( paste(.libPaths(),'safetygraphics','safetyGraphics_app', 'www','index.css', sep="/")))
    
    #script to append population badge nav bar
    participant_badge<-tags$script(
        HTML(
            "var header = $('.navbar> .container-fluid');
            header.append('<div id=\"population-header\" class=\"badge\" title=\"Selected Participants\" ><span id=\"header-count\"></span>/<span id=\"header-total\"></span></div>');"
        )
    )

    #app UI using calls to modules
    ui<-tagList(
        useShinyjs(),
        tags$head(
            tags$style(app_css),
            tags$link(
                rel = "stylesheet",
                type = "text/css",
                href = "https://use.fontawesome.com/releases/v5.8.1/css/all.css"
            )
        ),
        navbarPage(
            "safetyGraphics",
            id="safetyGraphicsApp",
            tabPanel("Home", icon=icon("home"),homeTabUI("home")),
            navbarMenu('Data',icon=icon("database"),
                tabPanel("Preview", icon=icon("table"), settingsDataUI("dataSettings", domains=domainData)),
                tabPanel("Mapping", icon=icon("map"), mappingTabUI("mapping", meta, domainData, mapping, standards)),
                tabPanel("Filtering", icon=icon("filter"), filterTabUI("filter","dm"))
            ),
            navbarMenu('Charts', icon=icon("chart-bar")),
            tabPanel("Reports", icon=icon("file-alt")),
            navbarMenu('',icon=icon("cog"),
                tabPanel(title = "Metadata", settingsMappingUI("metaSettings")),
                tabPanel(title = "Charts", settingsChartsUI("chartSettings"))
            ),
            participant_badge
        )
    )
    return(ui)
}
