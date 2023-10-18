### Firs load packages. You might have to install some of them. 
# 
# Exampels: 

if (!requireNamespace("BiocManager", quietly = TRUE))
install.packages("BiocManager")
BiocManager::install(c("DESeq2","tximport","tximportData","tidyverse","ggplot2", "gplots","vsn","IHW","readxl","rhdf5","apeglm"))

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

samples<-str_remove(files, "/abundance.h5") %>% str_remove("1_PkVRF01_He028_kallisko/") #Clean up file, string remove
names(files)<-samples # Name file after sample
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
dds<-DESeqDataSetFromTximport(txi.kallisto, 
                              colData = metadata, #Read metadataset by above object
                              design=~Treatment+Replicates+Timepoints)

# First step in normalization, but might not capture really low/high input values in this linear model, might need a more complex one
dds <- DESeq(dds) # differential expression using GLM (generalized linear model)
# saveRDS(dds, "dds.rds") # so you can load this datamatrix OR you can save Rdata as below:
# save.image("all.Rdata") save data-working environment
# load("all.Rdata") if cleared environment you can just load it here. Would be good in Rmarkdown(?)

# Examples from the tutorial
resultsNames(dds) # Based on the design from metadata
res <- results(dds, name = "Timepoints_13_vs_0") #Pick out specific name, must be from the Names in line above to spot differences, look at pvalue column, can arrange with reOrdered below.
resLFC <- lfcShrink(dds, coef="Timepoints_13_vs_0", type="apeglm") # log forms data to remove extremes of low/high values
resLFC

# We can order our results table by the smallest p value:
resOrdered <- res[order(res$pvalue),] # To spot significantly different values
resOrdered_2 <- resLFC[order(resLFC$pvalue),] # as above, but with log form data, this example shows the most differentially expressed genes between time points 13 and 01

# How many adjusted p-values were less than 0.01?
sum(res$padj < 0.01, na.rm=TRUE)
sum(resLFC$padj < 0.01, na.rm=TRUE)

# See what can be done with the results() function: 
# ?results
res05 <- results(dds, alpha=0.05)# add contrast as a parameter to include design setup, e.g. to include/exclude control/infected and so on. e.g. contrast = c("A", "B", "C"), look into manual on how to do this
summary(res05) # Look at how many genes are up-regulated and how many are down-regulated
sum(res05$padj < 0.05, na.rm=TRUE)


# Independent hypothesis weighting
# (unevaluated code chunk)

resIHW <- results(dds, filterFun=ihw)
summary(resIHW)
sum(resIHW$padj < 0.05, na.rm=TRUE)
metadata(resIHW)$ihwResult

plotMA(res, ylim=c(-2,2)) # Scewed because only looking at viral data, should filter out control
plotMA(resLFC, ylim=c(-2,2))

# Plotting the gene with lowest p-value:  
plotCounts(dds, gene=which.min(res$padj), intgroup="Timepoints") # Find the gene that changes the most over time, which in this case is 38
plotCounts(dds, 892, intgroup="Timepoints") # See how the normalized expression changes over time for specific gene
plotCounts(dds, 940, intgroup="Timepoints")
plotCounts(dds, 637, intgroup="Timepoints")
plotCounts(dds, 522, intgroup="Timepoints")
plotCounts(dds, 522, intgroup="Treatment")
plotCounts(dds, 522, intgroup=c("Replicates", "Treatment"))
# Using a for loop you can plot 10 plots side by side of the 10 genes with lowest p-value (changes the most in expression during the infection)

p1 <- plotCounts(dds, 522, intgroup=c("Timepoints","Treatment","Replicates"),
                 returnData=TRUE)

# You can also take the data above and represent it using ggplot:
d <- plotCounts(dds, gene=which.min(res$padj), intgroup="Timepoints", 
                returnData=TRUE)

ggplot(d, aes(x=Timepoints, y=count)) + 
  geom_point(position=position_jitter(w=0.1,h=0.0)) + 
  scale_y_log10(breaks=c(25,100,400))

# Add treatment as color
library("ggeasy")
library("ggpubr")
ggplot(p1 , aes(x=Timepoints, y=count, color = factor(Treatment))) + # Can change Treatment to Replicate
  geom_point(position=position_jitter(w=0.1,h=0.0)) +
  easy_add_legend_title("Treatment") +
  ggtitle(paste("Gene xxx"))
# + 
#scale_y_log10(breaks=c(25,100,400))


ordered_genes <- rownames(resOrdered) %>% 
  str_split_fixed("_",2) %>% .[,2] %>%  as.numeric()
genes_of_interest <- ordered_genes[1:9] # Change to e.g. 10:19 to get the next ones
genes_of_interest_2 <-  c(32,556,25,50) # extract specific genes

list_of_plots <-list()

for(i in 1:length(genes_of_interest))
{
  list_of_plots[[i]]  <- plotCounts(dds, genes_of_interest[i], 
                                    intgroup=c("Timepoints","Treatment","Replicates"),
                                    returnData=TRUE) %>% 
    ggplot(aes(x=Timepoints, y=count, color = factor(Treatment))) + 
    geom_point(position=position_jitter(w=0.1,h=0.0)) +
    easy_add_legend_title("Treatment") +
    ggtitle(paste("Gene",  genes_of_interest[i]))
}

ggarrange(plotlist=list_of_plots, ncol = 3, nrow = 3)

# ggsave("top9genes.pdf", width = 15, height = 15)

### ADDING SE TO PLOT
library(Rmisc)
p1.1 <- p1 %>% summarySE(measurevar="count", groupvars=c("Timepoints","Treatment"))

