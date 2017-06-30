#' @export
IDseq_umi_count <- function(
    IDseq_barcode_tbl = IDseq_split_data, output_filename = "IDseq_umi_count",
    output_dir = "output/data/") {
  # using dplyr package to easily summarize the counts for each row.
  IDseq_umi_count <- dplyr::tbl_df(IDseq_barcode_tbl) %>%
      dplyr::group_by(UMI, Barcode_1, Barcode_2, sample_folder, add = TRUE) %>%
      dplyr::summarize(row_occurence_count = n())

  output_filename <- utils::write.table(
      IDseq_umi_count,
      file = file.path(output_dir, paste0(output_filename, ".tsv")), sep = "\t",
      row.names = FALSE, col.names = TRUE)

  IDseq_umi_count
}

#' @export
IDseq_umi_count_frequency <- function(
    UMI_count_input = UMI_count,
    output_filename = "output/data/IDseq_umi_count_frequency") {
  UMI_count_frequency <- dplyr::tbl_df(UMI_count_input) %>%
      dplyr::group_by(row_occurence_count) %>%
      dplyr::summarize(count_frequency = n())

  # TODO: use data.table::fwrite
  # (https://github.com/Rdatatable/data.table/issues/580)
  utils::write.table(
      UMI_count_frequency, file = paste0(output_filename, ".tsv"), sep = "\t",
      row.names = FALSE, col.names = TRUE)

  UMI_count_frequency
}
