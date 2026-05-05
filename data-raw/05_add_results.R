#' Add/Update Result Data
#'
#' @description Run this script to add or update result data. ONLY INCLUDE
#' NUMERIC RESULTS. Result data must be saved as a csv file in the `data-raw`
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
#' @param results_csv Name of CSV file containing result data.
#' @param in_format Input format. Accepted formats: WQdashboard, WQX, MassWateR,
#' RI_DEM, RI_WW, MA_BRC, ME_DEP, ME_FOCB, Custom
#'
#' @param date_format Format used for "Date" column. List of abbreviations:
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
#' @param recalculate_score If `TRUE`, recalculates all parameter scores,
#' including for old data. If `FALSE`, does not recalculate old scores.
#' @param update_citation If `TRUE`, will update the "year_updated" variable
#' for `Download.qmd`
#'
#' @noRd

results_csv <- "results_2024.csv"
in_format <- "ri_ww"
date_format <- "m/d/Y"
timezone <- Sys.timezone()

overwrite_existing <- FALSE
recalculate_score <- FALSE
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
    wqformat::format_wqd_results(date_format)
} else if (in_format == "wqdashboard") {
  df_raw <- wqformat::format_wqd_results(df_raw, date_format)
} else {
  df_raw <- df_raw |>
    wqformat::format_results(
      in_format, "wqdashboard", date_format, timezone,
      drop_extra_col = FALSE
    )
}

# QAQC data ----
df_qaqc <- importwqd::qaqc_results(df_raw, df_sites_all)
chk_years <- unique(df_qaqc$Year)

# Combine datasets (if overwrite_existing is FALSE)
if (!overwrite_existing && exists("df_data_all") && nrow(df_data_all) > 0) {
  df_qaqc <- dplyr::bind_rows(df_data_all, df_qaqc) |>
    unique() |>
    wqformat::standardize_units(
      "Parameter",
      "Result",
      "Result_Unit",
      warn_only = FALSE
    ) |>
    wqformat::standardize_units_across(
      "Result_Unit",
      "Detection_Limit_Unit",
      c("Lower_Detection_Limit", "Upper_Detection_Limit"),
      warn_only = FALSE
    ) |>
    unique()
}

if (nrow(df_qaqc) > 250000) {
  warning(
    "Large dataset. Website may experience performance issues.",
    call. = FALSE
  )
}

# Upload df_data_all
df_data_all <- df_qaqc
usethis::use_data(df_data_all, overwrite = TRUE)
message("Saved df_data_all")

# Format data ----
df_thresh <- NULL
if (exists("df_thresholds")) {
  df_thresh <- df_thresholds
}

df_temp <- importwqd::format_results(df_data_all, df_sites_all, df_thresh)

df_data <- df_temp |>
  dplyr::select(!c("Calculation", "Good", "Fair"))

usethis::use_data(df_data, overwrite = TRUE)
message("Saved df_data")

# Calculate scores ----
chk <- !overwrite_existing & !recalculate_score & exists("df_score") &
  nrow(df_score) > 0
if (chk) {
  df_temp <- dplyr::filter(df_temp, .data$Year %in% chk_years)
  df_old <- dplyr::filter(df_score, !.data$Year %in% chk_years)
}

df_score <- importwqd::score_results(df_temp, df_sites)

if (chk) {
  df_score <- rbind(df_old, df_score)
}

usethis::use_data(df_score, overwrite = TRUE)
message("Saved df_score")

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

if (file.exists("data/df_data_extra.rda")) {
  load("data/df_data_extra.rda")
} else {
  df_data_extra <- NULL
}

varlist <- importwqd::sidebar_var(df_sites, df_data, df_score, df_data_extra)

usethis::use_data(varlist, internal = TRUE, overwrite = TRUE)
message("Done")

rm(list = ls(all.names = TRUE))

# Go to next page
rstudioapi::navigateToFile("data-raw/06_add_fish.R")
rstudioapi::navigateToFile("data-raw/07_add_categorical_results.R")
rstudioapi::navigateToFile("data-raw/08_preview.R")
