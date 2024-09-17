# R/logging_config.R

#' Configure Logging
#'
#' Sets up the logging configuration using Python's logging module.
#' @noRd

configure_logging <- function(level = "INFO", format = "%(message)s", datefmt = "%d-%b-%Y %H:%M:%S") {
  logging$basicConfig(
    level = level,
    format = format,
    datefmt = datefmt
    #handlers = list(rc$RichHandler(rich_tracebacks = rich_tracebacks))
  )
}
