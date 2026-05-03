#' Add/Update Categorical Results - OPTIONAL
#'
#' @description THIS STEP IS OPTIONAL. Run this script to add or update
#' categorical and/or download only result data. This data will ONLY be
#' available for download, and will not display on the maps, report card, or
#' graph tabs.
#'
#' Categorical result data must be saved as a csv file in the `data-raw`
#' folder. The following formats are supported:
#'
#' * WQdashboard
#' * WQX
#' * MassWateR
#' * Maine DEP (ME_DEP)
#' * RI DEM (RI_DEM)
#' * RI Watershed Watch (RI_WW)
#' * Blackstone River Coalition (MA_BRC)
#' * Friends of Casco Bay (ME_FOCB)
#'
#' To use a custom, unsupported format, set `in_format` to "custom" and update
#' the following files:
#' * `data-raw/custom_format/colnames_results.csv`
#' * `data-raw/custom_format/varnames_activity.csv`
#' * `data-raw/custom_format/varnames_parameters.csv`
#' * `data-raw/custom_format/varnames_qualifiers.csv`
#' * `data-raw/custom_format/varnames_units.csv`
#'
#' If you would like to use the official WQdashboard format, a template can be
#' found here:
#' `inst/extdata/template_results.csv`
#'
#' @param results_csv Name of csv file containing result data.
#' @param in_format Input format. Accepted formats: WQdashboard, WQX, MassWateR,
#' RI_DEM, RI_WW, MA_BRC, ME_DEP, ME_FOCB, Custom
#'
#' @param date_format Format used for Date column. List of abbreviations:
#'
#' * B - Full month name (August)
#' * b - Abbreviated month name (Aug)
#' * m - Month, numeric (8)
#' * d - Day of the month
#' * y - Year without century (26)
#' * Y - Year with century (2026)
#'
#' * H - Hour
#' * m - Minute
#' * S - Second
#' * p - AM/PM
#' * z - Timezone
#'
#' @param timezone Timezone.
#'
#' @param overwrite_existing If `TRUE`, replaces old result data with new data.
#' If `FALSE`, combines old and new result data.
#' @param update_citation If `TRUE`, will update the "year_updated" variable
#' for `Download.qmd`
#'
#' @noRd

results_csv <- "categorical_results.csv"
in_format <- "ri_ww"

date_format <- "m/d/Y"
timezone <- Sys.timezone()

overwrite_existing <- FALSE
update_citation <- TRUE

# CODE - DO NOT EDIT BELOW THIS LINE -------------------------------------------
devtools::load_all()
library("readr")

# Import, format data ----
df_raw <- readr::read_csv(
  paste0("data-raw/", results_csv),
  show_col_types = FALSE,
  guess_max = Inf
)

if (in_format == "custom") {
  df_colnames <- readr::read_csv(
    "data-raw/custom_format/colnames_results.csv",
    show_col_types = FALSE
  )
  df_param <- readr::read_csv(
    "data-raw/custom_format/varnames_parameters.csv",
    show_col_types = FALSE
  )
  df_unit <- readr::read_csv(
    "data-raw/custom_format/varnames_units.csv",
    show_col_types = FALSE
  )
  df_qual <- readr::read_csv(
    "data-raw/custom_format/varnames_qualifiers.csv",
    show_col_types = FALSE
  )
  df_activity <- readr::read_csv(
    "data-raw/custom_format/varnames_activity.csv",
    show_col_types = FALSE
  )

  df_raw <- df_raw |>
    importwqd::prep_results(
      df_colnames, df_param, df_unit, df_qual, df_activity
    ) |>
    wqformat::format_wqd_results(date_format, TRUE)
} else if (in_format == "wqdashboard") {
  df_raw <- df_raw |>
    wqformat::format_wqd_results(date_format, TRUE)
} else {
  df_raw <- df_raw |>
    wqformat::format_results(
      in_format, "wqdashboard", date_format, timezone,
      drop_extra_col = FALSE
    )
}

# QAQC data ----
df_qaqc <- importwqd::qaqc_cat_results(df_raw, df_sites_all)

# Combine datasets (if overwrite_existing is FALSE)
if (!overwrite_existing && exists("df_data_extra")) {
  df_qaqc <- dplyr::bind_rows(df_data_extra, df_qaqc) |>
    unique()
}

# Upload df_data_extra ----
df_data_extra <- df_qaqc
usethis::use_data(df_data_extra, overwrite = TRUE)
message("Saved df_data_extra")

# Update download tab ----
if (update_citation) {
  brand <- brand.yml::read_brand_yml("inst/app/www/_brand.yml")

  quarto::quarto_render(
    "inst/app/www/Download.qmd",
    execute_params = list(
      org_name = brand$meta$name$full,
      year_updated = format(Sys.time(), "%Y")
    )
  )
  qmd_download <- importwqd::embed_quarto("inst/app/www/Download.html")
  usethis::use_data(qmd_download, overwrite = TRUE)
}

# Set sidebar variables ----
message("Setting sidebar dropdown lists")
varlist <- importwqd::sidebar_var(df_sites, df_data, df_score, df_data_extra)

usethis::use_data(varlist, internal = TRUE, overwrite = TRUE)
message("Done")

rm(list = ls(all.names = TRUE))

# Go to next page
rstudioapi::navigateToFile("data-raw/08_preview.R")
