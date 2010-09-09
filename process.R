#!/usr/bin/env Rscript
suppressPackageStartupMessages(library("optparse"))

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
                   help="skip RMA preprocessing"))

parser <- OptionParser(usage="%prog [options] cel-files", option_list=option_list)
arguments <- parse_args(parser, positional_arguments = TRUE)
opt <- arguments$options

if(length(arguments$args)==0) {
  print_help(parser)
  quit("no")
}

print(opt)

if(is.null(opt$cdf)) {
  stop("you must specify a CDF file (-d option)")
}

cmd <- paste("apt-probeset-summarize",
             if(opt$rma) "-a rma-sketch -o rma_output" else "",
             "-d", opt$cdf,
             paste(arguments$args, collapse=" "))
print(cmd)

if(FALSE) {
fileName <- commandArgs(trailingOnly=TRUE)

upn <- read.table("petacc3-phase1-list_of_244.dat", as.is=TRUE)$V1[-1]
map1 <- read.csv("../vlad_normalized/Sample-Chip-mapping.csv", as.is=TRUE)
map <- map1$ArrayNameUPDATE
names(map) <- map1$Patient.ID
files <- file.path("/export/scratch/PETACC3/phase1/petacc3-phase1-cel",
                   paste(map[upn], ".CEL", sep=""))
writeLines(c('cel_files', files), "celFiles.txt")

system("apt-probeset-summarize -a rma-sketch --write-sketch -d ../ADXCRCG2a520319.cdf -o rma_output --cel-files celFiles.txt")

X <- read.delim("rma_output/rma-sketch.summary.txt", sep="\t",
                comment.char="", skip=46+length(files))
save(X, file="X.RData")
}
