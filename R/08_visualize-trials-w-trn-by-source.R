source(here::here("R", "environment.R"))

dir <- here("data")

abstracts <-
  latest("abstracts.csv", here("data")) %>%
  read_csv()

databanks <-
  latest("databanks.csv", here("data")) %>%
  read_csv()

pmid_check <-
  latest("checked-pmids.csv", here("data")) %>%
  read_csv()

# Prepare data ------------------------------------------------------------

# Number of trials classified as human clinical trials by PubMed
n_trials_pm_human_ct <-
  pmid_check %>%
  filter(found == 1) %>%
  nrow()

# # Number of trns per trial
# abstracts %>%
#   count(n_reg = n, name = "n_trials")

# Number of abstracts with at least one trn
n_abs_trn <-
  abstracts %>%
  distinct(pmid) %>%
  nrow()

# Number of secondary identifiers with at least one trn
n_si_trn <-
  databanks %>%
  distinct(pmid) %>%
  nrow()

# Number of full text with at least one trn
# NOTE: Placeholder, made-up value.
n_ft_trn <- 185

n_trials_w_trn_by_source <-
  tribble(
    ~source, ~n_trials,
    "PubMed Metadata", n_abs_trn,
    "Abstract", n_si_trn,
    "Full-Text", n_ft_trn
  ) %>%
  mutate(source = factor(source, levels = c("PubMed Metadata", "Abstract", "Full-Text")))

# Create plot -------------------------------------------------------------

trials_w_trn_by_source <-
  ggplot(n_trials_w_trn_by_source, aes(source, n_trials)) +
  geom_bar(stat = "identity") +
  ggthemes::theme_fivethirtyeight() +
  theme(
    # title = element_text(size = rel(1.3)),
    axis.title = element_text(size = rel(1)),
    # axis.text = element_text(size = rel(1.1))
  ) +
  labs(
    x = "Registration Number Source",
    y = "Number of trials",
    title = "How many trials report registration numbers?",
    # subtitle = "Reported in PubMed metadata (secondary identifiers)",
    caption = "* Note: Trials identified via PubMed query (`'clinical trial'[pt] NOT (animals [mh] NOT humans [mh])`)\n and do not necessarily represent the true number of human clinical trials."
  ) +
  geom_label(
    aes(label = n_trials),
    # x = 5, y = 160,
    # vjust = .5,
    # stat = "unique",
    # family = "Bangers",
    size = 4,
    # color = "darkcyan"
  ) +
  annotate(
    "text",
    x = 1, y = n_trials_w_trn_by_source$n_trials[1],
    label = glue::glue("PubMed identified {n_trials_pm_human_ct} human clinical trials*"),
    vjust = -4,
    hjust = .25,
    size = 4
  )

ggsave(
  filename = paste0(Sys.Date(), "_trials_w_trn_by_source.png"),
  plot = trials_w_trn_by_source,
  device = png(),
  path = here("output")
)
