# ReDish: Evaluation of Drug-Induced Serious Hepatotoxicity with R

The **ReDish** package* provides a framework for the Evaluation of Drug-Induced Serious Hepatotoxicity (eDISH) in R. A prototype of the interactive graphic available [here](https://asa-dia-interactivesafetygraphics.github.io/safety-eDISH/test/) and is shown below.

![edishgif](https://user-images.githubusercontent.com/3680095/45834450-02b3a000-bcbc-11e8-8172-324c2fe43521.gif)

This package is built being in conjunction with the [safety-eDISH](https://github.com/ASA-DIA-InteractiveSafetyGraphics/safety-eDISH) javascript library. Both packages are under active development with beta testing planned for fall 2018 and an initial release to follow in early 2019.

(* - Name subject to change)

## Usage

Initializing the graphic will only require a few lines of code for data sets using [ADaM](https://www.cdisc.org/standards/foundational/adam) or [SDTM](https://www.cdisc.org/standards/foundational/sdtm) data standards: 

```r
devtools::install_github("ASA-DIA-InteractiveSafetyGraphics/ReDish", ref="v0.1.0")
library("ReDish")
eDish(data=adlbc)
```

Fully customizable settings and an easy-to-use Shiny app facilitating custom configuration and data mapping will be included in the first full release. 
