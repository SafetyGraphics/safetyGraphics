context("Tests for the mappingDomain R module")
library(safetyGraphics)
library(shinytest)
library(testthat)
library(stringr)

app <- ShinyDriver$new("./module_examples/mappingDomain")
initial<-app$getAllValues()

test_that("UI function stops with invalid inputs (non-data.frame)",{
  id_meta <- meta%>%filter(domain=="labs")%>%filter(col_key=="id_col")
  id_mapping_list<-list(id_col="USUBJID")
  expect_error(mappingDomainUI("test1.1", list(id_col="USUBJID"), labs)) #invalid metadata
  expect_error(mappingDomainUI("test1.2", id_meta, "invalid_data_option")) #invalid data
  expect_error(mappingDomainUI("test1.3", id_meta, labs, list(id_col="USUBJID"))) #invalid mapping
})

test_that("the correct number of inputs are created (1 per field/column)",{
  inputs <- names(initial$input)
  expect_length(str_subset(inputs,"ex1"),5)
  expect_length(str_subset(inputs,"ex2"),5)
  expect_length(str_subset(inputs,"ex3"),nrow(meta %>% filter(domain=="aes")))
  expect_length(str_subset(inputs,"ex4"),nrow(meta %>% filter(domain=="aes")))
  expect_length(str_subset(inputs,"ex5"),nrow(meta %>% filter(domain=="labs")))
  expect_length(str_subset(inputs,"ex6"),nrow(meta %>% filter(domain=="labs")))
})

test_that("output are data frames with the have expected values",{
  #all exported values are data frames ...
  expect_true(all(sapply(initial$export,is.data.frame))) 
  
  # ... with correct column names
  expect_true(all(sapply(initial$export,function(x){names(x)==c("text_key","current")}))) 
  
  #all exported values have the correct number of rows
  expect_equal(nrow(initial$export$ex1_data),5)
  expect_equal(nrow(initial$export$ex2_data),5)
  expect_equal(nrow(initial$export$ex3_data),nrow(meta %>% filter(domain=="aes")))
  expect_equal(nrow(initial$export$ex4_data),nrow(meta %>% filter(domain=="aes")))
  expect_equal(nrow(initial$export$ex5_data),nrow(meta %>% filter(domain=="labs")))
  expect_equal(nrow(initial$export$ex6_data),nrow(meta %>% filter(domain=="labs")))

})

app$stop()

