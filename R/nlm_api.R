#' National Library of Medicine's ICD-10-CM API
#'
#' @description [icd10api()] allows you to search the National Library of
#'   Medicine's ICD-10-CM API by code or associated term.
#'
#' @details ICD-10-CM (International Classification of Diseases, 10th Revision,
#'   Clinical Modification) is a medical coding system for classifying diagnoses
#'   and reasons for visits in U.S. health care settings.
#'
#'   ## Links
#'  * [NIH NLM Clinical Table Service ICD-10-CM API](https://clinicaltables.nlm.nih.gov/apidoc/icd10cm/v3/doc.html)
#'  * [Learn more about ICD-10-CM.](http://www.cdc.gov/nchs/icd/icd10cm.htm)
#'
#' @note Current Version: ICD-10-CM **2024**
#'
#' @source National Library of Medicine/National Institute of Health
#'
#' @param icd_code `<chr>` ICD-10-CM code containing 3 to 7 characters, excluding
#'   the dot
#'
#' @param term `<chr>` Associated term describing an ICD-10-CM code
#'
#' @param field `<chr>` `code` or `both`; default is `code`
#'
#' @param limit `<int>` API limit, defaults to `500`. Note that the current
#'   limit on the total number of results that can be retrieved is 7,500.
#'
#' @template args-dots
#'
#' @template returns
#'
#' @examples
#' # Returns the seven codes beginning with `A15`
#' icd10api(icd_code = "A15")
#'
#' # Returns the first five codes
#' # associated with tuberculosis
#' icd10api(term = "tuber", field = "both", limit = 5)
#'
#' # Returns the two codes
#' # associated with pleurisy
#' icd10api(term = "pleurisy", field = "both")
#'
#' # If you're searching for codes beginning
#' # with a certain letter, you must set the
#' # `field` param to `"code"` or it will
#' # search for terms as well:
#'
#' # Returns terms containing the letter "Z"
#' icd10api(icd_code = "z", limit = 5)
#'
#' # Returns codes beginning with "Z"
#' icd10api(icd_code = "z", field = "code", limit = 5)
#'
#' # Will error if results exceed API limit
#' try(icd10api(icd_code = "I", field = "both"))
#'
#' @autoglobal
#'
#' @export
icd10api <- function(icd_code = NULL,
                     term     = NULL,
                     field    = c("code", "both"),
                     limit    = 500L,
                     ...) {

  stopifnot(
    "Both `icd_code` and `term` cannot be NULL" = all(
      !is.null(
        c(icd_code, term)
        )
      )
    )

  args <- stringr::str_c(
    c(code = icd_code,
      term = term),
    collapse = ",")

  field <- match.arg(field)

  switch(
    field,
    "code" = field <- "code",
    "both" = field <- "code,name",
    stop('`field` must be either `"code"` or `"both"`')
  )

  results <- httr2::request(
    "https://clinicaltables.nlm.nih.gov/api/icd10cm/v3/search?") |>
    httr2::req_url_query(terms   = args,
                         maxList = 500,
                         count   = limit,
                         offset  = 0L,
                         sf      = field) |>
    httr2::req_perform() |>
    httr2::resp_body_json(check_type     = TRUE,
                          simplifyVector = TRUE,
                          simplifyMatrix = TRUE)

  count <- results[[1]]

  if (count > 7500L) {
    cli::cli_abort(c(
      "Your search returned {.strong {.val {count}}} results.",
      "x" = "The NLM ICD-10-CM API limit is {.strong {.emph 7,500}}."))
  }

  if (limit < 500L | count <= 500) {

    results <- results[[4]] |>
      as.data.frame() |>
      dplyr::rename(icd_code = V1,
                    icd_description = V2) |>
      dplyr::tibble()
  }

  if (limit == 500L && count > 500L) {

    pgs <- 1:round(count / 500) * 500

    res2 <- purrr::map(pgs, \(x) .multiple_request(
      offset = x,
      args = args,
      field = field
      )
    ) |>
      purrr::list_rbind()

    results <- results[[4]] |>
      as.data.frame() |>
      dplyr::rename(icd_code        = V1,
                    icd_description = V2) |>
      dplyr::tibble() |>
      vctrs::vec_rbind(res2)
  }
  return(results)
}


#' @autoglobal
#' @noRd
.multiple_request <- function(offset, args, field) {

  results <- httr2::request(
    "https://clinicaltables.nlm.nih.gov/api/icd10cm/v3/search?") |>
    httr2::req_url_query(terms   = args,
                         maxList = 500,
                         count   = 500,
                         offset  = offset,
                         sf      = field) |>
    httr2::req_perform() |>
    httr2::resp_body_json(check_type     = TRUE,
                          simplifyVector = TRUE,
                          simplifyMatrix = TRUE)


  if (vctrs::vec_is_empty(results[[4]])) {return(NULL)}

  results[[4]] |>
    as.data.frame() |>
    dplyr::rename(icd_code        = V1,
                  icd_description = V2) |>
    dplyr::tibble()

}


