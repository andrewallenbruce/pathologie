library(rvest)
library(fs)
library(curl)
library(zip)
library(tidyverse)


# Appendix A List of MS-DRGs Version 41.1
appendixA <- readr::read_fwf("data-raw/MSDRGv41.1ICD10_R0_DefinitionsManual_TEXT_0/appendix_A.txt",
                skip_empty_rows = TRUE,
                skip = 10) |>
  janitor::row_to_names(1) |>
  janitor::clean_names() |>
  janitor::remove_empty(which = c("cols", "rows"))

names(appendixA) <- c("drg", "mdc", "ms", "description", "col1", "col2")

appendixA <- appendixA |> dplyr::select(drg, mdc, ms, description)

# Update Pin
board <- pins::board_folder(here::here("inst/extdata/pins"))

board |> pins::pin_write(
  appendixA,
  name = "msdrg_41.1",
  title = "Appendix A List of MS-DRGs Version 41.1",
  description = c("Appendix A contains a list of each MS-DRG with a specification",
                  "of the MDC and whether the MS-DRG is medical or surgical. Some",
                  "MS-DRGs which contain patients from multiple MDCs do not have",
                  "an MDC specified. The letter M is used to designate a medical",
                  "MS-DRG and the letter P is used to designate a surgical MS-DRG."),
  type = "qs")

board |> pins::write_board_manifest()


# Appendix B Diagnosis Code/MDC/MS-DRG Index
#
# The Diagnosis Code/MDC/MS-DRG Index lists
# each diagnosis code, as well as the  MDC,
# and the MS-DRGs to which the diagnosis is
# used to define the logic of the DRG either
# as a principal or secondary diagnosis.

# Appendix B
appendixB <- readr::read_fwf(
  "data-raw/MSDRGv41.1ICD10_R0_DefinitionsManual_TEXT_0/appendix_B.txt",
  skip_empty_rows = TRUE,
  skip = 9
  ) |>
  dplyr::select(
    code = X1,
    mdc = X2,
    drg = X3,
    code_description = X4
    )

# Update Pin
board <- pins::board_folder(here::here("inst/extdata/pins"))

board |> pins::pin_write(
  appendixB,
  name = "msdrg_index_41.1",
  title = "Appendix B Diagnosis Code/MDC/MS-DRG Index 41.1",
  description = c("The Diagnosis Code/MDC/MS-DRG Index lists each",
                  "diagnosis code, as well as the  MDC, and the MS-DRGs",
                  "to which the diagnosis is used to define the logic of",
                  "the DRG either as a principal or secondary diagnosis."),
  type = "qs")

board |> pins::write_board_manifest()

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
