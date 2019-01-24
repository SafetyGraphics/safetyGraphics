#######################################################
#
# Tests that settings are valid and chart is drawn 
# using default data without user input 
#
#######################################################

app <- ShinyDriver$new("../")
app$snapshotInit("defaultPath")

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

