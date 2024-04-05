#' Add ICD-10-CM Chapter Labels
#'
#' @param df `<data.frame>`data frame
#'
#' @param col `<sym>` unquoted column name of ICD-10-CM codes to match
#'
#' @return A [tibble][tibble::tibble-package] with a `chapter` column
#'
#' @examples
#' dplyr::tibble(code = c("F50.8", "G40.311", "Q96.8", "Z62.890", "R45.4",
#' "E06.3", "H00.019", "D50.1", "C4A.70", "Z20.818")) |>
#' case_chapter_icd10(code)
#' @export
#'
#' @autoglobal
case_chapter_icd10 <- function(df, col) {

  ch <- icd10_chapter_regex()

  df |>
    dplyr::mutate(chapter = dplyr::case_when(
      stringr::str_detect({{ col }}, stringr::regex(ch[1, ]$regex)) == TRUE ~ ch[1, ]$chapter,
      stringr::str_detect({{ col }}, stringr::regex(ch[2, ]$regex)) == TRUE ~ ch[2, ]$chapter,
      stringr::str_detect({{ col }}, stringr::regex(ch[3, ]$regex)) == TRUE ~ ch[3, ]$chapter,
      stringr::str_detect({{ col }}, stringr::regex(ch[4, ]$regex)) == TRUE ~ ch[4, ]$chapter,
      stringr::str_detect({{ col }}, stringr::regex(ch[5, ]$regex)) == TRUE ~ ch[5, ]$chapter,
      stringr::str_detect({{ col }}, stringr::regex(ch[6, ]$regex)) == TRUE ~ ch[6, ]$chapter,
      stringr::str_detect({{ col }}, stringr::regex(ch[7, ]$regex)) == TRUE ~ ch[7, ]$chapter,
      stringr::str_detect({{ col }}, stringr::regex(ch[8, ]$regex)) == TRUE ~ ch[8, ]$chapter,
      stringr::str_detect({{ col }}, stringr::regex(ch[9, ]$regex)) == TRUE ~ ch[9, ]$chapter,
      stringr::str_detect({{ col }}, stringr::regex(ch[10, ]$regex)) == TRUE ~ ch[10, ]$chapter,
      stringr::str_detect({{ col }}, stringr::regex(ch[11, ]$regex)) == TRUE ~ ch[11, ]$chapter,
      stringr::str_detect({{ col }}, stringr::regex(ch[12, ]$regex)) == TRUE ~ ch[12, ]$chapter,
      stringr::str_detect({{ col }}, stringr::regex(ch[13, ]$regex)) == TRUE ~ ch[13, ]$chapter,
      stringr::str_detect({{ col }}, stringr::regex(ch[14, ]$regex)) == TRUE ~ ch[14, ]$chapter,
      stringr::str_detect({{ col }}, stringr::regex(ch[15, ]$regex)) == TRUE ~ ch[15, ]$chapter,
      stringr::str_detect({{ col }}, stringr::regex(ch[16, ]$regex)) == TRUE ~ ch[16, ]$chapter,
      stringr::str_detect({{ col }}, stringr::regex(ch[17, ]$regex)) == TRUE ~ ch[17, ]$chapter,
      stringr::str_detect({{ col }}, stringr::regex(ch[18, ]$regex)) == TRUE ~ ch[18, ]$chapter,
      stringr::str_detect({{ col }}, stringr::regex(ch[19, ]$regex)) == TRUE ~ ch[19, ]$chapter,
      stringr::str_detect({{ col }}, stringr::regex(ch[20, ]$regex)) == TRUE ~ ch[20, ]$chapter,
      stringr::str_detect({{ col }}, stringr::regex(ch[21, ]$regex)) == TRUE ~ ch[21, ]$chapter,
      stringr::str_detect({{ col }}, stringr::regex(ch[22, ]$regex)) == TRUE ~ ch[22, ]$chapter,
      TRUE ~ "Unmatched"
    ),
    .after = {{ col }})
}


#' ICD-10-CM Chapter Labels and Regexes
#'
#' @examples
#' icd10_chapter_regex()
#'
#' @noRd
#'
#' @autoglobal
icd10_chapter_regex <- function() {
  dplyr::tibble(
    chapter = c(
      "Certain infectious and parasitic diseases",
      "Neoplasms",
      "Diseases of the blood and blood-forming organs and certain disorders involving the immune mechanism",
      "Endocrine, nutritional and metabolic diseases",
      "Mental, behavioral and neurodevelopmental disorders",
      "Diseases of the nervous system",
      "Diseases of the eye and adnexa",
      "Diseases of the ear and mastoid process",
      "Diseases of the circulatory system",
      "Diseases of the respiratory system",
      "Diseases of the digestive system",
      "Diseases of the skin and subcutaneous tissue",
      "Diseases of the musculoskeletal system and connective tissue",
      "Diseases of the genitourinary system",
      "Pregnancy, childbirth and the puerperium",
      "Certain conditions originating in the perinatal period",
      "Congenital malformations, deformations and chromosomal abnormalities",
      "Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified",
      "Injury, poisoning and certain other consequences of external causes",
      "External causes of morbidity",
      "Factors influencing health status and contact with health services",
      "Codes for special purposes"
    ),
    regex = c(
      "^[A-B]",
      "(^[C]|^[D][0-4])",
      "^[D][5-8]",
      "^[E]",
      "^[F]",
      "^[G]",
      "^[H][0-5]",
      "^[H][6-9]",
      "^[I]",
      "^[J]",
      "^[K]",
      "^[L]",
      "^[M]",
      "^[N]",
      "^[O]",
      "^[P]",
      "^[Q]",
      "^[R]",
      "^[S-T]",
      "^[V-Y]",
      "^[Z]",
      "^[U]"
    ),
  )
}

#' Add a dot to an ICD-10 code
#'
#' `add_dot()` adds a dot to the ICD-10 code in the appropriate position
#'  where one does not exist
#'
#' @param x A valid ICD-10 code without a dot
#'
#' @returns A valid ICD-10 code with a dot included
#'
#' @export
#'
#' @keywords internal
#'
#' @examples
#' add_dot("F320")
#'
#' add_dot("F32")  # no dot added if code is only 3-digits
add_dot <- function(x) {

  stopifnot(!stringr::str_detect(x, stringr::fixed(".")))

  ifelse(stringr::str_length(x) > 3,
         gsub("^(.{3})(.*)$", paste0("\\1.\\2"), x),
         x)
}


#' Remove dot from an ICD-10 code
#'
#' `remove_dot()` removes a dot from the ICD-10 code if it exists
#'
#' @param x A valid ICD-10 code with a dot
#'
#' @returns A valid ICD-10 code without a dot included
#'
#' @export
#'
#' @keywords internal
#'
#' @examples
#' remove_dot("F32.0")
#'
#' remove_dot("F32")
remove_dot <- function(x) {
  stringr::str_remove(x, stringr::fixed("."))
}

# https://github.com/andrewallenbruce/icd10us/blob/master/R/addremove_dot.R
