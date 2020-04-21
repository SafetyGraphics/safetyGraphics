# Data Build Process 

This page summarizes the process used to create the data used in the safetyGraphics app. 

Per the standard structure for R packages, raw data is saved in `/data-raw` and processed, ready-to-use data is saved in `/data`. The `makeAllData.R` generates all contents of the `/data` folder using the contents or `/data-raw`. The script should be run whenever the raw data is updated.  

In general, there are 2 types of data provided in the package, sample clinical datasets and metadata. Sample data sets are saved in `/data-raw/sample` and metadata is saved as `/date-raw/meta.csv`. 

Prior to version 1.2, the package was focused on only 1 type of clinical data (lab data), but the version 2.0 release of safetyGraphics supports mutiple data domains. Each data domain included in the app should have a sample data set (saved in `/data-raw/sample`) and rows defining domains-specif metadata in `/data-raw/meta.csv`.  