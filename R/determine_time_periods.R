#' Determine Time Periods
#'
#' Helper function to calculate time periods based on the given start date, end date,
#' number of days, and time window.
#'
#' @param start_date The starting date of the time period.
#' @param end_date The ending date of the time period.
#' @param num_of_days Number of days between \code{start_date} and \code{end_date}.
#' @param time_window Time window in days to divide the period into segments.
#'
#' @return A vector of dates representing the determined time periods.
#' @noRd


determine_time_periods <- function(start_date, end_date, num_of_days, time_window) {
  timeperiod <- ceiling(num_of_days / time_window)
  times <- seq.Date(start_date, by = paste0(time_window, " days"), length.out = timeperiod + 1)
  times[length(times)] <- end_date
  return(times)
}
