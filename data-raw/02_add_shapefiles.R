#' Add Shapefiles - OPTIONAL
#'
#' @description THIS STEP IS OPTIONAL. If you would like to add custom watershed
#' or river layers to the interactive map, use this script to upload shapefiles.
#' Shapefiles must use the WGS 1984 projection.
#'
#' Save shapefiles to folder `data-raw` before running this script. Use
#' `CTRL` + `SHIFT` + `ENTER` to run the script.
#'
#' @param watershed_shp Name of the watershed shapefile. Shapefile must be a
#' polygon layer.
#' @param watershed_name_col Field name for watershed shapefile. This field will
#' be used to label each polygon.
#' @param river_shp Name of river shapefile. Shapefile must be a polyline layer.
#' @param river_name_col Field name for river shapefile. This field will be
#' used to label each polyline.
#'
#' @noRd

# SHAPEFILE - Watershed Boundaries
watershed_shp <- NA
watershed_name_col <- "Field"

# SHAPEFILE - Rivers
river_shp <- NA
river_name_col <- "Field"

# CODE - DO NOT EDIT BELOW THIS LINE -------------------------------------------
devtools::load_all()

# Import shapefiles ----
if (!is.null(watershed_shp) && !is.na(watershed_shp)) {
  shp_watershed <- importwqd::qaqc_shp(
    watershed_shp,
    watershed_name_col,
    path = "data-raw"
  )

  usethis::use_data(shp_watershed, overwrite = TRUE)
}

if (!is.null(river_shp) && !is.na(river_shp)) {
  shp_river <- importwqd::qaqc_shp(
    river_shp,
    river_name_col,
    path = "data-raw"
  )

  usethis::use_data(shp_river, overwrite = TRUE)
}

rm(list = ls(all.names = TRUE))

# Go to next page
rstudioapi::navigateToFile("data-raw/03_add_sites.R")
