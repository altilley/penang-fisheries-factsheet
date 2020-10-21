# Clean the landings data frame
clean_landings <- function(landings){
  landings %>%
    dplyr::select(-rec_id, -common_eng) %>%
    dplyr::mutate(date = as.Date(date, tz = "Asia/Kuala_Lumpur")) %>%
    dplyr::mutate(imei = as.integer(imei),
                  imei = dplyr::if_else(
                    condition = imei == 0,
                    true = NA_integer_,
                    false = imei)) %>%
    dplyr::mutate(common_malay = tolower(common_malay)) %>%
    dplyr::rename(weight_kg = kg,
                  total_price = total_revenue)
}

# Clean the species data frame
clean_species <- function(species){
  species %>%
    dplyr::mutate(common_malay = tolower(common_malay))
}
