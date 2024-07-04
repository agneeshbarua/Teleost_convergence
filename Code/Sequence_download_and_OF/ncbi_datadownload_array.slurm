#!/bin/bash --login

#SBATCH --job-name ncbi_datasets
#SBATCH --partition=cpu
#SBATCH --array=1-142%20
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBTACH --mem-per-cpu=2G
#SBATCH --output=csubst.%A_%a.out
#SBATCH --error=csubst.%A_%a.out
#SBATCH --time 0-24:00:00

module load gcc miniconda3 mafft/7.481 trimal/1.4.1 emboss/6.6.0

conda activate ~/myproject_envs/Pigmentation_env/

#Array indexing
acc=$(awk '{print $1}' accessions_genomes.txt | sed -n "$SLURM_ARRAY_TASK_ID"p)
sp=$(sed -n "$SLURM_ARRAY_TASK_ID"p species_list.txt)
cds_dir="genomes_data/CDS_dat"
prot_dir="genomes_data/Protein_dat"
gff_dir="genomes_data/GFF_dat"

mkdir $cds_dir/${sp}
mkdir $prot_dir/${sp}
mkdir $gff_dir/${sp}

###### download cds data from ncbi ##########
./datasets download genome accession ${acc} --include cds --filename $cds_dir/${sp}/${sp}".zip"
unzip $cds_dir/${sp}/${sp}."zip" -d $cds_dir/${sp} 
mv $cds_dir/${sp}/ncbi_dataset/data/${acc}/cds_from_genomic.fna $cds_dir/${sp}/${sp}"_cds.fa"
rm $cds_dir/${sp}/README.md
rm -r $cds_dir/${sp}/ncbi_dataset

#### download protein data from ncbi #####
./datasets download genome accession ${acc} --include protein --filename $prot_dir/${sp}/${sp}".zip"
unzip $prot_dir/${sp}/${sp}."zip" -d $prot_dir/${sp}
mv $prot_dir/${sp}/ncbi_dataset/data/${acc}/protein.faa $prot_dir/${sp}/${sp}"_protein.fa"
rm $prot_dir/${sp}/README.md
rm -r $prot_dir/${sp}/ncbi_dataset

#### download gff data from ncbi #####
./datasets download genome accession ${acc} --include gff3 --filename $gff_dir/${sp}/${sp}".zip"
unzip $gff_dir/${sp}/${sp}."zip" -d $gff_dir/${sp}
mv $gff_dir/${sp}/ncbi_dataset/data/${acc}/genomic.gff $gff_dir/${sp}/${sp}".gff"
rm $gff_dir/${sp}/README.md
rm -r $gff_dir/${sp}/ncbi_dataset

#mkdir GFF_dat/${sp}
#curl -OJX GET "https://api.ncbi.nlm.nih.gov/datasets/v2alpha/genome/accession/"${acc}"/download?include_annotation_type=GENOME_GFF,SEQUENCE_REPORT&filename="${acc}".zip" -H "Accept: application/zip"
#mv ${acc}".zip" GFF_dat/${sp}
#unzip GFF_dat/${sp}/${acc}."zip" -d GFF_dat/${sp}
#mv GFF_dat/${sp}/ncbi_dataset/data/${acc}/genomic.gff3 GFF_dat/${sp}/${sp}".gff"
#rm GFF_dat/${sp}/README.md
#rm -r GFF_dat/${sp}/ncbi_dataset
