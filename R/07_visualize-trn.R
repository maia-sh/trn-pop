source(here::here("R", "environment.R"))

dir <- here("data")

abstracts <-
  latest("abstracts.csv", here("data")) %>%
  read_csv()

databanks <-
  latest("databanks.csv", here("data")) %>%
  read_csv()

si_registrations <-
  databanks %>%
  group_by(pmid) %>%
  summarise(registries = list(registry)) %>%
  ggplot(aes(x = registries)) +
  geom_bar() +
  geom_text(stat='count', aes(label = after_stat(count)), vjust = -.5) +
  ggupset::scale_x_upset() +
  scale_y_continuous(breaks = NULL, #lim = c(0, 3),
                     name = "") +
    labs(
      x = "Registries",
      y = NULL,
      title = "Trial registration numbers by registry",
      subtitle = "Reported in PubMed metadata (secondary identifiers)",
      caption = "https://www.nlm.nih.gov/bsd/medline_databank_source.html"
    ) +
    ggthemes::theme_fivethirtyeight() +
    ggupset::theme_combmatrix(
      combmatrix.label.make_space = TRUE,
      combmatrix.label.text = element_text(size=12)
    ) +
    theme(panel.grid.major = element_line(colour = NA))

abs_registrations <-
  abstracts %>%
  group_by(pmid) %>%
  summarise(registries = list(registry)) %>%
  ggplot(aes(x = registries)) +
  geom_bar() +
  geom_text(stat='count', aes(label = after_stat(count)), vjust = -.5) +
  ggupset::scale_x_upset() +
  scale_y_continuous(breaks = NULL, #lim = c(0, 3),
                     name = "") +
  labs(
    x = "Registries",
    y = NULL,
    title = "Trial registration numbers by registry",
    subtitle = "Reported in PubMed abstracts"
  ) +
  ggthemes::theme_fivethirtyeight() +
  ggupset::theme_combmatrix(
    combmatrix.label.make_space = TRUE,
    combmatrix.label.text = element_text(size=12)
  ) +
  theme(panel.grid.major = element_line(colour = NA))

ggsave(
  filename = paste0(Sys.Date(), "_si-registrations.png"),
  plot = si_registrations,
  device = png(),
  path = here("output")
)

ggsave(
  filename = paste0(Sys.Date(), "_abs-registrations.png"),
  plot = abs_registrations,
  device = png(),
  path = here("output")
)
