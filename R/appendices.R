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
#' @examples
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

  if (!is.null(type)) {
    msd <- vctrs::vec_slice(msd, msd$drg_type == type)
  }

  msd <- fuimus::search_in_if(msd, msd$drg, drg)
  msd <- fuimus::search_in_if(msd, msd$mdc, mdc)

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
#' @examples
#' head(appendix_B())
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
#' Part 1 lists these codes. Each code is indicated as CC or MCC. A link is
#' given to a collection of diagnosis codes which, when used as the principal
#' diagnosis, will cause the CC or MCC to be considered as only a non-CC.
#'
#' Part 2 lists codes which are assigned as a Major CC only for patients
#' discharged alive. Otherwise they are assigned as a non-CC.
#'
#' Part 3 lists diagnosis codes that are designated as a complication or
#' comorbidity (CC) or major complication or comorbidity (MCC) and included in
#' the definition of the logic for the listed DRGs. When reported as a secondary
#' diagnosis and grouped to one of the listed DRGs the diagnosis is excluded
#' from acting as a CC/MCC for severity in DRG assignment.
#'
#' @template args-icd_code
#'
#' @param pdx `<chr>` 4-digit Principal Diagnosis (PDX) Group number, e.g.,
#'   `0011` (~ 2,040 in total)
#'
#' @param unnest `<lgl>` Unnest the `pdx_icd` column
#'
#' @template args-dots
#'
#' @template returns
#'
#' @examples
#' appendix_C(icd = "A17.81")
#'
#' appendix_C(pdx = "0032")
#'
#' @autoglobal
#'
#' @export
appendix_C <- function(icd = NULL,
                       pdx = NULL,
                       unnest = FALSE,
                       ...) {

  mcc <- pins::pin_read(mount_board(), "msdrg_ccmcc_41.1")

  mcc <- fuimus::search_in_if(mcc, mcc$pdx_group, pdx)

  mcc <- fuimus::search_in_if(mcc, mcc$icd_code, icd)

  return(mcc)
}


#' Appendix D MS-DRG Surgical Hierarchy by MDC and MS-DRG

#' Since patients can have multiple procedures related to their principal
#' diagnosis during a particular hospital stay, and a patient can be assigned to
#' only one surgical class, the surgical classes in each MDC are defined in a
#' hierarchical order.
#'
#' Patients with multiple procedures are assigned to the highest surgical class
#' in the hierarchy to which one of the procedures is assigned. Thus, if a
#' patient receives both a D&C and a hysterectomy, the patient is assigned to the
#' hysterectomy surgical class because a hysterectomy is higher in the hierarchy
#' than a D&C. Because of the surgical hierarchy, ordering of the surgical
#' procedures on the patient abstract or claim has no influence on the assignment
#' of the surgical class and the MS-DRG. The surgical hierarchy for each MDC
#' reflects the relative resource requirements of various surgical procedures.
#'
#' In some cases a surgical class in the hierarchy is actually an MS-DRG. For
#' example, Arthroscopy is both a surgical class in the hierarchy and MS-DRG 509
#' in MDC 8, Diseases and Disorders of the Musculoskeletal System and Connective
#' Tissue.
#'
#' In other cases the surgical class in the hierarchy is further partitioned
#' based on other variables such as complications and comorbidities, or principal
#' diagnosis to form multiple MS-DRGs. As an example, in MDC 5, Diseases and
#' Disorders of the Circulatory System, the surgical class for permanent
#' pacemaker implantation is divided into three MS-DRGs (242-244) based on
#' whether or not the patient had no CCs, a CC or an MCC.
#'
#' Appendix D presents the surgical hierarchy for each MDC. Appendix D is
#' organized by MDC with a list of the surgical classes associated with that MDC
#' listed in hierarchical order as well as the MS-DRGs that are included in each
#' surgical class.
#'
#' The names given to the surgical classes in the hierarchy correspond to the
#' names used in the MS-DRG logic tables and in the body of the Definitions
#' Manual.
#'
#' @template returns
#'
#' @examples
#' head(appendix_D())
#'
#' @autoglobal
#'
#' @export
appendix_D <- function() {
  pins::pin_read(mount_board(), "msdrg_drg_groups_41.1")
}
