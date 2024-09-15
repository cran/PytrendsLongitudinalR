#' Concatenate Multiple Time-Series Data Sets
#'
#' This function concatenates the time-series data collected by the 'time_series()' function.
#'
#' @param params A list containing parameters including keyword, topic, folder_name, start_date, end_date, and data_format.
#' @param reference_geo_code Google Trends Geo code for the user-selected reference region. For example, UK's Geo is 'GB', Central Denmark Region's Geo is 'DK-82, and US DMA Philadelphia PA's Geo is '504'. The default is 'US'.
#' @param zero_replace When re-scaling data from different time periods for concatenation, the last/first data point of a time period may be zero. Then the calculation will throw an error, or every single data point will be zero. To avoid this, the user can adjust the zero to an insignificant number to continue the calculation. The default is 0.1.

#' @details
#' This method concatenates the reference time-series data collected by the 'time_series()' function when the function has produced more than one data file. Because the time series data of each time period is normalized, the multiple time-series data sets are not on the same scale and must be re-scaled.
#' The re-scaled reference time-series data will be used in the next step to re-scale the cross-section data. If the given period is less than 269 days/weeks/months, and the 'time_series()' function produced only one data file, concatenation is unnecessary, and thus no concatenated file will be created in this step. The user can move to the 'convert_cross_section()' function without any problems.
#' @return No return value, called for side effects. The function concatenates the time-series data and saves it as a CSV file.
#'
#' @examples
#' \donttest{
#' # Please note that this example may take a few minutes to run
#' # Create a temporary folder for the example
#'
#' # Ensure the temporary folder is cleaned up after the example
#' if (reticulate::py_module_available("pytrends")) {
#'   params <- initialize_request_trends(
#'     keyword = "Coronavirus disease 2019",
#'     topic = "/g/11j2cc_qll",
#'     folder_name = file.path(tempdir(), "test_folder"),
#'     start_date = "2017-12-31",
#'     end_date = "2024-05-19",
#'     data_format = "weekly"
#'   )
#'   result <- TRUE
#'
#'   # Run the time_series function and handle TooManyRequestsError
#'   tryCatch({
#'     time_series(params, reference_geo_code = "US-CA")
#'   }, error = function(e) {
#'     message("An error occurred: ", conditionMessage(e))
#'     result <- FALSE # Indicate failure only on error
#'   })
#'
#'   # Check if at least one file is present in the expected directory
#'   data_dir <- file.path("test_folder", "weekly", "over_time", "US-CA")
#'   if (result && length(list.files(data_dir)) > 0) {
#'     concat_time_series(params, reference_geo_code = "US-CA")
#'   } else {
#'     if (result) {
#'       message("Skipping concat_time_series because no files were found in the expected directory.")
#'     } else {
#'       message("Skipping concat_time_series because time_series failed.")
#'     }
#'     result <- FALSE
#'   }
#'
#'   # Clean up temporary directory
#'   on.exit(unlink("test_folder", recursive = TRUE))
#' } else {
#'   message("The 'pytrends' module is not available.
#'   Please install it by running install_pytrendslongitudinalr()")
#' }
#' }
#' @importFrom utils read.csv write.csv

#' @export
#'
concat_time_series <- function(params, reference_geo_code = "US", zero_replace = 0.1) {

  logger <- params$logger
  folder_name <- params$folder_name
  data_format <- params$data_format
  keyword <- params$keyword

  logger$info("Concatenating Over Time data now", extra = list(markup = TRUE))

  # Create Folder to save the concatenated time series data
  create_required_directory(file.path(folder_name, data_format, "concat_time_series"))

  path_to_time_data <- file.path(folder_name, data_format, "over_time", reference_geo_code)

  # List to store DataFrames
  dfs <- list()

  # Read each CSV file into a DataFrame and store in dfs list
  files <- list.files(path_to_time_data, full.names = TRUE)

  # Check if the number of files is less than 2
  if (length(files) < 2) {
    stop("Since the given period is less than 269 days/weeks/months, concatenation is not necessary and there is no file generated. You can move to convert_cross_section without any problem.")
  }


  for (file in files) {
    df <- read.csv(file, check.names = FALSE)
    dfs[[length(dfs) + 1]] <- df
  }

  df <- df[, colSums(is.na(df)) != nrow(df)]

  # Replace zeros with zero_replace value
  for (i in seq_along(dfs)) {
    dfs[[i]][dfs[[i]][[keyword]] == 0, keyword] <- zero_replace
  }

  # Concatenate the time series data
  prev_window <- dfs[[1]]


  for (periods in 2:length(dfs)) {
    #print(periods)
    next_window <- dfs[[periods]]

    prev_window_multiplier <- 100 / prev_window[nrow(prev_window), keyword]
    next_window_multiplier <- 100 / next_window[1, keyword]

    prev_window[, keyword] <- prev_window[, keyword] * prev_window_multiplier
    next_window[, keyword] <- next_window[, keyword] * next_window_multiplier

    prev_window <- rbind(prev_window[-nrow(prev_window), ], next_window)

  }

  # Write concatenated DataFrame to CSV
  concat_file_path <- file.path(folder_name, data_format, "concat_time_series", paste0(reference_geo_code, ".csv"))
  write.csv(prev_window, concat_file_path, row.names = FALSE)

  logger$info("Concatenation Complete! :)")
}
