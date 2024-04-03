library(rvest)
library(fs)
library(curl)
library(zip)
library(tidyverse)

# https://www.cms.gov/medicare/payment/prospective-payment-systems/acute-inpatient-pps/ms-drg-classifications-and-software

# FY 2024 – Version 41.1 (Effective April 1, 2024 through September 30, 2024)

# The ICD-10 Definitions of Medicare Code Edits file contains the following: A
# description of each coding edit with the corresponding code lists as well as
# all the edits and the code lists effective for FY 2024. Zip file contains a
# PDF and text file that is 508 compliant.

# A zip file with the ICD-10 MS DRG Definitions Manual (Text Version) contains
# the complete documentation of the ICD-10 MS-DRG Grouper logic. - Updated
# 03/12/2024

drg_site <- "https://www.cms.gov/medicare/payment/prospective-payment-systems/acute-inpatient-pps/ms-drg-classifications-and-software"

drg_links <- rvest::read_html(drg_site) |>
  rvest::html_elements("a") |>
  rvest::html_attr("href") |>
  stringr::str_subset("zip")

code_edits <- drg_links |>
  stringr::str_subset("definition-medicare-code-edits")

definitions_manual <- drg_links |>
  stringr::str_subset("icd-10-ms-drg-definitions-manual-files")

drg_urls <- stringr::str_c(
  "https://www.cms.gov/",
  c(
    code_edits[1],
    definitions_manual[1]
  )
)

drgs <- curl::multi_download(
  urls = drg_urls,
  destfiles = fs::path(
    "data-raw",
    basename(drg_urls)
  )
)

# files_in_zip <- fs::dir_info(fs::path("data-raw")) |>
#   dplyr::select(path) |>
#   dplyr::filter(stringr::str_detect(path, ".zip")) |>
#   tibble::deframe() |>
#   rlang::set_names(basename) |>
#   purrr::map(zip::zip_list) |>
#   purrr::list_rbind(names_to = "zipfile") |>
#   dplyr::mutate(compressed = fs::fs_bytes(compressed_size),
#                 uncompressed = fs::fs_bytes(uncompressed_size)) |>
#   dplyr::select(zipfile,
#                 filename,
#                 compressed,
#                 uncompressed) |>
#   dplyr::tibble() |>
#   dplyr::filter(stringr::str_detect(filename, ".txt"))

zip::unzip(
  zipfile = "data-raw/Definitions of Medicare Code Edits_v_41_1.zip",
  files = "Definitions of Medicare Code Edits_v_41_1.txt",
  exdir = "data-raw"
)

# readr::read_table("data-raw/Definitions of Medicare Code Edits_v_41_1.txt", col_names = FALSE)

icddef <- readLines("data-raw/Definitions of Medicare Code Edits_v_41_1.txt")

# The Medicare Code Editor detects inconsistencies between a patient’s age and
# any diagnosis on the patient’s record. For example, a five-year-old patient
# with benign prostatic hypertrophy or a 78-year-old patient coded with a
# delivery. In the above cases, the diagnosis is clinically and virtually
# impossible in a patient of the stated age. Therefore, either the diagnosis or
# the age is presumed to be incorrect. There are four age categories for
# diagnoses in the program.
# 4A. Perinatal/Newborn: Age 0 years only; a subset of diagnoses which will only occur during the perinatal or newborn period of age 0 (e.g., tetanus neonatorum, health examination for newborn under 8 days old).
# 4B. Pediatric. Age range is 0–17 years inclusive (e.g., Reye’s syndrome, routine child health exam).
# 4C. Maternity. Age range is 9–64 years inclusive (e.g., diabetes in pregnancy, antepartum pulmonary complication).
# 4D. Adult. Age range is 15–124 years inclusive (e.g., senile delirium, mature cataract).

# Manifestation codes describe the manifestation of an underlying disease, not the disease itself, and therefore should not be used as a principal diagnosis.

