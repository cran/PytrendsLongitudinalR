#' Time Series Data Collection Method for 'weekly/daily'
#'
#' This function collects time series data on a weekly/daily basis using the Google Trends API.
#' It retrieves interest over time data using pytrends.interest_over_time() and saves it to the specified directory.
#'
#' @param params A list containing parameters including logger, pytrend, folder_name, data_format, start_date, end_date, keyword, and topic.
#' @param reference_geo_code Geographic code to specify the location for data collection (default is "US").
#' @keywords internal
#' @details
#' This function collects Google Trends time series data based on the specified parameters and saves it in the following structure:
#' \code{folder_name/data_format/over_time/reference_geo_code}.
#' The filename includes the start and end dates of the data period.
#'
#' @importFrom utils read.csv write.csv
#' @return NULL
#' @noRd


time_series_nmonthly <- function(params, reference_geo_code = "") {

  logger <- params$logger
  pytrend <- params$pytrend
  folder_name <- params$folder_name
  data_format <- params$data_format
  times <- params$times
  keyword <- params$keyword
  topic <- params$topic


  for (period in 1:(length(times) - 1)) {
    start <- times[[period]]
    end <- times[[period + 1]]

    if (data_format == "weekly") {
      num_days <- as.integer(difftime(end, start, units = "days"))
      if (num_days < 270) {
        stop(sprintf("For period: %d, days given: %d. Please increase timeline", period, num_days))
      }
    }

    file_path <- file.path(folder_name, data_format, "over_time", reference_geo_code,
                           sprintf("%d-%s-%s.csv", period, format(start, "%Y%m%d"), format(end, "%Y%m%d")))


    if (file.exists(file_path)) {
      logger$info(sprintf("Data for %s to %s already collected. Moving to next date...", format(start, "%d/%m/%Y"), format(end, "%d/%m/%Y")), extra = list(markup = TRUE))
    } else {
      tryCatch({
        # Use the topic if provided; otherwise, use the keyword

        pytrend$build_payload(
          kw_list = if (!is.null(topic) && topic != "") list(topic) else list(keyword),
          geo = reference_geo_code,
          timeframe = sprintf('%s %s', format(start, "%Y-%m-%d"), format(end, "%Y-%m-%d"))
        )

        Sys.sleep(5)
        df <- pytrend$interest_over_time()
        df <- reticulate::py_to_r(df)



        if (nrow(df) == 0) {
          logger$info(sprintf("No Data was returned for period: %d -> '%s' to '%s'", period, format(start, "%d/%m/%Y"), format(end, "%d/%m/%Y")))
        } else {
          names(df)[names(df) == if (!is.null(topic) && topic != "") topic else keyword] <- keyword

          if ("isPartial" %in% names(df)) {
            df <- df[, !names(df) %in% "isPartial", drop = FALSE]
          }
          write.csv(df, file_path)
        }
      }, ResponseError = function(e) {
        logger$info("Please have patience as we reset rate limit ... ", extra = list(markup = TRUE))
        Sys.sleep(5)
      }, error = function(e) {
        logger$error(sprintf("[bold]Whoops![/bold] An error occurred during the request: %s", e$message), exc_info = TRUE, extra = list(markup = TRUE))

      })
    }
  }
}
