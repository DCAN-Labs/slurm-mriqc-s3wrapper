#!/bin/bash -l
#SBATCH -J mriqc_v23_2yr
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=6G
#SBATCH --tmp=350gb
#SBATCH -t 04:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lmoore@umn.edu
#SBATCH -p msismall,agsmall
#SBATCH -o mriqc_logs/mriqc_%A_%a.out
#SBATCH -e mriqc_logs/mriqc_%A_%a.err
#SBATCH -A faird

cd run_files.mriqc

module load singularity

file=run${SLURM_ARRAY_TASK_ID}

bash ${file}
