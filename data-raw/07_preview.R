#' Preview Website
#'
#' @description Running this script will launch the website on your local
#' computer and let you preview how it looks.
#'
#' @noRd

# CODE - DO NOT EDIT BELOW THIS LINE -------------------------------------------
# Set options
options(golem.app.prod = FALSE)
options(shiny.port = httpuv::randomPort())

# Detach all loaded packages and clean environment
golem::detach_all_attached()
rm(list = ls(all.names = TRUE))

# Document and reload package
golem::document_and_reload()

# Run application
run_app()
