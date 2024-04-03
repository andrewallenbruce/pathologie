#' Search in data frame
#' @noRd
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

#' gt Theme
#' @param gt_tbl description
#' @param lbl description
#' @param tablign description
#' @param tabsize description
#' @param tabwt description
#' @return description
#' @export
#' @keywords internal
#' @autoglobal
gt_style <- function(gt_tbl,
                     lbl = TRUE,
                     tablign = "center",
                     tabsize = 16,
                     tabwt = "normal") {
  gt_tbl |>
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
#' @param gt_tbl description
#' @param cols description
#' @return description
#' @export
#' @keywords internal
#' @autoglobal
gt_marks <- function(gt_tbl, cols) {

  gt_tbl |>
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
