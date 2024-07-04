#!/bin/bash

# Define output and input directories 
output_dir=~/ESP/Filtered_contigs
input_dir=/home/msi/monster/Trinity/Fasta

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# Loop through the files 
for read_file in "$input_dir"/*.fasta; do
    if [ -f "$read_file" ]; then
        # Extract sample name from the file name
        sample_name=$(basename "$read_file" .fasta)
        # Run reformat
        /home/msi/Downloads/bbmap/reformat.sh in="$read_file" out="$output_dir/${sample_name}_filtered.fasta" minlength=700
    fi
done
