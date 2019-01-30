context("Tests for the generateSettings() function")
library(safetyGraphics)
setting_names<-c("id_col","value_col","measure_col","normal_col_low","normal_col_high","studyday_col", "visit_col", "visitn_col", "filters","group_cols", "measure_values", "baseline", "analysisFlag", "x_options", "y_options", "visit_window", "r_ratio_filter", "r_ratio_cut", "showTitle", "warningText")

test_that("a list with the expected properties and structure is returned for all standards",{
  
  expect_is(generateSettings(standard="None"),"list")
  expect_named(generateSettings(standard="None"),setting_names)
  expect_named(generateSettings(standard="None")[["measure_values"]], c("ALT","AST","TB","ALP"))
  
  expect_is(generateSettings(standard="ADaM"),"list")
  expect_named(generateSettings(standard="ADaM"),setting_names)
  expect_named(generateSettings(standard="ADaM")[["measure_values"]], c("ALT","AST","TB","ALP"))
               
  expect_is(generateSettings(standard="SDTM"),"list")
  expect_named(generateSettings(standard="SDTM"),setting_names)
  expect_named(generateSettings(standard="SDTM")[["measure_values"]], c("ALT","AST","TB","ALP"))
})

test_that("a warning is thrown if chart isn't eDish",{
  expect_error(generateSettings(chart="aeexplorer"))
  expect_error(generateSettings(chart=""))
  expect_silent(generateSettings(chart="eDish"))
  expect_silent(generateSettings(chart="edish"))
  expect_silent(generateSettings(chart="EdIsH"))
})

test_that("data mappings are null when setting=none, character otherwise",{
  column_setting_names<-c("id_col", "value_col", "measure_col", "normal_col_low", "normal_col_high", "studyday_col", "visit_col", "visitn_col")
  none_settings <- generateSettings(standard="None")
  for(name in column_setting_names){
    expect_null(none_settings[[name]])
  }
  
  sdtm_settings <- generateSettings(standard="SDTM")
  for(name in column_setting_names){
    expect_is(sdtm_settings[[name]],"character")
  }
  
  sdtm_settings2 <- generateSettings(standard="SdTm")
  for(name in column_setting_names){
    expect_is(sdtm_settings2[[name]],"character")
  }
  
  adam_settings <- generateSettings(standard="ADaM")
  for(name in column_setting_names){
    expect_is(adam_settings[[name]],"character")
  }
  
  adam_settings2 <- generateSettings(standard="ADAM")
  for(name in column_setting_names){
    expect_is(adam_settings2[[name]],"character")
  }
  
  # Test Partial Spec Match
  partial_adam_settings <- generateSettings(standard="SDTM", partial=TRUE, partial_cols = c("USUBJID","TEST"))
  for(name in column_setting_names){
    
    if (name %in% c("id_col","measure_col")) {
      expect_is(partial_adam_settings[[name]],"character")
    } else {
      expect_null(partial_adam_settings[[name]])
    }
  }
  
  #Testing that partial cols are only used when partial=TRUE
  full_adam_partial_cols <- generateSettings(standard="ADaM", partial_cols = c("USUBJID","TEST"))
  for(name in column_setting_names){
    expect_is(full_adam_partial_cols[[name]],"character")
  }
  
  #Testing failure when partial is true with no specified columns
  expect_error(partial_settings_no_cols <- generateSettings(standard="ADaM", partial=TRUE))
  
  
})
