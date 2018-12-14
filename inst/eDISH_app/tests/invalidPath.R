#######################################################
#
# Tests that settings are not valid and chart is not 
# drawn when using data with no standard without 
# adjusting settings 
#
#######################################################


app <- ShinyDriver$new("../")
app$snapshotInit("invalidPath")

#Upload ADBDS file from viz-library that does not have a recognizable standard
app$uploadFile(datafile = "ADBDS.csv") 

#Select the newly uplaoded ADBDS file
app$setInputs(select_file = "ADBDS.csv")

#Navigate to charts tab
app$setInputs(inTabset = "charts")

# Give it time to attempt to draw the chart (should fail)
Sys.sleep(5) 

# Generate snapshot
app$snapshot(items = list(
  export = "valid_settings", 
  input = FALSE,
  output = FALSE),  # This will capture if the settings are valid 
  screenshot = TRUE)  # this will produce a visual output (.png) and ensure the chart renders with the download button
