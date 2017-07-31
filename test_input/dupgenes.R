
gff <- read.table("2556921600.gff", header = FALSE, sep = "\t", quote="")
gff <- gff[gff[,3]=="CDS",]
gff[,10] <- gff[,5]-gff[,4]+1
gff[,11] <- gff[,10]/3
gff2 <- gff[, c(9,11)]
gff2[,1] <- gsub(";.*","",gff2[,1])
gff2[,1] <- gsub("ID=","",gff2[,1])
colnames(gff2) <- c("gene","len")


bsp <- read.table("JSC1.bsp", header = FALSE)
bsp <- bsp[bsp[,1]!=bsp[,2],]
bsp[,1] <- as.character(bsp[,1])
bsp[,2] <- as.character(bsp[,2])
bsp2 <- bsp[,1:4]
colnames(bsp2) <- c("query","subject","identity","length")
library(data.table)
bsp2 <- data.table(bsp2, key = "query")
bspuniq <- bsp2[, head(.SD, 1), by = key(bsp2)]
bspuniqcal <- merge(bspuniq, gff2, by.x = "query", by.y = "gene", all.x = TRUE)
bspuniqcal2 <- merge(bspuniqcal, gff2, by.x = "subject", by.y = "gene", all.x = TRUE)
colnames(bspuniqcal2) <- c("query","subject","identity","length","slength","qlength")
bspuniqcal2[,"maxlen"] <- apply(bspuniqcal2[,c("slength","qlength")], 1, max)
bspuniqcal2$percent <- bspuniqcal2$length/bspuniqcal2$maxlen*100


dupgene1 <- bspuniqcal2[,c("query","subject","identity","percent")]
dupgene1 <- dupgene1[dupgene1$percent >= 80,]
dupgene2 <- bspuniqcal2[,c("query","subject","identity","length","percent")]
dupgene2 <- dupgene2[dupgene2$percent < 80,]
dupgene2 <- dupgene2[dupgene2$length > 150,]
dupgene2[,"I"] <- (0.01*6+4.8*dupgene2[,"length"]^-0.32*(1-exp(-dupgene2[,"length"]/1000)))*100 
dupgene2 <- dupgene2[dupgene2$percent >= dupgene2$I,]

dupgene <- rbind(dupgene1[,c("query","subject")],dupgene2[,c("query","subject")])
for (i in 1:nrow(dupgene)){
  dupgene[i, ] = sort(dupgene[i, ])
}                        
dupgene <- dupgene[!duplicated(dupgene),]
write.table(dupgene, "dupgene.txt", row.names = FALSE, sep = "\t")




