source(here::here("R", "environment.R"))

input_filename <- here("data-raw", "2021-01-07_pp-dataset-oa.csv")
output_dir <- here("data", "roadoi")

pp_df <- read_csv(input_filename)

# NOTE: This takes a while to run!
if (rstudioapi::showQuestion("Warning!", "You are about query Unpaywall. It could take a while!", ok = "Yes, go ahead", cancel = "No, don't query")) {

  oa_doi <-
    pp_df %>%
    distinct(doi) %>%
    pull() %>%
    roadoi::oadoi_fetch()
}

# Some records (n = 38) did not resolve, so try again to check...Still did not resolve
if (rstudioapi::showQuestion("Warning!", "You are about query Unpaywall. It could take a while!", ok = "Yes, go ahead", cancel = "No, don't query")) {

  oa_doi_2 <-
    anti_join(pp_df, oa_doi, by = "doi") %>%
    distinct(doi) %>%
    pull() %>%
    roadoi::oadoi_fetch()
}

# Inspect pp dois that didn't resolve in roadoi...Also missing here
anti_join(pp_df, oa_doi, by = "doi") %>%
  select(doi, color)

# Compare with roadoi
left_join(
  select(pp_df, doi, oa_roadoi = color),
  select(oa_doi, doi, oa_status),
  by = "doi"
) %>%
  mutate(oa_match =
           if_else(
             oa_status == oa_roadoi | (is.na(oa_status) & is.na(oa_roadoi)),
             TRUE, FALSE
           )
  ) %>%
  # count(oa_match)
  # filter(!oa_match) %>%
  # count(oa_status, oa_roadoi)
  write_csv(here("output", paste0(Sys.Date(), "_compare-roadoi.csv")))


# Save roadoi data --------------------------------------------------------

# Extract list columns to save in own csvs
# Note: there's probably a function to unnest all list columns, but didn't find on a quick search
best_oa_location <-
  oa_doi %>%
  select(doi, best_oa_location) %>%
  tidyr::unnest(cols = best_oa_location)

oa_locations <-
  oa_doi %>%
  select(doi, oa_locations) %>%
  tidyr::unnest(cols = oa_locations)

oa_locations_embargoed <-
  oa_doi %>%
  select(doi, oa_locations_embargoed) %>%
  tidyr::unnest(cols = oa_locations_embargoed)

authors <-
  oa_doi %>%
  select(doi, authors) %>%
  tidyr::unnest(cols = authors) %>%
  select(-affiliation)

affiliation <-
  oa_doi %>%
  select(doi, authors) %>%
  tidyr::unnest(cols = authors) %>%
  select(doi, family, given, affiliation) %>%
  tidyr::unnest(cols = affiliation)

oa_doi_flat <-
  oa_doi %>%
  select(-best_oa_location, -oa_locations, -oa_locations_embargoed, -authors)

if (!dir_exists(output_dir)) dir_create(output_dir)

write_csv(
  oa_doi_flat,
  paste0(output_dir, "/", Sys.Date(), "_pp-roadoi_main.csv")
)

write_csv(
  best_oa_location,
  paste0(output_dir, "/", Sys.Date(), "_pp-roadoi_best-oa-location.csv")
)

write_csv(
  oa_locations,
  paste0(output_dir, "/", Sys.Date(), "_pp-roadoi_oa-locations.csv")
)

write_csv(
  oa_locations_embargoed,
  paste0(output_dir, "/", Sys.Date(), "_pp-roadoi_oa-locations-embargoed.csv")
)

write_csv(
  authors,
  paste0(output_dir, "/", Sys.Date(), "_pp-roadoi_authors.csv")
)

write_csv(
  affiliation,
  paste0(output_dir, "/", Sys.Date(), "_pp-roadoi_affiliation.csv")
)
