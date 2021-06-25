context("Tests for the makeMapping() function")
library(safetyGraphics)
library(safetyData)
library(stringr)

testData<- list(
    labs=safetyData::adam_adlbc, 
    aes=safetyData::adam_adae, 
    dm=safetyData::adam_adsl
)

test_that("object with the correct properties is returned",{})
test_that("when autoMapping is false, customMapping is returned",{
  customMap <- list(ae=list(test_col="TEST1",another_col="TEST2"),labs=list(id_col="ID"))
  m<-makeMapping(testData, safetyGraphics::meta, FALSE, customMap)
})
test_that("customMapping overwrites autoMapping values",{})

