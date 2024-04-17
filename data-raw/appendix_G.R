# Appendix G Diagnoses Defined as Complications or Comorbidities
#
# Diagnoses in Appendix G are considered complications or comorbidities (CC)
# except when used in conjunction with the principal diagnosis in the
# corresponding CC Exclusion List in Appendix C.


library(tidyverse)

path_G <- "C:/Users/Andrew/Desktop/payer_guidelines/data/MSDRG/MSDRGv41.1ICD10_R0_DefinitionsManual_TEXT_0/appendix_G.txt"

g_file <- readr::read_table(
  path_G,
  skip = 0,
  col_names = FALSE) |>
  dplyr::mutate(dx_type = "CC",
                X1 = pathologie::add_dot(X1)) |>
  tidyr::unite("icd_description", X2:X9, na.rm = TRUE, sep = " ") |>
  dplyr::rename(icd_code = X1)

# Update Pin
board <- pins::board_folder(here::here("inst/extdata/pins"))

board |> pins::pin_write(
  g_file,
  name = "msdrg_icd_ccs_41.1",
  title = "Appendix G Diagnoses Defined as Complications or Comorbidities 41.1",
  description = c(
    "Diagnoses in Appendix G are considered complications or comorbidities (CC) except when used in conjunction with the principal diagnosis in the corresponding CC Exclusion List in Appendix C."
  ),
  type = "qs"
)

board |> pins::write_board_manifest()
