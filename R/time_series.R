#' Collect Time-Series Google Trends Data
#'
#' This function uses the 'pytrends.interest_over_time()' function available in 'pytrends' Python library to collect time-series Google Trends data and automatically store it in the specified directory.
#'
#' @param params A list containing parameters including keyword, topic, folder_name, start_date, end_date, and data_format.
#' @param reference_geo_code Google Trends Geo code for the user-selected reference region. For example, UK's Geo is 'GB', Central Denmark Region's Geo is 'DK-82, and US DMA Philadelphia PA's Geo is '504'. Default is 'US'.

#' @details
#' This function collects Google Trends time-series data based on the specified parameters and saves it in the following structure: \code{folder_name/data_format/over_time/reference_geo_code}. Google Trends provides daily data if the time period between the start and end dates is less than 270 days, weekly data if the time period is between 270 days and 1890 days (270 weeks), and monthly data if it's equal to or greater than 270 weeks.
#'
#'
#' @return No return value, called for side effects.

#'
#' @examples
#' \donttest{
#' # Create a temporary folder for the example
#'
#' # Ensure the temporary folder is cleaned up after the example
#'
#'
#' if (reticulate::py_module_available("pytrends")) {
#'   params <- initialize_request_trends(
#'     keyword = "Coronavirus disease 2019",
#'     topic = "/g/11j2cc_qll",
#'     folder_name = file.path(tempdir(), "test_folder"),
#'     start_date = "2024-05-01",
#'     end_date = "2024-05-03",
#'     data_format = "daily"
#'   )
#'   on.exit(unlink("test_folder", recursive = TRUE))
#'
#'   # Run the time_series function with the parameters
#'   tryCatch({
#'     time_series(params, reference_geo_code = "US-CA")
#'   }, pytrends.exceptions.TooManyRequestsError = function(e) {
#'   message("Too many requests error: ", conditionMessage(e))
#'   })
#' } else {
#'   message("The 'pytrends' module is not available.
#'   Please install it by running install_pytrendslongitudinalr()")
#' }
#' }

#' @export
#'
time_series <- function(params, reference_geo_code = "") {

  logger <- params$logger
  folder_name <- params$folder_name
  data_format <- params$data_format
  time_window <- params$time_window

  logger$info("Collecting Over Time Data now")

  create_required_directory(file.path(folder_name, data_format, "over_time"))
  create_required_directory(file.path(folder_name, data_format, "over_time", reference_geo_code))

  if (!is.null(time_window)) {

    time_series_nmonthly(params, reference_geo_code)
  } else {
    time_series_monthly(params, reference_geo_code)
  }

  logger$info("Collected Time Series Data!")
}
