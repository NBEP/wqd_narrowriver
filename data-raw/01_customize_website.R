#' Add About Page
#'
#' @description WQdasbhoard includes several customizable pages, including the
#' "About" and "Download" pages. Before running this script, go to the folder
#' `inst/app/www` and update the following files: `About.qmd`, `Download.qmd`,
#' and `_brand.yml`
#'
#' `About.qmd` lets you update the "About" page and `Download.qmd` lets you
#' update the "Download" page. Both of these files can be updated in visual
#' mode. Images and tables are supported. `Download.qmd` contains some light
#' code to dynamically update the organization name and latest year updated;
#' feel free to replace these elements with static text.
#'
#' If you make any changes to `About.qmd` or `Download.qmd`, you must rerun this
#' script.
#'
#' DO NOT CHANGE THE HEADER FOR EITHER QMD FILE. (format, engine, brand, params)
#'
#' `_brand.yml` lets you set the appearance of the site. At minimum, you MUST
#' change `meta` > `name` to the name of your organization. `meta` > `title`
#' sets the title for the website. The remaining elements set the color palette
#' and font for the website. You can find more information on what `_brand.yml`
#' is and what it does here:
#' https://posit-dev.github.io/brand-yml/
#'
#' To run this script, use `CTRL` + `SHIFT` + `ENTER`
#'
#' @noRd

# CODE - DO NOT EDIT BELOW THIS LINE -------------------------------------------
library(quarto)

# Render About page
quarto::quarto_render("inst/app/www/About.qmd")
qmd_about <- importwqd::embed_quarto("inst/app/www/About.html")
usethis::use_data(qmd_about, overwrite = TRUE)

# Render Download page
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

rm(list = ls(all.names = TRUE))

# Go to next page
rstudioapi::navigateToFile("data-raw/02_add_shapefiles.R")
