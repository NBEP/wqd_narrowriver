#' Upload thresholds - OPTIONAL
#'
#' @description THIS STEP IS OPTIONAL. Thresholds are used to designate whether
#' paramater values should be classified as excellent, good, fair, or poor.
#' WQdashboard includes several thresholds based on state or federal
#' regulations, however some thresholds are highly site specific. To this end,
#' WQdashboard allows users to submit site, group, or state specific thresholds.
#'
#' If you wish to include custom thresholds, fill out the template
#' `inst/extdata/template_thresholds.csv` and save the resulting CSV file to the
#' `data-raw` folder. (For your convenience, this template has already been
#' copied to the `data-raw` folder and saved as `thresholds.csv`)
#'
#' Here is how the file should be filled out:
#'
#' * `State`, `Group`, `Site_ID`: These columns determine which site(s) the
#' threshold applies to. Each row may specify `Group` OR `Site_ID` but not both.
#' If all three columns are blank, the threshold will be applied to all sites.
#'
#' * `Depth_Category`: OPTIONAL. If you wan the paramater to apply to a specific
#' depth category, specify that here. Values: Surface, Midwater, Near Bottom,
#' Bottom
#'
#' * `Parameter`, `Unit`: Parameter, unit.
#'
#' * `Calculation`: How the annual value should be calculated. Acceptable
#' values: minimum, maximum, average, median, geometric mean
#'
#' * `Threshold_Min`, `Threshold_Max`: The minimum and maximum acceptable
#' values. Must enter value for at least one column.
#'
#' * `Excellent`, `Good`, `Fair`: The threshold values for the excellent/good,
#' good/fair, and fair/poor boundaries respectively. Either leave all three
#' columns blank or fill all three of them out.
#'
#' @param skip_step Set to `TRUE` to skip this step and go to the next file.
#' Set to `FALSE` if you would like to add custom thresholds.
#' @param threshold_csv Name of csv file containing threshold metadata.
#' @param in_format Format used for parameters and units. Accepted formats:
#'
#' * WQdashboard
#' * WQX
#' * MassWateR
#' * RI_DEM (Rhode Island DEM)
#' * RI_WW (RI Watershed Watch)
#' * MA_BRC (Blackstone River Coalition)
#' * ME_DEP (Maine DEP)
#' * ME_FOCB (Friends of Casco Bay)
#'
#' To use a custom format, set `in_format` to "custom" and update the following
#' files:
#' * `data-raw/custom_format/varnames_parameters.csv`
#' * `data-raw/custom_format/varnames_units.csv`
#'
#' @noRd

skip_step <- TRUE
threshold_csv <- "thresholds.csv"
in_format <- "ri_ww"

# CODE - DO NOT EDIT BELOW THIS LINE -------------------------------------------
devtools::load_all()
library("readr")

if (!skip_step) {
  message("Uploading thresholds")
  df_raw <- readr::read_csv(
    paste0("data-raw/", threshold_csv),
    show_col_types = FALSE
  )

  if (nrow(df_raw) == 0) {
    stop("Empty dataframe, no thresholds found")
  }

  if (in_format == "custom") {
    df_param <- readr::read_csv(
      "data-raw/custom_format/varnames_parameters.csv",
      show_col_types = FALSE
    )
    df_unit <- readr::read_csv(
      "data-raw/custom_format/varnames_units.csv",
      show_col_types = FALSE
    )

    df_raw <- importwqd::prep_thresholds(df_raw, df_param, df_unit)

    in_format <- "wqdashboard"
  }

  # QAQC data, save to inst/extdata
  custom_thresholds <- importwqd::qaqc_thresholds(df_raw, in_format)
  message("Exporting thresholds to inst/extdata/custom_thresholds.csv")
  readr::write_csv(custom_thresholds, "inst/extdata/custom_thresholds.csv")

  # Format data, save to data
  df_thresholds <- importwqd::format_thresholds(custom_thresholds)
  usethis::use_data(df_thresholds, overwrite = TRUE)
  message("Done")
}

rm(list = ls(all.names = TRUE))

# Go to next page
rstudioapi::navigateToFile("data-raw/05_add_results.R")
