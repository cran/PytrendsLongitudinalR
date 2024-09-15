#' Install and Set Up Python Environment for PytrendsLongitudinalR
#'
#' This function sets up the Python virtual environment and installs required packages.
#' @param envname Name of the virtual environment.
#' @param new_env Checks if virtual environment already exists
#' @param ... Additional arguments passed to `py_install()`.
#' @importFrom reticulate py_install virtualenv_exists virtualenv_remove
#' @return No return value, called for side effects. This function sets up the virtual environment and installs required Python packages.

#' @export
install_pytrendslongitudinalr <- function(envname = "pytrends-in-r-new", new_env = identical(envname, "pytrends-in-r-new"), ...) {
  if(new_env && virtualenv_exists(envname))
    virtualenv_remove(envname)

  # Install the required Python packages
  reticulate::py_install(
    c("pandas", "requests", "pytrends", "rich"),
    envname = envname,
    ...
  )
}


