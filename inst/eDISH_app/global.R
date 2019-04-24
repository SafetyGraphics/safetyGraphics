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

# create vector of all possible charts
all_charts <- c("edish","safetyhistogram")

## source modules
source('modules/renderSettings/renderSettingsUI.R')
source('modules/renderSettings/renderSettings.R')

source('modules/renderChart/render_edish_chartUI.R')
source('modules/renderChart/render_edish_chart.R')
source('modules/renderChart/render_safetyhistogram_chartUI.R')
source('modules/renderChart/render_safetyhistogram_chart.R')

source('modules/dataUpload/dataUploadUI.R')
source('modules/dataUpload/dataUpload.R')

