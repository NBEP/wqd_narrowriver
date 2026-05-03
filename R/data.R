#' Result data (dataframe)
#'
#' Dataframe containing raw result data.
#'
#' @format A dataframe with at least 13 columns:
#'  \describe{
#'    \item{Site_ID}{Site ID}
#'    \item{Activity_Type}{Activity type}
#'    \item{Date}{Date}
#'    \item{Depth}{Sample depth}
#'    \item{Depth_Unit}{Depth unit}
#'    \item{Depth_Category}{Depth category}
#'    \item{Parameter}{Parameter}
#'    \item{Result}{Result value}
#'    \item{Result_Unit}{Result unit}
#'    \item{Lower_Detection_Limit}{Lower detection limit}
#'    \item{Upper_Detection_Limit}{Upper detection limit}
#'    \item{Detection_Limit_Unit}{Detection limit unit}
#'    \item{Qualifier}{Qualifier code}
#'  }
"df_data_all"

#' Filtered result data (dataframe)
#'
#' Dataframe containing filtered result data.
#'
#' @format A dataframe with 15 columns:
#'  \describe{
#'    \item{Site_ID}{Site ID}
#'    \item{Site_Name}{Site name}
#'    \item{Watereshed}{Watershed}
#'    \item{Date}{Date}
#'    \item{Year}{Year}
#'    \item{Parameter}{Parameter}
#'    \item{Result}{Result value}
#'    \item{Unit}{Result unit}
#'    \item{Depth}{Depth category}
#'    \item{Min}{Minimum acceptable value}
#'    \item{Max}{Maximum acceptable value}
#'    \item{Excellent}{Threshold between excellent and good data}
#'    \item{Best}{Whether excellent data is higher or lower than fair data}
#'    \item{Month}{Month}
#'    \item{Description}{Popup text for interactive graph}
#'  }
"df_data"

#' Annual parameter scores (dataframe)
#'
#' Dataframe containing annual parameter scores.
#'
#' @format A dataframe with 15-17 columns:
#'  \describe{
#'    \item{Year}{Year}
#'    \item{Site_Name}{Site name}
#'    \item{Site_ID}{Site ID}
#'    \item{Town}{Town}
#'    \item{Watereshed}{Watershed}
#'    \item{Group}{Site group}
#'    \item{Depth}{Depth category}
#'    \item{Parameter}{Parameter}
#'    \item{Unit}{Result unit}
#'    \item{score_typ}{How annual score is calculated. Values: Minimum, Maximum,
#'    Average, Median, NA}
#'    \item{score_num}{Numeric score}
#'    \item{score_str}{Score. Values: Meets Criteria, Does Not Meet Criteria,
#'    Excellent, Good, Fair, Poor, No Threshold Established, No Data Available}
#'    \item{Longitude}{Longitude}
#'    \item{Latitude}{Latitude}
#'    \item{popup_loc}{Popup text for map. Describes site.}
#'    \item{popup_score}{Popup text for map. Describes parameter and score.}
#'    \item{alt}{Alt text for map}
#'  }
"df_score"

# #' Categorical result data (dataframe)
# #'
# #' Dataframe containing categorical result data, available for download only.
# #'
# #' @format A dataframe with 15 columns:
# #'  \describe{
# #'    \item{Site_ID}{Site ID}
# #'    \item{Site_Name}{Site name}
# #'    \item{Watereshed}{Watershed}
# #'    \item{Date}{Date}
# #'    \item{Year}{Year}
# #'    \item{Parameter}{Parameter}
# #'    \item{Result}{Result value}
# #'    \item{Unit}{Result unit}
# #'    \item{Depth}{Depth category}
# #'    \item{Min}{Minimum acceptable value}
# #'    \item{Max}{Maximum acceptable value}
# #'    \item{Excellent}{Threshold between excellent and good data}
# #'    \item{Best}{Whether excellent data is higher or lower than fair data}
# #'    \item{Month}{Month}
# #'    \item{Description}{Popup text for interactive graph}
# #'  }
# "df_data_extra"

