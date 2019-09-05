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

#' Generate all rasters.
#'
#' @export
generate_all <- function() {
  ss <- wrims_subset()$aphiaid
  temp <- get_biooracle_temperature()
  sal <- get_biooracle_salinity()
  for (id in ss) {
    message(id)
    generate(id, temp, sal)
  }
}
