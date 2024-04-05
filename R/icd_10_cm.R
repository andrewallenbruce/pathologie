#' ICD-10-CM Codes
#'
#' ICD-10-CM (International Classification of Diseases, 10th Revision,
#' Clinical Modification) is a medical coding system for classifying
#' diagnoses and reasons for visits in U.S. health care settings.
#'
#' @template args-icd_code
#'
#' @template args-dots
#'
#' @template returns
#'
#' @examples
#' icd10cm(
#'    c("F50.8", "G40.311", "Q96.8", "Z62.890", "R45.4", "E06.3", "H00.019", "D50.1", "C4A.70")
#'    )
#'
#' @autoglobal
#'
#' @export
icd10cm <- function(icd = NULL,
                    ...) {

  icd10 <- pins::pin_read(mount_board(), "icd10cm")

  if (!is.null(icd)) {

    icd10 <- tidyr::unnest(
      icd10,
      icd_ch_sec
      ) |>
      tidyr::unnest(icd_sec_code)

    icd10 <- search_in(icd10, icd10$icd_code, icd)

    edit <- search_edits(icd = icd)

    if (!vctrs::vec_is_empty(edit)) {

      icd10 <- dplyr::left_join(
        icd10,
        edit,
        by = dplyr::join_by(
          icd_code,
          icd_description
          )
        )
    }
  }
  return(icd10)
}
