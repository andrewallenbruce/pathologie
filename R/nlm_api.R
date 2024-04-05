#' National Library of Medicine's ICD-10-CM API
#'
#' @description [icd10api()] allows you to search the National Library of
#'    Medicine's ICD-10-CM API by code or associated term.
#'
#' @details ICD-10-CM (International Classification of Diseases, 10th Revision,
#' Clinical Modification) is a medical coding system for classifying
#' diagnoses and reasons for visits in U.S. health care settings.
#'
#' ## Links
#'  * [NIH NLM Clinical Table Service ICD-10-CM API](https://clinicaltables.nlm.nih.gov/apidoc/icd10cm/v3/doc.html)
#'  * [Learn more about ICD-10-CM.](http://www.cdc.gov/nchs/icd/icd10cm.htm)
#'
#' @note Current Version: ICD-10-CM **2024**
#'
#' @source National Library of Medicine/National Institute of Health
#'
#' @param code `<chr>` ICD-10-CM code
#'
#' @param term `<chr>` Associated term describing an ICD-10 code
#'
#' @param field `<chr>` `code` or `both`; default is `both`
#'
#' @param limit `<int>` API limit, defaults to 500
#'
#' @template args-dots
#'
#' @template returns
#'
#' @examples
#' # Returns the seven codes
#' # beginning with "A15"
#' icd10api(code = "A15")
#'
#' # Returns the first five codes
#' # associated with tuberculosis
#' icd10api(term = "tuber", limit = 5)
#'
#' # Returns the two codes
#' # associated with pleurisy
#' icd10api(term = "pleurisy")
#'
#' # If you're searching for codes beginning
#' # with a certain letter, you must set the
#' # `field` param to `"code"` or it will
#' # search for terms as well:
#'
#' # Returns terms containing the letter "Z"
#' icd10api(code = "z", limit = 5)
#'
#' # Returns codes beginning with "Z"
#' icd10api(code = "z", field = "code", limit = 5)
#'
#' @autoglobal
#'
#' @export
icd10api <- function(code  = NULL,
                     term  = NULL,
                     field = c("both", "code"),
                     limit = 500L,
                     ...) {

  stopifnot(
    "Both `code` and `term` cannot be NULL" = all(
      !is.null(
        c(code, term)
        )
      )
    )

  args <- stringr::str_c(
    c(code = code,
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

  if (limit < 500L | count <= 500) {

    results <- results[[4]] |>
      as.data.frame() |>
      dplyr::rename(code        = V1,
                    description = V2) |>
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
      dplyr::rename(code        = V1,
                    description = V2) |>
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
    dplyr::rename(code        = V1,
                  description = V2) |>
    dplyr::tibble()

}


