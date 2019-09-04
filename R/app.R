#' Launch shiny app.
#'
#' @export
launch_app <- function() {
  shiny::runApp(appDir = system.file("application"))
}
