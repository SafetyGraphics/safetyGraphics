# Data Build Process 

This page summarizes the process used to create the data used in the safetyGraphics app. 

Per the standard structure for R packages, raw data is saved in `/data-raw` and processed, ready-to-use data is saved in `/data`. The `makeAllData.R` generates all contents of the `/data` folder using the contents or `/data-raw`. The script should be run whenever the raw data is updated.  

In general, there are 2 types of data provided in the package, sample clinical datasets and metadata. Sample data sets are saved in `/data-raw/sample` and metadata is saved in `/data-raw/meta` and it's sub-folders. 

Prior to version 1.2, the package was focused on only 1 type od clinical data (lab data), but the version 1.2 release of safetyGraphics supports mutiple data domains. Each data domain included in the app should have a sample data set (saved in `/data-raw/sample`) and it's own set of metadata (saved in `/data-raw/meta/`).  

So, adding a new demographics, or 'dm', domain to the app, would require adding the following 6 files:

- `/data-raw/sample/dm.csv` - sample clinical demographics data set
- `/data-raw/meta/dm/chartsMetadata.csv` - 
- `/data-raw/meta/dm/settingsMetadata.csv` 
- `/data-raw/meta/dm/settingsMetadataCharts.csv` 
- `/data-raw/meta/dm/generateSettingsMetadataDefaults.R`
- `/data-raw/meta/dm/standardsMetadata.csv`

We recommend starting by creating a copy of `/data-raw/meta/template/` folder, which provides shells for the metadata files. 

Notes: 
- More details about the exact content of the metadata files can be found in the vignettes associated with the package. 
- For more specific details about any specific `/data` files, associated roxygen2 documentation.``