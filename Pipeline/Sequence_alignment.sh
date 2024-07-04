#!/bin/bash

# Define output and input directories 
output_dir=~/monster/Blast
input_dir=~/monster/Filtered_contigs
# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# Loop through the files 
for read_file in "$input_dir"/*.fasta; do
    if [ -f "$read_file" ]; then
        # Extract sample name from the file name
        sample_name=$(basename "$read_file" .fasta)
        # Run Blast
        blastn -query "$read_file" -db /home/msi/monster/Blast/DB/sequences.fasta -evalue 1e-3 -num_threads 12 -out "$output_dir/${sample_name}_blast_results.txt" -outfmt "6 qseqid sseqid stitle pident length mismatch gapopen qstart qend sstart send ppos evalue bitscore"
    fi
done
