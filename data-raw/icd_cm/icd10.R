library(tidyverse)
library(rvest)
library(icd10us)


# download_icd10 <- function() {
#
#   base <- "https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Publications/ICD10CM/"
#   x <- rvest::session(base) |>
#     rvest::session_follow_link("2024") |>
#     rvest::html_elements("a") |>
#     rvest::html_attr("href")
#
#   x[2:8]
#
# }

## Load 2024 version
icdcodes <- "https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Publications/ICD10CM/2024/icd10cm-CodesDescriptions-2024.zip"

download.file(url      = icdcodes,
              destfile = "data-raw/2024_Code_Descriptions.zip",
              method   = "libcurl")


unzip(
  "data-raw/2024_Code_Descriptions.zip",
  files     = c("icd10cm-order-2024.txt"),
  exdir     = "data-raw",
  junkpaths = TRUE
)



icd10cm <- read_fwf(
  "data-raw/icd10cm-order-2024.txt",
  fwf_cols(
    order_number              = c(1,5),
    icd10cm_code              = c(7,13),
    valid_billing_code        = c(14,15),
    icd10cm_short_description = c(17,77),
    icd10cm_long_description  = c(78,500)),
  col_types = c("i", "c", "l", "c", "c"))

icd10 <- icd10cm |>
  select(
    order = order_number,
    icd_code = icd10cm_code,
    valid = valid_billing_code,
    icd_description = icd10cm_long_description) |>
  mutate(valid = as.integer(valid)) |>
  mutate(icd_code = add_dot(icd_code)) |>
  case_chapter_icd10(icd_code) |>
  select(order,
         valid,
         icd_code,
         icd_description,
         icd_ch_name = chapter)

chapters <- icd10us::icd10cm_chapters |>
  select(icd_ch_no = chapter_num,
         icd_ch_abb = chapter_abbr,
         icd_ch_name = chapter_desc,
         chapter_start = code_start,
         chapter_end = code_end) |>
  mutate(icd_ch_range = paste0(chapter_start, " - ", chapter_end),
         icd_ch_no = as.integer(icd_ch_no)) |>
  select(-chapter_start, -chapter_end)


icd_join <- icd10 |>
  left_join(chapters, by = join_by(icd_ch_name))

icd_chapter_order <- icd_join |>
  group_by(icd_ch_no, icd_ch_name) |>
  summarise(chapter_start = min(order)) |>
  ungroup() |>
  mutate(chapter_end = lead(chapter_start) - 1,
         chapter_end = if_else(chapter_start == 97292, 97296, chapter_end),
         chapter_end = as.integer(chapter_end)
  )

icd_section_order <- icd_join |>
  select(order,
         valid,
         icd_code,
         icd_section = icd_description) |>
  filter(valid == 0, stringr::str_length(icd_code) == 3L) |>
  mutate(section_start = order,
         section_end = lead(order) - 1,
         section_end = if_else(order == 97295, 97296, section_end),
         section_end = as.integer(section_end))

sec_end <- icd10 |>
  filter(order %in% icd_section_order$section_end) |>
  select(section_end = order, code_end = icd_code)

icd_section_order <- icd_section_order |>
  left_join(sec_end) |>
  select(-section_start, -section_end) |>
  mutate(section_start = icd_code,
         section_range = if_else(
           section_start != code_end, paste0(
             section_start, " - ", code_end), section_start)) |>
  select(order, valid, icd_code, icd_sec_name = icd_section, icd_sec_range = section_range)

icd_nest <- icd_join |>
  left_join(icd_section_order) |>
  fill(icd_sec_name, icd_sec_range) |>
  nest(icd_sec_code = c(order, valid, icd_code, icd_description)) |>
  nest(icd_ch_sec = c(icd_sec_name, icd_sec_range, icd_sec_code)) |>
  select(icd_ch_no,
         icd_ch_abb,
         icd_ch_name,
         icd_ch_range,
         icd_ch_sec)

fs::file_delete(fs::path("data-raw", c("icd10cm-order-2024.txt", "2024_Code_Descriptions.zip")))

# Update Pin
board <- pins::board_folder(here::here("inst/extdata/pins"))

board |>
  pins::pin_write(
    icd_nest,
    name = "icd10cm",
    title = "2024 ICD-10-CM",
    description = "2024 ICD-10-CM Codes and Descriptions",
    type = "qs")

board |> pins::write_board_manifest()
