library(tidyverse)
library(pathologie)
library(vctrs)

years_floor <- function(from = lubridate::today() - 1052,
                        to   = lubridate::today()) {
  floor(
    as.double(
      difftime(
        to,
        from,
        units = "weeks",
        tz = "UTC"
        )
      ) / 52.17857
    )
}

years_floor()

apply_age_edits <- function(df) {
  dplyr::mutate(
    df,
    conflict = dplyr::if_else(
      icd_limitation == "Perinatal/Newborn (Age 0 Only)" &
        age != 0,
      "Conflict",
      NA_character_
    ),
    conflict = dplyr::if_else(
      icd_limitation == "Pediatric (Ages 0-17)" &
        dplyr::between(age, 0, 17) == FALSE,
      "Conflict",
      NA_character_
    ),
    conflict = dplyr::if_else(
      icd_limitation == "Maternity (Ages 9-64)" &
        dplyr::between(age, 9, 64) == FALSE,
      "Conflict",
      NA_character_
    ),
    conflict = dplyr::if_else(
      icd_limitation == "Adult (Ages 15-124)" &
        dplyr::between(age, 15, 124) == FALSE,
      "Conflict",
      NA_character_
    )
  )
}

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

file <- "C:/Users/Andrew/Desktop/Repositories/responsive_centers/data/cpt_rpt.csv"

age_example <- readr::read_csv(file, show_col_types = FALSE) |>
  dplyr::select(
    dob      = patient_dob,
    dos      = cpt_dos,
    icd_code = diagnosis) |>
  tidyr::separate_longer_delim(
    cols  = icd_code,
    delim = ",") |>
  dplyr::filter(icd_code %in% age_icds)

age_example

edits <- pathologie::search_edits() |>
  dplyr::select(
    icd_code        = code,
    icd_description = description,
    icd_limitation  = category
  ) |>
  dplyr::mutate(
    icd_conflict = dplyr::case_match(
      icd_limitation,
      c(
        "Perinatal/Newborn (Age 0 Only)",
        "Pediatric (Ages 0-17)",
        "Maternity (Ages 9-64)",
        "Adult (Ages 15-124)"
      ) ~ "Age",
      c("Female Only", "Male Only") ~ "Sex",
      .default = "Other"
    ),
    .before = icd_limitation
  )

edits

age_example_edits <- age_example |>
  dplyr::mutate(age = years_floor(dob, dos)) |>
  dplyr::left_join(edits,
                   by = dplyr::join_by(icd_code),
                   relationship = "many-to-many") |>
  dplyr::filter(icd_conflict == "Age") |>
  apply_age_edits() |>
  dplyr::select(
    dob,
    dos,
    age,
    icd_code,
    # icd_description,
    icd_limitation,
    conflict
  )

age_example_edits

age_example_edits |>
  dplyr::filter(!is.na(conflict))

pathologie::icd10cm("Z00.00") |>
  dplyr::glimpse()
