age_range <- dplyr::tribble(
  ~icd_limitation,                  ~start, ~end,
  "Perinatal/Newborn (Age 0 Only)",  0.0,     0.1,
  "Pediatric (Ages 0-17)",           0.1,     17,
  "Maternity (Ages 9-64)",           9,     64,
  "Adult (Ages 15-124)",            15,    124
) |>
  dplyr::mutate(
    age_range = ivs::iv(start, end),
    .keep = "unused"
    )

search_edits() |>
  dplyr::select(
    icd = code,
    icd_description = description,
    icd_limitation = category) |>
  dplyr::left_join(
    age_range,
    by = "icd_limitation") |>
  dplyr::count(icd_limitation, age_range, sort = TRUE)

report <- readr::read_csv("C:/Users/Andrew/Desktop/Repositories/responsive_centers/data/cpt_rpt.csv")


edits <- pathologie::search_edits() |>
  dplyr::select(
    icd = code,
    icd_description = description,
    icd_limitation = category) |>
  dplyr::left_join(
    age_range,
    by = "icd_limitation")

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

age_example <- report |>
  dplyr::select(
    dob = patient_dob,
    dos = cpt_dos,
    icd = diagnosis) |>
  tidyr::separate_longer_delim(
    cols = icd,
    delim = ",") |>
  dplyr::filter(icd %in% age_icds)

age_example |>
  dplyr::mutate(age_years = as.numeric(difftime(dos, dob, units = "weeks") / 52)) |>
  dplyr::left_join(edits, by = dplyr::join_by(icd == icd), relationship = "many-to-many") |>
  dplyr::mutate(is_between = ivs::iv_between(age_years, age_range),
                is_includes = ivs::iv_includes(age_range, age_years)) |>
  dplyr::filter(is_between == TRUE) |>
  dplyr::pull(type)
