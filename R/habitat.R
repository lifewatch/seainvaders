#' Creates a habitat suitability raster based on Mahalanobis distance.
#'
#' @param occ Occurrence sf object.
#' @param temp Temperature raster.
#' @param sal Salinity raster.
#' @export
make_suitability <- function(occ, temp, sal) {
  t <- extract_raster(temp, occ$longitude, occ$latitude)
  s <- extract_raster(sal, occ$longitude, occ$latitude)
  m <- cbind(t, s)
  m <- m[complete.cases(m),]
  v <- var(m)
  cm <- colMeans(m)
  maha <- function(tp, sp) {
    return(mahalanobis(c(tp, sp), cm, v))
  }
  res <- overlay(temp, sal, fun = Vectorize(maha))
  res <- 1 - (res / maxValue(res))
  names(res) <- "suitability"
  return(res)
}

#' Creates a habitat suitability raster based on Mahalanobis distance.
#'
#' @param occ Occurrence sf object.
#' @param temp Temperature raster.
#' @param sal Salinity raster.
#' @export
plot_niche <- function(occ, temp, sal) {
  t <- extract_raster(temp, occ$longitude, occ$latitude)
  s <- extract_raster(sal, occ$longitude, occ$latitude)
  m <- cbind(t, s)
  plot(m)
}
