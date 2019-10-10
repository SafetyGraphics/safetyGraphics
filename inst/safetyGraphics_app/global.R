#  global.R code for safetyGraphics app
#  - load all required libraries
#  - source module functions
library(safetyGraphics)
library(shiny)
library(shinyWidgets)
library(shinyjs)
library(dplyr)
library(purrr)
library(stringr)
library(DT)
library(haven)
library(tidyr)
library(shinybusy)

# use metadata in user settings folder if provided
if(!is.null(getShinyOption("settings_location"))){
  chartsMetadata <-  options('sg_chartsMetadata_df')[[1]]
  settingsMetadata <-  options('sg_settingsMetadata_df')[[1]]
  standardsMetadata <-  options('sg_standardsMetadata_df')[[1]]
}

# subset chartsMetadata if user requests it
if (!is.null(getShinyOption("safetygraphics_charts"))){
  all_charts <- getShinyOption("safetygraphics_charts")
  cat(length(all_charts), "of", nrow(chartsMetadata), "available charts included being loaded. Run `safetyGraphicsApp(charts=NULL)` to use all charts.")
} else{
  all_charts <- chartsMetadata$chart
}

## source modules
source('modules/renderSettings/renderSettingsUI.R')
source('modules/renderSettings/renderSettings.R')

source('modules/renderChart/renderChartUI.R')
source('modules/renderChart/renderChart.R')

source('modules/renderReports/renderReportsUI.R')
source('modules/renderReports/renderReports.R')

# source('modules/renderChart/render_edish_chartUI.R')
# source('modules/renderChart/render_edish_chart.R')
# source('modules/renderChart/render_safetyhistogram_chartUI.R')
# source('modules/renderChart/render_safetyhistogram_chart.R')

source('modules/dataUpload/dataUploadUI.R')
source('modules/dataUpload/dataUpload.R')
