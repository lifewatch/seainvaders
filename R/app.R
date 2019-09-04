library(shiny)

#' Launch shiny app.
#'
#' @export
launch_app <- function() {
  runApp(appDir = system.file("application", package = "findingdemo"))
}
