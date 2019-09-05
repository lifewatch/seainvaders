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

#' Make species ranking table.
#'
#' @export
make_ranking <- function(rasters, lon, lat) {
  ss <- wrims_subset()$aphiaid
  result <- data.frame(wrims_subset(), d = NA, hs = NA)
  for (i in 1:length(ss)) {
    aphiaid <- ss[i]
    d <- extract(rasters[[aphiaid]]$d, cbind(lon, lat))
    hs <- extract(rasters[[aphiaid]]$hs, cbind(lon, lat))
    result$d[i] <- d
    result$hs[i] <- hs
  }
  result$score <- result$hs + ifelse(result$d > 1000000 & result$d < 3100000, 0.1, 0) + ifelse(result$d < 1000000, -0.3, 0)
  #ggplot(data = result) + geom_point(aes(x = hs, y = d, size = score))
  return(result %>% arrange(desc(score)))
}
