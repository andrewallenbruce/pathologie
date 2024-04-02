test_that("validation checks works", {

  # x <- c("H00.019", "D50.1", "C4A.70", "Z20.818", "11646", "E8015")

  expect_equal(is_valid_icd("H00.019"), "H00.019")

})
