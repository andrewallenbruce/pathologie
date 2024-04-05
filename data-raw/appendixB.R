#   Appendix B Diagnosis Code/MDC/MS-DRG Index
#
#   The Diagnosis Code/MDC/MS-DRG Index lists each diagnosis code, as well as
#   the MDC, and the MS-DRGs to which the diagnosis is used to define the logic
#   of the DRG either as a principal or secondary diagnosis.

library(tidyverse)

path <- "C:/Users/Andrew/Desktop/payer_guidelines/data/MSDRG/MSDRGv41.1ICD10_R0_DefinitionsManual_TEXT_0/appendix_B.txt"

appendixB <- readr::read_fwf(
  path,
  skip_empty_rows = TRUE,
  skip            = 9
) |>
  dplyr::select(
    icd_code = X1,
    mdc = X2,
    drg = X3,
    icd_description = X4
  ) |>
  tidyr::fill(icd_code, icd_description) |>
  dplyr::mutate(icd_code = add_dot(icd_code))

appendixB

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
