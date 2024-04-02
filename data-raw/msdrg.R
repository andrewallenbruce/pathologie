library(rvest)

# https://www.cms.gov/medicare/payment/prospective-payment-systems/acute-inpatient-pps/ms-drg-classifications-and-software

# FY 2024 – Version 41.1 (Effective April 1, 2024 through September 30, 2024)

# The ICD-10 Definitions of Medicare Code Edits file contains the following: A
# description of each coding edit with the corresponding code lists as well as
# all the edits and the code lists effective for FY 2024. Zip file contains a
# PDF and text file that is 508 compliant.

drg_v41_code_edits <- "https://www.cms.gov/files/zip/definition-medicare-code-edits-v411.zip"


# A zip file with the ICD-10 MS DRG Definitions Manual (Text Version) contains
# the complete documentation of the ICD-10 MS-DRG Grouper logic. - Updated
# 03/12/2024

drg_v41_manual <- "https://www.cms.gov/files/zip/icd-10-ms-drg-definitions-manual-files-v411.zip"



# Version 36
ms_drg_v36 <- read_html("https://www.hipaaspace.com/medical.coding.library/drgs/") |>
  html_element(xpath = '//*[contains(concat( " ", @class, " " ), concat( " ", "table-striped", " " ))]') |>
  html_table(na.strings = c("N/A", "N/S"), convert = FALSE)

ms_drg_v36 <- ms_drg_v36 |>
  janitor::clean_names() |>
  dplyr::select(-number) |>
  dplyr::mutate(
    mdc = dplyr::na_if(mdc, "N/A"),
    mdc_description = dplyr::na_if(mdc_description, "N/S")) |>
  tidyr::separate_wider_delim(drg_type, " ", names = c("drg_type", "drg_abbrev")) |>
  dplyr::mutate(
    drg_abbrev = stringr::str_remove(drg_abbrev, "\\("),
    drg_abbrev = stringr::str_remove(drg_abbrev, "\\)"),
    drg_abbrev = dplyr::na_if(drg_abbrev, "")
  )

ms_drg_v36
ms_drg_v36 <- northstar::search_msdrg()
# Update Pin
board <- pins::board_folder(here::here("inst/extdata/pins"))

board |>
  pins::pin_write(ms_drg_v36,
                  name = "msdrg",
                  title = "MS-DRG Version 36.0",
                  description = "Medicare Severity Diagnosis-Related Groups (MS-DRGs) Version 36.0",
                  type = "qs")

board |> pins::write_board_manifest()
