library(ncdf4)
library(raster)

#' Fetches temperature data.
#'
#' @export
get_temperature <- function(bbox = c(-40, 50, 20, 90), time = "2015-12-15T00:00:00Z") {
  return(get_raster("TEMP", bbox, time))
}

#' Fetches salinity data.
#'
#' @export
get_salinity <- function(bbox = c(-40, 50, 20, 90), time = "2015-12-15T00:00:00Z") {
  return(get_raster("PSAL", bbox, time))
}

get_raster <- function(var, bbox, time) {
  url <- paste0("http://62.94.122.131/thredds/ncss/fmrc/CORIOLIS-GLOBAL-CORA05.0-OBS-", var, "/CORIOLIS-GLOBAL-CORA05.0-OBS-", var, "_best.ncd?var=", var, "&north=", bbox[4], "&west=", bbox[1], "&east=", bbox[2], "&south=", bbox[3], "&disableLLSubset=on&disableProjSubset=on&horizStride=1&time=", time, "&timeStride=1&vertCoord=&accept=netcdf")
  temp <- tempfile()
  download.file(url, temp)
  nc_data <- nc_open(temp)
  br <- brick(temp)
  extent(br) <- bbox
  return(br[[1]])
}

#' Extract raster values for point locations.
#'
#' @export
extract_raster <- function(x, lon = 0, lat = 55) {
  extract.pts <- cbind(lon, lat)
  ext <- extract(x, extract.pts, method = "bilinear")
  return(ext)
}
