source(here::here("R", "environment.R"))

dir <- here("data")
input_dir <- here("data-raw", "pubmed-xml")
filename <- "ct-human"
log_file <-
  paste0(dir, "/",
         Sys.Date(),"_",
         filename,
         "_parsing.log"
  )
loggit::set_logfile(log_file)

suffix = 1
for (file in fs::dir_ls(input_dir)){
  read_file(file) %>%
    pubmedparser::parse_batch(datatypes = c("table", "abstract", "databanks",
                                            "authors", "mesh", "keywords",
                                            "pubtypes"),
                              # datatypes = c("keywords"#, "pubtypes"
                              #               ),
                              file_name = filename,
                              suffix = suffix,
                              dir = dir,
                              subdir = here("data", "tables"),
                              return = FALSE)
  suffix = suffix + 1
}
