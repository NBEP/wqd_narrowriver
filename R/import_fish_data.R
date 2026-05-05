#' Format fish data
#'
#' @description `format_fish()` formats fish data for use in `wqdashboard`.
#'
#' @param .data Input dataframe. Must have two columns: Year, Quantity.
#' @param fish_spp String. Name of fish species.
#' @param fish_unit String. Unit.
#' @param site_id String. Site ID.
#'
#' @return Updated dataframe.
#'
#' @noRd
format_fish <- function(.data, fish_spp, fish_unit, site_id) {
  # Initial formatting/checks
  dat <- .data |>
    wqformat::col_to_numeric("Year", silent = FALSE) |>
    wqformat::col_to_numeric("Quantity", silent = FALSE)

  chk <- dat$Year < 1900 | dat$Year > format(Sys.Date(), "%Y")
  if (any(chk)) {
    bad_rws <- which(chk)
    stop("Invalid year. Check rows: ", paste(bad_rws, collapse = ", "))
  }

  if (is.na(fish_unit) | is.null(fish_unit)) {
    fish_unit <- "None"
  }

  # Proceed
  dat <- .data |>
    dplyr::rename("Date" = "Year", "Result" = "Quantity") |>
    dplyr::mutate("Site_ID" = !!site_id) |>
    dplyr::mutate("Activity_Type" = "Field Msr/Obs") |>
    dplyr::mutate(
      "Date" = as.Date(
        paste0(.data$Date, "-12-31")
      )
    ) |>
    dplyr::mutate("Parameter" = !!fish_spp) |>
    dplyr::mutate("Result_Unit" = fish_unit) |>
    dplyr::mutate("Depth_Category" = "Surface")

  blank_rows <- c(
    "Depth", "Depth_Unit", "Lower_Detection_Limit",
    "Upper_Detection_Limit", "Detection_Limit_Unit", "Qualifier"
  )
  blank_rows <- setdiff(blank_rows, colnames(dat))
  dat[blank_rows] <- NA

  dat
}
