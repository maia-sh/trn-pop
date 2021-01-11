# Adapted from https://codeberg.org/bgcarlisle/PubmedIntersectionCheck

source(here::here("R", "environment.R"))

query <- '"clinical trial"[pt] NOT (animals [mh] NOT humans [mh])'
input_filename <- latest("pmids.csv", here("data"))
output_filename <- here("data", paste0(Sys.Date(), "_checked-pmids.csv"))

tribble(~pmid, ~found) %>%
  write_csv(output_filename)

# ncbi api key for responsible-metrics@charite.de
# https://www.ncbi.nlm.nih.gov/myncbi/
apikey <-
  ifelse(
    nrow(keyring::key_list("ncbi-pubmed")) != 0,
    keyring::key_get(service = "ncbi-pubmed",
                     username = "responsible-metrics@charite.de"),
    keyring::key_set(service = "ncbi-pubmed")
  )

batchsize <- 100

download_pubmed_results <- function (apikey, query, pmids) {

  out <- tryCatch({

    pmid_search_term <- pmids %>%
      unlist() %>%
      paste(collapse="[PMID] OR ") %>%
      paste0("[PMID]")

    search_term <- paste0(
      "(",
      query,
      ") AND (",
      pmid_search_term,
      ")"
    )

    pubmed_search <- list(
      api_key = apikey,
      term = search_term,
      db = "pubmed"
    )

    res <- POST(
      "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi",
      body=pubmed_search,
      encode="form"
    )

    result <- read_xml(res)

    closeAllConnections()

    return(result)

  },
  error=function(cond) {
    message(
      paste(
        "Error:",
        cond
      )
    )

    return(NA)
  },
  warning=function(cond) {
    message(
      paste(
        "Warning:",
        cond
      )
    )

    return(NA)
  },
  finally={
  })

  return(out)

}

while (sum (! read_csv(input_filename)$pmid %in% read_csv(output_filename)$pmid) > 0) {

  input <- read_csv(input_filename)

  input$checked <- ! input$pmid %in% read_csv(output_filename)$pmid

  pmid_batch <- input %>%
    filter (checked) %>%
    head (n=batchsize)

  results <- download_pubmed_results(apikey, query, pmid_batch$pmid)

  found_pmids <- xml_find_all(
    results,
    "/eSearchResult/IdList/Id"
  ) %>%
    xml_text()

  for (pmid in pmid_batch$pmid) {

    if (pmid %in% found_pmids) {
      tribble(
        ~pmid, ~found,
        pmid, 1
      ) %>%
        write_csv(
          output_filename,
          append=TRUE,
          col_names=FALSE
        )
    } else {
      tribble(
        ~pmid, ~found,
        pmid, 0
      ) %>%
        write_csv(
          output_filename,
          append=TRUE,
          col_names=FALSE
        )
    }

  }

  denom <- read_csv(input_filename) %>%
    nrow()

  numer <- read_csv(output_filename) %>%
    nrow()

  message(
    paste0(
      format(100*numer/denom, digits=2),
      "% done"
    )
  )

}
