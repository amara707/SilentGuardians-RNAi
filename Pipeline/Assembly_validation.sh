#QUAST
#!/bin/bash

# Specify the path to Quast
quast_path="/home/msi/quast-5.2.0/quast.py"

# Specify the Python interpreter
PYTHON="/usr/bin/python3"

# Define output directory for Quast results
output_dir="/home/msi/monster/QUAST"

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# Define the output directory for this run of Quast
quast_output_dir="$output_dir/Tradescantia_fluminensis"

# Set the number of threads for Quast
threads=12

# Run Quast command with specified parameters
"$PYTHON" "$quast_path" --threads "$threads" \
    -o "$quast_output_dir" --report-all-metrics -m 0 \
    "/home/msi/monster/Trinity/Fasta/Tradescantia_fluminensis_trinity.fasta" \
    "/home/msi/monster/Velvet/kmer_17/Tradescantia_fluminensis/contigs.fa" \
    "/home/msi/monster/Velvet/kmer_18/Tradescantia_fluminensis/contigs.fa" \
    "/home/msi/monster/Velvet/kmer_19/Tradescantia_fluminensis/contigs.fa" \
    "/home/msi/monster/Velvet/kmer_20/Tradescantia_fluminensis/contigs.fa" \
    "/home/msi/monster/Velvet/kmer_21/Tradescantia_fluminensis/contigs.fa" \
    "/home/msi/monster/Velvet/kmer_22/Tradescantia_fluminensis/contigs.fa" \
    "/home/msi/monster/Velvet/kmer_23/Tradescantia_fluminensis/contigs.fa" \
    "/home/msi/monster/Velvet/kmer_24/Tradescantia_fluminensis/contigs.fa" \
    "/home/msi/monster/Velvet/kmer_25/Tradescantia_fluminensis/contigs.fa"
