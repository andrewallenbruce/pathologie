# Appendix A List of MS-DRGs Version 41.1
#
# Appendix A contains a list of each MS-DRG with a specification of the MDC and
# whether the MS-DRG is medical or surgical. Some MS-DRGs which contain patients
# from multiple MDCs (e.g., 014 Allogeneic Bone Marrow Transplant) do not have
# an MDC specified. The letter M is used to designate a medical MS-DRG and the
# letter P is used to designate a surgical MS-DRG.

library(tidyverse)

appendixA <- readr::read_fwf(
    "data-raw/MSDRGv41.1ICD10_R0_DefinitionsManual_TEXT_0/appendix_A.txt",
    skip_empty_rows = TRUE,
    skip = 10
  ) |>
  janitor::row_to_names(1) |>
  janitor::clean_names() |>
  janitor::remove_empty(which = c("cols", "rows"))

names(appendixA) <- c("drg", "mdc", "ms", "description", "col1", "col2")

appendixA <- appendixA |>
  dplyr::select(drg, mdc, ms, description)

# Update Pin
board <- pins::board_folder(here::here("inst/extdata/pins"))

board |> pins::pin_write(
  appendixA,
  name        = "msdrg_41.1",
  title       = "Appendix A List of MS-DRGs Version 41.1",
  description = c(
    "Appendix A contains a list of each MS-DRG with a specification",
    "of the MDC and whether the MS-DRG is medical or surgical. Some",
    "MS-DRGs which contain patients from multiple MDCs do not have",
    "an MDC specified. The letter M is used to designate a medical",
    "MS-DRG and the letter P is used to designate a surgical MS-DRG."
  ),
  type        = "qs"
)

board |> pins::write_board_manifest()
