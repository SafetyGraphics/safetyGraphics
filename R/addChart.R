#' Adds a new chart for use in the safetyGraphics shiny app
#'
#' This function updates settings objects to add a new chart to the safetyGraphics shiny app
#'
#' This function makes it easy for users to adds a new chart to the safetyGraphics shiny app, by making updates to the underlying metadata used by the package. Specifically, the function adds a row to chartsMetadata.rda describing the chart and adds a column to settingsMetadata.rda specifying which settings are used with the chart. If new settings are needed for the chart, the user should call addSetting() for each new setting required.
#'
#' @param settings_location path where the custom settings will be loaded/saved. If metadata is not found in that location, it will be read from the package (e.g. safetyGraphics::settingsMetadata), and then written to the specified location once the new chart has been added.
#' @param chart Name of the chart - one word, all lower case
#' @param label Nicely formatted name of the chart
#' @param description Description of the chart
#' @param repo_url Homepage for chart's code repository (if any)
#' @param settings_url Homepage for chart's settings documentation
#' @param main Name of the main function used to initialize the app. If the type is htmlwidgets, the js function must accept "location" and "settings" parameters (in that order) and have an .init() method, expecting a json data array. Otherwise, the r function should accept named data and settings parameters, andshould be loaded in the user's namespace.
#' @param type type of chart (e.g. 'htmlwidget')
#' @param maxWidth max width for the widget in pixels
#' @param requiredSettings array of text_key values (matching those used in settingsMetadata) for the required settings for this chart
#' @param settingsLocation folder location of user-defined settings metadata
#' @param overwrite overwrite any existing chart metadata? Note that having multiple charts with the same name is not supported and will cause unexpected results. default = true
#'
#' @export
#'
addChart <- function(
  chart,
  label="",
  description="",
  repo_url="",
  settings_url="",
  main="character",
  type='htmlwidget',
  maxWidth=1000,
  requiredSettings=c(""),
  settingsLocation=getwd(),
  overwrite = FALSE
){

  # check inputs
  stopifnot(
    typeof(chart)=="character",
    typeof(label)=="character",
    typeof(description)=="character",
    typeof(repo_url)=="character",
    typeof(settings_url)=="character",
    typeof(main)=="character",
    typeof(type)=="character",
    type %in% c("htmlwidget","plotly","static"),
    is.numeric(maxWidth)
  )

  # create settings for new chart
  newChart <- list(
    chart=chart,
    main=main,
    label=label,
    description=description,
    repo_url=repo_url,
    settings_url=settings_url,
    type=type,
    maxWidth=maxWidth
  )

  # load charts metadata
  chartsMetaPath <- paste(settingsLocation,"chartsMetadata.Rds",sep="/")
  if(file.exists(chartsMetaPath)){
    chartsMeta <- readRDS(chartsMetaPath)
  }else{
    chartsMeta <- safetyGraphics::chartsMetadata
  }

  #delete rows for the specified chart if overwrite is true
  if(overwrite){
    chartsMeta <- chartsMeta %>% filter(.data$chart != !!chart)
  }

  # add custom chart settings and save
  chartsMeta[nrow(chartsMeta)+1,] <- newChart
  saveRDS(chartsMeta, chartsMetaPath)

  # add a column for the new chart to the settings metadata
  settingsMetaPath <- paste(settingsLocation,"settingsMetadata.Rds",sep="/")
  if(file.exists(settingsMetaPath)){
    settingsMeta <- readRDS(settingsMetaPath)
  }else{
    settingsMeta <- safetyGraphics::settingsMetadata
  }

  #Fill in the column based on requiredSettings and save
  chart_col <- sym(paste0("chart_",chart))
  settingsMeta <- settingsMeta %>% mutate(!!chart_col := text_key %in% !!requiredSettings)
  saveRDS(settingsMeta, settingsMetaPath)
}
