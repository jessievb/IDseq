# General Description

The R package *IDseq* contains functions that are used to process sequencing reads from the IDseq technology. The immuno-Detection by sequencing can measure proteins via sequencing DNA-tags from antibodies. 
The package allows to:

1. Import reads from FASTQ files and extracts the following DNA sequences from the reads:
    - Unique Molecular Identifier (UMI)
    - Antibody barcode (BARCODE1)
    - Sample barcode (BARCODE2)
2. Create a data table with three columns of DNA sequences (UMI, BARCODE1, BARCODE2) and 1 column with sample-index information. 
3. Report the frequency of duplicate (or more) UMI DNA sequences.
4. Create count table (Unique UMI) per antibody per sample.
5. Log the run and experiment information.

# Install and load IDseq package in R

## Quick and easy install directly from GitHub

The 'devtools' package allows installing the IDseq package from GitHub directly.

```r 
# First start R and install and load the devtools package
install.packages('devtools')
library(devtools)
```

```r
# Then install the IDseq package from the repository jessievb/IDseq
devtools::install_github("jessievb/IDseq")
```

```r
# Finally load the package
library(IDseq)
```
 ## Optional: install package after manual download

 #### Download package from GitHub

- Windows: [Direct download](https://github.com/jessievb/IDseq/archive/master.zip) from github

- Linux: Download via command line and git. If git is not installed, download it [here](https://git-scm.com/download/linux). Then run the following command: `git clone git@github.com:jessievb/IDseq.git`

```
# move into the folder with R packages (any folder you like)
cd ~/my-R-packages/

# download the IDseq package using git
git clone git@github.com:jessievb/IDseq.git
```


#### Install/deploy IDseq package in R

'Devtools' package also allows you to install a package from a local folder. Extra information on devtools package you can find [here](devtoolsinfo).

- Start R 
- Make sure working directory = the package directory   
- Run documentation and installation of the IDseq package (only once needed)  

```
setwd(~/my-R-packages/IDseq/) # Make sure working directory = folder with R-package
devtools::document() # to create documentation
devtools::install() # install package
```

```r
# Finally load the package
library(IDseq)
```

# Functions description

### (I) IDseq_split_reads()

IDseq_split_reads function uses ShortRead package to extract all reads from (zipped)  FASTQ files. 

1. Load reads from .FASTQ.gz files  
2. (Approximate) matches reads to anchor sequence 
3. Then, the UMI sequence, Barcode 1 and Barcode 2 were extracted from the reads via a regular expression 
4. Export: "splitreads.tsv": table with - UMI  - Barcode 1 - Barcode 2 - Sequencing_ID.
5. Run information is logged to output/exp_log/Run_info.log



### (II) IDseq_UMI_analysis()

This functions combines the following functions in order:
 1. IDseq_import_split_data()
 2. IDseq_umi_count()
 3. IDseq_umi_count_frequency()
 4. IDseq_barcode_count()
Also, it adds run and experiment information to the .log files in the output/exp_log/ folder. Finally it creates a bar and dotplot with the count distribution and UMI-duplicate rates in the output/figures/ folder

# Example workflow

## 1. Create the following experiment directory (via command line in linux)
```sh 
mkdir -p /home/Experiment_ID/{data,config,output/{data,exp_log,figures}}
```

## 2. Split reads


### In R (or R-studio)

```r
library(IDseq)
setwd(~/Experiment_ID/)
IDseq_split_reads(fastq_file="data/sample_1/sample_name.fastq.gz")
```


### From command line 
Start any number of processes, depending on the number of fastq.gz files to process:

```sh
# check if the command works. Should print all FASTQ filenames found in the indicated. Indicate behind -P how many cores should be used.
find Path_to_folders_with_fastqfiles/*/sample_name*__R1_0*.fastq.gz -name "*.fastq.gz" | xargs -P 4 -i -- echo "'{}'"

# copy command until -i , and then start R by using -- R -e
find Path_to_folders_with_fastqfiles/*/sample_name*__R1_0*.fastq.gz -name "*.fastq.gz" | xargs -P 4 -i -- R -e 'library(IDseq); setwd("~/Experiment_ID"); system.time(IDseq_split_reads(fastq_file="'{}'")); quit(save="no")'
```

## 3. Create .tsv files with antibody and sample index information

Save these two tables in the config folder

## 4. Analyze the split reads
Briefly, the following workflow can be followed:

```r
setwd(Experiment_folder)

## Combine different split read files into one: "output/data/IDseq_split_reads.tsv"
IDseq_analysis_splitreads(experiment_dir=getwd())
```

## 4. Match barcodes to antibody and samples
```r
## Import barcode count table into environment
barcode_count <- fread(input="output/data/barcode_count.tsv")

## match barcodes to antibody and samples. If no 100% match is found, the well_name and Ab_name (and other columns) receive value NA
barcode_count_matched <- IDseq_barcode_match()

## Filter all matched reads:
barcode_count_matched_filtered <- IDseq_barcode_match_filtered()

## Extra: 
not_matched_counts <- IDseq_barcode_match_na()
```