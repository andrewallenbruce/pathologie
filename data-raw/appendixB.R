#   Appendix B Diagnosis Code/MDC/MS-DRG Index
#
#   The Diagnosis Code/MDC/MS-DRG Index lists each diagnosis code, as well as
#   the MDC, and the MS-DRGs to which the diagnosis is used to define the logic
#   of the DRG either as a principal or secondary diagnosis.

library(tidyverse)

appendixB <- readr::read_fwf(
  "data-raw/MSDRGv41.1ICD10_R0_DefinitionsManual_TEXT_0/appendix_B.txt",
  skip_empty_rows = TRUE,
  skip            = 9
) |>
  dplyr::select(
    code             = X1,
    mdc              = X2,
    drg              = X3,
    code_description = X4
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
