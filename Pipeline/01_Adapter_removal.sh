#BBDuk
find . -type f -name "*.fastq" -o -name "*.fq" | parallel -j 4 /home/msi/Downloads/bbmap/bbduk.sh in={} out={.}_clean.fastq ref=/home/msi/Downloads/bbmap/resources/adapters.fa ktrim=r k=21 mink=11 hdist=2 tpe tbo

#Cutadapt
#This is cutadapt 4.2 with Python 3.11.6

#!/bin/bash

# Create output directory if it doesn't exist
mkdir -p ~/monster/Cutadapt

# Iterate over each input file
for input_file in /home/msi/monster/Data/Banana/00/Raw_B_Sequences/*.fastq; do
    output_file=~/monster/no_shorties/$(basename "${input_file}") 
    cutadapt -a file:/home/msi/Downloads/bbmap/resources/adapters.fa -m 18 -j 12 -o "${output_file}" "${input_file}" 
done

#Trimmomatic 
!/bin/bash

# Set input directory and output directory
input_dir="/home/msi/ESP/00_Raw_sequences"
output_dir="/home/msi/ESP/Trimmomatic/00_Clean_sequences_Trimmomatic"

# Set Trimmomatic parameters
trimmomatic_jar="/usr/share/java/trimmomatic-0.39.jar"
adapters="/home/msi/Downloads/bbmap/resources/adapters.fa"
threads=12

# Iterate over each FASTQ file in the input directory
for file in "$input_dir"/*.fastq; do
    # Get the filename without extension
    filename=$(basename "$file" .fastq)
    # Run Trimmomatic on the current FASTQ file
    java -jar "$trimmomatic_jar" SE -threads "$threads" -phred33 "$file" "$output_dir"/"$filename"_trimmed.fastq ILLUMINACLIP:"$adapters":2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:15
done
