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
#' @template returns
#'
#' @examples
#' search_msdrg(drg = "011")
#'
#' search_msdrg(mdc = "24")
#'
#' @autoglobal
#'
#' @export
search_msdrg <- function(drg  = NULL, mdc  = NULL, type = NULL) {

  x <- get_pin("msdrg")
  x <- search_in(x, x[["drg"]], drg)
  x <- search_in(x, x[["mdc"]], mdc)
  x <- search_in(x, x[["drg_type"]], type)

  return(x)
}

#' MS-DRG List
#'
#' __Appendix A__: Contains each MS-DRG with a specification of
#' the MDC and whether the MS-DRG is Medical or Surgical.
#'
#' Some MS-DRGs which contain patients from multiple MDCs
#' e.g., `"014"` (Allogeneic Bone Marrow Transplant) do not
#' have an MDC specified.
#'
#' The letter M is used to designate a medical MS-DRG and the
#' letter P is used to designate a surgical MS-DRG.
#'
#' @template args-drg
#'
#' @template args-mdc
#'
#' @param type `<chr>` `"M"` (Medical) or `"P"` (Surgical)
#'
#' @template returns
#'
#' @examples
#' msdrg_list(drg = "014")
#'
#' msdrg_list(mdc = "24")
#'
#' msdrg_list(type = "M")
#'
#' @autoglobal
#'
#' @export
msdrg_list <- function(drg = NULL, mdc  = NULL, type = NULL) {

  x <- get_pin("msdrg_41.1")
  x <- search_in(x, x[["drg_abb"]], type)
  x <- search_in(x, x[["drg"]], drg)
  x <- search_in(x, x[["mdc"]], mdc)

  return(x)
}

#' ICD-10-CM|MDC|MS-DRG Index
#'
#' __Appendix B__: ICD-10-CM|MDC|MS-DRG Index
#'
#' The Diagnosis Code/MDC/MS-DRG Index lists each ICD-10-CM code,
#' the MDC and the MS-DRGs to which the diagnosis is used to define
#' the logic of the MS-DRG either as a principal or secondary diagnosis.
#'
#' @param icd `<chr>` ICD-10-CM code
#'
#' @template args-drg
#'
#' @template args-mdc
#'
#' @template returns
#'
#' @examples
#' msdrg_index(icd = "A17.81")
#'
#' msdrg_index(drg = "011")
#'
#' msdrg_index(mdc = "24")
#'
#' @autoglobal
#'
#' @export
msdrg_index <- function(icd = NULL, drg = NULL, mdc  = NULL) {

  x <- get_pin("msdrg_index_41.1")
  x <- search_in(x, x[["icd_code"]], icd)
  x <- search_in(x, x[["drg"]], drg)
  x <- search_in(x, x[["mdc"]], mdc)

  return(x)
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
#' @param unnest `<lgl>` Unnest the `pdx_icd` column; default is `FALSE`
#'
#' @template returns
#'
#' @examples
#' msdrg_pdx(icd = "A17.81")
#'
#' msdrg_pdx(pdx = "0032")
#'
#' @autoglobal
#'
#' @export
msdrg_pdx <- function(icd = NULL, pdx = NULL, unnest = FALSE) {

  x <- get_pin("msdrg_ccmcc_41.1")
  x <- search_in(x, x[["pdx_group"]], pdx)
  x <- search_in(x, x[["icd_code"]], icd)

  if (unnest) x <- tidyr::unnest(x, pdx_icd)

  return(x)
}


#' Appendix D MS-DRG Surgical Hierarchy by MDC and MS-DRG
#'
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
appendix_D <- \() get_pin("msdrg_drg_groups_41.1")

#' Appendix G Diagnoses Defined as Complications or Comorbidities
#'
#' Diagnoses in Appendix G are considered complications or comorbidities (CC)
#' except when used in conjunction with the principal diagnosis in the
#' corresponding CC Exclusion List in Appendix C.
#'
#' @template returns
#'
#' @examples
#' head(appendix_G())
#'
#' @autoglobal
#'
#' @export
appendix_G <- \() get_pin("msdrg_icd_ccs_41.1")

#' Appendix H Diagnoses Defined as Major Complications or Comorbidities
#'
#' Diagnoses in Appendix H Part I are considered major complications or
#' comorbidities (MCC) except when used in conjunction with the principal
#' diagnosis in the corresponding CC Exclusion List in Appendix C. In addition to
#' the CC exclusion list, the diagnoses in Part II are assigned as a major CC
#' only for patients discharged alive, otherwise they will be assigned as a non
#' CC.
#'
#' @template returns
#'
#' @examples
#' head(appendix_H())
#'
#' @autoglobal
#'
#' @export
appendix_H <- \() get_pin("msdrg_icd_mccs_41.1")
