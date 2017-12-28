## 1) Load reads from separate small FASTQ.gz files
## 2) The reads will be split in UMI and BARCODE1 strings
## 3) also a column with sample-ID will be added before 
## 4) export a .tsv file with columns: - UMI  - BARCODE1 - BARCODE2 - SequencingID

IDseq_load_reads <- function(fastq_file) {
  FASTQ_data <- ShortRead::readFastq(fastq_file)
  reads <- ShortRead::sread(FASTQ_data)
  reads <- as.character(reads)
}

## First function uses Shortread package to extract all reads from the FASTQ files. 
## The fastq files can be zipped (fastq.gz), if doesn`t work have a look at 
## if there is a change in the shortread package and file extensions that can be used.
ANCHOR <- "(ATCAGTCAACAGATAAGCGA)"
REGULAR_EXPRESSION_PATTERN <- paste0(
  "[ACTGN]+([ACTGN]{15,15})([ACTGN]{10,10})", ANCHOR,
  "([ACTGN]{10,10})[ACTGN]+")

#' Split reads from FASTQ files into UMI, antibody barcode and sample barcode sequence.
#'
#' First, the IDseq_split_reads function uses shortread package function "readFastq" to load all reads from
#' a .fastq or .fastq.gz file. 
#' The fastq files can be zipped (fastq.gz), if doesn`t work have a look at 
#' if there is a change in the shortread package and file extensions that can be used.  
#' Then the reads containing an anchor sequence are extracted 
#' and these reads are split to retrieve - UMI - Barcode_1 - Barcode_2 sequences (and stored in a table with 3 columns)
#' Finally a column with the sequencing_ID (folder name that contained the fastq file) is added.
#' @param fastq_file fastq formatted files in a directory path. Default settings from \code{\link{ShortRead::readFastq}}
#' @return Saves a .tsv file with four columns: UMI , Barcode_1 , Barcode_2, sample_ID. Location of file: workingdir/output/data/
#' @seealso for -importing reads from fastq- information ShortRead::readFastq
#' @export
#' @examples
#' IDseq_split_reads("experiment/data/seq_id/sample-ID.fastq.gz", matching_distance = 2) 
IDseq_split_reads <- function(fastq_file, matching_distance = 2) {
  ## Create log files
  futile.logger::flog.appender(
      futile.logger::appender.file("output/exp_log/experimental_info.log"),
      name = "1")
  futile.logger::flog.layout(futile.logger::layout.tracearg, name = "1")
  futile.logger::flog.appender(
      futile.logger::appender.file("output/exp_log/Run_info.log"), name = "2")
  futile.logger::flog.layout(futile.logger::layout.tracearg, name = "2")


  futile.logger::flog.info("Loading reads from '%s' ...", fastq_file,
                           name = "2")

  reads <- IDseq_load_reads(fastq_file)
  # reads <- reads[1:10]

  futile.logger::flog.info("Split reads from '%s' ...", fastq_file, name = "2")

  anchor_matches <- stringr::str_match(reads, REGULAR_EXPRESSION_PATTERN)


  ## Determine which row numbers contain `NA` (not 100% matched).
  row_index_for_aregexec <- which(is.na(anchor_matches[, 1]))

  ## Use the list with row numbers to perform approximate matching on the
  ## left sequences. with aregexec the 'rownumbers' an index is create
  ## where there is approximate match with max.distance of 2 With
  ## max.distance the number of mismatches that are allowed can be set. In
  ## our system we allow 10% mismatch.
  approximate_matches_index <- utils::aregexec(
      REGULAR_EXPRESSION_PATTERN, reads[row_index_for_aregexec],
      max.distance = matching_distance)
  futile.logger::flog.info("Matching distance: '%s' ...", matching_distance, name = "2")
  ## Creates a matrix with 5 columns | Read | UMI | Barcode_1 | anchor |
  ## Barcode_2 | of all 'approximated matches' via `regmatches())` that
  ## only uses the reads not having 100% match
  ## (`reads[row_index_for_aregexec]`) and only matches with an allowed
  ## distance of 2 via list of `approximate_matches_index`.
  approximate_matches <- matrix(unlist(regmatches(reads[row_index_for_aregexec],
                                                  approximate_matches_index)),
                                byrow = TRUE, ncol = 5)

  ## TODO: replace rbind with rbindlist van data.table? is faster.  TODO:
  ## Maybe use data.table whereever possible instead of dplyr?
  ## Concatenate the rows of the 100% matches and approximate matches
  ## matrix.
  anchor_matches <- rbind(anchor_matches, approximate_matches)

  colnames(
      anchor_matches) <- c("Read", "UMI", "Barcode_1", "anchor", "Barcode_2")

  remove(reads, approximate_matches, row_index_for_aregexec,
         approximate_matches_index)

  ## Creates 'clean' table (usable by dplyr) from matched sequences that
  ## contains 3 columns UMI, Barcode_1 (= Antibody) and Barcode_2 (=
  ## Well).
  fastq_folder <- basename(dirname(fastq_file))

  data <- dplyr::data_frame(
              anchor_matches[, 2], anchor_matches[, 3], anchor_matches[, 5]) %>%
      na.omit() %>% dplyr::mutate(sample_folder = fastq_folder)  # %>%
  # dplyr::mutate_each(funs(as.character))
  colnames(data) <- c("UMI", "Barcode_1", "Barcode_2", "sample_folder")

  remove(anchor_matches)

  file_name <- basename(
      tools::file_path_sans_ext(file_path_sans_ext(fastq_file)))
  save_split_data_name <- paste0("split", file_name, ".tsv")
  
  workingdirectory <- getwd()
  location_dir <- paste0(workingdirectory, "/output/data")

  utils::write.table(data, file = file.path(location_dir, save_split_data_name),
                     sep = "\t", row.names = FALSE, col.names = FALSE)

  futile.logger::flog.info(
      "Total split reads from: %s = %d", fastq_file, nrow(data), name = "1")

  futile.logger::flog.info(
      "Saved data file in %s ...", location_dir, name = "2")

  data
}
