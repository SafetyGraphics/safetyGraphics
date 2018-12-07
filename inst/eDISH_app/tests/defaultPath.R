#######################################################
#
# Tests that settings are valid and chart is drawn 
# using default data without user input 
#
#######################################################

app <- ShinyDriver$new("../")
app$snapshotInit("defaultPath")

#Navigate to charts tab
app$setInputs(inTabset = "charts")  

# Give it time to draw the chart
Sys.sleep(5) 

# Generate snapshot
app$snapshot(items = list(
             export = "valid_settings", 
             input = FALSE,
             output = FALSE),  # This will capture if the settings are valid 
             screenshot = TRUE)  # this will produce a visual output (.png) and ensure the chart renders with the download button

