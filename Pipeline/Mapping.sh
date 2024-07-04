#!/bin/bash

# Set the number of CPUs to use
CPUS=12

# Define the output directory for BWA results
OUTPUT_DIR="/home/msi/monster/bwa_vf"

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Define the reference sequence paths and corresponding sample names
declare -A REFERENCES
REFERENCES=(
    ["LC758578.1, HQ442266.1"]="B2.fastq"
    ["LN680393.2, HQ442266.1, LC485018.1"]="B1.fastq"
    ["AJ619959.1, AJ270986.1"]="Prosthechea_radiata.fastq"
    ["LN680393.2, HQ442266.1, NC055568.1"]="Tradescantia_fluminensis.fastq"
    ["KP984504.1,LC485018.1,LC758578.1,MK066243.1,HQ442266.1,OQ953827.1"]="Zea_Mays.fastq"
)

# Function to download and process each reference and sample
process_sample() {
    local REFERENCE_IDS=$1
    local SAMPLE_NAME=$2

    # Create a directory for the sample within OUTPUT_DIR
    SAMPLE_DIR="$OUTPUT_DIR/${SAMPLE_NAME%.fastq}"
    mkdir -p $SAMPLE_DIR

    # Split the reference IDs
    IFS=',' read -ra REFS <<< "$REFERENCE_IDS"
    
    for REFERENCE_ID in "${REFS[@]}"; do
        # Trim whitespace
        REFERENCE_ID=$(echo $REFERENCE_ID | xargs)

        # Define paths
        REFERENCE_PATH="/home/msi/monster/Reference/${REFERENCE_ID}.fna"
        INDEX_PATH="${REFERENCE_PATH}.bwt"  # Assuming bwt index file for BWA

        # Check if reference file already exists
        if [ ! -f "$REFERENCE_PATH" ]; then
            echo "Downloading reference sequence for ${REFERENCE_ID}..."
            esearch -db nucleotide -query ${REFERENCE_ID} | efetch -format fasta > $REFERENCE_PATH
        else
            echo "Reference sequence ${REFERENCE_ID} already exists. Skipping download."
        fi

        # Index the reference sequence if index files do not exist
        if [ ! -f "${INDEX_PATH}" ]; then
            echo "Indexing reference sequence ${REFERENCE_ID}..."
            bwa index $REFERENCE_PATH
        else
            echo "Reference sequence ${REFERENCE_ID} is already indexed. Skipping indexing."
        fi

        # Continue with downloading reads, aligning them, and other processing steps
        READS_FILE="/home/msi/monster/no_shorties/${SAMPLE_NAME}"
        BASE_NAME=$(basename $READS_FILE .fastq)

        # Download reads using SRA Toolkit (if not already downloaded)
        if [ ! -f "$READS_FILE" ]; then
            echo "Downloading reads for ${SAMPLE_NAME}..."
            prefetch ${SAMPLE_NAME} -O /home/msi/monster/no_shorties/
            fasterq-dump /home/msi/monster/no_shorties/${SAMPLE_NAME}
        else
            echo "Reads for ${SAMPLE_NAME} already exist. Skipping download."
        fi

        # Align reads and sort them
        bwa mem -t $CPUS $REFERENCE_PATH $READS_FILE | samtools sort -@ $CPUS -o $SAMPLE_DIR/${BASE_NAME}_${REFERENCE_ID}_sorted.bam

        # Index the sorted BAM file
        samtools index $SAMPLE_DIR/${BASE_NAME}_${REFERENCE_ID}_sorted.bam

        # Extract reads with specific match lengths and mismatches
        for M in 21 22 23 24; do
            for N in 0 1 2; do
                samtools view $SAMPLE_DIR/${BASE_NAME}_${REFERENCE_ID}_sorted.bam | grep -w "${M}M" | grep "NM:i:${N}" > $SAMPLE_DIR/${M}nt_${N}MM_${REFERENCE_ID}.txt
            done
        done

        # Generate header
        samtools view -H $SAMPLE_DIR/${BASE_NAME}_${REFERENCE_ID}_sorted.bam > $SAMPLE_DIR/header_${REFERENCE_ID}.txt

        # Combine the filtered reads into a single BAM file
        cat $SAMPLE_DIR/header_${REFERENCE_ID}.txt $SAMPLE_DIR/21nt_0MM_${REFERENCE_ID}.txt $SAMPLE_DIR/21nt_1MM_${REFERENCE_ID}.txt $SAMPLE_DIR/21nt_2MM_${REFERENCE_ID}.txt $SAMPLE_DIR/22nt_0MM_${REFERENCE_ID}.txt $SAMPLE_DIR/22nt_1MM_${REFERENCE_ID}.txt $SAMPLE_DIR/22nt_2MM_${REFERENCE_ID}.txt $SAMPLE_DIR/23nt_0MM_${REFERENCE_ID}.txt $SAMPLE_DIR/23nt_1MM_${REFERENCE_ID}.txt $SAMPLE_DIR/23nt_2MM_${REFERENCE_ID}.txt $SAMPLE_DIR/24nt_0MM_${REFERENCE_ID}.txt $SAMPLE_DIR/24nt_1MM_${REFERENCE_ID}.txt $SAMPLE_DIR/24nt_2MM_${REFERENCE_ID}.txt > $SAMPLE_DIR/21-24nt_${REFERENCE_ID}.bam

        # Sort the combined BAM file
        samtools sort $SAMPLE_DIR/21-24nt_${REFERENCE_ID}.bam -o $SAMPLE_DIR/21-24nt_sorted_${REFERENCE_ID}.bam

        # Separate forward and reverse reads
        samtools view -F16 $SAMPLE_DIR/21-24nt_sorted_${REFERENCE_ID}.bam > $SAMPLE_DIR/21-24nt_012MM_For_${REFERENCE_ID}.txt
        samtools view -f16 $SAMPLE_DIR/21-24nt_sorted_${REFERENCE_ID}.bam > $SAMPLE_DIR/21-24nt_012MM_Rev_${REFERENCE_ID}.txt

        # Assemble the For and Rev files before calculating the depth
        cat $SAMPLE_DIR/header_${REFERENCE_ID}.txt $SAMPLE_DIR/21-24nt_012MM_For_${REFERENCE_ID}.txt > $SAMPLE_DIR/21-24nt_012MM_For_${REFERENCE_ID}.bam
        cat $SAMPLE_DIR/header_${REFERENCE_ID}.txt $SAMPLE_DIR/21-24nt_012MM_Rev_${REFERENCE_ID}.txt > $SAMPLE_DIR/21-24nt_012MM_Rev_${REFERENCE_ID}.bam

        # Calculate depth
        samtools depth -a $SAMPLE_DIR/21-24nt_012MM_For_${REFERENCE_ID}.bam > $SAMPLE_DIR/21-24nt_012MM_For_depth_${REFERENCE_ID}.txt
        samtools depth -a $SAMPLE_DIR/21-24nt_012MM_Rev_${REFERENCE_ID}.bam > $SAMPLE_DIR/21-24nt_012MM_Rev_depth_${REFERENCE_ID}.txt

        # Determine nucleotide distributions
        for M in 21 22 23 24; do
            for NT in A G C T; do
                samtools view $SAMPLE_DIR/21-24nt_sorted_${REFERENCE_ID}.bam | grep "${M}M" | cut -f10 | grep -i "^${NT}" | wc -l > $SAMPLE_DIR/${M}nt_${NT}_count_${REFERENCE_ID}.txt
            done
        done
    done
}

# Process each reference and sample
for REF_ID in "${!REFERENCES[@]}"; do
    SAMPLE_NAME=${REFERENCES[$REF_ID]}
    process_sample "$REF_ID" "$SAMPLE_NAME"
done
