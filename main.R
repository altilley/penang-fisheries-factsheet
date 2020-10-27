# Prepare workspace -------------------------------------------------------

library(magrittr)
library(drake)

# load functions
f <- lapply(list.files(path = here::here("R"), full.names = TRUE,
                       include.dirs = TRUE, pattern = "*.R"), source)

# Variables
raw_data_object_uri <- "gs://penang-catch/penang-fisheries-landings.xlsx"

# Authenticate
googleCloudStorageR::gcs_auth(json_file = "auth/penang-catch-auth.json")

# Plan analysis ------------------------------------------------------------

get_data <- drake_plan(
  data_download = target(
    command = googleCloudStorageR::gcs_get_object(
      object_name = raw_data_object_uri,
      saveToDisk = file_out("data/raw/penang-fisheries-landings.xlsx"),
      overwrite = TRUE)),
  landings = readxl::read_excel(
    path = file_in("data/raw/penang-fisheries-landings.xlsx"),
    sheet = "catch"),
  species = readxl::read_excel(
    path = file_in("data/raw/penang-fisheries-landings.xlsx"),
    sheet = "species"),
)

clean_data <- drake_plan(
  landings_clean = clean_landings(landings),
  species_clean = clean_species(species),
  tracks = clean_points(file_in("data/raw/points.csv")),
  boats = clean_boats(file_in("data/raw/boats.csv")),
)



test_plan <- drake_plan(
  trip_id_tests = test_trip_id(landings_clean),
  # rec_id_tests = test_rec_id(landings),
  imei_tests = test_imei(landings_clean),
  # species_tests = test_species(landings_clean, species_clean),
  weight_tests = test_weight(landings_clean),
  price_tests = test_price(landings_clean),
)

report_plan <- drake_plan(
  readme = target(
    command = rmarkdown::render(knitr_in("README.Rmd"))
  )
)

full_plan <- rbind(get_data,
                   clean_data,
                   test_plan,
                   report_plan)

# Execute plan ------------------------------------------------------------

if (!is.null(full_plan)) {
  make(full_plan)
}
