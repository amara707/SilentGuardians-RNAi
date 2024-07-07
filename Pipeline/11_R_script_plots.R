#Preparing_data_for_R_script
#!/bin/bash

# Directories and files
OUTPUT_DIR="/home/msi/monster/bwa_vf/R_man"
BAM_FILES=(
    "/home/msi/monster/bwa_vf/B1/B1_HQ442266.1_sorted.bam" 
    "/home/msi/monster/bwa_vf/B1/B1_LC485018.1_sorted.bam" 
    "/home/msi/monster/bwa_vf/B1/B1_LN680393.2_sorted.bam"
)
SAMPLE_NAMES=(
    "M. acuminata AAA Group_HQ442266.1"
    "M. acuminata AAA Group_LC485018.1"
    "M. acuminata AAA Group_LN680393.2"
)

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Extract coverage data using samtools and convert to CSV
for i in "${!BAM_FILES[@]}"; do
    BAM_FILE="${BAM_FILES[$i]}"
    SAMPLE_NAME="${SAMPLE_NAMES[$i]}"
    
    NEGATIVE_COVERAGE_FILE="$OUTPUT_DIR/negative_coverage_${SAMPLE_NAME}.csv"
    POSITIVE_COVERAGE_FILE="$OUTPUT_DIR/positive_coverage_${SAMPLE_NAME}.csv"
    
    # Initialize files with headers
    echo "chromosome,position,coverage" > "$NEGATIVE_COVERAGE_FILE"
    echo "chromosome,position,coverage" > "$POSITIVE_COVERAGE_FILE"
    
    # Extract coverage data using samtools and separate positive/negative coverage
    samtools depth -a "$BAM_FILE" | awk -v neg="$NEGATIVE_COVERAGE_FILE" -v pos="$POSITIVE_COVERAGE_FILE" '
    {
        if ($3 < 0) {
            print $1","$2","$3 >> neg
        } else {
            print $1","$2","$3 >> pos
        }
    }'
done


#R_script 
library(ggplot2)

# Define the base directory and sample names
base_dir <- "/home/msi/monster/bwa_vf/R_man"
sample_names <- c(    "M. acuminata AAA Group_HQ442266.1",
    "M. acuminata AAA Group_LC485018.1",
    "M. acuminata AAA Group_LN680393.2")

# Loop through each sample
for (sample in sample_names) {
  
  # Define file paths for negative and positive coverage
  neg <- file.path(base_dir, paste0("negative_coverage_", sample, ".csv"))
  pos <- file.path(base_dir, paste0("positive_coverage_", sample, ".csv"))
  
  # Read CSV files
  neg_data <- read.csv(neg, header = TRUE)
  pos_data <- read.csv(pos, header = TRUE)
  
  # Print column names to verify they match
  print(paste("Negative coverage data columns for", sample, ":"))
  print(colnames(neg_data))
  print(paste("Positive coverage data columns for", sample, ":"))
  print(colnames(pos_data))
  
  # Rename columns to ensure consistency
  colnames(neg_data) <- c("chromosome", "position", "coverage_below")
  colnames(pos_data) <- c("chromosome", "position", "coverage_above")
  
  # Merge data on position
  merged_data <- merge(neg_data, pos_data, by = c("chromosome", "position"), all = TRUE)
  
  # Replace NA values with 0 for plotting purposes
  merged_data[is.na(merged_data)] <- 0
  
  # Add a sample column for facet labels
  merged_data$sample <- sample
  
  # Create the plot
  p <- ggplot(merged_data, aes(x = position)) +
    geom_col(aes(y = coverage_below), fill = "black") +
    geom_col(aes(y = coverage_above), fill = "black") +
    geom_hline(yintercept = 0) +
    facet_wrap(~ sample, scales = "free_x", ncol = 1) +  # Facet by sample
    theme_minimal() +
    theme(
      strip.background = element_rect(fill = "lightgreen", color = NA),  # Set background color of facet strips
      strip.text = element_text(color = "black"),  # Set text color of facet strips
      strip.placement = "outside",  # Place facet strips outside the plot area
      panel.grid = element_blank(),  # Remove grid lines
      strip.position = "top",  # Place strips at the top
      axis.line.x = element_line(color = "black"),  # Set x-axis line color
      axis.line.y = element_line(color = "black"),  # Set y-axis line color
      axis.ticks = element_line(color = "black"),  # Set axis tick color
      axis.text = element_text(color = "black")    # Set axis text color
    ) +
    labs(y = "Number of reads", x = "Nucleotide position (nt)") +
    scale_x_continuous(expand = c(0, 0)) +  # Grade the x-axis
    scale_y_continuous(expand = c(0, 0))  # Grade the y-axis
  
  # Save the plot as a PDF
  pdf(file = file.path(base_dir, paste0("coverage_plot_", sample, ".pdf")), width = 10, height = 7)
  print(p)
  dev.off()
}
