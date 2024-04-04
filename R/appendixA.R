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
