# safetyGraphics v2.1.0

This release focuses on updates the safetyGraphics metadata framework:

- The default metadata table has been migrated to safetyCharts and modularized. In short,`safetyGraphics::meta` is now saved as `safetyCharts::meta_aes`, `safetyCharts::meta_labs` and `safetyCharts::meta_dm`.
- A new `makeMeta` function has been created and integrated in to the default workflow for the Shiny app. `makeMeta` provides a much more flexible framework for creating and storing metadata. See `?makeMeta` and the Cookbook and Chart Configuration vignettes for more details.

# safetyGraphics v2.0.0

Version 2 of {safetyGraphics} is a major update that adds the following features: 

- Added support for multiple data domains 
- Streamlined support for multiple chart types 
- Improved chart export and newly added full-app export
- Single filtering module for all charts
- New "Config" tab summarizing app configuration
- Created new `safetyGraphicsInit()` app with a simple UI that can initialize the app with custom data/charts

For more details, see the fully updated vingettes.

# safetyGraphics v1.1.0

Allows users to preload their own charts and data sets for use in the safetyGraphics Shiny Application. See the "Custom Workflows" Vignette for details and examples. 

# safetyGraphics v1.0.0

The first production release of safetyGraphics includes many improvements including the addition of 5 new interactive graphics and an embedded help page with a detailed clinical workflow for using the tool. 

# safetyGraphics v0.7.3

Initial CRAN release for safetyGraphics. The safetyGraphics package provides framework for evaluation of clinical trial safety. Users can interactively explore their data using the 'Shiny' application or create standalone 'htmlwidget' charts. Interactive charts are built using 'd3.js' and 'webcharts.js' 'JavaScript' libraries.

See the [GitHub release tracker](https://github.com/safetyGraphics/safetyGraphics/releases) for additional release documentation and links to issues. 