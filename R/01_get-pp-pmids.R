# Raw data manually downloaded from https://codeberg.org/QUEST/responsible-metrics/src/branch/open-access-delwen/publications/pilot/output/2021-01-07_pp-dataset-oa.csv

source(here::here("R", "environment.R"))

input_filename <- here("data-raw", "2021-01-07_pp-dataset-oa.csv")
output_dir <- here("data")
output_filename <- paste0(output_dir, "/", Sys.Date(), "_pmids.csv")

fs::dir_create(output_dir)

read_csv(input_filename) %>%

  # Use dimensions pmid's
  mutate(pmid = pmid_dimensions) %>%

  select(pmid) %>%
  write_csv(output_filename)
