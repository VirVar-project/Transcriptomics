Analysis of transcriptomics on SAGA
================
Marius Saltvedt
9/28/2021

-   [1 VirVar transcriptomics](#virvar-transcriptomics)
    -   [1.1 Clean Raw data](#clean-raw-data)
        -   [1.1.1 The SAGA Script](#the-saga-script)
        -   [1.1.2 For-loop](#for-loop)
        -   [1.1.3 Copy files](#copy-files)
        -   [1.1.4 Creating softlinks
            (shortcuts)](#creating-softlinks-shortcuts)
    -   [1.2 Bowtie - Map reads to
        genome](#bowtie---map-reads-to-genome)
        -   [1.2.1 Map to reference genome](#map-to-reference-genome)
        -   [1.2.2 The SAGA script](#the-saga-script-1)
        -   [1.2.3 For-loop](#for-loop-1)
        -   [1.2.4 Results](#results)
    -   [1.3 Kallisto - Map reads to
        transcriptome](#kallisto---map-reads-to-transcriptome)
        -   [1.3.1 Map to CDSs](#map-to-cdss)
        -   [1.3.2 Softlinks](#softlinks)
        -   [1.3.3 The SAGA script](#the-saga-script-2)
        -   [1.3.4 For-loop](#for-loop-2)
        -   [1.3.5 Results](#results-1)
    -   [1.4 Other notes](#other-notes)

# 1 VirVar transcriptomics

-   **Anders Krabberød description:**
    <https://github.com/krabberod/VirVar_transcriptomes>  

-   **Visualize the sequence quality:**  

    -   Look at the quaility of the data by opening the FASTQ PDF file  
    -   Sequence report: phred score table  
    -   Sequencing forming a bridge that is read forward and reverse,
        but since it it deteriorates/get damaged quickly the reverse
        (R2) is always worse than forward strand (R1).  
          

-   **View the first line in the zip file:**  
    `zcat NAME.fastq.gz | head`  
      
      

## 1.1 Clean Raw data

-   Here you can choose from using `Cutadapt`, `Trimmomatic` and
    `Trim_galore`. For our analysis below we used `Trim_galore`.
    `Trim_galore` will remove adapters and primers (if present) and
    remove low quality sequences. (Trimmomatic can be run as a part of
    the Trinity!).  

### 1.1.1 The SAGA Script

-   Made a script for `Trim_galore` that we called `trim_galore.slurm`
    and contained the following script:

<!-- -->

    #!/bin/bash
    ## Name the job, arbitrary
    #SBATCH --job-name=trimgalore
    ## Project folder, every job must be accounted for
    #SBATCH --account=nn9845k 
    ## Text file of the commands that will be sent to the queue
    #SBATCH --output=slurm-%j.base 
    ## Every job requires a runtime limit
    #SBATCH --time=10:00:00
    ## Number of cpus needed
    #SBATCH --cpus-per-task=6
    ## Not needed unless more than one node is needed
    ##SBATCH --nodes=1
    ## Every job requires some specification of the memory (RAM) it needs
    #SBATCH --mem-per-cpu=8G
    ## Not needed unless more than one node is used
    ##SBATCH --partition=normal
    ## If you ask for more than 180G mem per cpu you need to specify bigmen
    ##SBATCH --partition=bigmen


    R1=$1 #Name for the first element
    R2=$2 #Name for the second element

    module purge
    module load Trim_Galore/0.6.2-foss-2018b-Python-3.6.6
    trim_galore $R1 $R2 --paired -j 6 #paired to R1 and R2, Tallet 6 må være det samme som cpus per task j = jobs/cpus.
     ESC

  
  

### 1.1.2 For-loop

-   Place the script together with all the samples (in our example it
    will be in the folder `1_data`). This directory is located in:
    `/cluster/projects/nn9845k/transcriptomics/1_PkVRF01_He028/1_data`  

-   While being `pwd` in this folder with the `Trim_galore.slurm` script
    you can run the following command in the terminal:  

<!-- -->

    for f in Sample_*; do
    cp trim_galore.slurm $f; 
    cd $f; 
    sbatch trim_galore.slurm *R1_001.fastq* *R2_001.fastq*; 
    cd ..; 
    done

-   This code will do the following prior to each semicolon `;`

    1.  For every folder (f) that is called Sample\_…
    2.  Copy script called trim_galore.slurm to this current folder (f),
    3.  Change directory to this folder (f),
    4.  Run the script in this folder (f) using the two fastq files R1
        and R2,
    5.  Go back to the main folder
    6.  done  
          

-   Remember that any for-loops must start and end with `do` and `done`,
    respectively. Every command is seperated by `;` or line-shift (above
    we did both).  

-   `R1` og `R2` in the script refer to `*R1_001.fastq*` and
    `*R2_001.fastq*`  

-   More info about trim_galore:
    <https://www.bioinformatics.babraham.ac.uk/projects/trim_galore/>

-   After loading `trim_galore` (module load) you can run:
    `trim_galore -help`  
    This might be helpful if you need to specify some parameters other
    than the standards given.  
      
      
      

### 1.1.3 Copy files

-   Copy the trimmed sequences to a new folder and keep the folder
    structure. This code will go into the folder directory `data`, go
    into all folders/directories that starts with `Sample_` and look for
    all files that contain `val` and copy the file and folder structure
    to new directory called `trimmed_sequences`.

<!-- -->

    rsync -avR data/Sample_*/*val* trimmed_sequences

  

### 1.1.4 Creating softlinks (shortcuts)

-   This loop creates new directories and softlinks (shortcuts) to the
    trimmed reads. You can use this instead of copying if you want to
    save space and avoid having to copy the same files multiple times.  

<!-- -->

    for f in Sample_*; do
    mkdir -p ./../3_genome_mapping/$f;
    REF=$(readlink -f $f);
    echo $REF;
    BACK=$(pwd);
    cd ./../3_genome_mapping/$f;
    ln -s $REF/*val* .;
    cd $BACK;
    done

1.  This code will into every folder that starts with `Sample_`
2.  It will then go one up the folder structure `..` and create a new
    directory `3_genome_mapping` and within this directory it will
    create the folder structure of `Sample_`.
3.  It will then create a softlink of the files in `Sample_` and save it
    as an object called `REF`.
4.  Next it will echo/print the object `REF`, which is every softlink it
    finds.
5.  It will save pwd (present-working-directory) as the object `BACK`.
6.  It will change directory to the newly created directory from step
    `2`.
7.  In this directory it will make and save the links (`ln`) of the
    files called *val* in this current directory (`.`).
8.  Change directory back to the starting folder.

  
  
  

## 1.2 Bowtie - Map reads to genome

-   Several mapping programs can be used, but for now we will use
    `bowtie` to map to the genome and `kallisto` (next section) to map
    to the orfs (predicted genes). `Kallisto` allows quantification.  
      

-   Download the reference genome of PkV RF01 with annotation from:

<!-- -->

    wget https://raw.githubusercontent.com/RomainBlancMathieu/PkV-RF01/master/PkV-RF01_final.gff
    wget https://raw.githubusercontent.com/RomainBlancMathieu/PkV-RF01/master/PkV-RF01_final.fnn
    wget https://raw.githubusercontent.com/RomainBlancMathieu/PkV-RF01/master/PkV-RF01_final.fasta
    wget https://raw.githubusercontent.com/RomainBlancMathieu/PkV-RF01/master/PkV-RF01_final.faa

  

### 1.2.1 Map to reference genome

-   After sequences have been trimmed by `trim_galore` we want to
    link/map the sequences to the virus genome by using `bowtie`.

-   Mapping requires that the reference is indexed. This command is
    performed in the folder where the genome is located. A couple of new
    files will be made starting with `PkV-RF01_final_genome*`.

<!-- -->

    module purge
    ml Bowtie2/2.4.4-GCC-10.3.0
    bowtie2-build PkV-RF01_final.fasta PkV-RF01_final_genome

  
  

### 1.2.2 The SAGA script

-   Next step is to place the bowtie.slurm script in the folder
    containing either a copy of trimmed galore sequences or softlinks to
    the trimmed galore sequences (see previous section of how we did
    this).

-   In the bowtie.slurm script you must set the location of the
    reference genome and the name you set in the bowtie-build command.
    Here we set the name as `PkV-RF01_final_genome`. The full location
    is
    `/cluster/projects/nn9845k/transcriptomics/3_PkVRF01_Pk033/PkVRF01_annotation/Genome/PkV-RF01_final_genome`

-   This is how your bowtie.slurm script should look like:

<!-- -->

    #!/bin/bash
    #SBATCH --job-name=bowtie
    #SBATCH --account=nn9845k
    #SBATCH --output=slurm-%j.base
    #SBATCH --time=1:00:00
    #SBATCH --cpus-per-task=16
    #SBATCH --mem-per-cpu=5G
    #SBATCH --partition=normal

    module purge
    #module load Bowtie2/2.3.5.1-GCC-8.2.0-2.31.1
    ml Bowtie2/2.4.4-GCC-10.3.0
    ml SAMtools/1.12-GCC-10.3.0

    REF=/cluster/projects/nn9845k/transcriptomics/3_PkVRF01_Pk033/PkVRF01_annotation/Genome/PkV-RF01_final_genome

    bowtie2 -p 16 --no-unal -x $REF -1 *R1* -2 *R2* > mapped.sam

    samtools sort -@ 16 mapped.sam > sorted.bam
    samtools index sorted.bam
    samtools view -h sorted.bam | cut -f 3,3 | grep 'PkV-RF01' | sort | uniq -c > counts.txt

  

### 1.2.3 For-loop

-   Now you must run this script for each sample with another for-loop

<!-- -->

    for f in Sample_*; do 
    cp bowtie.slurm $f; 
    cd $f; 
    sbatch bowtie.slurm *R1* *R2*; 
    cd ..; 
    done

### 1.2.4 Results

-   For each sample the results will include:

    -   **sorted.bam**: file with reads mapped/aligned to the reference
        genome
    -   **counts.txt**: a simple summary of the number of reads mapping
        to the reference  
          
          

## 1.3 Kallisto - Map reads to transcriptome

-   Mapping the reads to the CDSs using Kallisto.

-   kallisto will map to your predicted genes and allows quantification.
    (kallisto also runs/uses bowtie for mapping)

-   **Help section**  

    -   <https://pachterlab.github.io/kallisto/manual>  
    -   <https://pachterlab.github.io/kallisto/starting>  

-   If you only have the sequence position on genome, but not the
    sequences themselves, please see section below on `R`.

  
  
  

### 1.3.1 Map to CDSs

-   First we must make the database required for Kallisto to run. Use
    the CDS (Coding Domain Sequences) file of the genome (containing
    predicted ORFs).

<!-- -->

    module purge
    ml kallisto/0.46.1-foss-2020a
    kallisto index PkV-RF01_final.fnn -i PkV-RF01_final_cds

  
  

### 1.3.2 Softlinks

-   Next step is to place the kallisto.slurm script in the folder
    containing either a copy of trimmed galore sequences or softlinks to
    the trimmed galore sequences (see section
    `4.1.4 Creating softlinks`). Example of softlink:

<!-- -->

    for f in Sample_*; do mkdir -p ./../4_kallisto/$f; REF=$(readlink -f $f); echo $REF; BACK=$(pwd); cd ./../4_kallisto/$f; ln -s $REF/*val* .; cd $BACK; done

  
  

### 1.3.3 The SAGA script

-   In the kallisto.slurm script you must set the location of the
    reference genome and the name you set in the kallisto-build command.
    Here we set the name as `PkV-RF01_final_cds`. The full location is
    `/cluster/projects/nn9845k/transcriptomics/3_PkVRF01_Pk033/PkVRF01_annotation/PkV-RF01_final_cds`  

-   This is how your kallisto.slurm script should look like:

<!-- -->

    #!/bin/bash
    #SBATCH --job-name=kallisto
    #SBATCH --account=nn9845k
    #SBATCH --output=slurm-%j.base
    #SBATCH --time=12:00:00
    #SBATCH --cpus-per-task=16
    #SBATCH --mem-per-cpu=5G
    #SBATCH --partition=normal

    module purge
    ml kallisto/0.46.1-foss-2020a

    REF=/cluster/projects/nn9845k/transcriptomics/3_PkVRF01_Pk033/PkVRF01_annotation/PkV-RF01_final_cds
    OUT=kallisto_results
    R1=*R1_001_val_1*
    R2=*R2_001_val_2*


    kallisto quant -i $REF -t "$SLURM_CPUS_PER_TASK" -o $OUT $R1 $R2

-   Instead of specifying the number of cores in the kallisto script you
    can write a shortcut/reference instead. This way you will only need
    to change `cpus-per-task` without having to also change this number
    in the kallisto script. This is done by writing
    `-t "$SLURM_CPUS_PER_TASK"`

  
  

### 1.3.4 For-loop

-   Now you must run this script for each sample with another for-loop

<!-- -->

    for f in Sample_*; do 
    cp kallisto.slurm $f; 
    cd $f; 
    sbatch kallisto.slurm; 
    cd ..; 
    done

  
  

### 1.3.5 Results

-   For each sample these output files are provided:

    -   abundance.h5: a binary file with abundance estimates (used in
        the R analysis)
    -   abundance.tsv: a plaintext table of the abundance estimate for
        each gene
    -   run_info.json: information about the run  
         

-   **The abundance file (TSV)** will display the two columns `length`
    and `eff_length`. The `length` column displays the full length of a
    specific CDS, while the `eff_length` displays the lenght that is
    unique/specific to that CDS. Many CDSs have several repetitive
    regions (eg. ATATATATATAT) which is not distinct/specific to that
    CDS. This is the reason why the mapped region (`length`) is often
    shorter than gene itself (`eff_length`).  

-   **The abundance file (H5)** is just a binary file that can only be
    read by computers. The reason for this file is that is much more
    efficient for a computer to read such a file compared to a normal
    text-file that we can read.  

-   It is also possible to set bootstrap values for kallisto  
      

-   Now you can use the grep command to fish out specific genes. e.g.:

<!-- -->

    grep -w "gene_195" Sample_*/kallisto_results/abundance.tsv

  
  

## 1.4 Other notes

-   Final step prior to analysis in R is to unzip the kallisto files

-   DESeq do normalization of samples

-   Substract the virus mapping reads from the complete reads to get all
    host reads  
    See differences of host reads between infected vs control

-   samtools go into manual, to change mapping cutoff, do not need to
    rerun analysis  

-   sam file textfile (larger file)  

-   bam file compressed samfile, only readable by machine  

-   Combat-seq R package to normalize data when for instance you have
    data that are not from the same experiment or the data between
    replicates is “bulky”. For instance we should use this package if we
    want to compare data from two different infection experiment.
    <https://github.com/zhangyuqing/ComBat-seq>

  
  