ggplot(p1.1 , aes(x=Timepoints, y=count, color = factor(Treatment))) + # Can change Treatment to Replicate
  geom_point() +
  geom_errorbar(aes(ymin=count-se, ymax=count+se, color = Treatment), width=.5) +
  easy_add_legend_title("Treatment") +
  ggtitle(paste("Gene xxx")) +
  theme_classic()

### ADDING SE TO MATRIX OF PLOTS
list_of_plots <-list()

for(i in 1:length(genes_of_interest))
{
  list_of_plots[[i]]  <- plotCounts(dds, genes_of_interest[i], 
                                    intgroup=c("Timepoints","Treatment","Replicates"),
                                    returnData=TRUE) %>% summarySE(measurevar="count", groupvars=c("Timepoints","Treatment")) %>% 
    ggplot(aes(x=Timepoints, y=count, color = factor(Treatment))) + 
    geom_point() +
    geom_errorbar(aes(ymin=count-se, ymax=count+se, color = Treatment), width=.5) +
    easy_add_legend_title("Treatment") +
    ggtitle(paste("Gene",  genes_of_interest[i])) +
    theme_classic()
}

ggarrange(plotlist=list_of_plots, ncol = 3, nrow = 3)


# WGCNA: weighted gene co-expression network analyses
## Can be used to correlate genes.
## Google WGCNA with DeSeq2, to use the normalized data from Deseq2.
## WGCNA can also normalize data, but should avoid this to use the same normalized data.
## Possibly generate a table that can be used in network analysis in cytoscape
## exportNetworkToCytoscpae in WGCNA

df <- resOrdered %>% as.data.frame()

ggplot(df, (aes(x = log2FoldChange, y = -log10(padj)))) +
  geom_point(alpha=0.4, size=0.5) +
  geom_vline(xintercept=c(-1,1),lty=4,col="black",lwd=0.2) +
  geom_hline(yintercept = 1.301,lty=4,col="black",lwd=0.2) +
  labs(x="log2(fold change)",
       y="-log10 (adj.p-value)",
       title="Volcanoplot")  +
  theme_bw()+
  theme(plot.title = element_text(hjust = 0.5), 
        legend.position="right", 
        legend.title = element_blank())


colData(dds)
resMFType <- results(dds, contrast=c("Timepoints","02","ar"))


# Transformation: 
ntd <- normTransform(dds) # A way of extracting data from Deseq matrix to a form that is possible to plot
meanSdPlot(assay(ntd))

#Heatmap with clustering and aggregation of rows: 
# The function also allows to aggregate the rows using kmeans clustering. 
# This is advisable if number of rows is so big that R cannot handle their hierarchical clustering anymore, roughly more than 1000. 

library("pheatmap")
select <- order(rowMeans(counts(dds,normalized=TRUE)), #extract count data
                decreasing=TRUE)[1:20] #Picking top 20 in row means for particular gene and order it

select.all <- order(rowMeans(counts(dds,normalized=TRUE)), #extract count data
                decreasing=TRUE)

df <- as.data.frame(colData(dds)[,c("Replicates","Timepoints")])

pheatmap(assay(ntd)[select,], #can also use the object we created earlier "genes_of_interest" (change "select"), this will show most differently expressed genes instead of highest expressed
         cluster_rows=FALSE, #Turn on cluster row, can group the genes, maybe include 100s of genes to cluster
         show_rownames=TRUE, #Can be changed to True to show gene names
         cluster_cols=FALSE, #Cluster the time points, still almost in the same order, which is really good
         #kmeans_k = 20,
         annotation_col=df)


plotPCA(ntd, intgroup="Timepoints",ntop = 500) #Principal component analyses, can change to Replicate etc



### Redo without the control. I.e. Subset to only virus

dds_vir <- dds[, dds$Treatment %in% "v"] #Extract only virus transcripts, look for "v" in metadata
# dds_01_and_14 <- dds[, dds$Timepoints %in% c("01", "14")] # Can also extract specific timepoint
# If you want to remove the resistant culture
`%notin%` <- Negate(`%in%`)
dds_vir<-dds_vir[, dds_vir$Timepoints %notin% "ar"] # Removing resistant

resultsNames(dds_vir)
res_vir <- results(dds_vir, name = "Timepoints_13_vs_01")
resLFC_vir <- lfcShrink(dds_vir, coef="Timepoints_13_vs_01", type="apeglm")
resLFC_vir

plotCounts(dds_vir, gene=which.min(res_vir$padj), intgroup="Timepoints")
d <- plotCounts(dds_vir, gene=which.min(res_vir$padj), intgroup="Timepoints", 
                returnData=TRUE)

ggplot(d, aes(x=Timepoints, y=count)) + 
  geom_point(position=position_jitter(w=0.1,h=0.0)) + 
  scale_y_log10(breaks=c(25,100,400))

ntd_vir <- normTransform(dds_vir)
meanSdPlot(assay(ntd_vir))
pheatmap(assay(ntd_vir)[select,], 
         cluster_rows=FALSE, 
         show_rownames=TRUE,
         cluster_cols=FALSE, 
         annotation_col=df)
# heatscale, normalized counts from DeSeq, which is extracted by first line normTransform(dds_vir)
# Can take the mean of replicates
# Keep this figure in supplementary to provide evidence that the replicates are similar.

plotPCA(ntd_vir, intgroup="Timepoints",ntop = 1100) #Take all of them, can also just show top 500
# You can see that they are clustered as early, mid and late phase.
# as an example we can make elipse around the different time phases

# ?hclust base clustering in R.

#RDA explain the variation over time, or night vs day etc.

#etc. etc 

