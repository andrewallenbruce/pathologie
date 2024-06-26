% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/icd_10_cm.R
\name{icd10cm}
\alias{icd10cm}
\title{ICD-10-CM Codes}
\usage{
icd10cm(icd = NULL, ...)
}
\arguments{
\item{icd}{\verb{<chr>} vector of ICD-10-CM codes}

\item{...}{Empty dots}
}
\value{
a \link[tibble:tibble-package]{tibble}
}
\description{
ICD-10-CM (International Classification of Diseases, 10th Revision,
Clinical Modification) is a medical coding system for classifying
diagnoses and reasons for visits in U.S. health care settings.
}
\examples{
icd10cm( c("F50.8", "G40.311", "Q96.8", "Z62.890", "R45.4", "E06.3",
"H00.019", "D50.1", "C4A.70") )

}
