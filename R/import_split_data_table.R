#' Import splitted FASTQ data into environment
#'
#' Using fread function, the IDseq_split_data.tsv file is imported and columns are named:
#' "UMI", "Barcode_1", "Barcode_2", "sample_folder"
#' 
#' @param .tsv file in a directory path.
#' @export
#' @examples
#' IDseq_import_split_data("output/data/IDseq_split_data.tsv")
IDseq_import_split_data <- function(
    
    ## ~12 minutes for ~50M observations
    split_data_file_path = "output/data/IDseq_split_data.tsv") {
  data.table::fread(
      input = split_data_file_path, sep = "\t", stringsAsFactors = FALSE,
      colClasses = c("character", "character", "character", "character"),
      header = FALSE,
      col.names = c("UMI", "Barcode_1", "Barcode_2", "sample_folder"))
}
