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
    sheet = "landings"),
  species = readxl::read_excel(
    path = file_in("data/raw/penang-fisheries-landings.xlsx"),
    sheet = "species"),
  prices = readxl::read_excel(
    path = file_in("data/raw/penang-fisheries-landings.xlsx"),
    sheet = "pvt_catch kg"),
)

test_plan <- drake_plan(
  trip_id_tests = test_trip_id(landings),
  rec_id_tests = test_rec_id(landings),
)

full_plan <- rbind(get_data,
                   test_plan)

# Execute plan ------------------------------------------------------------

if (!is.null(full_plan)) {
  make(full_plan)
}
