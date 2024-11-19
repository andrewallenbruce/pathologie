#' Mount [pins][pins::pins-package] board
#'
#' @param source `<chr>` string; whether source is `"local"` or `"remote"`
#'
#' @returns `<pins_board_folder>` if `source = "local"` or `<pins_board_url>`
#'    if `source = "remote"`
#'
#' @keywords internal
#'
#' @autoglobal
#'
#' @export
mount_board <- function(source = c("local", "remote")) {

  source <- match.arg(source)

  switch(
    source,
    local  = pins::board_folder(fs::path_package("extdata/pins", package = "pathologie")),
    remote = pins::board_url(fuimus::gh_raw(
      "andrewallenbruce/pathologie/master/inst/extdata/pins/"
    ))
  )
}

#' gt Theme
#'
#' @param tbl `<gt_tbl>` object
#'
#' @param lbl `<lgl>` hide column labels; default is `TRUE`
#'
#' @param tablign `<chr>` table stub alignment; default is `"center"`
#'
#' @param tabsize `<int>` table stub font size in pixels; default is `16`
#'
#' @param tabwt `<chr>` table stub font weight; default is `"normal"`
#'
#' @template returns
#'
#' @keywords internal
#'
#' @autoglobal
#'
#' @export
gt_style <- function(tbl,
                     lbl     = TRUE,
                     tablign = "center",
                     tabsize = 16,
                     tabwt   = "normal") {
  tbl |>
    # gt::fmt_markdown() |>
    gt::cols_align("left") |>
    gt::opt_table_font(
      font      = gt::google_font(name = "Atkinson Hyperlegible")) |>
    gt::tab_style(
      style     = gt::cell_text(
        align   = tablign,
        size    = gt::px(tabsize),
        font    = gt::google_font(name = "Fira Code"),
        weight  = tabwt),
      locations = gt::cells_stub()) |>
    gt::tab_options(
      column_labels.hidden       = lbl,
      table.font.size            = gt::px(16),
      table.width                = gt::pct(100),
      heading.align              = "left",
      heading.title.font.size    = gt::px(16),
      heading.subtitle.font.size = gt::px(16),
      source_notes.font.size     = gt::px(16),
      row_group.as_column        = TRUE,
      row_group.font.size        = gt::px(24)
    )
}

#' Example data set
#'
#' @template returns
#'
#' @keywords internal
#'
#' @autoglobal
#'
#' @export
ex_data <- function() {
  pins::pin_read(pathologie::mount_board(), "exdata")
}
