library(ncdf4)
library(raster)

#' Fetches temperature data.
#'
#' @export
get_temperature <- function(bbox = c(-40, 50, 20, 90), time = "2015-03-15T00:00:00Z") {
  return(get_raster("TEMP", bbox, time))
}

#' Fetches salinity data.
#'
#' @export
get_salinity <- function(bbox = c(-40, 50, 20, 90), time = "2015-03-15T00:00:00Z") {
  return(get_raster("PSAL", bbox, time))
}

#' Reads bio-oracle temperature data.
#'
#' @export
get_biooracle_temperature <- function(bbox = c(-40, 50, 20, 90)) {
  return(get_biooracle("Temperature", bbox))
}

#' Reads bio-oracle salinity data.
#'
#' @export
get_biooracle_salinity <- function(bbox = c(-40, 50, 20, 90)) {
  return(get_biooracle("Salinity", bbox))
}

get_biooracle <- function(var, bbox) {
  file <- paste0(path.package("findingdemo"), "/biooracle/Present.Surface.", var, ".Mean.tif")
  r <- raster(file)
  r <- crop(r, bbox)
  return(r)
}

get_raster <- function(var, bbox, time) {
  url <- paste0("http://62.94.122.131/thredds/ncss/fmrc/CORIOLIS-GLOBAL-CORA05.0-OBS-", var, "/CORIOLIS-GLOBAL-CORA05.0-OBS-", var, "_best.ncd?var=", var, "&north=", bbox[4], "&west=", bbox[1], "&east=", bbox[2], "&south=", bbox[3], "&disableLLSubset=on&disableProjSubset=on&horizStride=1&time=", time, "&timeStride=1&vertCoord=&accept=netcdf")
  temp <- tempfile()
  download.file(url, temp)
  nc_data <- nc_open(temp)
  br <- brick(temp)

  # this is problematic as latitude is irregular
  extent(br) <- bbox
  # attempt at fix below but not working
  #plot(br[[1]])
  #lon <- ncvar_get(nc_data, "longitude")
  #lat <- ncvar_get(nc_data, "latitude")
  #df <- as.data.frame(br[[1]], xy=T)
  #df$x <- df$x + 0.5
  #df$y <- df$y + 0.5
  #df$x <- lon[df$x]
  #df$y <- lat[df$y]
  #r <- rasterFromXYZ(df)

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
