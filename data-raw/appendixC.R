# Appendix C Complications or Comorbidities Exclusion list
#
# Appendix C is a list of all of the codes that are defined as either a
# complication or comorbidity (CC) or a major complication or comorbidity (MCC)
# when used as a secondary diagnosis.
#
# Part 1 lists these codes. Each code is indicated as CC or MCC. A link is given
# to a collection of diagnosis codes which, when used as the principal
# diagnosis, will cause the CC or MCC to be considered as only a non-CC.
#
# Part 2 lists codes which are assigned as a Major CC only for patients
# discharged alive. Otherwise they are assigned as a non-CC.
#
# Part 3 lists diagnosis codes that are designated as a complication or
# comorbidity (CC) or major complication or comorbidity (MCC) and included in
# the definition of the logic for the listed DRGs. When reported as a secondary
# diagnosis and grouped to one of the listed DRGs the diagnosis is excluded from
# acting as a CC/MCC for severity in DRG assignment.

appendixC <- readr::read_fwf(
  "data-raw/MSDRGv41.1ICD10_R0_DefinitionsManual_TEXT_0/appendix_C.txt",
  skip = 17
) |>
  janitor::row_to_names(1) |>
  janitor::clean_names() |>
  dplyr::select(
    code = i10_dx,
    level = lev,
    pdx_exclusions,
    code_description = icd_10_cm_description
  ) |>
  dplyr::mutate(row = dplyr::row_number())

pdx_rows <- appendixC |>
  dplyr::filter(is.na(code)) |>
  dplyr::pull(row)

pdx_rows <- pdx_rows + 1

pdx_groups <- appendixC |>
  dplyr::slice(pdx_rows) |>
  dplyr::select(-code_description) |>
  dplyr::mutate(
    start = row + 1,
    end = dplyr::lead(row) - 2,
    pdx_collection = stringr::str_remove(
      pdx_exclusions, stringr::fixed("n "))
  ) |>
  dplyr::select(pdx_collection, start, end)

appendixC_pdx <- appendixC |>
  dplyr::slice(18217:dplyr::n()) |>
  dplyr::mutate(
    start = row + 1,
    pdx_collection = stringr::str_remove(pdx_exclusions, stringr::fixed("n "))
  ) |>
  dplyr::left_join(pdx_groups, by = dplyr::join_by(start, pdx_collection)) |>
  dplyr::mutate(
    pdx_collection = dplyr::if_else(
      stringr::str_detect(
        pdx_collection,
        stringr::regex("[A-Za-z]")),
    NA_character_, pdx_collection)) |>
  tidyr::fill(pdx_collection) |>
  dplyr::filter(!is.na(code)) |>
  dplyr::filter(is.na(end)) |>
  dplyr::select(code, pdx_collection)

appendixC <- appendixC |>
  dplyr::slice(1:18217) |>
  dplyr::select(-row) |>
  tidyr::separate_wider_delim(
    pdx_exclusions, ":",
    names = c("pdx", "n_codes"),
    too_few = "align_start")

appendixC <- list(
  apx_c = appendixC,
  pdx = appendixC_pdx
)

# Update Pin
board <- pins::board_folder(here::here("inst/extdata/pins"))

board |> pins::pin_write(
  appendixC,
  name = "msdrg_ccmcc_41.1",
  title = "Appendix C Complications or Comorbidities Exclusion list 41.1",
  description = c(
    "Appendix C is a list of all of the codes that are defined as either a complication or comorbidity (CC) or a major complication or comorbidity (MCC) when used as a secondary diagnosis."
  ),
  type = "qs"
)

board |> pins::write_board_manifest()
