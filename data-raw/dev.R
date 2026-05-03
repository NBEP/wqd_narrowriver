#' Dev
#'
#' @description This script generates the files in the folder "custom_format".
#' It DOES NOT need to be run again unless those files are lost or modified and
#' you want to generate fresh files. IT WILL OVERWRITE EXISTING FILES IN
#' "custom_format".
#'
#' @noRd

# CODE -------------------------------------------------------------------------
devtools::load_all()
library("readr")

# Set temp wd ----
wd <- getwd()
setwd(paste0(getwd(), "/data-raw"))
if (!dir.exists("custom_format")) {
  dir.create("custom_format")
}
setwd(paste0(getwd(), "/custom_format"))

# Add varname templates to data-raw ----
df_param <- wqformat:::varnames_parameters |>
  dplyr::filter(!is.na(.data$wqdashboard)) |>
  dplyr::select("wqdashboard") |>
  dplyr::mutate(
    "wqdashboard" = dplyr::if_else(
      grepl("|", .data$wqdashboard, fixed = TRUE),
      stringr::str_split_i(.data$wqdashboard, "\\|", 1),
      .data$wqdashboard
    )
  ) |>
  dplyr::mutate("Custom" = NA) |>
  dplyr::arrange(.data$wqdashboard)

readr::write_csv(df_param, "varnames_parameters.csv", na = "")

df_units <- wqformat:::varnames_units |>
  dplyr::filter(!is.na(.data$wqdashboard)) |>
  dplyr::select("wqdashboard") |>
  dplyr::mutate(
    "wqdashboard" = dplyr::if_else(
      grepl("|", .data$wqdashboard, fixed = TRUE),
      stringr::str_split_i(.data$wqdashboard, "\\|", 1),
      .data$wqdashboard
    )
  ) |>
  dplyr::mutate("Custom" = NA) |>
  dplyr::arrange(.data$wqdashboard)

readr::write_csv(df_units, "varnames_units.csv", na = "")

df_activity <- wqformat:::varnames_activity |>
  dplyr::filter(!is.na(.data$wqdashboard)) |>
  dplyr::select("wqdashboard") |>
  dplyr::mutate(
    "wqdashboard" = dplyr::if_else(
      grepl("|", .data$wqdashboard, fixed = TRUE),
      stringr::str_split_i(.data$wqdashboard, "\\|", 1),
      .data$wqdashboard
    )
  ) |>
  dplyr::mutate("Custom" = NA) |>
  dplyr::arrange(.data$wqdashboard)

readr::write_csv(df_activity, "varnames_activity.csv", na = "")

df_qual <- system.file(
  "extdata",
  "varnames_qualifiers.csv",
  package = "wqformat"
)

df_qual <- readr::read_csv(df_qual, show_col_types = FALSE) |>
  dplyr::filter(!is.na(.data$wqdashboard)) |>
  dplyr::mutate("Custom" = NA) |>
  dplyr::select("wqdashboard", "Custom", "Description") |>
  dplyr::arrange(.data$wqdashboard)

readr::write_csv(df_qual, "varnames_qualifiers.csv", na = "")

# Add state, EPA thresholds to inst/extdata/ ----
setwd(wd)
thresholds <- importwqd:::dat_thresholds

readr::write_csv(thresholds, "inst/extdata/default_thresholds.csv", na = "")

# Add null data -----
if (!exists("df_sites_all")) {
  df_sites_all <- data.frame(matrix(ncol = 7, nrow = 0))
  colnames(df_sites_all) <- c(
    "Site_ID", "Site_Name", "Latitude", "Longitude", "Max_Surface_Depth_m",
    "Max_Midwater_Depth_m", "Max_Depth_m"
  )
  usethis::use_data(df_sites_all)
}

if (!exists("df_sites")) {
  df_sites <- data.frame(matrix(ncol = 4, nrow = 0))
  colnames(df_sites) <- c(
    "Site_ID", "Site_Name", "Latitude", "Longitude"
  )
  usethis::use_data(df_sites)
}

if (!exists("df_data_all")) {
  df_data_all <- data.frame(matrix(ncol = 13, nrow = 0))
  colnames(df_data_all) <- c(
    "Site_ID", "Activity_Type", "Date", "Depth", "Depth_Unit", "Depth_Category",
    "Parameter", "Result", "Result_Unit", "Lower_Detection_Limit",
    "Upper_Detection_Limit", "Detection_Limit_Unit", "Qualifier"
  )
  usethis::use_data(df_data_all)
}

if (!exists("df_data")) {
  df_data <- data.frame(matrix(ncol = 14, nrow = 0))
  colnames(df_data) <- c(
    "Site_ID", "Site_Name", "Date", "Year", "Parameter", "Result", "Unit",
    "Depth", "Min", "Max", "Excellent", "Best", "Month", "Description"
  )
  usethis::use_data(df_data)
}

if (!exists("df_score")) {
  df_score <- data.frame(matrix(ncol = 14, nrow = 0))
  colnames(df_score) <- c(
    "Year", "Site_Name", "Site_ID", "Depth", "Parameter", "Unit", "score_typ",
    "score_num", "score_str", "Longitude", "Latitude", "popup_loc",
    "popup_score", "alt"
  )
  usethis::use_data(df_score)
}

if (!exists("varlist")) {
  varlist <- list(
    state = NULL,
    town = NULL,
    watershed = NULL,
    site_id = "1",
    site_name = "site1",
    loc_choices = "blank",
    loc_tab = "blank",
    param = "parameter",
    param_score = "parameter",
    param_cat = NULL,
    depth = NULL,
    year = 2026,
    month = "March"
  )
  usethis::use_data(varlist)
}

# Clean up ----
rm(list = ls())
