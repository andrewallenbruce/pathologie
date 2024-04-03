#' Medicare Severity Diagnosis-Related Groups
#'
#' The Medicare Severity Diagnosis-Related Group (MS-DRG) is a classification
#' system used by the Centers for Medicare and Medicaid Services (CMS) to group
#' patients with similar clinical characteristics and resource utilization into
#' a single payment category.
#'
#' The system is primarily used for Medicare reimbursement purposes, but it is
#' also adopted by many other payers as a basis for payment determination.
#'
#' MS-DRGs are based on the principal diagnosis, up to 24 additional diagnoses,
#' and up to 25 procedures performed during the stay. In a small number of
#' MS-DRGs, classification is also based on the age, sex, and discharge status
#' of the patient.
#'
#' Hospitals serving more severely ill patients receive increased
#' reimbursements, while hospitals treating less severely ill patients will
#' receive less reimbursement.
#'
#' @param drg `<chr>` vector of 3-digit DRG codes
#' @param mdc `<chr>` vector of 2-digit Major Diagnostic Category codes
#' @param type `<chr>` DRG type: `Medical` or `Surgical`
#' @param ... Empty
#' @return A [tibble][tibble::tibble-package]
#' @examples
#' search_msdrg(drg = "011")
#'
#' search_msdrg(mdc = "24")
#' @autoglobal
#' @export
search_msdrg <- function(drg  = NULL,
                         mdc  = NULL,
                         type = NULL,
                         ...) {

  ms <- pins::pin_read(mount_board(), "msdrg")

  if (!is.null(type)) {ms <- vctrs::vec_slice(ms, ms$drg_type == type)}

  if (!is.null(drg)) {ms <- search_in(ms, ms$drg, drg)}

  if (!is.null(mdc)) {ms <- search_in(ms, ms$mdc, mdc)}

  return(ms)
}

#' Search ICD-10-CM Code Edits
#'
#' Definitions of Medicare Code Edits, version 41.1
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
