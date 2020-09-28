#' UI for the default safetyGraphics shiny app
#'
#' @param meta data frame containing the metadata for use in the app. See the preloaded file (\code{?safetyGraphics::meta}) for more data specifications and details. Defaults to \code{safetyGraphics::meta}. 
#' @param domainData named list of data.frames to be loaded in to the app.
#' @param mapping data.frame specifying the initial values for each data mapping. If no mapping is provided, the app will attempt to generate one via \code{detectStandard()}
#' @param standards a list of information regarding data standards. Each list item should use the format returned by safetyGraphics::detectStandard.
#' 
#' @export

app_ui <- function(meta, domainData, mapping, standards){
    ui<-tagList(
      useShinyjs(),
      #add_busy_spinner(spin = "fading-circle", position = "bottom-left", timeout=3000),
       tags$head(
        tags$style(HTML(readLines( paste(.libPaths(),'safetygraphics','safetyGraphics_app', 'www','index.css', sep="/")))),
        tags$link(
          rel = "stylesheet",
          type = "text/css",
          href = "https://use.fontawesome.com/releases/v5.8.1/css/all.css"
        )
      ),
      navbarPage(
        "safetyGraphics",
        id="nav_id",
        tabPanel("Home", icon=icon("home"),homeTabUI("home")),
        tabPanel("Mapping", icon=icon("map"), mappingTabUI("mapping", meta, domainData, mapping, standards)),
        tabPanel("Filtering", icon=icon("filter"), filterTabUI("filter","dm")),
        navbarMenu('Charts', icon=icon("chart-bar")),
        tabPanel("Reports", icon=icon("file-alt")),
        navbarMenu('Config',icon=icon("cog"),
          tabPanel(title = "Metadata", settingsMappingUI("metaSettings")),
          tabPanel(title = "Domain Data", settingsDataUI("dataSettings", domains=domainData)),
          tabPanel(title = "Charts", settingsChartsUI("chartSettings"))
        )
      )
    )
    return(ui)
}
