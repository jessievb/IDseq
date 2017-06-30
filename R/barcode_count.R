#' Count the number of unique UMI per Barcode_1 and Barcode_2 columns.

#' The data table that should be used is the IDseq_UMI_count table, which
#' contains all the unique (collapsed) UMI,
#' barcode_1 and barcode_2 information. The column row_occurence_count can be
#' ignored.
#' @export
IDseq_barcode_count <- function(
    UMI_count_tbl = UMI_count, output_filename = "output/data/barcode_count") {
  barcode_count <- UMI_count_tbl %>%
      dplyr::group_by(Barcode_1, Barcode_2, sample_folder) %>%
      dplyr::summarize(antibody_count = n())

  utils::write.table(barcode_count, file = paste0(output_filename, ".tsv"),
                     sep = "\t", row.names = FALSE, col.names = TRUE)

  barcode_count
}

#' Add antibody and sample specific information to the table with barcode
#' counts.
#'
#' The function makes use of the dplyr package 'left_join' option. If there is
#' a direct match between shared columns of data table and the input tables
#' antibody_barcode_index and well_barcode_index.
#' @export
IDseq_barcode_match <- function(
    barcode_count_tbl = barcode_count,
    output_filename = "output/data/barcode_count_matched") {
  # TODO: rename tab-separated table files (TSV) to .tsv, since that will
  # not surprise and confuse the user.  Needed are two txt files (tab
  # separated) with known barcode sequences and their corresponding
  # information The column name of the antibody barcode sequences should
  # be exactly matching with the column name in the barcode_count table
  antibody_barcode_tbl <- tbl_df(
      read.table("config/antibody_barcode_index.txt", header = TRUE,
                 stringsAsFactors = FALSE))
  # To add the well specific information both column 'Barcode_2' and
  # 'sample_folder' should be present in the txt file !
  well_barcode_tbl <- tbl_df(
      read.table("config/well_barcode_index.txt", header = TRUE,
                 stringsAsFactors = FALSE))

  barcode_count_tbl$Barcode_1 <- as.character(barcode_count_tbl$Barcode_1)
  barcode_count_tbl$Barcode_2 <- as.character(barcode_count_tbl$Barcode_2)

  barcode_count_matched <- barcode_count_tbl %>%
      dplyr::left_join(antibody_barcode_tbl, copy = TRUE) %>%
      dplyr::left_join(well_barcode_tbl, copy = TRUE)

  utils::write.table(
      barcode_count_matched, file = paste0(output_filename, ".tsv"), sep = "\t",
      row.names = FALSE, col.names = TRUE)

  return(barcode_count_matched)

}

#' @export
IDseq_barcode_match_na <- function(
    barcode_count_matched_tbl = barcode_count_matched) {
  barcode_count_NA <- barcode_count_matched_tbl %>%
      dplyr::filter(is.na(Ab_name) | is.na(well_name))
}

#' @export
IDseq_barcode_match_filtered <- function(
    barcode_count_matched_tbl = barcode_count_matched) {
  barcode_count_matched_filtered <- barcode_count_matched_tbl %>%
      dplyr::filter(!is.na(Ab_name) & !is.na(well_name))
}
