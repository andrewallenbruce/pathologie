library(rvest)

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
