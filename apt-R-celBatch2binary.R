#!/usr/bin/env Rscript
if(!suppressPackageStartupMessages(require("optparse", quietly=TRUE))) {
  stop("the 'optparse' package is needed in order to run this script")
}

option_list <-
  list(make_option(c("-d", "--cdf"), help="CDF file name"),
       make_option(c("-o", "--output-file"), default="X.RData",
                   help="output RData file name [default: X.bin]"))

parser <- OptionParser(usage="%prog [options] cel-files", option_list=option_list)
arguments <- parse_args(parser, positional_arguments = TRUE)
opt <- arguments$options

celFiles <- arguments$args
if(length(celFiles)==0) {
  print_help(parser)
  quit("no")
}

## TODO
