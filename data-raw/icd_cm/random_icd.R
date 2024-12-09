source(here::here("data-raw", "pins_internal.R"))

icd_vec <- get_pin("icd10cm") |>
  tidyr::unnest(icd_ch_sec) |>
  tidyr::unnest(icd_sec_code) |>
  dplyr::mutate(icd_length = stringr::str_length(icd_code)) |>
  dplyr::filter(valid == 1) |>
  dplyr::select(icd_ch_no, icd_sec_range, icd_code, icd_length, icd_description) |>
  # dplyr::count(icd_length, sort = TRUE)
  # dplyr::filter(icd_ch_no == 9) |>
  # dplyr::slice_tail(n = 10)
  dplyr::pull(icd_code) |>
  codex::sf_convert()

#    A tibble: 5 × 2
#    icd_length     n
#         <int> <int>
#  1          8 51141
#  2          7 10301
#  3          6  6968
#  4          5  5418
#  5          3   216

icd_split_by_lengths <- \(x) {

  stopifnot(is.character(x))

  x <- codex::strsort(
    codex::uniq_narm(
      codex::sf_remove(x, "\\*|\\s")))

  l <- codex::vlen(x)

  list(
    i1 = x[l == 1],
    i2 = x[l == 2],
    i3 = x[l == 3],
    i4 = x[l == 4],
    i5 = x[l == 5],
    i6 = x[l == 6],
    i7 = x[l == 7],
    i8 = x[l == 8]
    )
}

icd_vec <- icd_vec |>
  icd_split_by_lengths() |>
  purrr::compact()


pin_update(
  icd_vec,
  "icdlst",
  "List of Vectors of ICD-10-CM Codes by Length",
  "List of Vectors of ICD-10-CM Codes by Length"
)
