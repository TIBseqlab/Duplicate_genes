# Duplicate_genes
This pipeline is prepared to get duplicates genes using gff annotation and amino acid file.

### Example commands：
perl Get_duplicate_genes.pl -g test_input/2556921600.gff -a test_input/2556921600.faa -o test_output -p JSC1 -v 

### Input files：
1. A gff annotation file
2. A file containing all amino acids

### Output files：
A output folder is given as argument and a prefix is given as well.
1. test_output/JSC1.bsp is the output of blast results.
2. test_output/JSC1.dup.txt is the output file containing duplicate gene pairs.

### Prerequisite:
1. Blastall binaries should be included in the PATH
2. R with "data.table" package installed
3. Perl 