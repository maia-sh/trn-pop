source(here::here("R", "environment.R"))

query <- '"clinical trial"[pt] NOT (animals [mh] NOT humans [mh])'

latest("checked-pmids.csv", here("data")) %>%
  read_csv() %>%
  filter(found == 1)

# Set directory for saving search/pmids, fetch batches, and log
dir <- here("data-raw")

# Get pubmed xml's for human clinical trials
latest("checked-pmids.csv", here("data")) %>%
  read_csv() %>%
  filter(found == 1) %>%
  pull(pmid) %>%
  pubmedparser::batch_ids(batch_size = 215) %>%
  map_chr(
    ~ rentrez::entrez_fetch(db = "pubmed", id = ., rettype = "xml", parsed = FALSE)
  ) %>%
  pubmedparser::write_pubmed_files(
    dir = here("data-raw", "pubmed-xml"),
    prefix = "ct-human"
  )
