source(here::here("R", "environment.R"))

# Read in and combine pubmed tables
input_dir <- here("data", "tables")
output_dir <- here("data")

abstracts <-
  fs::dir_ls(input_dir) %>%
  str_subset("abstract") %>%
  map_dfr(read_csv)

databanks <-
  fs::dir_ls(input_dir) %>%
  str_subset("databanks") %>%
  map_dfr(read_csv)


# Prep databanks
databanks <-
  databanks %>%
  ctregistries::mutate_trn_registry(accession_number)

# Visually inspect mismatching trns (n = 3) and registries
# 1 is likely typo for NTR 1880, for now, exclude
databanks %>%
  filter(!accession_number %in% trn)
databanks %>%
  filter(!databank %in% registry)

databanks <-
  databanks %>%
  drop_na(trn) %>%
  group_by(pmid) %>%
  mutate(n = row_number()) %>%
  ungroup() %>%
  select(pmid, n, trn, registry)

# Prep abstracts
abstracts <-
  abstracts %>%
  ctregistries::mutate_trn_registry(abstract) %>%
  drop_na(trn) %>%
  group_by(pmid) %>%
  mutate(n = row_number()) %>%
  ungroup() %>%
  select(pmid, n, trn, registry)

# Write files
write_csv(abstracts, paste0(output_dir, "/", Sys.Date(), "_abstracts.csv"))
write_csv(databanks, paste0(output_dir, "/", Sys.Date(), "_databanks.csv"))

