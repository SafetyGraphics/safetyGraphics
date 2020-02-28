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

# remove settings and charts metadata in the workspace to avoid carryover from previous instances of the app.
if(exists("settingsMetadata", inherits = FALSE)){
  rm("settingsMetadata")
}

if(exists("chartsMetadata", inherits = FALSE)){
  rm("chartsMetadata")
}

# use metadata in user settings folder if provided
if (!is.null(options('sg_chartsMetadata')[[1]]) && options('sg_chartsMetadata')[[1]]){
  chartsMetadata <-  options('sg_chartsMetadata_df')[[1]]
}
if (!is.null(options('sg_settingsMetadata')[[1]]) && options('sg_settingsMetadata')[[1]]){
  settingsMetadata <-  options('sg_settingsMetadata_df')[[1]]
}
if (!is.null(options('sg_standardsMetadata')[[1]]) && options('sg_standardsMetadata')[[1]]){
  standardsMetadata <-  options('sg_standardsMetadata_df')[[1]]
}

# temporary! until we move this part to the modules
settingsMetadata <- subset(settingsMetadata, domain=="labs")
chartsMetadata <- subset(chartsMetadata, domain=="labs")
standardsMetadata <- subset(standardsMetadata, domain=="labs")


# subset chartsMetadata if user requests it
if (!is.null(getShinyOption("safetygraphics_charts"))){
  all_charts <- getShinyOption("safetygraphics_charts")
  cat(length(all_charts), "of", nrow(chartsMetadata), "available charts included being loaded. Run `safetyGraphicsApp(charts=NULL)` to use all charts.")
} else{
  all_charts <- chartsMetadata$chart
}


# Prepare initial datasets/labels (with info about standards) to be loaded into the app 
# pre-load data into app if requested
if(!is.null(getShinyOption("sg_loadData")) && getShinyOption("sg_loadData")){
  preload_data_list <- list()

  # names of data in environment
  dat_names <- ls(pos=1)[sapply(ls(pos=1), function(x) inherits(get(x), "data.frame"))]
  dat_names <- dat_names[!dat_names %in% c("chartsMetadata","standardsMetdata","settingsMetadata")]

  preload_data_list$data <- lapply(dat_names, function(x) {get(x)})
  names(preload_data_list$data) <- dat_names

  # set all to not currently selected
  preload_data_list$current <- c(1, rep(0, length(dat_names)-1))

  # detect standard for all datasets
  preload_data_list$standard <- lapply(preload_data_list$data, function(x){ detectStandard(x) })

  # get display name for all datasets
  preload_data_list$display <- list()

  for (i in 1:length(dat_names)){

    temp_standard <- preload_data_list$standard[[i]]$standard
    standard_label <- ifelse(temp_standard=="adam","AdAM",ifelse(temp_standard=="sdtm","SDTM",temp_standard))
    if(temp_standard == "none") {
      preload_data_list$display[[i]] <- HTML(paste0("<p>", names(preload_data_list$data)[i], " - <em style='font-size:12px;'>No Standard Detected</em></p>"))
    } else if (preload_data_list$standard[[i]]$details[[temp_standard]]$match == "full") {
      preload_data_list$display[[i]] <- HTML(paste0("<p>", names(preload_data_list$data)[i], " - <em style='color:green; font-size:12px;'>", standard_label, "</em></p>"))
      # If partial data spec match - give the fraction of variables matched
    } else {

      valid_count <- preload_data_list$standard[[i]]$details[[temp_standard]]$valid_count
      total_count <- preload_data_list$standard[[i]]$details[[temp_standard]]$invalid_count + valid_count

      fraction_cols  <- paste0(valid_count, "/" ,total_count)

      preload_data_list$display[[i]] <- HTML(paste0("<p>", names(preload_data_list$data)[i], " - <em style='color:green; font-size:12px;'>", "Partial ",
                                  standard_label, " (", fraction_cols, " data settings)",  "</em></p>"))
    }
  }
} else {  # otherwise use example data
  preload_data_list <- list(data = list("Example data" = labs),
                            current = 1,
                            standard = list(list("standard" = "adam", "details" = list("adam"=list("match"="full")))),
                            display = list(HTML("<p>Example data - <em style='color:green; font-size:12px;'>ADaM</em></p>")))
}

## source modules
source('modules/renderSettings/renderSettingsUI.R')
source('modules/renderSettings/renderSettings.R')

source('modules/renderChart/renderChartUI.R')
source('modules/renderChart/renderChart.R')

source('modules/renderReports/renderReportsUI.R')
source('modules/renderReports/renderReports.R') 

source('modules/dataUpload/dataUploadUI.R')
source('modules/dataUpload/dataUpload.R')


source('modules/main/mainUI.R')
source('modules/main/main.R')
