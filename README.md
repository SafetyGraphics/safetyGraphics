# safetyGraphics: Clinical Trial Safety Graphics with R
[![Travis-CI Build Status](https://travis-ci.org/ASA-DIA-InteractiveSafetyGraphics/safetyGraphics.svg?branch=master)](https://travis-ci.org/ASA-DIA-InteractiveSafetyGraphics/safetyGraphics)
The **safetyGraphics** package provides a framework for evaluation of clinical trial safety in R. The initial release focuses on Evaluation of Drug-Induced Serious Hepatotoxicity (eDISH). A prototype of the eDish interactive graphic available [here](https://asa-dia-interactivesafetygraphics.github.io/safety-eDISH/test/) and is shown below.

![edishgif](https://user-images.githubusercontent.com/3680095/45834450-02b3a000-bcbc-11e8-8172-324c2fe43521.gif)

This package is built being in conjunction with the [safety-eDISH](https://github.com/ASA-DIA-InteractiveSafetyGraphics/safety-eDISH) javascript library. Both packages are under active development with beta testing and an initial release planned for early 2019.

## Usage

Initializing the graphic will only require a few lines of code for data sets using [ADaM](https://www.cdisc.org/standards/foundational/adam) or [SDTM](https://www.cdisc.org/standards/foundational/sdtm) data standards:

```r
devtools::install_github("ASA-DIA-InteractiveSafetyGraphics/safetyGraphics", ref="v0.1.0")
library("ReDish")
eDISH(data=adlbc)
```

Fully customizable settings and an easy-to-use Shiny app facilitating custom configuration and data mapping will be included in the first full release.
