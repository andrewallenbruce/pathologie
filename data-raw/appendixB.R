#   Appendix B Diagnosis Code/MDC/MS-DRG Index
#
#   The Diagnosis Code/MDC/MS-DRG Index lists each diagnosis code, as well as
#   the MDC, and the MS-DRGs to which the diagnosis is used to define the logic
#   of the DRG either as a principal or secondary diagnosis.

library(tidyverse)
library(pathologie)

path <- "C:/Users/Andrew/Desktop/payer_guidelines/data/MSDRG/MSDRGv41.1ICD10_R0_DefinitionsManual_TEXT_0/appendix_B.txt"

appendixB <- readr::read_fwf(
  path,
  skip_empty_rows = TRUE,
  skip            = 9
) |>
  dplyr::select(
    icd_code = X1,
    mdc = X2,
    drg = X3
    # , icd_description = X4
  ) |>
  tidyr::fill(icd_code) |>
  dplyr::mutate(icd_code = add_dot(icd_code))

drg_expand <- appendixB |>
  dplyr::count(drg, sort = TRUE) |>
  dplyr::select(drg) |>
  dplyr::filter(stringr::str_detect(drg, "-")) |>
  tidyr::separate_wider_delim(
    drg,
    delim = "-",
    names = c("start", "end"),
    cols_remove = FALSE
  ) |>
  dplyr::mutate(start = as.integer(start),
                end = as.integer(end)) |>
  dplyr::rowwise() |>
  dplyr::mutate(seq = list(c(start, end)),
                full = list(tidyr::full_seq(seq, 1))) |>
  dplyr::select(drg, full) |>
  tidyr::unnest(full) |>
  dplyr::mutate(full = stringr::str_pad(as.character(full), width = 3, pad = "0"))

appendixB <- appendixB |>
  dplyr::left_join(
    drg_expand,
    by = c("drg" = "drg"),
    relationship = "many-to-many") |>
  dplyr::select(
    icd_code,
    mdc,
    drg_range = drg,
    drg = full
  )

# Update Pin
board <- pins::board_folder(here::here("inst/extdata/pins"))

board |> pins::pin_write(
  appendixB,
  name        = "msdrg_index_41.1",
  title       = "Appendix B Diagnosis Code/MDC/MS-DRG Index 41.1",
  description = c(
    "The Diagnosis Code/MDC/MS-DRG Index lists each",
    "diagnosis code, as well as the  MDC, and the MS-DRGs",
    "to which the diagnosis is used to define the logic of",
    "the DRG either as a principal or secondary diagnosis."
  ),
  type        = "qs"
)

board |> pins::write_board_manifest()
