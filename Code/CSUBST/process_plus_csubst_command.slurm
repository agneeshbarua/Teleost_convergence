#!/bin/bash --login

#SBATCH --job-name csubst_pipeline
#SBATCH --partition=cpu
#SBATCH --array=1-1004%50
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBTACH --mem-per-cpu=2G
#SBATCH --output=csubst.%A_%a.out
#SBATCH --error=csubst.%A_%a.out
#SBATCH --time 0-72:00:00

module load gcc miniconda3 mafft/7.481 trimal/1.4.1 emboss/6.6.0

conda activate ~/myproject_envs/Pigmentation_env/

#Array indexing
name=$(sed -n "$SLURM_ARRAY_TASK_ID"p og_list.txt) #og_list contains all the Orthgroups names in each line

outDir="./All_fish/02.CSUBST/output_csubst"
rm -r ${name}
mkdir ${name}


#copy sequences from store folder to working folder
cp /work/FAC/FBM/DEE/mrobinso/default/Agneesh/Projects/Pigmentation_project/All_fish/00.Seqs/For_CSUBST/${name}"_CDS.fa" .
python modify_fasta_header_with_key_value.py ${name}"_CDS.fa" ${name}"_modhead.fa" orth_sp_pairs.tsv
rm ${name}"_CDS.fa"
cat ${name}"_modhead.fa" | ./rename_duplicate_headers.sh > ${name}"_modhead2.fa"
rm ${name}"_modhead.fa"

#get the longest isoform for each gene (helps reduce false positives)
cdskit aggregate --seqfile ${name}"_modhead2.fa" --expression ":.*" --outfile ${name}"_modhead3.fa"

#remove the digit after the ":"
sed -i 's/:[0-9]//' ${name}"_modhead3.fa"
rm ${name}"_modhead2.fa"

#make nucleotide sequences in-frame by head and tail paddings
seqkit seq ${name}"_modhead3.fa" | cdskit pad --codontable 1 > ${name}/$name"_cds_pad.fa"

#translate cds into protein sequences
transeq -sequence ${name}/$name"_cds_pad.fa" -outseq ${name}/$name"_cds_trans.fa" -frame 1 -table 0

#remove the '_1' from header made by transeq
sed -i 's/_1$//' ${name}/$name"_cds_trans.fa"

#align the protein sequences
mafft --auto --thread 3 --amino ${name}/$name"_cds_trans.fa" > ${name}/$name"_cds_trans_pep_aligned.fa"

#translate align the protein alignment with unaigned cds
tranalign -table 0 -asequence ${name}/$name"_cds_pad.fa" -bsequence ${name}/$name"_cds_trans_pep_aligned.fa" -outseq ${name}/$name"_cds_tranaligned.fa"

#trim poorly aligned codon sites
trimal -in ${name}/$name"_cds_trans_pep_aligned.fa" -backtrans ${name}/$name"_cds_pad.fa" -out ${name}/$name"_cds_trimal_aligned.fa" -ignorestopcodon -automated1

#mask ambiguous and/or stop codons
cdskit mask --seqfile ${name}/$name"_cds_trimal_aligned.fa" --outfile ${name}/$name"_cds_mask_tranalign.fa"

#remove uninformative sites
cdskit hammer --seqfile ${name}/$name"_cds_mask_tranalign.fa" --outfile ${name}/$name"_cds_hammer.fa" --nail 4 --codontable 1

#iqtree to construct gene trees
iqtree -s ${name}/$name"_cds_hammer.fa" -m MFP -bb 1000 -nt AUTO -bnni --prefix ${name}/$name"_cds_hammer.fa" -wsr -asr

#run generax
bash ./run_generax.sh ${name}/$name"_cds_hammer.fa"

#convert nhx format to newick format
nwkit nhx2nwk --infile ${name}/$name"_generax"/reconciliations/family_1_reconciliated.nhx --outfile ${name}/$name"_generax.nwk" 
nwkit drop --infile ${name}/$name"_generax.nwk" --target intnode --name yes --outfile ${name}/$name"_generax2.nwk"

mkdir ${name}/csubst_all_clusts
cd ${name}/csubst_all_clusts

#Run CSUBST
csubst analyze --alignment_file ../$name"_cds_hammer.fa" \
               --rooted_tree_file ../$name"_generax2.nwk" \
               --threads 5 \
               --cutoff_stat 'OCNany2spe,5.0|omegaCany2spe,5.0' \
               --max_arity 10

#Move the CSUBST output # I have provided all these files in the Output_csusbt folder
#Please not that not all the following files will be produced. Only the arity values for which convergence was detected will be produced. 
mv csubst_cb_3.tsv $outDir/${name}"_"${fg_type}"_csubst_cb_3.tsv"
mv csubst_cb_4.tsv $outDir/${name}"_"${fg_type}"_csubst_cb_4.tsv"
mv csubst_cb_5.tsv $outDir/${name}"_"${fg_type}"_csubst_cb_5.tsv"
mv csubst_cb_6.tsv $outDir/${name}"_"${fg_type}"_csubst_cb_6.tsv"
mv csubst_cb_7.tsv $outDir/${name}"_"${fg_type}"_csubst_cb_7.tsv"
mv csubst_cb_8.tsv $outDir/${name}"_"${fg_type}"_csubst_cb_8.tsv"
mv csubst_cb_9.tsv $outDir/${name}"_"${fg_type}"_csubst_cb_9.tsv"
mv csubst_cb_10.tsv $outDir/${name}"_"${fg_type}"_csubst_cb_10.tsv"
mv csubst_tree.nwk $outDir/${name}"_"${fg_type}"_csubst_tree.nwk"

#Move files to reproduce analysis
mv ../${name}"_generax2.nwk" $outDir/
mv ../${name}"_cds_hammer.fa" $outDir/
mv ../${name}"_cds_hammer.fa.iqtree" $outDir/
mv ../${name}"_cds_hammer.fa.treefile" $outDir/
mv ../${name}"_cds_hammer.fa.mldist" $outDir/
mv ../${name}"_cds_hammer.fa.rate" $outDir/
mv ../${name}"_cds_hammer.fa.state" $outDir/
mv ../${name}"_cds_hammer.fa.log" $outDir/
