test_trip_id <- function(landings){

  testthat::test_that("trip_id corresponds to a single date", {
    n_trips_with_more_than_one_date <- landings %>%
      dplyr::group_by(trip_id) %>%
      dplyr::summarise(n_dates = dplyr::n_distinct(date)) %>%
      dplyr::filter(n_dates > 1) %>%
      nrow()

    testthat::expect_equal(n_trips_with_more_than_one_date, 0)
  })

  testthat::test_that("trip_id corresponds to a single fisher", {
    n_trips_with_more_than_one_fisher <- landings %>%
      dplyr::group_by(trip_id) %>%
      dplyr::summarise(n_fishers = dplyr::n_distinct(fisher)) %>%
      dplyr::filter(n_fishers > 1) %>%
      nrow()

    testthat::expect_equal(n_trips_with_more_than_one_fisher, 0)
  })

  testthat::test_that("trip_id corresponds to a single imei", {
    n_trips_with_more_than_one_imei <- landings %>%
      dplyr::group_by(trip_id) %>%
      dplyr::summarise(n_imei = dplyr::n_distinct(imei)) %>%
      dplyr::filter(n_imei > 1) %>%
      nrow()

    testthat::expect_equal(n_trips_with_more_than_one_imei, 0)
  })
}

test_rec_id <- function(landings){

  testthat::test_that("rec_id is unique", {
    n_unique_rec_ids <- landings %>%
      dplyr::count(rec_id, sort = TRUE) %>%
      dplyr::filter(n == 1)

    n_rec_ids <- unique(landings$rec_id)

    testthat::expect_equal(n_unique_rec_ids, n_rec_ids)
  })

}
