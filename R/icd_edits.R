#' ICD-10-CM Code Edits
#'
#' Definitions of Medicare Code Edits, version 41.1
#'
#' FY 2024 – Version 41.1 (Effective April 1, 2024 through September 30, 2024)
#'
#' The **ICD-10 Definitions of Medicare Code Edits** file contains the following: A
#' description of each coding edit with the corresponding code lists as well as
#' all the edits and the code lists effective for FY 2024.
#'
#' @template args-icd_code
#'
#' @template returns
#'
#' @examples
#' search_edits(c("Q96.8", "N47.0", "R45.4", "A33"))
#'
#' @autoglobal
#'
#' @export
search_edits <- function(icd = NULL) {

  x <- get_pin("code_edits")
  x <- search_in(x, x[["icd_code"]], icd)
  return(x)
}

#' Apply Age Conflict Edits
#'
#' @param rule `<chr>` ICD-10-CM Conflict Rule
#'
#' @param age `<int>` age in years
#'
#' @template returns
#'
#' @examples
#' apply_age_edits(
#'    c("Pediatric (Ages 0-17)",
#'      "Maternity (Ages 9-64)"),
#'    c(18, 7))
#'
#' @autoglobal
#'
#' @export
apply_age_edits <- function(rule, age) {

  msg <- "Age Conflict"

  dplyr::case_when(
    rule == "Perinatal/Newborn (Age 0 Only)" & age != 0 ~ msg,
    rule == "Pediatric (Ages 0-17)" & dplyr::between(age, 0, 17) == FALSE ~ msg,
    rule == "Maternity (Ages 9-64)" & dplyr::between(age, 9, 64) == FALSE ~ msg,
    rule == "Adult (Ages 15-124)" & dplyr::between(age, 15, 124) == FALSE ~ msg,
    .default = NA_character_
  )
}
