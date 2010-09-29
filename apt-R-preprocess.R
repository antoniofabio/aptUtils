#!/usr/bin/env Rscript
if(!suppressPackageStartupMessages(require("optparse", quietly=TRUE))) {
  stop("the 'optparse' package is needed in order to run this script")
}

option_list <-
  list(
       make_option(c("-d", "--cdf"), help="CDF file name"),
       make_option(c("--files-list"), help="txt file containing the path to the files to be preprocessed"),
       make_option(c("-l", "--load-quantiles"), action="store_true", default=FALSE,
                   help="load previously computed quantiles, don't recompute them [default: FALSE]"),
       make_option(c("-q", "--quantiles-file"), default="quantiles.txt",
                   help="quantiles file name [default: quantiles.txt]"),
       make_option("--no-rma", action="store_false", dest="rma",
                   help="skip RMA preprocessing (not yet implemented)"),
       make_option(c("-o", "--output-file"), default="X.RData",
                   help="output RData file name [default: X.RData]"),
       make_option("--output-folder", default="",
                   help="output folder where to store logs and extra analysis results [default: trash everything]")
       )

parser <- OptionParser(usage="%prog [options] cel-files", option_list=option_list)
arguments <- parse_args(parser, positional_arguments = TRUE)
opt <- arguments$options

if(!is.null(opt$`files-list`)) {
  celFiles <- readLines(opt$`files-list`)
} else {
  celFiles <- arguments$args
}
if(length(celFiles)==0) {
  print_help(parser)
  quit("no")
}

if(is.null(opt$cdf)) {
  stop("you must specify a CDF file (-d option)")
}

outputDir <- opt$`output-folder`
if(outputDir=="") {
  outputDir <- tempdir()
}
cmd <- paste("apt-probeset-summarize -a rma-sketch -o", outputDir,
             if(opt$`load-quantiles`) paste("--target-sketch", opt$`quantiles-file`) else "--write-sketch",
             "-d", opt$cdf,
             paste(celFiles, collapse=" "))
aptVersion <- gsub("^version: apt-(.*?) .*", "\\1",
                   system("apt-probeset-summarize --version", intern=TRUE))
message("using Affymetrix Power Tools, version ", aptVersion)
message("console command:")
message(sQuote(cmd))

quantilesOriginalFileName <- file.path(outputDir, "rma-bg.quant-norm.normalization-target.txt")
txtOut <- file.path(outputDir, "rma-sketch.summary.txt")
system(cmd)
txtTemp <- tempfile()
system(paste("grep --invert-match ^#%.*", txtOut, ">", txtTemp))
X <- read.delim(txtTemp, sep="\t", comment.char="", as.is=TRUE)
X <- structure(t(as.matrix(X[,-1])), dimnames=list(colnames(X)[-1], X[,1]))
save(X, file="X.RData")

if(!opt$`load-quantiles`) {
  if(!file.copy(quantilesOriginalFileName, opt$`quantiles-file`, overwrite=TRUE)) {
    stop("can't store the quantiles file")
  }
}
