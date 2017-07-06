#' @export
IDseq_analysis_splitreads <- function(experiment_dir, split_reads_table = "output/data/IDseq_split_reads.tsv") {
  ## First set working directory to experiment folder
  setwd(experiment_dir)

  ## Location of the log files
  futile.logger::flog.appender(
      futile.logger::appender.file("output/exp_log/experimental_info.log"),
      name = "1")
  futile.logger::flog.layout(futile.logger::layout.tracearg, name = "1")

  futile.logger::flog.appender(
      futile.logger::appender.file("output/exp_log/Run_info.log"), name = "2")
  futile.logger::flog.layout(futile.logger::layout.tracearg, name = "2")

  ## Log info
  futile.logger::flog.info(
      "Start experiment %s analysis", experiment_dir, name = "1")
  futile.logger::flog.info(
      "Import reads from experiment: %s", experiment_dir, name = "2")

  ## Import the total split
  IDseq_split_reads <- IDseq_import_split_data(split_reads_table)

  ## Log info
  split_reads_total <- nrow(IDseq_split_reads)
  futile.logger::flog.info("Total split reads in experiment %s: %d",
                           experiment_dir, split_reads_total, name = "1")

  ## Count row occurence and save tbl
  futile.logger::flog.info("Counting row occurence ... ", name = "2")
  UMI_count <- IDseq_umi_count(IDseq_barcode_tbl = IDseq_split_reads)

  ## Log info
  unique_reads_total <- nrow(UMI_count)
  futile.logger::flog.info("Total unique reads in experiment %s: %d",
                           experiment_dir, unique_reads_total, name = "1")

  ## Create UMI frequency table
  futile.logger::flog.info("Create UMI frequency tbl", name = "2")
  UMI_count_frequency <- IDseq_umi_count_frequency(UMI_count_input = UMI_count)

  ## Count UMI per barcode1 per barcode2
  futile.logger::flog.info(
      strwrap(
          "Counting total unique UMI strings per barcode1 per barcode2 per
          sample_folder ... "),
      name = "2")
  barcode_count <- IDseq_barcode_count(UMI_count_tbl = UMI_count)

  futile.logger::flog.info("Create plots", name = "2")
  ## Create plot of barcode counts (which shows the distribution of
  ## counts)
  ggplot2::ggplot(data = barcode_count, aes(antibody_count)) +
      ggplot2::geom_histogram(binwidth = 0.1)   +
      ggplot2::xlab("Antibody count") + ggplot2::ylab("frequency") +
      ggplot2::scale_x_log10() +
      ggplot2::scale_y_log10() + ggplot2::theme_bw()
    ggplot2::ggsave(
      "output/figures/barcode_count_histogram.eps", width = 5, height = 5)
 
  ## create plot of the UMI distribution
  ggplot2::ggplot(data = UMI_count_frequency,
                  aes(x = row_occurence_count, y = count_frequency)) +
      ggplot2::geom_point() +
      ggplot2::xlab("UMI occurance") + ggplot2::ylab("frequency") +
      ggplot2::scale_y_log10() + ggplot2::theme_bw()
  ggplot2::ggsave("output/figures/UMI_frequency.eps", width = 5, height = 5)
  
  futile.logger::flog.info("Finished analysis", name = "1")
  futile.logger::flog.info("Finished analysis", name = "2")
}
