#' Convert the Cross-Section data for Re-scaling.
#'
#' This function uses the single or concatenated reference time-series data to re-scale the cross-section data collected by the cross_section() function.
#'
#' @param params A list containing parameters including keyword, topic, folder_name, start_date, end_date, and data_format.
#' @param reference_geo_code Google Trends Geo code for the user-selected reference region. For example, UK's Geo is 'GB', Central Denmark Region's Geo is 'DK-82, and US DMA Philadelphia PA's Geo is '504'. The default is 'US'.
#' @param zero_replace When re-scaling data from different time periods for concatenation, the last/first data point of a time period may be zero. Then the calculation will throw an error, or every single data point will be zero. To avoid this, the user can adjust the zero to an insignificant number to continue the calculation. The default is 0.1.
#' @details
#' This final method rescales the cross-section data based on the concatenated time series data to generate re-scaled accurate longitudinal Google Trends index.
#' @return No return value, called for side effects.
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
#'     start_date = "2024-05-01",
#'     end_date = "2024-05-03",
#'     data_format = "daily"
#'   )
#'   cross_section_success <- TRUE
#'   time_series_success <- TRUE
#'
#'   # Run the cross_section function and handle potential errors
#'   tryCatch({
#'     cross_section(params, geo = "US", resolution = "REGION")
#'   }, pytrends.exceptions.TooManyRequestsError = function(e) {
#'     message("Too many requests error in cross_section: ", conditionMessage(e))
#'     cross_section_success <- FALSE # Indicate failure
#'   })
#'
#'   # Run the time_series function and handle potential errors
#'   tryCatch({
#'     time_series(params, reference_geo_code = "US-CA")
#'   }, pytrends.exceptions.TooManyRequestsError = function(e) {
#'     message("Too many requests error in time_series: ", conditionMessage(e))
#'     time_series_success <- FALSE # Indicate failure
#'   })
#'
#'   data_dir_time <- file.path("test_folder", "daily", "over_time", "US-CA")
#'   data_dir_region <- file.path("test_folder", "daily", "by_region")
#'
#'   # Conditionally run convert_cross_section only if both functions succeeded
#'   if (cross_section_success && time_series_success && length(list.files(data_dir_time)) > 0
#'   && length(list.files(data_dir_region)) > 0) {
#'     convert_cross_section(params, reference_geo_code = "US-CA")
#'   } else {
#'     message("Skipping convert_cross_section due to previous errors.")
#'   }
#'
#'   # Clean up temporary directory
#'   on.exit(unlink("test_folder", recursive = TRUE))
#' } else {
#'   message("The 'pytrends' module is not available.
#'   Please install it by running install_pytrendslongitudinalr()")
#' }
#' }

#' @importFrom utils read.csv write.csv tail
#' @export
#'

convert_cross_section <- function(params, reference_geo_code = "US-CA", zero_replace = 0.1) {

  logger <- params$logger
  folder_name <- params$folder_name
  data_format <- params$data_format
  keyword <- params$keyword
  topic <- params$topic
  start_date <- params$start_date
  end_date <- params$end_date

  #logger$info("Rescaling cross section Data now", extra = list(markup = TRUE))

  # Create required directories
  create_required_directory(file.path(folder_name, data_format, "converted"))
  create_required_directory(file.path(folder_name, data_format, "converted", reference_geo_code))

  concat_file_path <- file.path(folder_name, data_format, "concat_time_series", paste0(reference_geo_code, ".csv"))
  if (file.exists(concat_file_path)) {
    time_series_concat <- read.csv(concat_file_path, header = TRUE, check.names = FALSE)
  } else {
    files_in_over_time <- list.files(file.path(folder_name, data_format, "over_time", reference_geo_code), full.names = TRUE)
    time_series_concat <- read.csv(files_in_over_time, header = TRUE, check.names = FALSE)
  }

  names(time_series_concat)[names(time_series_concat) == ''] <- 'date'

  # Initialize empty data frame for conversion result
  conv <- data.frame()

  # Iterate over rows in time_series_concat
  for (ind in seq_len(nrow(time_series_concat))) {
    record <- format(as.POSIXct(as.character(time_series_concat$date[ind]), format = "%Y-%m-%d %H:%M:%S"), "%Y%m%d")
    time_ind <- as.numeric(time_series_concat[[keyword]][ind])

    # Construct snapshot file path based on record date
    snap_file <- list.files(path = file.path(folder_name, data_format, "by_region"), pattern = paste0(".*", record, ".*csv"), full.names = TRUE)[1]


    # Extract column name from snapshot file
    if (Sys.info()['sysname'] == "Windows") {

      fl_name <- tail(unlist(strsplit(snap_file, "\\\\")), 1)

    } else {

      fl_name <- tail(unlist(strsplit(snap_file, "/")), 1)

    }

    col_name <- gsub("\\.csv", "", fl_name)

    # Read snapshot data
    snap_df <- read.csv(snap_file, header = TRUE, stringsAsFactors = FALSE, na.strings = "", check.names = FALSE)


    # Handle case where spaces are replaced with periods
    keyword_with_period <- gsub(" ", ".", keyword)
    topic_with_period <- gsub(" ", ".", topic)

    # Identify the correct column name in snap_df
    col_name_in_snap <- if (keyword %in% names(snap_df)) {
      keyword
    } else if (keyword_with_period %in% names(snap_df)) {
      keyword_with_period
    } else if (topic %in% names(snap_df)) {
      topic
    } else if (topic_with_period %in% names(snap_df)) {
      topic_with_period
    } else {
      # Handle case where topic gets prefixed with ".X"
      potential_col_name <- paste0("X", gsub("/", ".", topic))
      if (potential_col_name %in% names(snap_df)) {
        potential_col_name
      } else {
        NA
      }
    }


    # Safely replace NA values if the column exists
    if (col_name_in_snap %in% names(snap_df)) {
      snap_df[[col_name_in_snap]][is.na(snap_df[[col_name_in_snap]])] <- zero_replace
    } else {
      message("Error: Column ", col_name_in_snap, " does not exist in snap_df.")
    }



    # Find reference value based on geoCode
    ref_value <- as.numeric(snap_df[snap_df$geoCode == reference_geo_code, col_name_in_snap])


    # Calculate conversion multiplier
    conv_multiplier <- time_ind / ref_value



    # Perform conversion on snapshot dataframe
    snap_df[[col_name]] <- round(snap_df[[col_name_in_snap]] * conv_multiplier, 2)


    # Collect initial geoName and geoCode if it's the first iteration
    if (ind == 1) {
      conv <- snap_df[, c(1, which(names(snap_df) == "geoCode"))]
    }



    # Append converted data to conv data frame
    conv[[col_name]] <- snap_df[[col_name]]
  }

  # Write converted DataFrame to CSV
  write.csv(conv, file.path(folder_name, data_format, "converted", reference_geo_code, paste0("final-converted-",
                                                                                              format(start_date, "%Y%m%d"), "-",
                                                                                              format(end_date, "%Y%m%d"), ".csv")), row.names = FALSE)



  logger$info("DONE Converting! :)")
}
