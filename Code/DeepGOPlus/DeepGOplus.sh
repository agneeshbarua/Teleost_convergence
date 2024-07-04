#!/bin/bash
#SBATCH --job-name deepgoplus_fish
#SBATCH --partition cpu
#SBATCH --nodes 1
#SBATCH --ntasks-per-node 1
#SBATCH --cpus-per-task 20
#SBTACH --mem 70G
#SBATCH --output deepgo.out
#SBATCH --error deepgo.err
#SBATCH --time 0-72:00:00
#SBATCH --mail-user=agneeshbarua@gmail.com
#SBATCH --mail-type=ALL

module load gcc python/3.7.10 diamond

source source /users/abarua/venv/bin/activate
pip install protobuf==3.9.2

deepgoplus --data-root ./data --in-file all_fish_protiens.fa --out-file all_fish_protiens_results.tsv