#!/usr/bin/env Rscript
if(!require("optparse", quietly=TRUE)) {
  stop("the 'optparse' package is needed in order to run this script")
}

option_list <-
  list(
       make_option(c("-v", "--verbose"), action="store_true", default=TRUE,
                   help="Print extra output [default]"),
       make_option(c("-q", "--quietly"), action="store_false",
                   dest="verbose", help="Print little output"),
       make_option(c("-d", "--cdf"), help="CDF file name"),
       make_option("--rma", action="store_true", default=TRUE,
                   help="do RMA preprocessing [default]"),
       make_option("--no-rma", action="store_false", dest="rma",
                   help="skip RMA preprocessing (not yet implemented)"),
       make_option(c("-o", "--output-file"), default="X.RData",
                   help="output RData file name [default: X.RData]"),
       make_option("--keep-logs", action="store_true", default=FALSE,
                   help="keep intermediate output files in the current working directory [default: FALSE]")
       )

parser <- OptionParser(usage="%prog [options] cel-files", option_list=option_list)
arguments <- parse_args(parser, positional_arguments = TRUE)
opt <- arguments$options

celFiles <- arguments$args
if(length(celFiles)==0) {
  print_help(parser)
  quit("no")
}

print(opt)

if(is.null(opt$cdf)) {
  stop("you must specify a CDF file (-d option)")
}

outputDir <- if(opt$`keep-logs`) . else tempdir()
cmd <- paste("apt-probeset-summarize",
             if(opt$rma) paste("-a rma-sketch -o", outputDir) else "",
             "-d", opt$cdf,
             paste(celFiles, collapse=" "))
print(cmd)

txtOut <- file.path(outputDir, "rma-sketch.summary.txt")
system(cmd)
txtTemp <- tempfile()
system(paste("grep --invert-match ^#%.*", txtOut, ">", txtTemp))
X <- read.delim(txtTemp, sep="\t", comment.char="", as.is=TRUE)
X <- structure(t(as.matrix(X[,-1])), dimnames=list(colnames(X)[-1], X[,1]))
save(X, file="X.RData")
