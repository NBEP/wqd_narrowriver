#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  brand <- brand.yml::read_brand_yml(app_sys("app/www/_brand.yml"))

  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic
    bslib::page_navbar(
      theme = bslib::bs_theme(brand = brand),
      useBusyIndicators(),
      title = h1(brand$meta$title),
      id = "tabset",
      sidebar = bslib::sidebar(
        id = "sbar",
        open = FALSE,
        importwqd::mod_sidebar_ui("sidebar", varlist)
      ),
      bslib::nav_panel(
        "About",
        value = "about",
        class = "bslib-page-dashboard",
        bslib::card(
          uiOutput("qmd_about")
        )
      ),
      bslib::nav_panel("Map",
        value = "map",
        class = "bslib-page-dashboard",
        importwqd::mod_map_ui("map")
      ),
      bslib::nav_panel("Report Card",
        value = "report_card",
        class = "bslib-page-dashboard",
        importwqd::mod_report_ui("report_card")
      ),
      bslib::nav_panel("Graphs",
        value = "graphs",
        class = "bslib-page-dashboard",
        importwqd::mod_graph_ui("graphs", varlist)
      ),
      bslib::nav_panel("Download Data",
        value = "download",
        class = "bslib-page-dashboard",
        bslib::card(
          uiOutput("qmd_download"),
          importwqd::mod_download_ui("download")
        )
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "wqdashboard"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
