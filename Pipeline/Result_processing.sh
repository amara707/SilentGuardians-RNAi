#!/bin/bash

# Define output and input directories 
output_dir=~/monster/Besthits
input_dir=/home/msi/monster/Blast

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# Loop through the files 
for read_file in "$input_dir"/*.txt; do
    if [ -f "$read_file" ]; then
        # Extract sample name from the file name without the extension
        sample_name=$(basename "$read_file" .txt)
        
        # Print debug information
        echo "Processing file: $read_file"
        echo "Sample name: $sample_name"
        
        # Sort the file and get the best hits
        export LANG=C
        export LC_ALL=C
        sort -k1,1 -k14,14gr -k13,13g -k3,3gr "$read_file" | sort -u -k1,1 --merge > "$output_dir/${sample_name}_best_hits.txt"
        
        # Check if the sort command was successful
        if [ $? -ne 0 ]; then
            echo "Error: Sorting failed for file $read_file"
        else
            echo "Successfully processed $read_file"
        fi
        
        # Reset LANG and LC_ALL
        unset LANG
        unset LC_ALL
    else
        echo "No files found in $input_dir"
    fi
done
