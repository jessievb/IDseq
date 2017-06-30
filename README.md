# General description

The IDseq R package contains functions that are useful to process sequencing reads from IDseq or related technologies. 
The immuno-Detection by sequencing is able to measure proteins via sequencing DNA-barcoded antibodies. The ID-seq package
is able to process the sequencing files from these experiments. 

The package allows to:

1. Extract reads from fastq files
2. Extract the following DNA sequences from the reads:
    - Unique Molecular Identifier (UMI)
    - Antibody barcode (BARCODE1)
    - Sample barcode (BARCODE2)
3. Create a data table with: 3 columns of DNA sequences (UMI, BARCODE1, BARCODE2) and 1 column with sequencing-index information  
4. Determine frequency of duplicate (or more) UMI DNA sequences
5. Create count table (Unique UMI) per antibody per sample.

# Install the IDseq package for usage in R

Download git repository

```
git clone 
```

Start R and install the following package

```r 
install.packages('devtools')

library(devtools)

```

set the folder with cloned repository as working directory

```r 
setwd()
```

Use Devtools to install locally the IDseq package

```
devtools::document()
devtools::install()
```


# Functions description

### (I) IDseq_split_reads()

split_reads function uses Shortread package to extract all reads from the FASTQ files. 
The fastq files can be zipped (fastq.gz), if doesn`t work have a look at 
if there is a change in the shortread package and file extensions that can be used.

What happens:

1. Load reads from separate small FASTQ.gz files  
2. approximate matches to anchor sequence (distance allowed, types of mismatches allowed)
3. Then, the UMI sequence, barcode 1 and barcode 2 were extracted from the reads via an regular expression 
4. Export: Table with - UMI  - BARCODE1 - BARCODE2 - Sequencing_ID. Also, a .log file with which file analysed and how many reads were split from that file.



### (II) IDseq_UMI_analysis()

What happens:

1. imports split_reads table after step (I)
2. Collapses exact duplicate rows count occurance of a row (duplicate number) (using in-house made umi_count function by counting duplicate rows)
3. save table with collapsed reads (UMI_count) and log number of unique reads in experiment
4. Calculate frequency of single, duplicate and more reads 
5. save UMI frequency table
6. Count number of UMI per barcode 1 per barcode 2 (is most simple way of counting UMI`s, can do this because most UMI are unique and we can not correct for PCR or sequence mistakes like using UMI tools oid)
7. create plots of barcode_count_histogram and UMI frequencies
