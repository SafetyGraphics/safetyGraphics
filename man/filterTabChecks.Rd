% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mod_filterTabChecks.R
\name{filterTabChecks}
\alias{filterTabChecks}
\title{Checks for whether the current data and settings support a filter tab}
\usage{
filterTabChecks(domainData, filterDomain, current_mapping)
}
\arguments{
\item{domainData}{list of data files for each domain}

\item{filterDomain}{domain to use for filtering (typically "dm")}

\item{current_mapping}{current data mapping (REACTIVE)}
}
\value{
reactive that returns a boolean indicating whether the checks passed and filtering can be initialized
}
\description{
Checks for whether the current data and settings support a filter tab
}