# Chapter 1: Edit code lists
# 01. Invalid diagnosis or procedure code
# 02. External causes of morbidity codes as principal diagnosis
# 03. Duplicate of PDX
# 04. Age conflict
# 05. Sex conflict
# 06. Manifestation code as principal diagnosis
# 07. Non-specific principal diagnosis (discontinued as of 10/01/07)
# 08. Questionable admission
# 09. Unacceptable principal diagnosis
# 10. Non-specific O.R. procedure (discontinued as of 10/01/07)
# 11. Non-covered procedure
# 12. Open biopsy check (discontinued as of 10/01/10)
# 13. Bilateral procedure (discontinued as of ICD-10 implementation)
# 14. Invalid age
# 15. Invalid sex
# 16. Invalid discharge status
# 17. Limited coverage
# 18. Wrong procedure performed
# 19. Procedure inconsistent with LOS
# 20. Unspecified code

icddef[15:70]      # toc
icddef[77:98]      # index
icddef[101:102]    # 01. Invalid diagnosis or procedure code
icddef[104:105]    # 02. External causes of morbidity codes as principal diagnosis
icddef[107:108]    # 03. Duplicate of PDX
icddef[109:115]    # 04. Age conflict
icddef[3689:3691]  # 05. Sex conflict
icddef[7127:9433]  # 5B. Procedures for females only
icddef[9967:11915] # 5C. Procedures for males only

test <- list(
  # 4A. Perinatal/Newborn diagnoses
  perinatal_newborn = icddef[118:159],
  # 4B. Pediatric diagnoses (age 0 through 17)
  pediatric         = icddef[162:286],
  # 4C. Maternity diagnoses (age 9 through 64)
  maternity         = icddef[289:2831],
  # 4D. Adult diagnoses (age 15 through 124)
  adult             = icddef[2833:3687],
  # 5A. Diagnoses for females only
  female            = icddef[3694:7124],
  # 5C. Diagnoses for males only
  male              = icddef[9436:9964],
  # 6. Manifestation codes not allowed as principal diagnosis
  manifestation     = icddef[11921:12342]
)

# tail(icddef[11921:12342], 20)
# tail(icddef[9436:sum(9436, 3000)], 20)
# which(icddef == "C. Diagnoses for males only")
# which(icddef == "7. Non-specific principal diagnosis (discontinued as of 10/01/07)")

code_edits <- tibble::enframe(test,
                              name = "limitation_category",
                              value = "icd_code") |>
  tidyr::unnest(icd_code) |>
  tidyr::separate_wider_delim(
    icd_code,
    "\t",
    names = c("icd_code", "icd_description"),
    too_few = "align_start") |>
  # dplyr::mutate(dot = stringr::str_detect(icd_code, stringr::fixed("."))) |>
  dplyr::filter(!is.na(icd_description)) |>
  dplyr::mutate(icd_code = pathologie:::add_dot(icd_code)) |>
  dplyr::select(
    code = icd_code,
    description = icd_description,
    category = limitation_category
  ) |>
  dplyr::mutate(
    category = dplyr::case_match(
      category,
      "perinatal_newborn" ~ "Perinatal/Newborn (Age 0 Only)",
      "pediatric"         ~ "Pediatric (Ages 0-17)",
      "maternity"         ~ "Maternity (Ages 9-64)",
      "adult"             ~ "Adult (Ages 15-124)",
      "female"            ~ "Female Only",
      "male"              ~ "Male Only",
      "manifestation"     ~ "Manifestation (Not Allowed as Principal Diagnosis)"
    )
  )

# Update Pin
board <- pins::board_folder(here::here("inst/extdata/pins"))

board |>
  pins::pin_write(code_edits,
                  name = "code_edits",
                  title = "Definitions of Medicare Code Edits v41.1",
                  description = "ICD-10 Definitions of Medicare Code Edits: Description of each coding edit with corresponding code lists as well as all the edits and the code lists effective for FY 2024.",
                  type = "qs")

board |> pins::write_board_manifest()
