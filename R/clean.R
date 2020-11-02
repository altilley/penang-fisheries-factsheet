# Clean the landings data frame
clean_landings <- function(landings, report_dates = NULL){
  landings_clean <- landings %>%
    dplyr::select(-rec_id, -common_eng) %>%
    dplyr::mutate(date = as.Date(date, tz = "Asia/Kuala_Lumpur")) %>%
    dplyr::mutate(imei = as.integer(imei),
                  imei = dplyr::if_else(
                    condition = imei == 0,
                    true = NA_integer_,
                    false = imei),
                  imei = as.character(imei)) %>%
    dplyr::mutate(common_malay = tolower(common_malay)) %>%
    dplyr::rename(weight_kg = kg,
                  total_price = total_revenue)

  if(!is.null(report_dates)){
    landings_clean %>%
      dplyr::filter(date >= report_dates[1],
                    date <= report_dates[2])
  }

  landings_clean
}

# Clean the species data frame
clean_species <- function(species){
  species %>%
    dplyr::mutate(common_malay = tolower(common_malay))
}

clean_points <- function(path, report_dates = NULL){
  points_clean <- path %>%
    readr::read_csv() %>%
    janitor::clean_names()

  if(!is.null(report_dates)){
    points_clean %<>%
      dplyr::filter(date >= report_dates[1],
                    dare <= report_dates[2])
  }

  points_clean
}

clean_boats <- function(path){
  path %>%
    readr::read_csv2() %>%
    janitor::clean_names() %>%
    dplyr::mutate(imei_long = as.character(imei)) %>%
    dplyr::mutate_if(is.character, ~ dplyr::if_else(. == "--", NA_character_, .))
}

process_trips <- function(landings_clean, points, boats){
  landings_trips <- landings_clean %>%
    dplyr::group_by(trip_id) %>%
    dplyr::summarise(date = dplyr::first(date),
                     fisher = dplyr::first(fisher),
                     imei = dplyr::first(imei),
                     weight_kg = sum(weight_kg, na.rm = TRUE),
                     total_price = sum(total_price, na.rm = TRUE)) %>%
    dplyr::rename(trip_id_landing = trip_id) %>%
    dplyr::mutate(imei_short = stringr::str_sub(imei, -7))

  one_landing_per_day <- landings_trips %>%
    # select largest catch of the day only
    dplyr::group_by(fisher, date) %>%
    dplyr::filter(weight_kg == max(weight_kg)) %>%
    dplyr::ungroup()

  remaining_landings <- landings_trips %>%
    dplyr::group_by(fisher, date) %>%
    dplyr::filter(weight_kg != max(weight_kg)) %>%
    dplyr::ungroup()

  boat_info <- boats %>%
    dplyr::mutate(imei_short = stringr::str_sub(imei_long, -7)) %>%
    dplyr::select(boat, imei_short)

  point_trips <- points %>%
    # dplyr::mutate(time = lubridate::with_tz(time, tzone = "Asia/Kuala_Lumpur")) %>%
    dplyr::group_by(trip) %>%
    dplyr::summarise(time_start = min(time),
                     time_end = max(time),
                     boat_name = dplyr::first(boat_name)) %>%
    dplyr::left_join(boat_info, by = c("boat_name" = "boat")) %>%
    dplyr::mutate(date = lubridate::as_date(time_end)) %>%
    dplyr::rename(trip_id_track = trip)

  one_landing_per_day %>%
    dplyr::full_join(point_trips) %>%
    dplyr::bind_rows(remaining_landings) %>%
    dplyr::arrange(date) %>%
    dplyr::mutate(trip_id = 1:dplyr::n()) %>%
    dplyr::group_by(fisher) %>%
    dplyr::mutate(imei_short = dplyr::if_else(!is.na(fisher), dplyr::first(na.omit(imei_short)), imei_short),
                  boat_name = dplyr::if_else(!is.na(fisher), dplyr::first(na.omit(boat_name)), boat_name)) %>%
    dplyr::group_by(imei_short) %>%
    dplyr::mutate(fisher = dplyr::if_else(!is.na(imei_short), dplyr::first(na.omit(fisher)), fisher),
                  fisher = dplyr::if_else(is.na(fisher), boat_name, fisher))

  # points %>%
  #   dplyr::mutate(time = lubridate::with_tz(time, tzone = "Asia/Kuala_Lumpur"),
  #                 hour = lubridate::hour(time)) %>%
  #   ggplot(aes(x = hour)) +
  #   geom_histogram(binwidth = 1)
  #
  # points %>%
  #   # dplyr::filter(boat_name == "Riduan/ PPS 5617") %>%
  #   dplyr::filter(trip == 2423728) %>%
  #   dplyr::group_by(trip) %>%
  #   dplyr::mutate(t = time - min(time),
  #                 t = as.numeric(t),
  #                 t = t / max(t)) %>%
  #   ggplot(aes(x = time, y = speed_m_s, colour = t)) +
  #   geom_line() +
  #   scale_colour_viridis_c(option = "magma") +
  #   theme(legend.position = "none")
}
