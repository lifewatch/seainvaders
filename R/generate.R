#' Generate rasters for species.
#'
#' @export
generate <- function(aphiaid, temp, sal) {
  dir.create(paste0(getwd(), "/inst/rasters"))
  hs_file <- paste0(getwd(), "/inst/rasters/hs_", aphiaid)
  d_file <- paste0(getwd(), "/inst/rasters/dist_", aphiaid)
  occ <- get_occurrence(aphiaid)
  message(hs_file)
  hs <- make_suitability(occ, temp, sal)
  message(d_file)
  d <- create_distance_raster(occ, res = 1000)
  writeRaster(hs, hs_file)
  writeRaster(d, d_file)
}

#' WRiMS subset.
#'
#' @export
wrims_subset <- function() {
  return(c(107451, 129884, 144476, 138963, 876640, 140416, 233889, 160585, 103732, 232032, 106362, 102296, 126916, 421139, 234025))
}

#' Generate all rasters.
#'
#' @export
generate_all <- function() {
  ss <- wrims_subset()
  temp <- get_biooracle_temperature()
  sal <- get_biooracle_salinity()
  for (id in ss) {
    message(id)
    generate(id, temp, sal)
  }
}
