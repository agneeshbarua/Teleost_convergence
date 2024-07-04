#!/bin/bash --login

#SBATCH --job-name=OrthoFinder
#SBATCH --partition=cpu
#SBATCH --mem=50G
#SBATCH --cpus-per-task=40
#SBATCH --time=48:00:00
#SBATCH --mail-user=agneeshbarua@gmail.com
#SBATCH --mail-type=BEGIN,FAIL,END
#SBATCH --input=none
#SBATCH --output=%j.out
#SBATCH --error=%j.er

module load gcc python diamond/2.0.15

conda activate ~/myproject_envs/comparative_genomics/


orthofinder -t 40 -I 1.7 -f All_fish/primary_transcripts
~