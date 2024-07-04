#Trinity
#!/bin/bash

# Directory containing your reads
reads_dir="/home/msi/monster/no_shorties/B"

# Output directory for Trinity results
output_dir="/home/msi/monster/Trinity"

# Maximum memory to be used by Trinity
max_memory="24G"

# Number of CPU cores to use
num_cores=$(nproc)  # This will automatically detect the number of CPU cores

# Path to Trinity executable
trinity_path="/home/msi/Downloads/trinityrnaseq-v2.15.1/Trinity"

# Iterate through the files in the reads directory
for file in "$reads_dir"/*.fastq; do
    # Get the base filename without extension
    base=$(basename "$file" .fastq)

    # Run Trinity with single-ended reads
    "$trinity_path" --seqType fq --single "$file" --max_memory "$max_memory" --CPU "$num_cores" --output "$output_dir"/"${base}"_trinity
done

#Velvet
#!/bin/bash
#SBATCH --job-name=Velvet_Velveth_Velvetg
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH --time=168:00:00
#SBATCH --mem=24gb
#SBATCH --output=Velvet.%J.out
#SBATCH --error=Velvet.%J.err

# module load velvet
# Define input and output directories
input_dir="/home/msi/monster/no_shorties/"
output_dir=~/monster/Velvet/

# Make sure output directory exists
mkdir -p "$output_dir"

# Iterate through k-mer sizes from 15 to 25
for kmer in {15..25}; do
    # Create a subdirectory for each kmer value
    kmer_dir="$output_dir/kmer_$kmer"
    mkdir -p "$kmer_dir"
    
    # Iterate through all fastq files in the input directory
    for file in "$input_dir"/*.fastq; do
        if [ -f "$file" ]; then
            # Get the base filename without extension
            base=$(basename "$file" .fastq)
            sample_dir="$kmer_dir/$base"
            mkdir -p "$sample_dir"
            
            # Run velveth
            velveth "$sample_dir" "$kmer" -fastq -short "$file"
            
            # Check if velveth was successful
            if [ $? -ne 0 ]; then
                echo "Error: velveth failed for $file with kmer $kmer"
                continue
            fi
            
            # Run velvetg
            velvetg "$sample_dir" -exp_cov auto -cov_cutoff auto
            
            # Check if velvetg was successful
            if [ $? -ne 0 ]; then
                echo "Error: velvetg failed for $sample_dir"
            fi
        fi
    done
done
