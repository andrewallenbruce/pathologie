#' Search ICD-10-CM Code Edits
#'
#' Definitions of Medicare Code Edits, version 41.1
#'
#' FY 2024 – Version 41.1 (Effective April 1, 2024 through September 30, 2024)
#'
#' The ICD-10 Definitions of Medicare Code Edits file contains the following: A
#' description of each coding edit with the corresponding code lists as well as
#' all the edits and the code lists effective for FY 2024. Zip file contains a
#' PDF and text file that is 508 compliant.
#'
#' A zip file with the ICD-10 MS DRG Definitions Manual (Text Version) contains
#' the complete documentation of the ICD-10 MS-DRG Grouper logic. - Updated
#' 03/12/2024
#'
#' @param code `<chr>` vector of ICD-10-CM codes
#'
#' @param ... Empty dots
#'
#' @return A [tibble][tibble::tibble-package]
#'
#' @examples
#' search_edits(c("Q96.8", "N47.0", "R45.4", "A33"))
#'
#' @autoglobal
#'
#' @export
search_edits <- function(code = NULL,
                         ...) {

  edt <- pins::pin_read(mount_board(), "code_edits")

  if (!is.null(code)) {edt <- search_in(edt, edt$code, code)}

  return(edt)
}
