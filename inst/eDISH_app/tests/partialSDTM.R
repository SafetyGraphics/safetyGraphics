#######################################################
#
# Tests upload of partial SDTM data. Chart and settings 
# should fail initially but succeed after user updates 
# settings. 
#
#######################################################


app <- ShinyDriver$new("../")
app$snapshotInit("partialSDTM")

#Upload parital_SDTM ADBDS file from viz-library
app$uploadFile(`datatab-datafile` = "partialSDTM.csv") 

# Give it time to load file
Sys.sleep(5) 

#Select the newly uploaded ADBDS file
app$setInputs(`datatab-select_file` = "partialSDTM.csv")

# Snapshot of Data 
app$snapshot(items = list(
  input = c("datatab-datafile","datatab-select_file"),
  output = "datatab-data_preview", # this has more than I'd like but not sure how to subset it to just x 
  export = FALSE),  
  screenshot = FALSE)  #could take this screenshot but would want to wait since checks can be delayed

# Navigate to Chart Tab 
app$findElement('#chart_tab_title')$click()

# Give it time to draw the chart 
Sys.sleep(5) 

# Snapshot of Chart
app$snapshot(items = list(
  input = FALSE,
  output = c("data_tab_title","settings_tab_title","chart_tab_title"), # Capture Status of Tabs
  export = FALSE),  
  screenshot = TRUE)  

# Navigate to Settings Tab
app$findElement('#settings_tab_title')$click()

# Snapshot of Settings
app$snapshot(items = list(
  export = c("datatab-status","settingsUI-status_df"), # Capture Status settings and Checks
  input = FALSE,
  output = FALSE),  
  screenshot = TRUE)

app$setInputs(`settingsUI-id_col` = "ID") # Set id col 

# Navigate to Chart Tab
app$findElement('#chart_tab_title')$click()

# Give it time to draw the chart 
Sys.sleep(5) 

# Snapshot of Chart
app$snapshot(items = list(
  input = FALSE,
  output = c("data_tab_title","settings_tab_title","chart_tab_title"), # Capture Status of Tabs
  export = FALSE),  
  screenshot = TRUE)  

# Navigate to Settings Tab
app$findElement('#settings_tab_title')$click()

# Snapshot of Settings
app$snapshot(items = list(
  export = c("datatab-status","settingsUI-status_df"), # Capture Status settings and Checks
  input = FALSE,
  output = FALSE),  
  screenshot = TRUE)







