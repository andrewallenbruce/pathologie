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
#> [1] 2

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

exdata <- readr::read_csv(
  file,
  show_col_types = FALSE) |>
  dplyr::select(
    dob      = patient_dob,
    dos      = cpt_dos,
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

exdata |>
  dplyr::filter(icd_code %in% age_icds)

age_example
#> # A tibble: 299 × 3
#>    dob        dos        icd_code
#>    <date>     <date>     <chr>
#>  1 2015-11-27 2023-01-08 Z00.00
#>  2 2010-02-02 2024-02-05 F32.81
#>  3 1990-11-07 2023-11-13 F53.0
#>  4 2006-12-23 2023-09-26 F64.2
#>  5 1993-05-30 2023-08-07 Q96.8
#>  6 1986-01-25 2023-08-05 Z91.82
#>  7 1992-10-23 2023-06-29 O90.6
#>  8 2014-01-25 2023-06-27 Z00.00
#>  9 2011-01-07 2023-04-12 F64.2
#> 10 1992-12-03 2023-03-02 F53.0
#> # ℹ 289 more rows

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
#> # A tibble: 7,946 × 4
#>    icd_code icd_description                          icd_conflict icd_limitation
#>    <chr>    <chr>                                    <chr>        <chr>
#>  1 A33      Tetanus neonatorum                       Age          Perinatal/New…
#>  2 E84.11   Meconium ileus in cystic fibrosis        Age          Perinatal/New…
#>  3 H04.531  Neonatal obstruction of right nasolacri… Age          Perinatal/New…
#>  4 H04.532  Neonatal obstruction of left nasolacrim… Age          Perinatal/New…
#>  5 H04.533  Neonatal obstruction of bilateral nasol… Age          Perinatal/New…
#>  6 H04.539  Neonatal obstruction of unspecified nas… Age          Perinatal/New…
#>  7 N47.0    Adherent prepuce, newborn                Age          Perinatal/New…
#>  8 Z00.110  Health examination for newborn under 8 … Age          Perinatal/New…
#>  9 Z00.111  Health examination for newborn 8 to 28 … Age          Perinatal/New…
#> 10 Z05.0    Obs & eval of NB for suspected cardiac … Age          Perinatal/New…
#> # ℹ 7,936 more rows

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
#> # A tibble: 224 × 6
#>    dob        dos          age icd_code icd_limitation        conflict
#>    <date>     <date>     <dbl> <chr>    <chr>                 <chr>
#>  1 2015-11-27 2023-01-08     7 Z00.00   Adult (Ages 15-124)   Conflict
#>  2 1990-11-07 2023-11-13    33 F53.0    Maternity (Ages 9-64) <NA>
#>  3 2006-12-23 2023-09-26    16 F64.2    Pediatric (Ages 0-17) <NA>
#>  4 1986-01-25 2023-08-05    37 Z91.82   Adult (Ages 15-124)   <NA>
#>  5 1992-10-23 2023-06-29    30 O90.6    Maternity (Ages 9-64) <NA>
#>  6 2014-01-25 2023-06-27     9 Z00.00   Adult (Ages 15-124)   Conflict
#>  7 2011-01-07 2023-04-12    12 F64.2    Pediatric (Ages 0-17) <NA>
#>  8 1992-12-03 2023-03-02    30 F53.0    Maternity (Ages 9-64) <NA>
#>  9 2000-11-12 2023-10-16    22 F53.0    Maternity (Ages 9-64) <NA>
#> 10 1993-10-12 2022-12-13    29 F53.0    Maternity (Ages 9-64) <NA>
#> # ℹ 214 more rows

age_example_edits |>
  dplyr::filter(!is.na(conflict))
#> # A tibble: 3 × 6
#>   dob        dos          age icd_code icd_limitation      conflict
#>   <date>     <date>     <dbl> <chr>    <chr>               <chr>
#> 1 2015-11-27 2023-01-08     7 Z00.00   Adult (Ages 15-124) Conflict
#> 2 2014-01-25 2023-06-27     9 Z00.00   Adult (Ages 15-124) Conflict
#> 3 2012-05-11 2022-09-21    10 Z00.00   Adult (Ages 15-124) Conflict

pathologie::icd10cm("Z00.00") |>
  dplyr::glimpse()
#> Rows: 1
#> Columns: 11
#> $ ch            <int> 21
#> $ abb           <chr> "STAT"
#> $ chapter_name  <chr> "Factors influencing health status and contact with heal…
#> $ chapter_range <chr> "Z00 - Z99"
#> $ section_name  <chr> "Encounter for general examination without complaint, su…
#> $ section_range <chr> "Z00 - Z00.8"
#> $ order         <int> 95509
#> $ valid         <int> 1
#> $ code          <chr> "Z00.00"
#> $ description   <chr> "Encounter for general adult medical examination without…
#> $ category      <chr> NA
