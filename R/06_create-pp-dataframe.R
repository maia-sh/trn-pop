# Combine abstract and secondary id trns, plus whether pmid is human clinical trial into proof of principle dataset

source(here::here("R", "environment.R"))

dir <- here("data")
output_dir <- here("data")

pmid_check <-
  latest("checked-pmids.csv", here("data")) %>%
  read_csv() %>%
  mutate(is_human_ct = as.logical(found), .keep = "unused") %>%
  filter(!is.na(pmid)) %>%
  distinct(pmid, .keep_all = TRUE)

abstracts <-
  latest("abstracts.csv", here("data")) %>%
  read_csv() %>%
  pivot_wider(
    names_from = n,
    names_glue = "abs_{.value}_{n}",
    values_from = c(trn, registry)
  )

databanks <-
  latest("databanks.csv", here("data")) %>%
  read_csv() %>%
  pivot_wider(
    names_from = n,
    names_glue = "si_{.value}_{n}",
    values_from = c(trn, registry)
  )

# Join the dataframes
pp_dataset <-
  here("data-raw", "2021-01-07_pp-dataset-oa.csv") %>%
  read_csv() %>%
  left_join(pmid_check, by = c("pmid_dimensions" = "pmid")) %>%
  left_join(abstracts, by = c("pmid_dimensions" = "pmid")) %>%
  left_join(databanks, by = c("pmid_dimensions" = "pmid"))

fs::dir_create(output_dir)

write_csv(pp_dataset, paste0(output_dir, "/", Sys.Date(), "_pp-dataset-trn.csv"))
