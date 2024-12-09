library(tidyverse)
library(pathologie)

years_floor <- function(from, to) {
  floor(as.double(difftime(to, from, units = "weeks", tz = "UTC")) / 52.17857)
}

apply_age_edits <- function(icd_conflict_rule, age) {

  msg <- "Age Conflict"

  dplyr::case_when(
    icd_conflict_rule == "Perinatal/Newborn (Age 0 Only)" & age != 0 ~ msg,
    icd_conflict_rule == "Pediatric (Ages 0-17)" & dplyr::between(age, 0, 17) == FALSE ~ msg,
    icd_conflict_rule == "Maternity (Ages 9-64)" & dplyr::between(age, 9, 64) == FALSE ~ msg,
    icd_conflict_rule == "Adult (Ages 15-124)" & dplyr::between(age, 15, 124) == FALSE ~ msg,
    .default = NA_character_
  )
}

exdata <- pins::pin_read(pathologie::mount_board(), "exdata")

exdata |>
  dplyr::mutate(patient_age = years_floor(date_of_birth, date_of_service)) |>
  dplyr::left_join(pathologie::search_edits(),
                   by = dplyr::join_by(icd_code), relationship = "many-to-many") |>
  dplyr::filter(!is.na(icd_description)) |>
  dplyr::arrange(date_of_service, icd_code) |>
  dplyr::mutate(conflict = apply_age_edits(icd_conflict_rule, patient_age)) |>
  dplyr::filter(!is.na(conflict)) |>
  dplyr::glimpse()

exdata <- readr::read_csv(
  file,
  show_col_types = FALSE) |>
  dplyr::select(
    date_of_birth = patient_dob,
    date_of_service = cpt_dos,
    icd_code = diagnosis) |>
  tidyr::separate_longer_delim(
    cols  = icd_code,
    delim = ",")

# Update Pin
board <- pins::board_folder(here::here("inst/extdata/pins"))

board |>
  pins::pin_write(
    exdata,
    name = "exdata",
    title = "Example Data",
    type = "qs")

board |> pins::write_board_manifest()



age_icds <- vctrs::vec_c(
  "F53.0",
  "F64.2",
  "F32.81",
  "Z62.21",
  "O90.6",
  "F03.90",
  "Q96.8",
  "Z00.00",
  "Z91.82",
  "G32.81",
  "T76.02XA"
)
