#' Create Required Directory
#'
#' Creates a directory if it does not already exist.
#'
#' This function checks if the specified directory exists. If not, it creates
#' the directory recursively.
#'
#' @param folder A character string specifying the directory path to create.
#' @keywords internal
#'
#' @return NULL
#' @noRd

create_required_directory <- function(folder) {
  if (!dir.exists(folder)) {
    dir.create(folder, recursive = TRUE)
  }
}
