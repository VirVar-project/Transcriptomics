#!/bin/sh
#SBATCH --job-name=star
#SBATCH --account=nn9699k
#SBATCH --output=slurm-%j.base
##SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=6G
##SBATCH --partition=bigmem


START=$(date +%s)
echo "###################################################"
echo "# Started: "
echo "#     $(date)" 
echo "###################################################"
echo ""
module purge
module load STAR/2.7.10a_alpha_220818-GCC-10.3.0

STAR --runMode genomeGenerate --sjdbGTFfile PkV-RF01_final.gtf --genomeDir PkV-RF01 --genomeFastaFiles PkV-RF01_final.fasta --genomeSAindexNbases 9 --runThreadN $SLURM_CPUS_PER_TASK

# Computing runtime
secs=$(($(date +%s)-$START))
echo ""
echo "######################"
echo "Script finished: "
echo "    $(date)"
echo "Running time:"
#echo "#     $(($(date +%si)-$START)) seconds"
printf '%dd:%dh:%02dm:%02ds\n' $(($secs/86400)) $(($secs%86400/3600)) $(($secs%3600/60)) $(($secs%60)) 
echo "######################"

