library(clinicaltrialr)
results <- ct_read_results("http://www.clinicaltrials.gov/ct2/results?cond=Heart+Failure")
# Install and load pbapply to parallelize this step
if (!('pbapply' %in% installed.packages()[,"Package"])) install.packages("pbapply")

# Extract data from each trial (this is time-consuming)
# (note that you may need to use a different cl number if your CPU has less than 8 cores)
trials_list <- pbapply::pblapply(results$`NCT Number`, ct_read_trial, cl = 7)
trials <- dplyr::bind_rows(trials_list)

missing_idx <- grep("Error in open", trials_list)
missing_nct <- results$`NCT Number`[missing_idx]
missing_doc <- pbapply::pblapply(missing_nct, read_trials, cl = 7)
trials_list[missing_idx] <- missing_doc
trials <- dplyr::bind_rows(trials_list)

write_csv(trials, "../output/trial-records.csv")
