model_landings <- function(trips, base_formula){
  require(brms)

  landing_trips <- dplyr::filter(trips, !is.na(trip_id_landing))

  landing_model_data <- landing_trips %>%
    dplyr::mutate(month = lubridate::month(date),
                  week = lubridate::isoweek(date),
                  wday = lubridate::wday(date, label = T))

  formulas <- list(
    weight = update(base_formula, weight_kg ~  .),
    price = update(base_formula, total_price ~ . ))

  formulas %>%
    purrr::map(function(x){
      brm(x,
          data = landing_model_data,
          family = lognormal,
          iter = 5000,
          save_pars = save_pars(all = TRUE),
          cores = 4)
    })
}


model_vessel <- function(trips, base_formula){
  require(brms)
  tracking_trips <- dplyr::filter(trips, !is.na(trip_id_track))

  vessel_model_data <- tracking_trips %>%
    dplyr::group_by(fisher) %>%
    dplyr::select(date, fisher, trip_id_track) %>%
    tidyr::complete(tidyr::nesting(fisher), date = tidyr::full_seq(date, 1)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(trip_activity = !is.na(trip_id_track),
                  trip_activity = as.numeric(trip_activity)) %>%
    dplyr::mutate(month = lubridate::month(date),
                  week = lubridate::isoweek(date),
                  wday = lubridate::wday(date, label = T))

  brm(update(base_formula, trip_activity ~ . ),
           data = vessel_model_data,
           family = bernoulli,
           iter = 5000,
           save_pars = save_pars(all = TRUE),
           cores = 4)
}

# function(){
#   require(ggplot2)
#   vessel_model_data %>%
#     ggplot(aes(x = date, y = trip_activity, colour = fisher)) +
#     geom_point() +
#     facet_wrap("fisher")
# }
