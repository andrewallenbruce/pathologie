#' Check if string is valid ICD-10-CM code
#' @param x `<chr>` string of `length(1)`
#' @param arg `<chr>` function argument name in the current function
#' @param call `<environment>` environment the function is called from
#' @return `<lgl>` `TRUE` if valid, `FALSE` otherwise
#' @examples
#' purrr::map_vec(
#' c("H00.019", "D50.1", "C4A.70", "Z20.818", "11646", "E8015"),
#' is_valid_icd)
#'
#' @export
#' @autoglobal
is_valid_icd <- function(x,
                         arg = rlang::caller_arg(x),
                         call = rlang::caller_env()) {

  stopifnot("`x` must be scalar character vector" = rlang::is_scalar_character(x))

  if (stringr::str_length(x) < 3L || stringr::str_length(x) > 7L) {
    cli::cli_abort(c(
      "An {.strong ICD-10-CM} code is between {.emph 3-7} characters.",
      "x" = "{.strong {.val {x}}} is {.val {nchar(x)}}."),
      call = call)}

  # https://www.johndcook.com/blog/2019/05/05/regex_icd_codes/
  icd10_regex <- "[A-TV-Z][0-9][0-9AB]\\.?[0-9A-TV-Z]{0,4}"

  stringr::str_detect(x, stringr::regex(icd10_regex))

  if (grepl("[[:lower:]]*", x)) {toupper(x)}
}

#' Check if an ICD-10-CM code is in a valid format
#'
#' @description
#' `is_valid_icd10cm` checks to see if the ICD-10-CM code is valid
#' and has between 3 and 8 characters, and starts with a letter and number.
#'
#' @param x A string
#'
#' @return Boolean
#' @export
#'
#' @examples
#' is_valid_icd10cm("F320") # valid
#' is_valid_icd10cm("F32")  # valid
#' is_valid_icd10cm("296")  # invalid
#'
is_valid_icd10cm <- function(x) {

  dplyr::case_when(
    stringr::str_length(x) < 3 ~ FALSE, # has at least 3 characters
    stringr::str_length(x) > 8 ~ FALSE, # has less than 8 characters (incl dot)
    !stringr::str_starts(x, "[A-Z][0-9]") ~ FALSE, # starts with letter & number
    stringr::str_count(x, "[0-9]") < 1 ~ FALSE, # has at least 1 number
    TRUE ~ TRUE
  )
}
