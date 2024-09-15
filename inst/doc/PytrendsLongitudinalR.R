## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----installation, eval = FALSE-----------------------------------------------
#  
#  library(PytrendsLongitudinalR)
#  install_pytrendslongitudinalr(envname = "pytrends-in-r-new")
#  

## ----usage, eval = FALSE------------------------------------------------------
#  library(PytrendsLongitudinalR)
#  
#  # Initialize parameters for data collection
#  params <- initialize_request_trends(
#    keyword = "Coronavirus disease 2019",
#    topic = "/g/11j2cc_qll",
#    folder_name = file.path(tempdir(), "test_folder"),
#    start_date = "2024-05-01",
#    end_date = "2024-05-03",
#    data_format = "daily"
#  )
#  
#  # Collect cross-section data
#  cross_section(params, geo = "US", resolution = "REGION") # REGION as a resolution is a sub-region of US in this example, and it indicates US states.
#  
#  # Collect reference time-series data
#  time_series(params, reference_geo_code = "US-CA") # The selected reference is California and its Google Trends Geo is 'US-CA'.
#  
#  # Given the short time period in this example, no concatenation is needed.
#  concat_time_series(params, reference_geo_code = "US", zero_replace = 0.1) # Error occurs because given period is less than 269 days, concatenation is unnecessary. You can move to convert_cross_section() without any problems.
#  
#  # Use the reference time-series data to re-scale the cross-sectional data.
#  convert_cross_section(params, reference_geo_code = "US-CA")

