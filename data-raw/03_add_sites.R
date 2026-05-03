#' Upload site metadata
#'
#' @description Run this script to upload site metadata. Site metadata must be
#' saved as a csv file in the `data-raw` folder. The following formats are
#' supported:
#'
#' * WQdashboard
#' * WQX
#' * MassWateR
#' * RI Watershed Watch (RI_WW)
#' * Blackstone River Coaltiion (MA_BRC)
#' * Friends of Casco Bay (ME_FOCB)
#'
#' To use a custom, unsupported format, set `in_format` to "custom" and update
#' this file:
#' `data-raw/custom_format/colnames_sites.csv`
#'
#' If you would like to use the official WQdashboard format, a template can be
#' found here:
#' `inst/extdata/template_sites.csv`
#'
#' @param sites_csv Name of csv file containing site metadata.
#' @param in_format Input format. Options: WQdashboard, WQX, MassWateR, RI_WW,
#' MA_BRC, ME_FOCB, Custom
#' @param default_state State name or abbreviation. Blank values in column
#' "State" will be updated to this value. Set to `NA` to leave blanks as-is.
#'
#' @noRd

sites_csv <- "sites.csv"
in_format <- "WQdashboard"
default_state <- NA

# CODE - DO NOT EDIT BELOW THIS LINE -------------------------------------------
devtools::load_all()
library("readr")

# Import data
df_raw <- readr::read_csv(
  paste0("data-raw/", sites_csv),
  show_col_types = FALSE
)

# Process data
if (tolower(in_format) == "custom") {
  message("Reformatting data...")
  df_colnames <- readr::read_csv(
    "data-raw/custom_format/colnames_sites.csv",
    show_col_types = FALSE
  )

  df_raw <- importwqd::prep_sites(df_raw, df_colnames)
} else if (tolower(in_format) != "wqdashboard") {
  df_raw <- wqformat::format_sites(
    df_raw,
    in_format,
    "wqdashboard",
    drop_extra_col = FALSE
  )
}

df_sites_all <- importwqd::qaqc_sites(df_raw, default_state)
usethis::use_data(df_sites_all, overwrite = TRUE)

df_sites <- importwqd::format_sites(df_sites_all)
usethis::use_data(df_sites, overwrite = TRUE)
message("Done")

rm(list = ls(all.names = TRUE))

# Go to next page
rstudioapi::navigateToFile("data-raw/04_add_thresholds.R")
