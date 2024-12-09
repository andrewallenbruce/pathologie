#' ICD-10-CM Codes
#'
#' ICD-10-CM (International Classification of Diseases, 10th Revision,
#' Clinical Modification) is a medical coding system for classifying
#' diagnoses and reasons for visits in U.S. health care settings.
#'
#' @template args-icd_code
#'
#' @template returns
#'
#' @examples
#' icd10cm(c("F50.8", "G40.311", "Q96.8",
#'           "Z62.890", "R45.4", "E06.3",
#'           "H00.019", "D50.1", "C4A.70"))
#'
#' @autoglobal
#'
#' @export
icd10cm <- function(icd = NULL) {

  x <- get_pin("icd10cm")

  if (null(icd))
    return(x)

  x <- tidyr::unnest(x, icd_ch_sec) |>
    tidyr::unnest(icd_sec_code)

  x <- search_in(x, x[["icd_code"]], icd)

  edit <- search_edits(icd = icd)

  if (empty(edit))
    return(x)

  dplyr::left_join(
    x,
    edit,
    by = dplyr::join_by(
      icd_code,
      icd_description
      )
    )
}
