FROM rocker/geospatial:4.0.3

# Extra R packages
RUN install2.r drake here janitor skimr googleCloudStorageR bigrquery brms cowplot ggdist

# Rstudio interface preferences
COPY rstudio-prefs.json /home/rstudio/.config/rstudio/rstudio-prefs.json
