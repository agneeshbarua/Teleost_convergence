#!/bin/bash --login

#SBATCH --job-name site_a4
#SBATCH --partition=cpu
#SBATCH --array=1-420%100
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBTACH --mem-per-cpu=2G
#SBATCH --output=csubst.%A_%a.out
#SBATCH --error=csubst.%A_%a.out
#SBATCH --time 0-24:00:00

module load gcc miniconda3 mafft/7.481 trimal/1.4.1 emboss/6.6.0

conda activate ~/myproject_envs/Pigmentation_env/

main_DIR="./All_fish/02.CSUBST"
data_DIR="./All_fish/02.CSUBST/lastest_version"
cout_DIR="./All_fish/02.CSUBST/output_csubst"
ar="3"

#Array indexing; Adjust the branch values based on the arity used. This example in shown with arity=3; input are in /Datasets/csubst_site_input
name=$(awk 'BEGIN {FS=","} {print $1}' "All_Arity_"$ar".csv" | sed -n "$SLURM_ARRAY_TASK_ID"p)
b1=$(awk 'BEGIN {FS=","} {print $2}' "All_Arity_"$ar".csv" | sed -n "$SLURM_ARRAY_TASK_ID"p)
b2=$(awk 'BEGIN {FS=","} {print $3}' "All_Arity_"$ar".csv" | sed -n "$SLURM_ARRAY_TASK_ID"p)
b3=$(awk 'BEGIN {FS=","} {print $4}' "All_Arity_"$ar".csv" | sed -n "$SLURM_ARRAY_TASK_ID"p)
#b4=$(awk 'BEGIN {FS=","} {print $5}' "All_Arity_"$ar".csv" | sed -n "$SLURM_ARRAY_TASK_ID"p)
#b5=$(awk 'BEGIN {FS=","} {print $6}' "All_Arity_"$ar".csv" | sed -n "$SLURM_ARRAY_TASK_ID"p)
#b6=$(awk 'BEGIN {FS=","} {print $7}' "All_Arity_"$ar".csv" | sed -n "$SLURM_ARRAY_TASK_ID"p)
#b7=$(awk 'BEGIN {FS=","} {print $8}' "All_Arity_"$ar".csv" | sed -n "$SLURM_ARRAY_TASK_ID"p)
#b8=$(awk 'BEGIN {FS=","} {print $9}' "All_Arity_"$ar".csv" | sed -n "$SLURM_ARRAY_TASK_ID"p)
#b9=$(awk 'BEGIN {FS=","} {print $10}' "All_Arity_"$ar".csv" | sed -n "$SLURM_ARRAY_TASK_ID"p)
#b10=$(awk 'BEGIN {FS=","} {print $11}' "All_Arity_"$ar".csv" | sed -n "$SLURM_ARRAY_TASK_ID"p)
#rep=$(awk '{print $11}' Arity_9.txt | sed -n "$SLURM_ARRAY_TASK_ID"p)
#rep=$(awk '{print $12}' Arity_9.txt | sed -n "$SLURM_ARRAY_TASK_ID"p)


mkdir site_csubst/${name}"_csubst_site"
cd site_csubst/${name}"_csubst_site"
cp $data_DIR/${name}"_generax2.nwk" .
cp $cout_DIR/${name}"_all_csubst_tree.nwk" .
#nwkit drop --infile $name"_generax.nwk" --target intnode --name yes --outfile $name"_generax2.nwk"

csubst site --alignment_file $data_DIR/${name}"_cds_hammer.fa" \
--rooted_tree_file $name"_generax2.nwk" \
--branch_id ${b1},${b2},${b3} \
--pdb besthit \
--threads 2
