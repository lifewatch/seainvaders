library(dplyr)

#' Load all rasters.
#'
#' @export
load_rasters <- function() {
  result <- list()
  ss <- wrims_subset()$aphiaid
  for (aphiaid in ss) {
    hs_file <- paste0(path.package("findingdemo"), "/rasters/hs_", aphiaid)
    d_file <- paste0(path.package("findingdemo"), "/rasters/dist_", aphiaid)
    message(hs_file)
    result[[aphiaid]] <- list(
      d = raster(d_file),
      hs = raster(hs_file)
    )
  }
  return(result)
}

#' Calculates a score from habitat suitability and distance.
#'
#' @export
calculate_score <- function(hs, d) {
  score <- hs + ifelse(d > 1000000 & d < 3100000, 0.1, 0) + ifelse(d < 1000000, -0.3, 0)
  return(score)
}

#' Make species ranking table.
#'
#' @export
make_ranking <- function(rasters, lon, lat) {
  ws <- wrims_subset() %>%
    mutate(image = paste0("<img src=\"", image, "\"/>"))
  ss <- ws$aphiaid
  result <- data.frame(ws, d = NA, hs = NA)
  for (i in 1:length(ss)) {
    aphiaid <- ss[i]
    d <- extract(rasters[[aphiaid]]$d, cbind(lon, lat))
    hs <- extract(rasters[[aphiaid]]$hs, cbind(lon, lat))
    result$d[i] <- d
    result$hs[i] <- hs
  }
  result$score <- calculate_score(result$hs, result$d)
  return(result %>% arrange(desc(score)))
}
