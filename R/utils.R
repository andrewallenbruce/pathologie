#' Search in data frame
#'
#' @template args-df
#'
#' @param dfcol `<sym>` unquoted column to search, in the form of `df$col`
#'
#' @param search `<chr>` vector of strings to search for in `df$col`
#'
#' @template returns
#'
#' @keywords internal
#'
#' @autoglobal
#'
#' @export
search_in <- function(df, dfcol, search) {
  vctrs::vec_slice(
    df,
    vctrs::vec_in(
      dfcol,
      collapse::funique(
        search
      )
    )
  )
}

#' Return GitHub raw url
#'
#' @noRd
gh_raw <- function(x) {
  paste0("https://raw.githubusercontent.com/", x)
}

#' Mount [pins][pins::pins-package] board
#'
#' @param `<chr>` string; whether source is `"local"` or `"remote"`
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
    remote = pins::board_url(gh_raw(
      "andrewallenbruce/pathologie/master/inst/extdata/pins/"
    ))
  )
}

#' Pivot data frame to long format for easy printing
#'
#' @template args-df
#'
#' @param cols `<syms>` vector of bare column name to pivot, default is [dplyr::everything()]
#'
#' @template returns
#'
#' @keywords internal
#'
#' @autoglobal
#'
#' @export
display_long <- function(df,
                         cols = dplyr::everything()) {

  df |> dplyr::mutate(
    dplyr::across(
      dplyr::everything(), as.character)) |>
    tidyr::pivot_longer({{ cols }})
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

#' gt Marks
#'
#' @param tbl `<gt_tbl>` object
#'
#' @param cols `<syms>` vector of bare column names, e.g. `c(mdc, drg)`
#'
#' @template returns
#'
#' @keywords internal
#'
#' @autoglobal
#'
#' @export
gt_marks <- function(tbl, cols) {

  tbl |>
    gt::text_case_when(
      x == TRUE ~ gt::html(
        fontawesome::fa("check",
                        prefer_type = "solid",
                        fill = "red")),
      x == FALSE ~ gt::html(
        fontawesome::fa("xmark",
                        prefer_type = "solid",
                        fill = "white")),
      .default = NA,
      .locations = gt::cells_body(
        columns = {{ cols }}))
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
