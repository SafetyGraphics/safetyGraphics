
[![Travis-CI Build Status](https://travis-ci.org/ASA-DIA-InteractiveSafetyGraphics/safetyGraphics.svg?branch=master)](https://travis-ci.org/ASA-DIA-InteractiveSafetyGraphics/safetyGraphics)

# safetyGraphics: Clinical Trial Safety Graphics with R  <img src="inst/safetyGraphicsHex/safetyGraphicsHex.png" width = "175" height = "200" align="right" /> 

The **safetyGraphics** package provides a framework for evaluation of clinical trial safety in R. The initial release focuses on Evaluation of Drug-Induced Serious Hepatotoxicity (eDISH). A prototype of the eDish interactive graphic available [here](https://asa-dia-interactivesafetygraphics.github.io/safety-eDISH/test/) and is shown below.

This package is built being in conjunction with the [safety-eDISH](https://github.com/ASA-DIA-InteractiveSafetyGraphics/safety-eDISH) javascript library. Both packages are under active development with beta testing and an initial release planned for early 2019.

![edishgif](https://user-images.githubusercontent.com/3680095/45834450-02b3a000-bcbc-11e8-8172-324c2fe43521.gif)

## Usage

Users can interactively explore thier data with a shiny application or create standalone interactive charts. 

### Shiny application

The Shiny app provides a simple interface for:
- Loading data
- Customizing settings and data mappings
- Viewing and exporting the interactive graphics

```r
devtools::install_github("ASA-DIA-InteractiveSafetyGraphics/safetyGraphics")
library("safetyGraphics")
chartBuilderApp() #open the shiny application
```

### Standalone charts

Users can also initialize standalone charts with a few lines of code. This works best for data sets using [ADaM](https://www.cdisc.org/standards/foundational/adam) or [SDTM](https://www.cdisc.org/standards/foundational/sdtm) data standards:

```r
devtools::install_github("ASA-DIA-InteractiveSafetyGraphics/safetyGraphics")
library("safetyGraphics")
eDISH(data=adlbc) #create htmlwidget using sample data
```
