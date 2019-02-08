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
  data_setting_keys<-c("id_col", "value_col", "measure_col", "normal_col_low", "normal_col_high", "studyday_col","measure_values--ALT","measure_values--ALP","measure_values--TB","measure_values--AST")
  none_settings <- generateSettings(standard="None")
  for(text_key in data_setting_keys){
    key<-textKeysToList(text_key)[[1]]
    expect_null(getSettingValue(settings=none_settings,key=key))
  }
  
  sdtm_settings <- generateSettings(standard="SDTM")
  for(text_key in data_setting_keys){
    key<-textKeysToList(text_key)[[1]]
    expect_is(getSettingValue(settings=sdtm_settings,key=key),"character")
  }
  
  
  sdtm_settings2 <- generateSettings(standard="SdTm")
  for(text_key in data_setting_keys){
    key<-textKeysToList(text_key)[[1]]
    expect_is(getSettingValue(settings=sdtm_settings2,key=key),"character")
  }
  
  
  adam_settings <- generateSettings(standard="ADaM")
  for(text_key in data_setting_keys){
    key<-textKeysToList(text_key)[[1]]
    expect_is(getSettingValue(settings=adam_settings,key=key),"character")
  }
  
  adam_settings2 <- generateSettings(standard="ADAM")
  for(text_key in data_setting_keys){
    key<-textKeysToList(text_key)[[1]]
    expect_is(getSettingValue(settings=adam_settings2,key=key),"character")
  }
  
  
  # Test Partial Spec Match
  partial_adam_settings <- generateSettings(standard="adam", partial=TRUE, partial_keys = c("id_col","measure_col","measure_values--ALT"))
  for(text_key in data_setting_keys){
    key<-textKeysToList(text_key)[[1]]
    if (text_key %in% c("id_col","measure_col","measure_values--ALT")) {
      expect_is(getSettingValue(settings=partial_adam_settings,key=key),"character")
    } else {
      expect_null(getSettingValue(settings=partial_adam_settings,key=key))
    }
  }
  
  #Testing that partial cols are only used when partial=TRUE
  full_adam_partial_cols <- generateSettings(standard="ADaM",  partial_keys = c("id_col","measure_col","measure_values--ALT"))
  for(text_key in data_setting_keys){
    key<-textKeysToList(text_key)[[1]]
    expect_is(getSettingValue(settings=full_adam_partial_cols,key=key),"character")
  }
  
  #Testing failure when partial is true with no specified columns
  expect_error(partial_settings_no_cols <- generateSettings(standard="ADaM", partial=TRUE))
})
