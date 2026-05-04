#' Add/Update Fish Data
#'
#' @description Run this script to add or update fish data. ONLY INCLUDE
#' NUMERIC RESULTS. Result data must be saved as a csv file in the `data-raw`
#' folder.
#'
#' IMPORTANT. This is a custom script for fish data containing two columns:
#' `Year`, `Quantity`.
#'
#' @param results_csv Name of CSV file containing result data.
#' @param fish_species Fish species.
#' @param site_id Site ID.
#'
#' @param overwrite_existing If `TRUE`, removes old data for `fish_species` and
#' replaces it with new data. If `FALSE`, combines old and new fish data.
#' @param recalculate_score If `TRUE`, recalculates all parameter scores,
#' including for old data. If `FALSE`, does not recalculate old scores.
#' @param update_citation If `TRUE`, will update the "year_updated" variable
#' for `Download.qmd`
#'
#' @noRd

results_csv <- "data.csv"
fish_species <- "River Herring"
site_id <- NA

overwrite_existing <- FALSE
recalculate_score <- FALSE
update_citation <- TRUE

# CODE - DO NOT EDIT BELOW THIS LINE -------------------------------------------
devtools::load_all()
library("readr")

# Import, format data ----
df_raw <- readr::read_csv(
  paste0("data-raw/", results_csv),
  show_col_types = FALSE
) |>
  format_fish(fish_species, site_id)

# QAQC data ----
df_qaqc <- importwqd::qaqc_results(df_raw, df_sites_all)
chk_years <- unique(df_qaqc$Year)

# Combine datasets (if overwrite_existing is FALSE)
if (exists("df_data_all") && nrow(df_data_all) > 0) {
  df_temp <- df_data_all

  if (overwrite_existing) {
    df_temp <- dplyr::filter(df_data_all, .data$Parameter != !!fish_species)
  }

  df_qaqc <- dplyr::bind_rows(df_temp, df_qaqc) |>
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
rstudioapi::navigateToFile("data-raw/07_add_categorical_results.R")
rstudioapi::navigateToFile("data-raw/08_preview.R")
