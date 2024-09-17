
<!-- README.md is generated from README.Rmd. Please edit that file -->

# PytrendsLongitudinalR

<!-- badges: start -->
<!-- badges: end -->

Welcome to the vignette for PytrendsLongitudinalR, a package for
collecting and analyzing Google Trends data over time. This vignette
will guide you through the setup process and show you how to use the
package’s main functionalities.

This is a package for downloading cross-section and time-series Google
Trends and converting them to longitudinal data. Although Google Trends
provides cross-section and time-series search data, longitudinal Google
Trends data are not readily available. There exist several practical
issues that make it difficult for researchers to generate longitudinal
Google Trends data themselves. First, Google Trends provides normalized
counts from zero to 100. As a result, combining different regions’
time-series Google Trends data does not create desired longitudinal
data. For the same reason, combining cross-sectional Google Trends data
over time does not create desired longitudinal data. Second, Google
Trends has restrictions on data formats and timeline. For instance, if
you want to collect daily data for 2 years, you cannot do so. Google
Trends automatically provides weekly data if your request timeline is
more than 269 days. Similarly, Google Trends automatically provides
monthly data if your request timeline is more than 269 weeks even though
you want to collect weekly data. This package resolves the
aforementioned issues and allows researchers to generate longitudinal
Google Trends.

## Installation

Step 1: Ensure Python is Installed

To use the PytrendsLongitudinalR package, you need Python version 3.7 or
higher installed on your system. Follow the steps below to check if
Python is installed and, if not, how to install it.

Check if Python is installed: Open a terminal (on Linux/Mac) or Command
Prompt (on Windows) and run the following command:

``` r

python3 --version
```

If you see a version number (e.g., Python 3.8.5), you’re ready to
proceed. If Python is not installed or the version is below 3.7, you’ll
need to install or update it.

Install Python (Optional - since installing the package in Step 2 will
automatically handle Python installations): MacOS and Windows: Download
the latest version of Python from the official Python website:
<https://www.python.org/downloads/>.

Linux: Most Linux distributions already include Python, but if you need
to install it or update to a newer version, run:

``` r

sudo apt-get update
sudo apt-get install python3
```

Step 2: Install PytrendsLongitudinalR

Once Python is installed, you can proceed with installing the
PytrendsLongitudinalR package. This package interacts with Python to
retrieve Google Trends data, so it requires some additional Python
packages (pandas, requests, pytrends) to work correctly. The process is
automated using the install_pytrendslongitudinalr() function.

The function automatically creates an isolated Python virtual
environment named pytrends-in-r-new to keep the Python packages separate
from your system Python and installs the required Python packages in
this virtual environment.

Run the following code to install PytrendsLongitudinalR and
automatically create an isolated virtual environment named
“pytrends-in-r-new”:

``` r

install.packages('PytrendsLongitudinalR')

library(PytrendsLongitudinalR)

# This will create a virtual environment and install the necessary Python packages in the virtual environment
install_pytrendslongitudinalr(envname = "pytrends-in-r-new")
```

What this does: It checks if the virtual environment pytrends-in-r-new
already exists. If it doesn’t exist, it creates it and installs the
required Python packages (pandas, requests, pytrends). If you ever need
to reinstall the environment, the function can also remove and recreate
the environment.

Troubleshooting Python Installation Issues: Windows users: If you run
into errors related to Python not being found, ensure Python is added to
your PATH during installation. You can verify this by running python
–version in the command line. MacOS users: If Python is not found,
ensure that you are using the command python3 and that Python 3 is
installed (since macOS may also have Python 2 by default).

Manual Installation (optional - not recommended for this package): If
you prefer to manually install the Python packages outside of R, you can
run the following command in your terminal (if you have pip or pip3
installed):

``` r

pip3 install pytrends pandas requests
```

After running this command, the PytrendsLongitudinalR package should
work as expected with your existing Python setup.

## Usage

Now you can start using PytrendsLongitudinalR to collect Google Trends
data.

``` r
library(PytrendsLongitudinalR)
install_pytrendslongitudinalr(envname = "pytrends-in-r-new")

# Initialize parameters for data collection
params <- initialize_request_trends(
  keyword = "Coronavirus disease 2019",
  topic = "/g/11j2cc_qll",
  folder_name = file.path(tempdir(), "test_folder"),
  start_date = "2024-05-01",
  end_date = "2024-05-03",
  data_format = "daily"
)

# Collect cross-section data
cross_section(params, geo = "US", resolution = "REGION") # REGION as a resolution is a sub-region of US in this example, and it indicates US states.

# Collect reference time-series data
time_series(params, reference_geo_code = "US-CA") # The selected reference is California and its Google Trends Geo is 'US-CA'.

# Given the short time period in this example, no concatenation is needed.
concat_time_series(params, reference_geo_code = "US", zero_replace = 0.1) # Error occurs because given period is less than 269 days, concatenation is unnecessary. You can move to convert_cross_section() without any problems.

# Use the reference time-series data to re-scale the cross-sectional data. 
convert_cross_section(params, reference_geo_code = "US-CA")
```

## Warning

We recommend that the user run the functions in the following sequence:

cross_section

time_series

concat_time_series

convert_time_series

First, the cross-sectional and reference time-series data must be
created. The concat_time_series() function uses the reference
time-series data files to concatenate multiple sets of time series.
Finally, the convert_time_series() function uses the concatenated
reference time series to re-scale the cross-sectional data.

The user may encounter a 429 Too Many Requests error when using
cross_section() and time_series() to collect Google Trends data. This
error indicates that the user has exceeded the rate limits set by the
Google Trends API. Here are a few strategies to mitigate the impact of
this error:

1)  Lower the frequency of your requests or extend the interval between
    requests. If you’re making requests with high frequency, consider
    spacing them out or reducing the number of requests made in a given
    time frame.

2)  If you’re querying a large time range or a high-resolution
    granularity, try reducing the scope of your queries. Smaller time
    periods and/or lower resolution might help stay within the rate
    limits.
