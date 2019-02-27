#  global.R code for safetyGraphics app
#  - load all required libraries
#  - source module functions
library(safetyGraphics)
library(shiny)
library(shinyjs)
library(dplyr)
library(purrr)
library(stringr)
library(DT)
library(haven)

## source modules
source('modules/renderSettings/renderSettingsUI.R')
source('modules/renderSettings/renderSettings.R')

source('modules/renderChart/renderEDishChartUI.R')
source('modules/renderChart/renderEDishChart.R')

source('modules/dataUpload/dataUploadUI.R')
source('modules/dataUpload/dataUpload.R')

