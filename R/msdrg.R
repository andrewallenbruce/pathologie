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
#'
#' @param mdc `<chr>` vector of 2-digit Major Diagnostic Category codes
#'
#' @param type `<chr>` DRG type: `Medical` or `Surgical`
#'
#' @template args-dots
#'
#' @template returns
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
