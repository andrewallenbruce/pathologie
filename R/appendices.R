#' Appendix A: List of MS-DRGs Version 41.1
#'
#' Appendix A contains a list of each MS-DRG with a specification of the MDC and
#' whether the MS-DRG is medical or surgical. Some MS-DRGs which contain patients
#' from multiple MDCs (e.g., 014 Allogeneic Bone Marrow Transplant) do not have
#' an MDC specified. The letter M is used to designate a medical MS-DRG and the
#' letter P is used to designate a surgical MS-DRG.
#'
#' @template args-drg
#'
#' @template args-mdc
#'
#' @param type `<chr>` DRG type: `M` (Medical) or `P` (Surgical)
#'
#' @template args-dots
#'
#' @template returns
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

  msd <- pins::pin_read(mount_board(), "msdrg_41.1")

  if (!is.null(type)) {msd <- vctrs::vec_slice(msd, msd$drg_type == type)}

  if (!is.null(drg)) {msd <- search_in(msd, msd$drg, drg)}

  if (!is.null(mdc)) {msd <- search_in(msd, msd$mdc, mdc)}

  return(msd)
}

#' Appendix B: Diagnosis Code/MDC/MS-DRG Index
#'
#' The Diagnosis Code/MDC/MS-DRG Index lists each diagnosis code, as well as
#' the MDC, and the MS-DRGs to which the diagnosis is used to define the logic
#' of the DRG either as a principal or secondary diagnosis.
#'
#' @template returns
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
#' @template returns
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
