# Appendix D MS-DRG Surgical Hierarchy by MDC and MS-DRG
#
# Since patients can have multiple procedures related to their principal
# diagnosis during a particular hospital stay, and a patient can be assigned to
# only one surgical class, the surgical classes in each MDC are defined in a
# hierarchical order.
#
# Patients with multiple procedures are assigned to the highest surgical class
# in the hierarchy to which one of the procedures is assigned. Thus, if a
# patient receives both a D&C and a hysterectomy, the patient is assigned to the
# hysterectomy surgical class because a hysterectomy is higher in the hierarchy
# than a D&C. Because of the surgical hierarchy, ordering of the surgical
# procedures on the patient abstract or claim has no influence on the assignment
# of the surgical class and the MS-DRG. The surgical hierarchy for each MDC
# reflects the relative resource requirements of various surgical procedures.
#
# In some cases a surgical class in the hierarchy is actually an MS-DRG. For
# example, Arthroscopy is both a surgical class in the hierarchy and MS-DRG 509
# in MDC 8, Diseases and Disorders of the Musculoskeletal System and Connective
# Tissue.
#
# In other cases the surgical class in the hierarchy is further partitioned
# based on other variables such as complications and comorbidities, or principal
# diagnosis to form multiple MS-DRGs. As an example, in MDC 5, Diseases and
# Disorders of the Circulatory System, the surgical class for permanent
# pacemaker implantation is divided into three MS-DRGs (242-244) based on
# whether or not the patient had no CCs, a CC or an MCC.
#
# Appendix D presents the surgical hierarchy for each MDC. Appendix D is
# organized by MDC with a list of the surgical classes associated with that MDC
# listed in hierarchical order as well as the MS-DRGs that are included in each
# surgical class.
#
# The names given to the surgical classes in the hierarchy correspond to the
# names used in the MS-DRG logic tables and in the body of the Definitions
# Manual.

path_d <- "C:/Users/Andrew/Desktop/payer_guidelines/data/MSDRG/MSDRGv41.1ICD10_R0_DefinitionsManual_TEXT_0/appendix_D.txt"

readr::read_fwf(
  path_d,
  readr::fwf_cols(
    icd_code = c(1, 7),
    cc_mcc = c(9, 12),
    pdx_group = c(14, sum(14 + 5)),
    icd_description = c(31, 500)
  )
) |>
  tidyr::separate_wider_delim(
    cols = pdx_group,
    delim = ":",
    names = c("pdx_group", "delete"),
    too_few = "align_start"
  ) |>
  dplyr::mutate(icd_code = pathologie::add_dot(icd_code)) |>
  dplyr::select(-c(delete, icd_description))
