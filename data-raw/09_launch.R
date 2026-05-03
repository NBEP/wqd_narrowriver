#' Launch Website
#'
#' @description Run this script to create or update WQdashboard as a website.
#' If you wish to host your website on shinyapps.io or posit connect, you MUST
#' create an account first.
#'
#' NOTE: If you have added custom thresholds, shapefiles, or categorical data,
#' you may receive a warning message about undocumented variables. This message
#' can be safely ignored, but if you want to stop seeing it, go to `R/data.R`
#' and uncomment the section describing the relevant file(s) by removing the
#' first `#` at the start of each line.
#'
#' @param launch_to Where to upload your website. Options: "shinyapps.io",
#' "posit connect", "shiny server"
#' @param create_docker_file Whether to generate a tar.gz file that can be used
#' to install the app locally.
#'
#' @noRd

launch_to <- "shinyapps.io"
create_docker_file <- FALSE

# CODE - DO NOT EDIT BELOW THIS LINE -------------------------------------------
library("golem")
if (!require(devtools)) {
  install.packages("devtools")
}
library("devtools")
if (!require(rsconnect)) {
  install.packages("rsconnect")
}
library("rsconnect")
if (!require(desc)) {
  install.packages("desc")
}
library("desc")

# Check code
devtools::check()

# Build a local tar.gz that can be installed locally
devtools::build()

# RStudio ----
if (launch_to == "shinyapps.io") {
  golem::add_shinyappsio_file()
} else if (launch_to == "posit connect") {
  golem::add_positconnect_file()
} else if (launch_to == "shiny server") {
  golem::add_shinyserver_file()
}

# Docker ----
if (create_docker_file) {
  golem::add_dockerfile_with_renv()
}

# Deploy to Posit Connect or ShinyApps.io ---
if (launch_to %in% c("shinyapps.io", "posit connect")) {
  rsconnect::deployApp(
    appName = desc::desc_get_field("Package"),
    appTitle = desc::desc_get_field("Title"),
    appFiles = c(
      "R/",
      "inst/",
      "data/",
      "NAMESPACE",
      "DESCRIPTION",
      "app.R"
    ),
    lint = FALSE,
    forceUpdate = TRUE
  )
}
