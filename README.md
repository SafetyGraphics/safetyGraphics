 <!-- badges: start -->
  [![R build status](https://www.github.com/safetyGraphics/safetyGraphics/workflows/R-CMD-check-main/badge.svg)](https://github.com/SafetyGraphics/safetyGraphics/actions)
  <!-- badges: end -->
  
# safetyGraphics: Clinical Trial Monitoring with R  <img src="https://raw.githubusercontent.com/SafetyGraphics/safetyGraphics/master/inst/safetyGraphicsHex/safetyGraphicsHex.png" width = "175" height = "200" align="right" />

The {safetyGraphics} package provides a framework for evaluating of clinical trial safety in R using a flexible data pipeline. The package includes a shiny application that allows users to explore safety data using a series of interactive graphics, including the hepatic safety explorer shown below.  The package has been developed as part of the <a target="_blank" href="https://safetygraphics.github.io/">Interactive Safety Graphics (ISG) workstream</a> of the ASA Biopharm-DIA Safety Working Group. 

![edishgif](https://user-images.githubusercontent.com/3680095/45834450-02b3a000-bcbc-11e8-8172-324c2fe43521.gif)

## Using the app

A demo of the app using sample data is available [here](https://jwildfire.shinyapps.io/safetyGraphics/) or can be initialized as follows:

```r
install.packages("safetyGraphics")
library("safetyGraphics")
safetyGraphicsApp() #open the shiny application
```

The most common workflow is for a user to initialize the app with their data, adjust settings as needed, and view the interactive charts. Finally, the user can share any chart by exporting its source code or by generating a self-contained, fully reproducible report that can be shared with others. 

Instructions for loading study data are provided in the <a target="_blank" href="https://github.com/SafetyGraphics/safetyGraphics/wiki/Intro">introductory vignette</a> and more complex customizations are provided in the <a target="_blank" href="https://github.com/SafetyGraphics/safetyGraphics/wiki/Cookbook">cookbook vignette</a>. 

# Charts 
The app is built to support a wide variety of chart types including static plots (e.g. from <a target="_blank" href="https://cran.r-project.org/package=ggplot2">{ggplot2}</a>), shiny modules, <a target="_blank" href="https://cran.r-project.org/package=htmlwidgets">{htmlwidgets}</a> and even static outputs like RTFs. Several pre-configured charts are included in the companion <a target="_blank" href="https://github.com/safetyGraphics/safetyCharts">{safetyCharts}</a> R Package, and are available by default in the app. Other charts can be added using the process descibed in <a target="_blank" href="https://github.com/SafetyGraphics/safetyGraphics/wiki/ChartConfiguration">this vignette</a>. 

