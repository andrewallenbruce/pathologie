
<!-- README.md is generated from README.Rmd. Please edit that file -->

# pathologie

> Tidy ICD-10-CM Interface

<!-- badges: start -->
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
icd10cm(icd = c("I10", "I15.0")) |> 
  glimpse()
#> Rows: 2
#> Columns: 10
#> $ icd_ch_no       <int> 9, 9
#> $ icd_ch_abb      <chr> "CARDIO", "CARDIO"
#> $ icd_ch_name     <chr> "Diseases of the circulatory system", "Diseases of the…
#> $ icd_ch_range    <chr> "I00 - I99", "I00 - I99"
#> $ icd_sec_name    <chr> "Other rheumatic heart diseases", "Secondary hypertens…
#> $ icd_sec_range   <chr> "I09 - I10", "I15 - I15.9"
#> $ order           <int> 11397, 11411
#> $ valid           <int> 1, 1
#> $ icd_code        <chr> "I10", "I15.0"
#> $ icd_description <chr> "Essential (primary) hypertension", "Renovascular hype…
```

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