#' Site metadata (dataframe)
#'
#' Dataframe containing raw site metadata.
#'
#' @format A dataframe with at least 8 columns:
#'  \describe{
#'    \item{Site_ID}{Site ID}
#'    \item{Site_Name}{Site name}
#'    \item{Latitude}{Latitude}
#'    \item{Longitude}{Longitude}
#'    \item{Town}{Town}
#'    \item{State}{State}
#'    \item{Watershed}{Watershed name}
#'    \item{Group}{Group. Values: Warmwater, Coldwater, Saltwater, NA}
#'    \item{Max_Surface_Depth_m}{Maximum surface depth, meters. Default 1.}
#'    \item{Max_Midwater_Depth_m}{Maximum midwater depth, meters}
#'    \item{Max_Depth_m}{Site depth, meters}
#'    \item{Location_Type}{Location type}
#'  }
"df_sites_all"

#' Filtered site metadata (dataframe)
#'
#' Dataframe containing site metadata.
#'
#' @format A dataframe with 5-7 columns:
#'  \describe{
#'    \item{Site_ID}{Site ID}
#'    \item{Site_Name}{Site name}
#'    \item{Latitude}{Latitude}
#'    \item{Longitude}{Longitude}
#'    \item{Town}{Town}
#'    \item{State}{State}
#'    \item{Watershed}{Watershed name}
#'    \item{Group}{Group. Values: Warmwater, Coldwater, Saltwater, NA}
#'  }
"df_sites"

# #' Custom thresholds (dataframe)
# #'
# #' Dataframe containing custom threshold values.
# #'
# #' @format A dataframe with 13 columns:
# #'  \describe{
# #'    \item{State}{State}
# #'    \item{Group}{Group}
# #'    \item{Site}{Site ID}
# #'    \item{Depth}{Depth category}
# #'    \item{Parameter}{Parameter}
# #'    \item{Unit}{Parameter unit}
# #'    \item{Calculation}{How to calculate annual score. Values: min, max, mean,
# #'    median}
# #'    \item{Min}{Minimum acceptable value}
# #'    \item{Max}{Maximum acceptable value}
# #'    \item{Excellent}{Threshold between excellent and good data}
# #'    \item{Good}{Threshold between good and fair data}
# #'    \item{Fair}{Threshold between fair and poor data}
# #'    \item{Best}{Whether excellent data is higher or lower than fair data}
# #'  }
# "df_thresholds"

# #' River polylines (shapefile)
# #'
# #' Polyline shapefile showing local rivers.
# #'
# #' @format A dataframe with 2 columns:
# #'  \describe{
# #'    \item{Label}{Label}
# #'    \item{Geometry}{Shapefile geometry}
# #'  }
# "shp_river"

# #' Watershed polygons (shapefile)
# #'
# #' Polygon shapefile showing local watersheds.
# #'
# #' @format A dataframe with 2 columns:
# #'  \describe{
# #'    \item{Label}{Label}
# #'    \item{Geometry}{Shapefile geometry}
# #'  }
# "shp_watershed"

#' "About" tab text
#'
#' HTML code for "About" tab.
#'
#' @format HTML text
"qmd_about"

#' "Download" tab text
#'
#' HTML code for "Download" tab.
#'
#' @format HTML text
"qmd_download"

#' Default UI dropdown values
#'
#' A list of default values for the various dropdown menus in the sidebar and
#' on the graph tab.
#'
#' @format A list with 13 columns:
#'  \describe{
#'    \item{state}{List of states}
#'    \item{town}{List of towns}
#'    \item{watershed}{List of watersheds}
#'    \item{site_id}{List of site IDs}
#'    \item{site_name}{List of site names}
#'    \item{loc_choices}{List of toggle options. Possible values: "blank",
#'    "By Town" = "town", "By State" = "town", "By Watershed" = "watershed"}
#'    \item{loc_tab}{Name of hidden tab for importwqd:::mod_sidebar_location.
#'    Possible values: "notoggle", "toggle", "blank"}
#'    \item{param}{List of parameters}
#'    \item{param_score}{List of parameters that have been assigned a score}
#'    \item{param_cat}{List of download only/categorical parameters}
#'    \item{depth}{List of depths. Possible values: Surface, Midwater,
#'    Near Bottom, Bottom}
#'    \item{year}{List of years}
#'    \item{month}{List of months}
#'  }
"varlist"
