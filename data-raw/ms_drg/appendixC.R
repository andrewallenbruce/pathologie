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

path_c11 <- "C:/Users/Andrew/Desktop/payer_guidelines/data/MSDRG/MSDRGv41.1ICD10_R0_DefinitionsManual_TEXT_0/appendix_C_1_1.txt"

appendix_c11 <- readr::read_fwf(
  path_c11,
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


path_c12 <- "C:/Users/Andrew/Desktop/payer_guidelines/data/MSDRG/MSDRGv41.1ICD10_R0_DefinitionsManual_TEXT_0/appendix_C_1_2.txt"

appendix_c12 <- readr::read_table(path_c12, col_names = FALSE) |>
  dplyr::mutate(row = dplyr::row_number(), .before = 1) |>
  dplyr::select(-X2)

pdx_rows <- appendix_c12 |>
  dplyr::filter(X1 == "PDX") |>
  dplyr::pull(row)

pdx_groups <- appendix_c12 |>
  dplyr::slice(pdx_rows) |>
  dplyr::mutate(start = row + 1,
                end = dplyr::lead(row) - 1) |>
  dplyr::select(pdx_group = X3,
                start,
                end)

appendix_c12 <- appendix_c12 |>
  dplyr::left_join(pdx_groups, by = dplyr::join_by(row == start)) |>
  dplyr::filter(X1 != "PDX") |>
  dplyr::select(pdx_icd = X1, pdx_group) |>
  tidyr::fill(pdx_group) |>
  dplyr::mutate(pdx_icd = pathologie::add_dot(pdx_icd))


pdx_join <- appendix_c11 |>
  left_join(appendix_c12, by = "pdx_group") |>
  tidyr::nest(pdx_icd = pdx_icd)

# appendix_c <- dplyr::left_join(
#   appendix_c11,
#   appendix_c12,
#   by = dplyr::join_by(pdx_group)) |>
#   tidyr::unnest(pdx_icd) |>
#   tidyr::nest(pdx_groups = c(pdx_group, pdx_icd))


pdx_join

# appendixC <- list(
#   cc_mcc = appendix_c11,
#   pdx_groups = appendix_c12
# )

# Update Pin
board <- pins::board_folder(here::here("inst/extdata/pins"))

board |> pins::pin_write(
  pdx_join,
  name = "msdrg_ccmcc_41.1",
  title = "Appendix C Complications or Comorbidities Exclusion list 41.1",
  description = c(
    "Appendix C is a list of all of the codes that are defined as either a complication or comorbidity (CC) or a major complication or comorbidity (MCC) when used as a secondary diagnosis."
  ),
  type = "qs"
)

board |> pins::write_board_manifest()



# appendixC_pdx <- appendixC |>
#   dplyr::slice(18217:dplyr::n()) |>
#   dplyr::mutate(
#     start = row + 1,
#     pdx_collection = stringr::str_remove(pdx_exclusions, stringr::fixed("n "))
#   ) |>
#   dplyr::left_join(pdx_groups, by = dplyr::join_by(start, pdx_collection)) |>
#   dplyr::mutate(
#     pdx_collection = dplyr::if_else(
#       stringr::str_detect(
#         pdx_collection,
#         stringr::regex("[A-Za-z]")),
#     NA_character_, pdx_collection)) |>
#   tidyr::fill(pdx_collection) |>
#   dplyr::filter(!is.na(code)) |>
#   dplyr::filter(is.na(end)) |>
#   dplyr::select(code, pdx_collection)
#
# appendixC <- appendixC |>
#   dplyr::slice(1:18217) |>
#   dplyr::select(-row) |>
#   tidyr::separate_wider_delim(
#     pdx_exclusions, ":",
#     names = c("pdx", "n_codes"),
#     too_few = "align_start")
