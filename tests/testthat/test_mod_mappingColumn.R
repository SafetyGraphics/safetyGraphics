context("Tests for the mappingColumn R module")
library(safetyGraphics)
library(shinytest)
library(testthat)
library(stringr)

app <- ShinyDriver$new("./module_examples/mappingColumn")
initial<-app$getAllValues()

test_that("UI function stops with invalid inputs (non-data.frame)",{
  id_meta <- meta%>%filter(domain=="labs")%>%filter(col_key=="id_col")
  id_mapping_list<-list(id_col="USUBJID")
  expect_error(mappingColumnUI("test1.1", list(id_col="USUBJID"), labs)) #invalid metadata
  expect_error(mappingColumnUI("test1.2", id_meta, "invalid_data_option")) #invalid data
  expect_error(mappingColumnUI("test1.3", id_meta, labs, list(id_col="USUBJID"))) #invalid mapping
})

test_that("the correct number of inputs are created (1 per field/column)",{
  inputs <- names(initial$input)
  expect_length(str_subset(inputs,"ex1"),1)
  expect_length(str_subset(inputs,"ex2"),1)
  expect_length(str_subset(inputs,"ex3"),5)
  expect_length(str_subset(inputs,"ex4"),5)
})

test_that("default values for inputs are set correctly in example app",{
  expect_equal(initial$input[["ex1-id_col-colSelect"]],"")
  expect_equal(initial$input[["ex2-id_col-colSelect"]],"USUBJID")
  expect_equal(initial$input[["ex3-measure_col-colSelect"]],"")
  expect_equal(initial$input[["ex3-measure_values--ALP-colSelect"]],"")
  expect_equal(initial$input[["ex3-measure_values--ALT-colSelect"]],"")
  expect_equal(initial$input[["ex3-measure_values--AST-colSelect"]],"")
  expect_equal(initial$input[["ex3-measure_values--TB-colSelect"]],"")
  expect_equal(initial$input[["ex4-measure_col-colSelect"]],"PARAM")
  expect_equal(initial$input[["ex4-measure_values--ALP-colSelect"]],"Alkaline Phosphatase (U/L)")
  expect_equal(initial$input[["ex4-measure_values--ALT-colSelect"]],"")
  expect_equal(initial$input[["ex4-measure_values--AST-colSelect"]],"")
  expect_equal(initial$input[["ex4-measure_values--TB-colSelect"]],"")
})

test_that("changing column input updates clears the field input values and updates input list",{
  app$setValue('ex4-measure_col-colSelect',"PARAMCD")
  expect_equal(app$getValue("ex4-measure_col-colSelect"),"PARAMCD") 
  Sys.sleep(.1) #TODO inplement app$waitForValue() instead of sleeping
  expect_equal(app$getValue("ex4-measure_values--ALP-colSelect"),"") #clears the selected input
  app$setValue('ex4-measure_values--ALP-colSelect',"ALP")
  Sys.sleep(.1) #TODO inplement app$waitForValue() instead of sleeping
  expect_equal(app$getValue("ex4-measure_values--ALP-colSelect"),"ALP") #expected new input is found
  #TODO: Probably be better get the new options directly using app$findElement, css is a bit of a mess though
})


test_that("output are data frames with the  expected values",{
  #all exported values are data frames ...
  expect_true(all(sapply(initial$export,is.data.frame))) 
  
  # ... with correct column names
  expect_true(all(sapply(initial$export,function(x){names(x)==c("text_key","current")}))) 
  
  #all exported values have the correct number of rows
  expect_equal(nrow(initial$export$ex1_data),1)
  expect_equal(nrow(initial$export$ex2_data),1)
  expect_equal(nrow(initial$export$ex3_data),5)
  expect_equal(nrow(initial$export$ex4_data),5)
  
  #initial values are set as expected
  ex2_id_col <- initial$export$ex2_data %>% filter(text_key=="id_col") %>% pull(current) %>% as.character()
  expect_equal(ex2_id_col, "USUBJID")

  ex4_measure_col <- initial$export$ex4_data %>% 
    filter(text_key=="measure_col") %>% 
    pull(current) %>% 
    as.character()
  expect_equal(ex4_measure_col, "PARAM")
  
  ex4_measure_col_ALP <- initial$export$ex4_data %>% 
    filter(text_key=="measure_values--ALP") %>% 
    pull(current) %>% 
    as.character()
  expect_equal(ex4_measure_col_ALP, "Alkaline Phosphatase (U/L)")
  
  #values from previous tests are set as expected
  updated<-app$getAllValues()
  
  ex2_id_col_updated <- updated$export$ex2_data %>% filter(text_key=="id_col") %>% pull(current) %>% as.character()
  expect_equal(ex2_id_col_updated, "USUBJID")
  
  ex4_measure_col_updated <- updated$export$ex4_data %>% 
    filter(text_key=="measure_col") %>% 
    pull(current) %>% 
    as.character()
  expect_equal(ex4_measure_col_updated, "PARAMCD")
  
  ex4_measure_values_ALP_updated <- updated$export$ex4_data %>% 
    filter(text_key=="measure_values--ALP") %>% 
    pull(current) %>% 
    as.character()
  expect_equal(ex4_measure_values_ALP_updated, "ALP")
})

app$stop()

