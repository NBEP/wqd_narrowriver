#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # About tab ----
  output$qmd_about <- renderUI({
    qmd_about
  }) |>
    bindCache(qmd_about)

  # Sidebar module ----
  sidebar_var <- importwqd::mod_sidebar_server(
    "sidebar",
    df_sites = df_sites,
    df_data = df_data,
    df_score = df_score,
    selected_tab = reactive({
      input$tabset
    }),
    selected_site = map_var$site
  )

  observe({
    if (input$tabset == "about") {
      bslib::toggle_sidebar("sbar", open = FALSE)
      golem::invoke_js("hideclass", "sidebar")
      golem::invoke_js("hideclass", "collapse-toggle")
    } else {
      bslib::toggle_sidebar("sbar", open = TRUE)
      golem::invoke_js("showclass", "sidebar")
      golem::invoke_js("showclass", "collapse-toggle")
    }
  }) |>
    bindEvent(input$tabset)

  # Map module ----
  map_bounds <- list(
    lat1 = min(df_sites$Latitude),
    lat2 = max(df_sites$Latitude),
    lng1 = min(df_sites$Longitude),
    lng2 = max(df_sites$Longitude)
  )

  watershed <- NULL
  river <- NULL

  if (exists("shp_watershed")) {
    watershed <- shp_watershed
  }
  if (exists("shp_river")) {
    river <- shp_river
  }

  map_var <- importwqd::mod_map_server(
    "map",
    in_var = sidebar_var,
    map_bounds = map_bounds,
    df_raw = df_score[0, ],
    selected_tab = reactive({
      input$tabset
    }),
    shp_watershed = watershed,
    shp_river = river
  )

  # Report card module ----
  brand <- brand.yml::read_brand_yml(app_sys("app/www/_brand.yml"))
  keep_col <- c(
    "Site_Name", "State", "Town", "Watershed", "Group", "Depth", "Parameter",
    "score_str"
  )

  df_report_raw <- df_score[0, ] |>
    dplyr::select(dplyr::any_of(keep_col))

  importwqd::mod_report_server(
    "report_card",
    in_var = sidebar_var,
    df_raw = df_report_raw,
    org_name = brand$meta$name$full
  )

  # Graph module ----
  importwqd::mod_graph_server("graphs", sidebar_var)

  # Download module -----
  output$qmd_download <- renderUI({
    qmd_download
  }) |>
    bindCache(qmd_download, Sys.Date())

  dat_all <- df_data_all
  if (exists("df_data_extra")) {
    dat_all <- data.table::rbindlist(
      list(df_data_all, df_data_extra),
      use.names = TRUE,
      fill = TRUE,
      ignore.attr = TRUE
    )
  }

  importwqd::mod_download_server(
    "download",
    sites = df_sites_all,
    results = dat_all,
    in_var = sidebar_var
  )

  # Update tabs ----
  observe({
    updateTabsetPanel(inputId = "tabset", selected = "graphs")
  }) |>
    bindEvent(map_var$graph_link())
}
