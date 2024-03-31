#' ICD-10-CM Codes
#'
#' ICD-10-CM (International Classification of Diseases, 10th Revision,
#' Clinical Modification) is a medical coding system for classifying
#' diagnoses and reasons for visits in U.S. health care settings.
#'
#' @param code `<chr>` vector of ICD-10-CM codes
#' @param ... Empty
#' @return a [tibble][tibble::tibble-package]
#' @examples
#' icd10cm(c("F50.8", "G40.311", "Q96.8", "Z62.890", "R45.4",
#'           "E06.3", "H00.019", "D50.1", "C4A.70", "Z20.818"))
#' @autoglobal
#' @export
icd10cm <- function(code = NULL,
                    ...) {

  icd <- pins::pin_read(mount_board(), "icd10cm")

  if (!is.null(code)) {

    icd <- tidyr::unnest(icd, chapter_sections) |>
      tidyr::unnest(section_codes)

    icd <- vctrs::vec_slice(icd,
           vctrs::vec_in(icd$code,
           collapse::funique(code)))
  }
  return(icd)
}
