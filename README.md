
[![Travis-CI Build Status](https://travis-ci.org/SafetyGraphics/safetyGraphics.svg?branch=master)](https://travis-ci.org/SafetyGraphics/safetyGraphics) [![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/safetyGraphics)](https://cran.r-project.org/package=safetyGraphics)

# safetyGraphics: Clinical Trial Safety Graphics with R  <img src="inst/safetyGraphicsHex/safetyGraphicsHex.png" width = "175" height = "200" align="right" />

The **safetyGraphics** package provides a framework for evaluation of clinical trial safety in R. It includes several safety-focused visualizations to empower clinical data monitoring. Chief among these is the Hepatic Explorer, based on the [Evaluation of the Drug-Induced Serious Hepatotoxicity (eDish)](https://www.ncbi.nlm.nih.gov/pubmed/21332248) visualization. A demo of the Hepatic Explorer interactive graphic is available [here](https://safetygraphics.github.io/hep-explorer/test-page/example1/) and is shown below.

This package is being built in conjunction with the [hep-explorer](https://github.com/SafetyGraphics/hep-explorer) javascript library.

![edishgif](https://user-images.githubusercontent.com/3680095/45834450-02b3a000-bcbc-11e8-8172-324c2fe43521.gif)

## Usage

Users can interactively explore their data with a shiny application or create standalone interactive charts.

### Shiny application

The Shiny app provides a simple interface for:
- Loading data
- Customizing settings and data mappings
- Viewing and exporting the interactive graphics

```r
devtools::install_github("SafetyGraphics/safetyGraphics")
library("safetyGraphics")
safetyGraphicsApp() #open the shiny application
```

### Standalone charts

Users can also initialize customized standalone charts with a few lines of code.

```r
devtools::install_github("safetyGraphics/safetyGraphics")
library("safetyGraphics")

settings <- list(
  id_col = "USUBJID",
  value_col = "AVAL",
  measure_col = "PARAM",
  visit_col = "VISIT",
  visitn_col = "VISITNUM",
  studyday_col = "ADY",
  normal_col_low = "A1LO",
  normal_col_high = "A1HI",
  measure_values = list(ALT = "Alanine Aminotransferase (U/L)",
                        AST = "Aspartate Aminotransferase (U/L)",
                        TB = "Bilirubin (umol/L)",
                        ALP = "Alkaline Phosphatase (U/L)")
  )

chartRenderer(data=adlbc, settings=settings, chart="hepexplorer")

```
