appendixA <- appendix_A() |>
  dplyr::rename(
    drg_abb = ms,
    drg_description = description
  )

drg_expand <- appendix_B() |>
  dplyr::count(drg, sort = TRUE) |>
  dplyr::select(drg) |>
  dplyr::filter(stringr::str_detect(drg, "-")) |>
  tidyr::separate_wider_delim(
    drg,
    delim = "-",
    names = c("start", "end"),
    cols_remove = FALSE
  ) |>
  dplyr::mutate(start = as.integer(start),
                end = as.integer(end)) |>
  dplyr::rowwise() |>
  dplyr::mutate(seq = list(c(start, end)),
                full = list(tidyr::full_seq(seq, 1))) |>
  dplyr::select(drg, full) |>
  tidyr::unnest(full) |>
  dplyr::mutate(full = stringr::str_pad(as.character(full), width = 3, pad = "0"))

appendixB <- appendix_B() |>
  dplyr::left_join(drg_expand,
                   by = c("drg" = "drg"),
                   relationship = "many-to-many") |>
  dplyr::select(
    icd_code,
    mdc,
    drg_range = drg,
    drg = full
  )


app_ab <- appendixA |>
  dplyr::left_join(appendixB,
                   by = dplyr::join_by(drg, mdc)) |>
  dplyr::select(
    icd_code,
    mdc,
    drg,
    drg_abb,
    drg_description,
    drg_range
  )

appendix_C()$apx_c |>
  dplyr::summarise(max_length = max(nchar(code), na.rm = TRUE))

append_C <- appendix_C()

apx_c <- append_C$apx_c |>
  dplyr::mutate(code = remove_dot(code),
                code = add_dot(code)) |>
  dplyr::select(
    icd_code = code,
    cc_mcc = level,
    pdx_group = pdx)

pdx <- append_C$pdx |>
  dplyr::mutate(code = remove_dot(code),
                code = add_dot(code)) |>
  dplyr::select(
    pdx_icd = code,
    pdx_group = pdx_collection
  ) |>
  tidyr::nest(pdx_icd = pdx_icd)

app_c <- dplyr::left_join(apx_c, pdx, by = dplyr::join_by(pdx_group))


app_abc <- app_ab |>
  dplyr::filter(!is.na(icd_code)) |>
  dplyr::left_join(app_c)

app_abc |>
  dplyr::filter(pdx_group == "0008")
