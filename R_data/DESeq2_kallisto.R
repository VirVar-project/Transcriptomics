### Firs load packages. You might have to install some of them. 
# 
# Exampels: 

# if (!requireNamespace("BiocManager", quietly = TRUE))
# install.packages("BiocManager")
# BiocManager::install(c("DESeq2","tximport","tximportData","tidyverse","ggplot2", "gplots","vsn","IHW","readxl","rhdf5","apeglm"))

# These are the libraries used: 
library("tximport")
library("DESeq2")
library("tximportData")
library("tidyverse")
library("ggplot2")
library("gplots")
library("vsn")
library("IHW")
library("readxl")
library("rhdf5")
library("apeglm")

#dir <- system.file("extdata", package = "tximportData")
#samples <- read.table(file.path(dir, "samples.txt"), header = TRUE)
#files <- file.path(dir, "kallisto_boot", samples$run, "abundance.h5")

# Import Kallisto-results 
files<-list.dirs("1_PkVRF01_He028_kallisko") %>% .[-1] %>% file.path(.,"abundance.h5") #Not normalized file

samples <- str_remove(files, "/abundance.h5") %>% 
  str_remove("1_PkVRF01_He028_kallisko/") #Clean up file, string remove
names(files) <- samples # Name file after sample
txi.kallisto <- tximport(files, type = "kallisto", 
                         txOut = TRUE, ignoreAfterBar = T) # Can run pseudomappers such as Kallisto, which is a k-mer pseudo counter. Approximation of gene expression, while STAR gives exact values.

metadata <- readxl::read_xlsx("Metadata_He028_PkVRF01.xlsx") # Read in metadata

# Quick heatmap to explore the data:
# based on counts and , wihtout reordering the samples:
heatmap(txi.kallisto$counts, Colv=NA, Rowv = NA) # Look on pseudocounts, not yet normalized
heatmap(txi.kallisto$counts) #Look at clustering based on similarities of expression levels, an example if we do not set parameters as we did above with Colv and Rowv
heatmap(txi.kallisto$abundance, Colv=NA,  Rowv = NA)


# Create the DESeq object: 
# DESeq: design = Treatment+ Replicate+Timepoints from the metadata sheet
# DeSeq will "know" and treat the data as replicate and will make it normalized per library

dds <- DESeqDataSetFromTximport(txi.kallisto, 
                              colData = metadata, #Read metadataset by above object
                              design=~Treatment+Replicates+Timepoints)

# First step in normalization, but might not capture really low/high input values in this linear model, might need a more complex one
dds <- DESeq(dds) # differential expression using GLM (generalized linear model)

# Tip:
# saveRDS(dds, "dds.rds") # so you can load this datamatrix OR you can save Rdata as below:
# save.image("all.Rdata") save data-working environment
# load("all.Rdata") if cleared environment you can just load it here. Would be good in Rmarkdown(?)