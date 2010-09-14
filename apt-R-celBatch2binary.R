#!/usr/bin/env Rscript
if(!suppressPackageStartupMessages(require("optparse", quietly=TRUE))) {
  stop("the 'optparse' package is needed in order to run this script")
}

option_list <-
  list(make_option(c("-d", "--cdf"), help="CDF file name"),
       make_option(c("-o", "--output-file"), default="X.bin",
                   help="output RData file name [default: X.bin]"),
       make_option(c("-p", "--progress"), action="store_true",
                   default=FALSE, help="show progress [default: FALSE]"))

parser <- OptionParser(usage="%prog [options] cel-files", option_list=option_list)
arguments <- parse_args(parser, positional_arguments = TRUE)
opt <- arguments$options
verbose <- opt$progress
cdfFile <- opt$cdf

celFiles <- arguments$args
if(length(celFiles)==0) {
  print_help(parser)
  quit("no")
}

stopifnot(!is.null(opt$cdf))

tmpOutDir <- tempdir()
tmpTxtFiles <- file.path(tmpOutDir, gsub("(.)\\.CEL$", "\\1.TXT", basename(celFiles)))
tmpBinFiles <- file.path(tmpOutDir, gsub("(.)\\.CEL$", "\\1.BIN", basename(celFiles)))

for(i in seq_along(celFiles)) {
  if(verbose) {
    cat('.')
  }
  cmd <- sprintf("apt-cel-extract -d %s -v 0 --pm-only -o %s %s",
                 cdfFile, tmpTxtFiles[i], celFiles[i])
  message("shell command: `", cmd, "`")
  system(cmd)
  y <- read.delim(tmpTxtFiles[i], sep="\t", colClasses=c(rep("NULL", 7), "integer"))[[1]]
  unlink(tmpTxtFiles[i])
  writeBin(y, tmpBinFiles[i], size=2, endian="little")
}
if(verbose) {
  cat('\n')
}

system(sprintf("cat %s > %s", paste(tmpBinFiles, collapse=" "), opt$`output-file`))
