# Appendix H Diagnoses Defined as Major Complications or Comorbidities
#
# Diagnoses in Appendix H Part I are considered major complications or
# comorbidities (MCC) except when used in conjunction with the principal
# diagnosis in the corresponding CC Exclusion List in Appendix C. In addition to
# the CC exclusion list, the diagnoses in Part II are assigned as a major CC
# only for patients discharged alive, otherwise they will be assigned as a non
# CC.


library(tidyverse)

path_h1 <- "C:/Users/Andrew/Desktop/payer_guidelines/data/MSDRG/MSDRGv41.1ICD10_R0_DefinitionsManual_TEXT_0/appendix_H_1.txt"

h1_file <- readr::read_table(
  path_h1,
  skip = 0,
  col_names = FALSE) |>
  dplyr::mutate(dx_type = "MCC",
                X1 = pathologie::add_dot(X1)) |>
  tidyr::unite("icd_description", X2:X3, na.rm = TRUE, sep = " ") |>
  dplyr::rename(icd_code = X1)

# Update Pin
board <- pins::board_folder(here::here("inst/extdata/pins"))

board |> pins::pin_write(
  h1_file,
  name = "msdrg_icd_mccs_41.1",
  title = "Appendix H Diagnoses Defined as Major Complications or Comorbidities 41.1",
  description = c(
    "Diagnoses in Appendix H Part I are considered major complications or comorbidities (MCC) except when used in conjunction with the principal diagnosis in the corresponding CC Exclusion List in Appendix C. In addition to the CC exclusion list, the diagnoses in Part II are assigned as a major CC only for patients discharged alive, otherwise they will be assigned as a non CC."
  ),
  type = "qs"
)

board |> pins::write_board_manifest()
