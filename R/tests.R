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

test_imei <- function(landings){

  testthat::test_that("imei is used for a single fisher", {
    n_imeis_with_more_than_one_fisher <- landings %>%
      dplyr::filter(imei != 0) %>%
      dplyr::group_by(imei) %>%
      dplyr::summarise(n_fisher = dplyr::n_distinct(fisher)) %>%
      dplyr::filter(n_fisher > 1) %>%
      nrow()

    testthat::expect_equal(n_imeis_with_more_than_one_fisher, 0)
  })
}

test_species <- function(landings_clean, species_clean){

  testthat::test_that("landed species are in the species table", {
    landed_species <- landings_clean$species %>% unique()
    registered_species <- species_clean$species %>% unique()

    not_identified_species <- landed_species[!landed_species %in% registered_species]

    n_not_identified_species <- length(not_identified_species)
    testthat::expect_equal(n_not_identified_species, 0)
  })

  testthat::test_that("there is a single entry per species per trip", {

    n_trips_repeated_species <- landings %>%
      dplyr::count(trip_id, species, sort = T) %>%
      dplyr::filter(n > 1) %>%
      nrow()

    testthat::expect_equal(n_trips_repeated_species, 0)

  })
}

test_weight <- function(landings){

  testthat::test_that("weight values make sense", {
    weights_larger_than_zero <- landings %$%
      weight_kg %>%
      magrittr::is_weakly_greater_than(., 0) %>%
      all()

    weights_under_a_tonne <- landings %$%
      weight_kg %>%
      magrittr::is_weakly_less_than(., 1000) %>%
      all()

    testthat::expect_true(weights_larger_than_zero)
    testthat::expect_true(weights_under_a_tonne)
  })
}

test_price <- function(landings){

  testthat::test_that("weight values make sense", {
    price_larger_than_zero <- landings %>%
      dplyr::filter(!is.na(price_kg)) %$%
      price_kg %>%
      magrittr::is_weakly_greater_than(., 0) %>%
      all()

    weights_under_1000 <- landings %>%
      dplyr::filter(!is.na(price_kg)) %$%
      price_kg %>%
      magrittr::is_weakly_less_than(., 1000) %>%
      all()

    testthat::expect_true(price_larger_than_zero)
    testthat::expect_true(weights_under_1000)
  })
}
