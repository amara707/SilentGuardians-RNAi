#FastQC
#To find all the files with the fastq extension in the working directory and to run fastqc on all of them
#To test it before running 
find . -name "*.fastq" | parallel --dry-run fastqc -o {//}/ {}
#To run it 
find . -name "*.fastq" | parallel fastqc -o {//}/ {}

#MultiQC for the files in the wd 
multiqc .
