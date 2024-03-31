#' Return GitHub raw url
#' @noRd
gh_raw <- function(x) {
  paste0("https://raw.githubusercontent.com/", x)
}

#' Mount [pins][pins::pins-package] board
#' @param source `"local"` or `"remote"`
#' @return `<pins_board_folder>` or `<pins_board_url>`
#' @noRd
mount_board <- function(source = c("local", "remote")) {

  source <- match.arg(source)

  switch(
    source,
    local  = pins::board_folder(fs::path_package("extdata/pins", package = "pathologie")),
    remote = pins::board_url(gh_raw(
      "andrewallenbruce/northstar/master/inst/extdata/pins/"
    ))
  )
}
