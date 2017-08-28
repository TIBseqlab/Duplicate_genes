#FILE: dupgenes.R
#AUTH: Yang Li (li_y1@tib.cas.cn)
#DATE: Aug. 7rd, 2017
#VERS: 2.0

#This script is prepread to get duplicate gene pairs using gff annotation file and blast results
#Usage: 
# Arguments:
# 1. The input annotation file 
# 2. The blast results
# 3. The output file
# example: Rscript dupgenes.R 2556921600.gff JSC1.bsp JSC1.dup.txt 

Args <- commandArgs(TRUE)

# Input gff file
gfffile =Args[1]

# input blast results
blastfile = Args[2]

# output file
output = Args[3]

# load data.table library
library(data.table)

# extract gene ID and length from gff file
gff <- read.table(gfffile, header = FALSE, sep = "\t", quote="")
gff <- gff[gff[,3]=="CDS",]
gff[,10] <- gff[,5]-gff[,4]+1
gff[,11] <- gff[,10]/3
gff2 <- gff[, c(9,11)]
gff2[,1] <- substr(gff2[,1],4,13) 
#colnames(gff2) <- c("gene","len")
setnames(gff2,c("gene","len"))


# extract reciprocal best hits from blast results 
bsp <- read.table(blastfile, header = FALSE, quote="")
bsp <- bsp[bsp[,1]!=bsp[,2],]
bsp[,1] <- as.character(bsp[,1])
bsp[,2] <- as.character(bsp[,2])
bsp2 <- bsp[,1:4]
#colnames(bsp2) <- c("query","subject","identity","length")
setnames(bsp2,c("query","subject","identity","length"))
bsp2 <- data.table(bsp2, key = "query")
bspuniq <- bsp2[, head(.SD, 1), by = key(bsp2)]          # keep best hits
bspuniq2 <- bspuniq[,1:2]
for (i in 1:nrow(bspuniq2)){
  bspuniq2[i,] = sort(bspuniq2[i,])
}
recibest <- bspuniq2[duplicated(bspuniq2),]
recibest2 <- merge(recibest, bspuniq, by = c("query","subject"), all.x = TRUE)


# get identity and length percentage of the best hits
recibest2 <- merge(recibest2, gff2, by.x = "query", by.y = "gene", all.x = TRUE)
recibest2 <- merge(recibest2, gff2, by.x = "subject", by.y = "gene", all.x = TRUE)
#colnames(recibest2) <- c("query","subject","identity","length","slength","qlength")
setnames(recibest2,c("query","subject","identity","length","slength","qlength"))
recibest2[,"maxlen"] <- apply(recibest2[,c("slength","qlength")], 1, max)
recibest2$percent <- recibest2$length/recibest2$maxlen*100


# screen duplicated gene pairs
dupgene1 <- recibest2[,c("query","subject","identity","length","percent")]
dupgene1 <- dupgene1[dupgene1$percent >= 80,]
dupgene2 <- dupgene1[dupgene1$length > 150,]
dupgene2 <- dupgene2[dupgene2$identity >= 30,]
dupgene3 <- dupgene1[dupgene1$length <= 150,]
dupgene3[,"I"] <- (0.01*6+4.8*(dupgene3[,"length"])^(-0.32*(1+exp(-dupgene3[,"length"]/1000))))*100
dupgene3 <- dupgene3[dupgene3$identity >= dupgene3$I,]
dupgene <- rbind(dupgene2[,c("query","subject")],dupgene3[,c("query","subject")])
write.table(dupgene, output, row.names = FALSE, sep = "\t")



