library(dplyr)
library(raster)
library(gdistance)
library(maptools)
library(rgdal)

#' Create a distance raster.
#'
#' @export
#' @examples
#' eur_x <- c(0, -20, -20)
#' eur_y <- c(30, 30, 50)
#' occ <- cbind(eur_x, eur_y)
#' map1 = get_distance_raster(occ = occ, res = 300)
#' plot(map1)
create_distance_raster = function(occ, res, bbox = c(-45, 70, 26, 90)) {
  occ <- as.matrix(as.data.frame(occ)[,c("longitude", "latitude")])
  ras <- raster(nrow = res, ncol = res)
  data(wrld_simpl)
  world <- wrld_simpl
  eurcrs <- crs("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs ")
  eurshp <- spTransform(world, eurcrs)
  e <- extent(bbox)
  crs(ras) <- crs(eurshp)
  extent(ras) <- extent(eurshp)
  eurmask <- rasterize(eurshp, ras)
  d <- crop(eurmask, e)
  eurras <- is.na(d)
  eurras[eurras==0] <- 999
  eurras[eurras==1] <- 1
  tr <- transition(eurras, function(x) 1/mean(x), 8)
  tr = geoCorrection(tr, scl=FALSE)
  sel_feat <- head(occ, 3)
  A <- accCost(tr, sel_feat)
  A <- mask(A, d, inverse=TRUE)
  return(A)
}

