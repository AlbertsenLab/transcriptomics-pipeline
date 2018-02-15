#!/bin/bash


mkdir -p rawreads
mkdir -p procreads


echo "Finding your samples and copying to folder."
while read sample
do 
echo $sample
if ! ls rawreads/$sample*.fastq 1> /dev/null 2>&1; then 
# Find and unzip.
find /space/sequences/ -name $sample'_'*.gz 2>/dev/null -exec cp -t ./rawreads {} \;
gzip -d $(find -name $sample'_'*.gz)
# Rename.
rename 's/_.*.L00/:L/' ./rawreads/$sample*.fastq
rename 's/_//' ./rawreads/$sample*.fastq
rename 's/_.*/.fastq/' ./rawreads/$sample*.fastq
rename 's/:/_/' ./rawreads/$sample*.fastq
rename 's/-/_/' ./rawreads/$sample*.fastq
fi
done < samples

# QC.
if [ ! -e reads.fasta ]; then	
echo "QC - trimming and relabling"
mkdir -p procreads

for f in rawreads/*.fastq
do
	f=${f##*/}
	usearch10 -fastq_filter rawreads/$f -fastq_minlen 45 -fastq_truncqual 20 -fastaout procreads/$f.fa -threads 40 -relabel @ -quiet
done
cat procreads/*.fa > reads.fasta
rm -rf procreads
fi

