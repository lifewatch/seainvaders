library(sf)

#' Fetches occurrences from Eurobis for a given aphiaID
#'
#' @export
get_occurrence <- function(aphiaid = 159559) {

  # list the parts of the wfs url
  base_url   <- 'http://geo.vliz.be/geoserver/ows'
  service    <- '?request=GetFeature&service=WFS&version=1.1.0'
  typeName   <- '&typeName=Dataportal:eurobis'
  viewParams <- '&viewParams=context:0100;'
  paramAphia <- paste0('aphiaid:', aphiaid)
  outFormat   <- '&outputFormat=application/json'

  # compose url
  wfs_url <- paste0(base_url, service, typeName,
                    viewParams,
                    URLencode(paste(paramAphia, sep=';'), reserved = TRUE),
                    outFormat)
  message(wfs_url)

  # retrieve spatial data
  output_sf <- st_read(wfs_url)[,c("aphiaidaccepted", "longitude", "latitude")]

  # return result
  return(output_sf)
}
