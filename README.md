# Duplicate_genes
This pipeline is prepared to get duplicates genes using gff annotation and amino acid file.

### Example commands：
perl Get_duplicate_genes.pl -g test_input/2556921600.gff -a test_input/2556921600.faa -o test_output -p JSC1 -v 

### prerequisite:
1. Blastall 
2. R with "data.table" package installed
3. Perl 