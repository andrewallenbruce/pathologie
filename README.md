
<!-- README.md is generated from README.Rmd. Please edit that file -->

# pathologie

<!-- badges: start -->
<!-- badges: end -->

The goal of pathologie is to …

## Installation

You can install **pathologie** from [GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("andrewallenbruce/pathologie")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(pathologie)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
```

``` r
icd10cm(code = c("I10", "I15.0")) |> 
  glimpse()
#> Rows: 2
#> Columns: 10
#> $ ch            <int> 9, 9
#> $ abb           <chr> "CARDIO", "CARDIO"
#> $ chapter_name  <chr> "Diseases of the circulatory system", "Diseases of the c…
#> $ chapter_range <chr> "I00 - I99", "I00 - I99"
#> $ section_name  <chr> "Other rheumatic heart diseases", "Secondary hypertensio…
#> $ section_range <chr> "I09 - I10", "I15 - I15.9"
#> $ order         <int> 11397, 11411
#> $ valid         <int> 1, 1
#> $ code          <chr> "I10", "I15.0"
#> $ description   <chr> "Essential (primary) hypertension", "Renovascular hypert…
```

``` r
icd10api(code = "I1")
#> # A tibble: 18 × 2
#>    code   description                                                           
#>    <chr>  <chr>                                                                 
#>  1 I10    Essential (primary) hypertension                                      
#>  2 I11.0  Hypertensive heart disease with heart failure                         
#>  3 I11.9  Hypertensive heart disease without heart failure                      
#>  4 I12.0  Hypertensive chronic kidney disease with stage 5 chronic kidney disea…
#>  5 I12.9  Hypertensive chronic kidney disease with stage 1 through stage 4 chro…
#>  6 I13.0  Hypertensive heart and chronic kidney disease with heart failure and …
#>  7 I13.10 Hypertensive heart and chronic kidney disease without heart failure, …
#>  8 I13.11 Hypertensive heart and chronic kidney disease without heart failure, …
#>  9 I13.2  Hypertensive heart and chronic kidney disease with heart failure and …
#> 10 I15.0  Renovascular hypertension                                             
#> 11 I15.1  Hypertension secondary to other renal disorders                       
#> 12 I15.2  Hypertension secondary to endocrine disorders                         
#> 13 I15.8  Other secondary hypertension                                          
#> 14 I15.9  Secondary hypertension, unspecified                                   
#> 15 I16.0  Hypertensive urgency                                                  
#> 16 I16.1  Hypertensive emergency                                                
#> 17 I16.9  Hypertensive crisis, unspecified                                      
#> 18 I1A.0  Resistant hypertension
```
