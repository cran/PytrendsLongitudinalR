# R/zzz.R

# Global references to Python modules (will be initialized in .onLoad)
pytrendsRequest <- NULL
ResponseError <- NULL
pd <- NULL
os <- NULL
glob <- NULL
json <- NULL
requests <- NULL
dt <- NULL
relativedelta <- NULL
time <- NULL
logging <- NULL
console <- NULL
rc <- NULL
math <- NULL
platform <- NULL


.onLoad <- function(libname, pkgname) {
  # Soft preference for a named virtual environment, but don't require it
  reticulate::use_virtualenv("pytrends-in-r-new", required = FALSE)


  # Initialize delayed loading of Python modules
  pytrendsRequest <<- reticulate::import("pytrends.request", delay_load = TRUE)
  ResponseError <<- reticulate::import("pytrends.exceptions", delay_load = TRUE)
  pd <<- reticulate::import("pandas", delay_load = TRUE)
  os <<- reticulate::import("os", delay_load = TRUE)
  glob <<- reticulate::import("glob", delay_load = TRUE)
  json <<- reticulate::import("json", delay_load = TRUE)
  requests <<- reticulate::import("requests", delay_load = TRUE)
  dt <<- reticulate::import("datetime", delay_load = TRUE)
  relativedelta <<- reticulate::import("dateutil.relativedelta", delay_load = TRUE)
  time <<- reticulate::import("time", delay_load = TRUE)
  logging <<- reticulate::import("logging", delay_load = TRUE)
  console <<- reticulate::import("rich.console", delay_load = TRUE)
  rc <<- reticulate::import("rich.logging", delay_load = TRUE)
  math <<- reticulate::import("math", delay_load = TRUE)
  platform <<- reticulate::import("platform", delay_load = TRUE)



  # Optionally configure logging
  configure_logging()
}

.onAttach <- function(libname, pkgname) {
  if (!interactive()) {
    return()  # Skip the prompt during non-interactive sessions
  }

  msg <- "This package creates new folders in your filespace to store downloaded Google Trends data. Do you want to proceed? (Y/N)"
  packageStartupMessage(msg)

  response <- readline(prompt = "Enter Y to proceed, or N to abort: ")

  if (toupper(response) != "Y") {
    stop("Initialization aborted by the user.")
  }
}


