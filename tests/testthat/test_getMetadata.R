context("Tests for the getMetadata() function")
library(safetyGraphics)

default<- getMetadata()

test_that("a list with the expected properties and structure is returned",{
  expect_is(default,"list")
  expect_named(default,c("settings","charts","standards"))
  expect_is(default[["standards"]],"data.frame")
  expect_is(default[["settings"]],"data.frame")
  expect_is(default[["charts"]],"data.frame")
  expect_equal(default,safetyGraphics::metadata)
})

test_that("domain filter works as expected",{  
    all <- getMetadata(domain=c("labs","aes"))
    expect_equal(all,default)
    expect_equal(unique(all$settings$domain),c("aes","labs"))
    
    all_CAPS <- getMetadata(domain=c("LABS","aEs"))
    expect_equal(all_CAPS,all)

    labs <-  getMetadata(domain=c("labs"))
   
    expect_equal(unique(labs$settings$domain),c("labs"))
    expect_equal(unique(labs$charts$domain),c("labs"))
    expect_equal(unique(labs$standards$domain),c("labs"))

    # vector not needed
    labs2 <-  getMetadata(domain="labs")
    expect_equal(labs,labs2)
  })


test_that("path option works as expected",{
  custom_path<-file.path(getwd(),"settings.RDS")
  custom <- list(charts=a$settings[1:5,], standards=a$standards[1:10,],settings=a$settings[1:30,]) 
  saveRDS(custom, custom_path)
  
  custom_meta <- getMetadata(path=custom_path)
  expect_equal(dim(custom_meta$charts)[1],5)
  expect_equal(dim(custom_meta$standards)[1],10)
  expect_equal(dim(custom_meta$settings)[1],30)
  file.remove(custom_path)
})

test_that("invalid path throws error",{
    broken_path<-file.path(getwd(),"not_my_settings.RDS")
    expect_error(getMetadata(path=broken_path))
})
