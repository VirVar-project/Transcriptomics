# See: http://bioconductor.org/help/course-materials/2016/CSAMA/lab-3-rnaseq/rnaseq_gene_CSAMA2016.html
# On saga: 
# Ask for interactive computing node:
# srun --account=nn9845k --mem-per-cpu=10G --time=10:00:00 --cpus-per-task=8 --pty bash -i
# Start running R:
# module load R/4.1.2-foss-2021b


# if (!require("BiocManager", quietly = TRUE))
#   install.packages("BiocManager")
# BiocManager::install("Rsubread")

library("Rsubread")
# fc <- featureCounts(files = "star_bam/Sample1.bam", 
#                     annot.ext = "star_bam/PkV-RF01_final.gtf", 
#                     isGTFAnnotationFile = TRUE,
#                     isPairedEnd = TRUE)
# You will need a list of the gene names, here we are using the same names
# as already used in the DESeq2 analysis. 
# rownames(fc$counts) <- rownames(dds)

# when you have multiple bam in a folder (mock-data): 

# files <- list.files("star_bam/Sample_01-a01va/", pattern = "bam", full.names =TRUE)
files <- list.dirs("star_bam_results") %>% .[-1] %>% file.path(.,"Aligned.out.bam")

# samples <- str_remove(files, "/Aligned.out.bam") %>% str_remove("star_bam_results/") #Clean up file, string remove
#names(files) <- samples # Name file after sample

fc <- featureCounts(files,
                    annot.ext = "star_bam_results/PkV-RF01_final.gtf", 
                    isGTFAnnotationFile = TRUE,
                    isPairedEnd = TRUE)

samples <- str_remove(files, "/Aligned.out.bam") %>% str_remove("star_bam_results/")

#rownames(fc$counts) <- rownames(dds)
rownames(fc$counts) <- paste0("gene_",1:nrow(fc2$counts))

colnames(fc$counts) <- samples

metadata<-readxl::read_xlsx("Metadata_He028_PkVRF01.xlsx")

### OBS Sample 74 is missing from the STAR output, this is why it did not match with the metadataset!!!!! Check SAGA

dds<-DESeqDataSetFromMatrix(fc$counts, 
                              colData = metadata, #metadata[1:9,], 
                              design=~Treatment+Replicates+Timepoints)

