
<!-- README.md is generated from README.Rmd. Please edit that file -->

# TRN Proof of Principle Dataset

This repo generates the proof of principle dataset for trial
registration numbers for human clinical trials following the PubMed
query `'"clinical trial"[pt] NOT (animals [mh] NOT humans [mh])'`.

The analysis identifies PubMed records with trial registrations numbers
reported in the secondary identifier (aka databank, meta-data) and/or
the abstract.

The input proof of principle file, with included PMIDs, is in
`data-raw`.

The output proof of principle data set is available in `output` and
includes the following additional columns, where `abs` means “abstract”
and `si` means “secondary identifier”. The number (`#`) of columns
depends on the max number of trial registrations numbers per type:

-   `is_human_ct`
-   `abs_trn_#`
-   `abs_registry_#`
-   `si_trn_#`
-   `si_registry_#`

To reproduce the intermediary data, run the scripts in `R`.

## Data Visualizations

`07_visualize-trn-by-registry.R` creates UpSet plots for the secondary
identifier and abstract trial registration numbers.

![UpSet plot of registrations in
metadata](output/2021-01-11_si-registrations.png "upset-si")

![UpSet plot of registrations in
abstracts](output/2021-01-11_abs-registrations.png "upset-abs")

`08_visualize-trials-w-trn-by-source.R` creates shows the number of
trials with registration numbers reported by source, as well as the
total number of trials classified as human clinical trials by PubMed.
Note that a placeholder number is used for full-text.

![Bar plot of trials with registration numbers by
source](output/2021-01-14_trials_w_trn_by_source.png "trials-tn")
