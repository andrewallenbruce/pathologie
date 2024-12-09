
<!-- README.md is generated from README.Rmd. Please edit that file -->

# pathologie

> Tidy ICD-10-CM Interface

<!-- badges: start -->

![GitHub R package
version](https://img.shields.io/github/r-package/v/andrewallenbruce/pathologie?style=flat-square&logo=R&label=Package&color=%23192a38)
[![CodeFactor](https://www.codefactor.io/repository/github/andrewallenbruce/pathologie/badge)](https://www.codefactor.io/repository/github/andrewallenbruce/pathologie)
[![Code
size](https://img.shields.io/github/languages/code-size/andrewallenbruce/pathologie.svg)](https://github.com/andrewallenbruce/pathologie)
[![Last
commit](https://img.shields.io/github/last-commit/andrewallenbruce/pathologie.svg)](https://github.com/andrewallenbruce/pathologie/commits/main)
[![Codecov test
coverage](https://codecov.io/gh/andrewallenbruce/pathologie/graph/badge.svg)](https://app.codecov.io/gh/andrewallenbruce/pathologie)
[![License:
MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://choosealicense.com/licenses/mit/)
<!-- badges: end -->

## :package: Installation

You can install **pathologie** from [GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("andrewallenbruce/pathologie")
```

## :beginner: Usage

``` r
library(pathologie)
library(dplyr)
```

``` r
icd10cm(icd = c("I15.0")) |> glimpse()
#> Rows: 1
#> Columns: 10
#> $ icd_ch_no       <int> 9
#> $ icd_ch_abb      <chr> "CARDIO"
#> $ icd_ch_name     <chr> "Diseases of the circulatory system"
#> $ icd_ch_range    <chr> "I00 - I99"
#> $ icd_sec_name    <chr> "Secondary hypertension"
#> $ icd_sec_range   <chr> "I15 - I15.9"
#> $ order           <int> 11411
#> $ valid           <int> 1
#> $ icd_code        <chr> "I15.0"
#> $ icd_description <chr> "Renovascular hypertension"
```

## NLM ICD-10-CM API

``` r
icd10api(icd_code = "I1")
#> # A tibble: 18 × 2
#>    icd_code icd_description                                                     
#>    <chr>    <chr>                                                               
#>  1 I10      Essential (primary) hypertension                                    
#>  2 I11.0    Hypertensive heart disease with heart failure                       
#>  3 I11.9    Hypertensive heart disease without heart failure                    
#>  4 I12.0    Hypertensive chronic kidney disease with stage 5 chronic kidney dis…
#>  5 I12.9    Hypertensive chronic kidney disease with stage 1 through stage 4 ch…
#>  6 I13.0    Hypertensive heart and chronic kidney disease with heart failure an…
#>  7 I13.10   Hypertensive heart and chronic kidney disease without heart failure…
#>  8 I13.11   Hypertensive heart and chronic kidney disease without heart failure…
#>  9 I13.2    Hypertensive heart and chronic kidney disease with heart failure an…
#> 10 I15.0    Renovascular hypertension                                           
#> 11 I15.1    Hypertension secondary to other renal disorders                     
#> 12 I15.2    Hypertension secondary to endocrine disorders                       
#> 13 I15.8    Other secondary hypertension                                        
#> 14 I15.9    Secondary hypertension, unspecified                                 
#> 15 I16.0    Hypertensive urgency                                                
#> 16 I16.1    Hypertensive emergency                                              
#> 17 I16.9    Hypertensive crisis, unspecified                                    
#> 18 I1A.0    Resistant hypertension
```

## Conflict Edit Rules

``` r
ex_data() |>
  reframe(dob = date_of_birth,
          dos = date_of_service,
          icd_code,
          age = years_floor(dob, dos)) |>
  right_join(search_edits(group = "Age"), 
             by = join_by(icd_code)) |>
  mutate(
    conflict = apply_age_edits(icd_conflict_rule, age),
    dob = NULL,
    dos = NULL,
    icd_conflict_group = NULL
  )
#> # A tibble: 3,780 × 5
#>    icd_code   age icd_description                     icd_conflict_rule conflict
#>    <chr>    <dbl> <chr>                               <chr>             <chr>   
#>  1 Z00.00       7 Encntr for general adult medical e… Adult (Ages 15-1… Age Con…
#>  2 F53.0       33 Postpartum depression               Maternity (Ages … <NA>    
#>  3 F64.2       16 Gender identity disorder of childh… Pediatric (Ages … <NA>    
#>  4 Z91.82      37 Personal history of military deplo… Adult (Ages 15-1… <NA>    
#>  5 O90.6       30 Postpartum mood disturbance         Maternity (Ages … <NA>    
#>  6 Z00.00       9 Encntr for general adult medical e… Adult (Ages 15-1… Age Con…
#>  7 F64.2       12 Gender identity disorder of childh… Pediatric (Ages … <NA>    
#>  8 F53.0       30 Postpartum depression               Maternity (Ages … <NA>    
#>  9 F53.0       22 Postpartum depression               Maternity (Ages … <NA>    
#> 10 F53.0       29 Postpartum depression               Maternity (Ages … <NA>    
#> # ℹ 3,770 more rows
```

------------------------------------------------------------------------

## :balance_scale: Code of Conduct

Please note that the **`pathologie`** project is released with a
[Contributor Code of
Conduct](https://andrewallenbruce.github.io/pathologie/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

## :classical_building: Governance

This project is primarily maintained by [Andrew
Bruce](https://github.com/andrewallenbruce). Other authors may
occasionally assist with some of these duties.
