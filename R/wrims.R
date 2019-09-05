library(dplyr)
library(rgbif)
library(stringr)

#' Fetches the WRiMS taxa from GBIF.
#'
#' @export
get_wrims_species <- function() {
  res <- name_usage(datasetKey = "0a2eaf0c-5504-4f48-a47f-c94229029dc8", limit = 10000)
  taxa <- res$data %>%
    filter(rank == "SPECIES" & taxonomicStatus == "ACCEPTED") %>%
    mutate(aphiaid = str_extract(taxonID, "[0-9]+"))
  return(taxa)
}

#' WRiMS subset.
#'
#' @export
wrims_subset <- function() {
  file <- paste0(path.package("findingdemo"), "/subset.csv")
  df <- read.csv(file, stringsAsFactors = FALSE)
  return(df)
}
