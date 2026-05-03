test_that("format_fish works", {
  df_in <- data.frame(
    Year = c(1981, 1982, 1983, 1984, 1985, 1986, 1987, 1988, 1989, 1990),
    Quantity = c(
      64297, 88194, 68919, 17337, 16492, 48011, 50893, 74324, 89577, 11009
    )
  )

  df_out <- data.frame(
    Date = as.Date(
      c(
        "1981-12-31", "1982-12-31", "1983-12-31", "1984-12-31", "1985-12-31",
        "1986-12-31", "1987-12-31", "1988-12-31", "1989-12-31", "1990-12-31"
      )
    ),
    Result = c(
      64297, 88194, 68919, 17337, 16492, 48011, 50893, 74324, 89577, 11009
    ),
    Site_ID = "foo",
    Activity_Type = "Field Msr/Obs",
    Parameter = "River Herring",
    Result_Unit = "None",
    Depth = NA,
    Depth_Unit = NA,
    Depth_Category = NA,
    Lower_Detection_Limit = NA,
    Upper_Detection_Limit = NA,
    Detection_Limit_Unit = NA,
    Qualifier = NA
  )

  # Basic check - function works
  expect_equal(
    format_fish(df_in, "River Herring", "foo"),
    df_out
  )

  # Advanced check - data can be processed
  df_sites <- data.frame(
    Site_ID = "foo"
  )

  df_qaqc <- df_out
  df_qaqc$Year <- c(1981, 1982, 1983, 1984, 1985, 1986, 1987, 1988, 1989, 1990)
  df_qaqc$Depth_Unit <- "m"
  df_qaqc[c("Depth", "Lower_Detection_Limit", "Upper_Detection_Limit")] <-
    NA_integer_

  expect_equal(
    suppressMessages(
      importwqd::qaqc_results(df_out, df_sites)
    ),
    df_qaqc
  )

  # Test errors
  df_in$Year[1] <- 5000
  df_in$Year[4] <- 26

  expect_error(
    format_fish(df_in, "River Herring", "foo"),
    regexp = "Invalid year. Check rows: 1, 4"
  )
})
