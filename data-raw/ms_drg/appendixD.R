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

library(tidyverse)

path_d <- "C:/Users/Andrew/Desktop/payer_guidelines/data/MSDRG/MSDRGv41.1ICD10_R0_DefinitionsManual_TEXT_0/appendix_D.txt"

dfile <- readr::read_table(
  path_d,
  skip = 27,
  col_names = FALSE) |>
  dplyr::mutate(row = dplyr::row_number(), .before = 1) |>
  dplyr::slice(2:dplyr::n()) |>
  tidyr::unite("drg_group_description", X2:X12, na.rm = TRUE, sep = " ") |>
  dplyr::rename(drg_groups = X1)


drows <- dfile |>
  dplyr::filter(drg_groups == "MDC") |>
  dplyr::mutate(end = lead(row) - 1,
                drg_groups = NULL) |>
  dplyr::mutate(mdc_group = substr(drg_group_description, 1, 2),
                mdc_group_description = substr(drg_group_description, 4, 100),
                drg_group_description = NULL)



dfinal <- dfile |>
  dplyr::left_join(drows) |>
  dplyr::mutate(end = NULL) |>
  tidyr::fill(mdc_group, mdc_group_description) |>
  tidyr::separate_longer_delim(cols = drg_groups, delim = "-") |>
  dplyr::select(
    mdc = mdc_group,
    mdc_description = mdc_group_description,
    drg_group = drg_groups,
    drg_group_description = drg_group_description
    ) |>
  dplyr::filter(drg_group != "MDC")


# Update Pin
board <- pins::board_folder(here::here("inst/extdata/pins"))

board |> pins::pin_write(
  dfinal,
  name = "msdrg_drg_groups_41.1",
  title = "Appendix D MS-DRG Surgical Hierarchy by MDC and MS-DRG 41.1",
  description = c(
    "Appendix D presents the surgical hierarchy for each MDC. Appendix D is organized by MDC with a list of the surgical classes associated with that MDC listed in hierarchical order as well as the MS-DRGs that are included in each surgical class."
  ),
  type = "qs"
)

board |> pins::write_board_manifest()


mdcs <- dplyr::tribble(
  ~mdc, ~mdc_description,
  "00", "Pre-MDC",
  "01", "Diseases and disorders of the nervous system",
  "02", "Diseases and disorders of the eye",
  "03", "Diseases and disorders of the ear, nose, mouth, and throat",
  "04", "Diseases and disorders of the respiratory system",
  "05", "Diseases and disorders of the circulatory system",
  "06", "Diseases and disorders of the digestive system",
  "07", "Diseases and disorders of the hepatobiliary system and pancreas",
  "08", "Diseases and disorders of the musculoskeletal system and connective tissue",
  "09", "Diseases and disorders of the skin, subcutaneous tissue, and breast",
  "10", "Endocrine, nutritional and metabolic diseases and disorders",
  "11", "Diseases and disorders of the kidney and urinary tract",
  "12", "Diseases and disorders of the male reproductive system",
  "13", "Diseases and disorders of the female reproductive system",
  "14", "Pregnancy, childbirth and the puerperium",
  "15", "Newborns and other neonates with conditions originating in the perinatal period",
  "16", "Diseases and disorders of blood, blood forming organs and immunological disorders",
  "17", "Myeloproliferative diseases and disorders, poor blood cell formation",
  "18", "Infectious and parasitic diseases",
  "19", "Mental diseases and disorders",
  "20", "Alcohol/drug use and alcohol/drug induced organic mental disorders",
  "21", "Injuries, poisonings and toxic effects of drugs",
  "22", "Burns",
  "23", "Factors influencing health status and other contacts with health services",
  "24", "Multiple significant trauma",
  "25", "Human immunodeficiency virus infections",
)

readr::read_fwf(
  path_d,
  readr::fwf_cols(
    icd_code = c(1, 7),
    cc_mcc = c(9, 12),
    pdx_group = c(14, sum(14 + 5)),
    icd_description = c(31, 500),
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
