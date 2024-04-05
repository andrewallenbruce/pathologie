#' Appendix A: List of MS-DRGs Version 41.1
#'
#' Appendix A contains a list of each MS-DRG with a specification of the MDC and
#' whether the MS-DRG is medical or surgical. Some MS-DRGs which contain patients
#' from multiple MDCs (e.g., 014 Allogeneic Bone Marrow Transplant) do not have
#' an MDC specified. The letter M is used to designate a medical MS-DRG and the
#' letter P is used to designate a surgical MS-DRG.
#'
#' @param drg `<chr>` vector of 3-digit DRG codes
#'
#' @param mdc `<chr>` vector of 2-digit Major Diagnostic Category codes
#'
#' @param type `<chr>` DRG type: `M` (Medical) or `P` (Surgical)
#'
#' @param ... Empty
#'
#' @return A [tibble][tibble::tibble-package]
#'
#' @examplesIf interactive()
#' appendix_A(drg = "011")
#'
#' appendix_A(mdc = "24")
#'
#' @autoglobal
#'
#' @export
appendix_A <- function(drg  = NULL,
                       mdc  = NULL,
                       type = NULL,
                       ...) {

  ms <- pins::pin_read(mount_board(), "msdrg_41.1")

  if (!is.null(type)) {ms <- vctrs::vec_slice(ms, ms$ms == type)}

  if (!is.null(drg)) {ms <- search_in(ms, ms$drg, drg)}

  if (!is.null(mdc)) {ms <- search_in(ms, ms$mdc, mdc)}

  return(ms)
}

#' Appendix B: Diagnosis Code/MDC/MS-DRG Index
#'
#' The Diagnosis Code/MDC/MS-DRG Index lists each diagnosis code, as well as
#' the MDC, and the MS-DRGs to which the diagnosis is used to define the logic
#' of the DRG either as a principal or secondary diagnosis.
#'
#' @return A [tibble][tibble::tibble-package]
#'
#' @examplesIf interactive()
#' appendix_B()
#'
#' @autoglobal
#'
#' @export
appendix_B <- function() {
  pins::pin_read(mount_board(), "msdrg_index_41.1")
}

#' Appendix C: Complications or Comorbidities Exclusion list
#'
#' Appendix C is a list of all of the codes that are defined as either a
#' complication or comorbidity (CC) or a major complication or comorbidity (MCC)
#' when used as a secondary diagnosis.
#'
#' Part 1 lists these codes. Each code is indicated as CC or MCC. A link is given
#' to a collection of diagnosis codes which, when used as the principal
#' diagnosis, will cause the CC or MCC to be considered as only a non-CC.
#'
#' Part 2 lists codes which are assigned as a Major CC only for patients
#' discharged alive. Otherwise they are assigned as a non-CC.
#'
#' Part 3 lists diagnosis codes that are designated as a complication or
#' comorbidity (CC) or major complication or comorbidity (MCC) and included in
#' the definition of the logic for the listed DRGs. When reported as a secondary
#' diagnosis and grouped to one of the listed DRGs the diagnosis is excluded from
#' acting as a CC/MCC for severity in DRG assignment.
#'
#' @return A [tibble][tibble::tibble-package]
#'
#' @examplesIf interactive()
#' appendix_C()
#'
#' @autoglobal
#'
#' @export
appendix_C <- function() {
  pins::pin_read(mount_board(), "msdrg_ccmcc_41.1")
}
