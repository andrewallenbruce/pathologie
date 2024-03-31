library(tidyverse)
library(rvest)
library(icd10us)

# base <- "https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Publications/ICD10CM/2024"
#
# x <- session(base) |>
#   session_follow_link("2024") |>
#   html_elements("a") |>
#   html_attr("href")
#
# x[2:8]

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
    order       = order_number,
    code        = icd10cm_code,
    valid       = valid_billing_code,
    description = icd10cm_long_description) |>
  mutate(valid  = as.integer(valid)) |>
  mutate(code   = add_dot(code)) |>
  case_chapter_icd10(code) |>
  select(order,
         valid,
         code,
         description,
         chapter_name = chapter)

chapters <- icd10us::icd10cm_chapters |>
  select(chapter_no = chapter_num,
         chapter_abb = chapter_abbr,
         chapter_name = chapter_desc,
         chapter_start = code_start,
         chapter_end = code_end) |>
  mutate(chapter_range = paste0(chapter_start, " - ", chapter_end),
         chapter_no = as.integer(chapter_no)) |>
  select(-chapter_start, -chapter_end)


icd_join <- icd10 |>
  left_join(chapters, by = join_by(chapter_name))

icd_chapter_order <- icd_join |>
  group_by(chapter_no, chapter_name) |>
  summarise(chapter_start = min(order)) |>
  ungroup() |>
  mutate(chapter_end = lead(chapter_start) - 1,
         chapter_end = if_else(chapter_start == 97292, 97296, chapter_end),
         chapter_end = as.integer(chapter_end)
  )

icd_section_order <- icd_join |>
  select(order,
         valid,
         code,
         section_name = description) |>
  filter(valid == 0, stringr::str_length(code) == 3L) |>
  mutate(section_start = order,
         section_end = lead(order) - 1,
         section_end = if_else(order == 97295, 97296, section_end),
         section_end = as.integer(section_end))

sec_end <- icd10 |>
  filter(order %in% icd_section_order$section_end) |>
  select(section_end = order, code_end = code)

icd_section_order <- icd_section_order |>
  left_join(sec_end) |>
  select(-section_start, -section_end) |>
  mutate(section_start = code,
         section_range = if_else(
           section_start != code_end, paste0(
             section_start, " - ", code_end), section_start)) |>
  select(order, valid, code, section_name, section_range)

icd_nest <- icd_join |>
  left_join(icd_section_order) |>
  fill(section_name, section_range) |>
  # left_join(icd_chapter_order) |>
  nest(section_codes = c(order, valid, code, description)) |>
  # mutate(chapter_sections = dplyr::n_distinct(section_name), .by = chapter_name) |>
  nest(chapter_sections = c(section_name, section_range, section_codes)) |>
  select(ch = chapter_no,
         abb = chapter_abb,
         chapter_name,
         chapter_range,
         # chapter_start,
         # chapter_end,
         chapter_sections)

fs::file_delete(fs::path("data-raw", c("icd10cm-order-2024.txt", "2024_Code_Descriptions.zip")))

# icd_nest <- northstar::icd10cm()

# Update Pin
board <- pins::board_folder(here::here("inst/extdata/pins"))

board |>
  pins::pin_write(icd_nest,
                  name = "icd10cm",
                  title = "2024 ICD-10-CM",
                  description = "2024 ICD-10-CM Codes and Descriptions",
                  type = "qs")

board |> pins::write_board_manifest()
