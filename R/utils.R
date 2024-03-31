#' Return GitHub raw url
#' @noRd
gh_raw <- function(x) {
  paste0("https://raw.githubusercontent.com/", x)
}

#' Mount [pins][pins::pins-package] board
#' @param source `"local"` or `"remote"`
#' @return `<pins_board_folder>` if `source = "local"` or `<pins_board_url>` if `source = "remote"`
#' @noRd
mount_board <- function(source = c("local", "remote")) {

  source <- match.arg(source)

  switch(
    source,
    local  = pins::board_folder(fs::path_package("extdata/pins", package = "pathologie")),
    remote = pins::board_url(gh_raw(
      "andrewallenbruce/pathologie/master/inst/extdata/pins/"
    ))
  )
}

#' Pivot data frame to long format for easy printing
#' @param df `<data.frame>`
#' @param cols `<chr>` vector of columns to pivot long, default is [dplyr::everything()]
#' @return A [tibble][tibble::tibble-package] of the pivoted data frame.
#' @autoglobal
#' @export
#' @keywords internal
display_long <- function(df, cols = dplyr::everything()) {

  df |> dplyr::mutate(
    dplyr::across(
      dplyr::everything(), as.character)) |>
    tidyr::pivot_longer({{ cols }})
}
