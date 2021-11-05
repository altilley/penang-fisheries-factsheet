library(magrittr)
library(drake)

# load functions
f <- lapply(list.files(path = here::here("R"), full.names = TRUE,
                       include.dirs = TRUE, pattern = "*.R"), source)

# Download points
retrieve_pds_data(
  path = "data/raw/points2.csv",
  type = "points",
  start_date = "2018-01-01",
  end_date = "2021-12-01"
)
