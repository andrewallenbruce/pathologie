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
