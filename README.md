# sRNA-seq
## Materials and methods 
## Workstation
The analyses presented in this study were performed on a high-performance workstation running a 64-bit version of the Linux operating system. The system is equipped with 32 GB of RAM and an AMD Ryzen 5 5500 processor. The workstation features a primary 953.9 GiB NVMe SSD for rapid data access and a secondary 119.3 GiB HDD for ample storage capacity.
## Data collection
The dataset was obtained from a series of small RNA sequencing (sRNA-seq) experiments aimed at studying small RNAs in monocots. The organisms studied are a diverse array of monocot species, each with significant agricultural and biological importance. These include **Tradescantia fluminensis**, commonly known as wandering Jew, often used in genetic and ecological studies due to its invasive nature. **Musa acuminata var. zebrina** and **Musa acuminata AAA Group**, representing different varieties of banana plants, are crucial for understanding genetic traits related to disease resistance and fruit development. **Zea mays**, or maize, a globally essential staple crop, is studied extensively for insights into crop improvement and stress responses. Lastly, **Prosthechea radiata**, an orchid species, is investigated for its unique genetic characteristics and evolutionary significance. 
The sequencing libraries were prepared using the ncRNA-Seq strategy, sourced from transcriptomic material, and sequenced using the Illumina HiSeq 2500 platform known for generating high-quality short reads.
We have selected 21 samples comprising different genotypes of each species studied: 5 samples of **Zea mays**, 5 samples of **Prosthechea radiata**, 4 samples of **Musa acuminata var. zebrina**, 4 samples of **Musa acuminata AAA Group**, and 3 samples of **Tradescantia fluminensis**. The full details of these samples are in Supplementary Table 1.
Raw single ended reads (are available in our public github repo) from these sRNA-seq experiments, available in Fastq format, can be downloaded from the Sequence Read Archive (SRA) under the National Center for Biotechnology Information (NCBI) at [https://www.ncbi.nlm.nih.gov/sra](https://www.ncbi.nlm.nih.gov/sra). 

#### Supplementary Table 1: Summary of sRNA-seq Experiments
(insert /home/msi/monster/SRA_Metadata.ods)
**description of the table :** The dataset comprises comprehensive metadata for a series of small RNA sequencing (sRNA-seq) experiments aimed at studying small RNAs in monocots. Each study is identified by a unique accession number and includes detailed titles and descriptions, providing context for the experiments conducted. The organisms studied range from "Tradescantia fluminensis" to "Zea mays," with taxonomy identifiers included for specificity. The sequencing libraries were prepared using the ncRNA-Seq strategy and sourced from transcriptomic material, sequenced using the Illumina HiSeq 2500 platform.

The dataset records essential sequencing metrics, including the total number of reads (spots) and the total base count, highlighting the substantial volume of data generated from these experiments. Additionally, each sample and experiment is linked to broader biosample and bioproject identifiers, ensuring connectivity and context within larger research initiatives. This rich collection of metadata ensures that the experiments are well-documented, reproducible, and accessible for further analysis by the research community.
Short single ended reads are normally sufficient for studies of gene expression levels in well-annotated organisms [A survey of best practices for RNA-seq data analysis](zotero://select/library/items/DNC73MZC)

## Sequence quality screening, trimming and virus genome assembly

### Data preprocessing
The raw reads underwent quality screening using FastQC v0.12.1 (Andrews S. FASTQC) and MultiQC version 1.14 to generate comprehensive reports. 
For trimming and filtering the adapters and reads shorter than 18 bp, we tested Cutadapt 4.2, Trimmomatic-0.39 and bbduk version 39.06 and compared between their results, more details are in Supplementary Table 2. Cutadapt gave the best results for adapter trimming so we used its output. 

***Detailed description of the pipeline***
***Script in github*** 
***Supplementary Table 2 (Tool, Parameters, results, adapter file used (bbduk adapter file and used DNApi to check if the adapters present in our reads are present in the adapter file) (you can be inspired from comparative papers))***

The trimmed and filtered accessions were then merged in a single file according to their respective species using the `cat`  command. ***(Do we need to mention this ??)*** 

(check the adapter removal statistics during the filtering step. The adapter sequences should be present in the majority of reads, ideally in over 90% of them. Lower percentages could indicate that the adapter sequence is incomplete or that the software used for adapter removal is not able to find all occurrences of the adapter.) [Analysis of Small RNA Sequencing Data in Plants](zotero://select/library/items/T4ZGIUV6)
(The majority of NGS workflows include PCR duplicate removal, but in the case of sRNA-seq analysis, this step should be avoided. As sRNA libraries mostly consist of short reads with nearly identical sequences, filtering for duplicate reads will remove the highly expressed sRNAs, thus producing skewed results.) [Analysis of Small RNA Sequencing Data in Plants](zotero://select/library/items/T4ZGIUV6)

### Assembling of reads 
Contigs were assembled from the cutadapt filtered reads using Trinity-v2.15.1 and velvet 1.2.10 (k-mers 17 to 25).
After running QUAST-5.2.0 to assess the quality of the assembly, we found out that Trinity had the best results, so we used its output. 
### Alignment of contigs 
The reference genome database used to compare our contigs and viruses was created by downloading the virus sequences database from NCBI Virus ([https://www.ncbi.nlm.nih.gov/labs/virus/vssi/#/virus?SeqType_s=Nucleotide](https://www.ncbi.nlm.nih.gov/labs/virus/vssi/#/virus?SeqType_s=Nucleotide)) on the 18th of May 2024 at 9:19 PM GMT. At the time of download, the database contained 156,575 virus nucleotide sequences. To ensure relevance to our study, we specified that the host organisms should be green plants (Viridiplantae, taxid: 33090). The nucleotide sequences were then processed to create the reference genome database in FASTA format.

After downloading, the database was formatted for BLAST analysis using the `makeblastdb` command. This command was executed as follows:

```bash
makeblastdb -in /home/msi/ESP/Blast_v2/DB/sequences.fasta -dbtype nucl
```

***For transparency and reproducibility, the species reference genome sequences and the database created are made publicly available on GitHub [insert GitHub repository link here].***

After aligning assembled contigs with viral reference genomes using Blast+ 2.12.0 locally, we selected the most significant hits by sorting the matches based on query name, bitscore, e-value, and nucleotide identity, prioritizing bitscore over e-value, and e-value over nucleotide identity to ultimately extract the most relevant viral sequences.

### Mapping of contigs 
Using the best hits identified from the BLAST analysis, we proceeded to map the reads to the reference genomes with BWA version 0.7.17-r1188. The resulting BAM files were analyzed using MISIS-2 to visualize sRNA coverage, identify SNPs and indels. We utilized Tablet version 1.21.02.08 to visualize the mapping results. 
