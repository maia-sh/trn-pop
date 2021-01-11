# Install and load packages -----------------------------------------------

cran_pkgs <- c(

  # General
  "dplyr", "tidyr", "janitor", "stringr", "readr", "here", "purrr", "tibble", "fs", "fuzzyjoin",
  # "tidylog",

  # PubMed
  "xml2", "httr", "rvest", "rentrez", "tidypubmed", "pubmedparser",
  # "easyPubMed", "XML",

  # Data visualization
  "UpSetR", "DiagrammeR", "ggplot2",

  # Testing
  "assertr", "assertthat",

  # Credentials
  "keyring",

  # Logging
  "loggit"
)

to_install <- cran_pkgs[!cran_pkgs %in% installed.packages()]

if (length(to_install) > 0) {
  install.packages(to_install, deps = TRUE, repos = "https://cran.r-project.org")
}

# non-CRAN packages
# if (!"officedown" %in% installed.packages()) {
#   devtools::install_github("davidgohel/officedown")
# }
# if (!"tidypubmed" %in% installed.packages()) {
#   devtools::install_github("cstubben/tidypubmed")
#   devtools::install_github("maia-sh/tidypubmed")
# }
#  if (!"pubmedparser" %in% installed.packages()) {
#   devtools::install_github("maia-sh/pubmedparser")
# }
if (!"ctregistries" %in% installed.packages()) {
  devtools::install_github("maia-sh/ctregistries")
}

# Don't library "loggit"
cran_pkgs <- cran_pkgs[!cran_pkgs %in% "loggit"]

invisible(lapply(c(cran_pkgs, "ctregistries"), library, character.only = TRUE))


# Utility functions -------------------------------------------------------

# credit: Wil Doane
latest <- function (name, dir = here::here("data"), hash = FALSE) {
  pattern <- sprintf("^20[0-9\\-]+_%s", name)
  filenames <- list.files(dir, pattern, full.names = TRUE)
  result <- sort(filenames, decreasing = TRUE)[1]
  if (is.na(result))
    NULL
  else {
    if (hash)
      message(digest::sha1(readLines(result)))
    result
  }
}
