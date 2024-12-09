#' Match ICD-10-CM Codes to Chapter Labels
#'
#' @param x `<chr>` vector of ICD-10-CM codes
#'
#' @returns `<chr>` vector of ICD-10-CM chapter labels
#'
#' @examples
#' codes <- c("F50.8", "G40.311", "Q96.8",
#'            "R45.4", "E06.3", "H00.019",
#'            "D50.1", "C4A.70", "Z20.818")
#'
#' icd_code_to_chapter(codes)
#'
#' data.frame(code = codes,
#'            chapter = icd_code_to_chapter(codes))
#'
#' @autoglobal
#'
#' @export
icd_code_to_chapter <- function(x) {

  data.table::fcase(
    rdetect(x, "^[AB]"), "Certain infectious and parasitic diseases",
    rdetect(x, "^(C|D[0-4])"), "Neoplasms",
    rdetect(x, "^D[5-8]"), "Diseases of the blood and blood-forming organs and certain disorders involving the immune mechanism",
    rdetect(x, "^E"), "Endocrine, nutritional and metabolic diseases",
    rdetect(x, "^F"), "Mental, behavioral and neurodevelopmental disorders",
    rdetect(x, "^G"), "Diseases of the nervous system",
    rdetect(x, "^H[0-5]"), "Diseases of the eye and adnexa",
    rdetect(x, "^H[6-9]"), "Diseases of the ear and mastoid process",
    rdetect(x, "^I"), "Diseases of the circulatory system",
    rdetect(x, "^J"), "Diseases of the respiratory system",
    rdetect(x, "^K"), "Diseases of the digestive system",
    rdetect(x, "^L"), "Diseases of the skin and subcutaneous tissue",
    rdetect(x, "^M"), "Diseases of the musculoskeletal system and connective tissue",
    rdetect(x, "^N"), "Diseases of the genitourinary system",
    rdetect(x, "^O"), "Pregnancy, childbirth and the puerperium",
    rdetect(x, "^P"), "Certain conditions originating in the perinatal period",
    rdetect(x, "^Q"), "Congenital malformations, deformations and chromosomal abnormalities",
    rdetect(x, "^R"), "Symptoms, signs and abnormal clinical and laboratory findings, not elsewhere classified",
    rdetect(x, "^[ST]"), "Injury, poisoning and certain other consequences of external causes",
    rdetect(x, "^[VWXY]"), "External causes of morbidity",
    rdetect(x, "^Z"), "Factors influencing health status and contact with health services",
    rdetect(x, "^U"), "Codes for special purposes",
    default = NA_character_)

}

#' Insert period into an ICD-10-CM code
#'
#' Inserts period into an ICD-10-CM code in between the 3rd and 4th
#' characters, if not present or if the code is longer than 3 characters
#'
#' @param x vector of ICD-10-CM codes
#'
#' @returns vector of ICD-10-CM codes with period inserted
#'
#' @examples
#' insert_period("F320")
#'
#' # Not inserted if code is only 3 characters
#' insert_period("F32")
#'
#' @autoglobal
#'
#' @export
insert_period <- \(x) iifelse(rnchar(x) > 3, gsub("^(.{3})(.*)$", paste0("\\1.\\2"), x), x)

#' Remove period from ICD-10-CM code
#'
#' Removes period from the ICD-10 code if it exists
#'
#' @param x A valid ICD-10 code with a dot
#'
#' @returns A valid ICD-10 code without a dot included
#'
#' @examples
#' remove_period("F32.0")
#'
#' remove_period("F32")
#'
#' @autoglobal
#'
#' @export
remove_period <- \(x) rremove(x, ".", fix = TRUE)

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

