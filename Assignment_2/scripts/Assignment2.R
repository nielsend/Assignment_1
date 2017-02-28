#Change working directory to get to directory with files
setwd("~/Assignment_1/BCB_GitHub_Files/")

#Load the Files into R from the current directory
fangGeno <- read.table("fang_et_al_genotypes.txt", header=FALSE)
snpPos <- read.table("snp_position.txt", fill=TRUE, header=FALSE)

# #Double check to ensure files imported as data frames
is.data.frame(fangGeno) 
is.data.frame(snpPos)

# #Extraneous code , Delete later
# options(max.print=1000000) #allows more to be printed in R studio
# fangGeno

#Run the dplyr package
library(dplyr)

#Use dlpyr's filter function on the third column to create "maize" and "teosinte" 
#maize has ZMMIL, ZMMLR, and ZMMMR in the third column
maize<-filter(fangGeno, V3=="ZMMIL"| V3=="ZMMLR" | V3=="ZMMMR")
#teosinte has ZMPBA, ZMPIL, and ZMPJA in the third column
teosinte<-filter(fangGeno, V3=="ZMPBA"| V3=="ZMPIL" | V3=="ZMPJA")

#Get first line of fang data (containes column info)
header<-head(fangGeno,n=1)

#Put header back as first row in maize and teosinte data
maize<-rbind(header,maize)
teosinte<-rbind(header,teosinte)

#Convert teosinte and maize dataframes into matrices for taking transpose, then take transpose, and then 
#convert back into dataframes for merging. 
tmaize <- as.data.frame(t(as.matrix(maize)))
tteosinte <- as.data.frame(t(as.matrix(teosinte)))

#merge data using the first column. 
tmaize_merged <- merge(snpPos, tmaize, by=c(1))
tteosinte_merged <- merge(snpPos, tteosinte, by=c(1))

setwd("~/Assignment_1/Assignment_2/files")
#create directories for teosinte and maize; recursive=TRUE makes parent dierectory as needed
dir.create("maize/forward",recursive=TRUE)
dir.create("maize/reverse")
dir.create("teosinte/reverse",recursive=TRUE)
dir.create("teosinte/forward")

#write data to text files. First grab subsets based on V3, the column containing the chromosome. Then write this to a
#file in the directories we made, without column or row data, and definitely without the annoying quotes. 
for (i in 1:10){
     maize_list=subset(tmaize_merged,tmaize_merged$V3==i)
     maize_list <- maize_list[,c(1,3,4,2,5:ncol(maize_list))]
     #sort data based on position (column V4). Note that we have to convert the string in column 4 to an integer. 
	 #We will have forward and reverse sorted lists. Note that the terminal comma is necessary (not sure why...)
     maize_list<- maize_list[order(strtoi(maize_list$V4)),]
     #sort in reverse direction
     maize_rev_list<- maize_list[order(strtoi(maize_list$V4),decreasing=TRUE),]
     maize_rev_list<-lapply(maize_rev_list, gsub, pattern = "?", replacement = "-", fixed = TRUE)
     teosinte_list=subset(tteosinte_merged,tteosinte_merged$V3==i)
     teosinte_list <- teosinte_list[,c(1,3,4,2,5:ncol(teosinte_list))]
     teosinte_list<- teosinte_list[order(strtoi(teosinte_list$V4)),]
     teosinte_rev_list<- teosinte_list[order(strtoi(teosinte_list$V4),decreasing=TRUE),]
     teosinte_rev_list<-lapply(teosinte_rev_list, gsub, pattern = "?", replacement = "-", fixed = TRUE)
     write.table(maize_list, file=sprintf("maize/forward/maize%i.txt",i), sep=" ", quote=FALSE, row.names=FALSE, col.names=FALSE)
     write.table(maize_rev_list, file=sprintf("maize/reverse/maize_rev%i.txt",i), sep=" ", quote=FALSE, row.names=FALSE, col.names=FALSE)
     write.table(teosinte_list, file=sprintf("teosinte/forward/teosinte%i.txt",i), sep=" ", quote=FALSE, row.names=FALSE, col.names=FALSE)
     write.table(teosinte_rev_list, file=sprintf("teosinte/reverse/teosinte_rev%i.txt",i), sep=" ", quote=FALSE, row.names=FALSE, col.names=FALSE)
}


#=================================================================================================================================================
##PART 2

#make headers for merged data. This has the headers from the SNP file and groups from maize/teosinte. We will want this for assinging SNPs to groups.
#grab group data from tmaize and tteosinte. 
maizegroups<-tmaize[3,c(2:ncol(tmaize))]
teosintegroups<-tteosinte[3,c(2:ncol(tteosinte))]
#merge with the SNP header
SNPheader<-head(snpPos,n=1)
maizeheader<-merge(SNPheader,maizegroups)
teosinteheader<-merge(SNPheader,teosintegroups)

#We must now go through the different chromosome files to count snps. We only need one direction for corn and teosinte.
#Here's how we will keep track of data:
#Make a Matrix for both corn and teosinte of the following styles (Corn of left, teosinte on right):
#
#                             Chromosome                                                Chromosome                
#                1   2   3   4   5   6   7   8   9  10                     1   2   3   4   5   6   7   8   9  10         
#Corn=   ZMMIL[[ #   #   #   #   #   #   #   #   #   # ] Teosinte= ZMPBA[[ #   #   #   #   #   #   #   #   #   # ]  
#        ZMMLR [ #   #   #   #   #   #   #   #   #   # ]           ZMPIL [ #   #   #   #   #   #   #   #   #   # ]   
#        ZMMMR [ #   #   #   #   #   #   #   #   #   # ]]          ZMPJA [ #   #   #   #   #   #   #   #   #   # ]] 
#
# where each # is a count which counts the number of SNPs for a chromosome given a group. This format gives the benefit of 
#store extra data that we can use later when we have to plot a new comparison...
#
corncount<-matrix(0,nrow=3,ncol=10)
teosintecount<-matrix(0,nrow=3,ncol=10)

corn_total_snp_count<-matrix(0,nrow=1,ncol=10) #here we will store number of SNPs per chromosome 
teosinte_total_snp_count<-matrix(0,nrow=1,ncol=10)
total_snp_count<-matrix(0,nrow=1,ncol=10)

#corn first. 
setwd("~/Assignment_2/files/")
#set working directory to forward corn directory.
#go through each column of data, and determine if it is a SNP. This will take literally a few minutes. 
for (i in 1:10){
	chromodata <- read.table(sprintf("maize/forward/maize%i.txt",i), header=FALSE, sep=" ")
	homozygous <- matrix(0,nrow=nrow(chromodata),ncol=1) #make a matrix (vector) of values for heterozygous or not. 
	for (j in 1:nrow(chromodata)){ #go through file line by line.
		line<-chromodata[j,] #get jth line from chromodata 
		for (k in 16:ncol(chromodata)){ #start in column 16 where SNP data start
			group=0
			snp <- line[,k]
			first <- substr(snp,1,1)
			last <- substr(snp,3,3)
			if (first=="?" || first=="-") {
				chromodata[j,k]="NA" #replace any ?/? or -/- with NA in dataframe
			}
			if (first!=last) {
				homozygous[j,1]=homozygous[j,1]+1
			}
			if (maizeheader[,k]=="ZMMIL"){
				group=1
			} else if (maizeheader[,k]=="ZMMLR"){
				group=2
			} else if (maizeheader[,k]=="ZMMMR"){
				group=3
			}
			if (group>0 ){ #check group was assigned 
				corncount[group, i]<-corncount[group, i]+1 #increment every sine instance of a polymorphism.
			}
		}
		if (homozygous[j,1]>0){
			corn_total_snp_count[1,i]=corn_total_snp_count[1,i]+1 #increment only once per position. 
			total_snp_count[1,i]=total_snp_count[1,i]+1
		}
	}
	#now we have all the data, with NA replacing ?/? or -/-, and a column called homozygous, with an entry of 0 if homozygous, and >0 otherwise. 
	#We will merge with the chromodata, and then rearrange columns to make homozygous the second column. 
	chromodata<-cbind(homozygous,chromodata)
	chromodata<-chromodata[,c(2,1,3:ncol(chromodata))]
	#now write a new file. 
	filename<-sprintf("maize/forward/maize.hetero.%i.txt",i)
	write.table(chromodata, file=filename, sep=" ", quote=FALSE, row.names=FALSE, col.names=FALSE)
	#this process takes a while, so write some friendly output. 
	print(sprintf("Wrote file %s successfully", filename))
}

#Repeat maize philosophy for teosinte
for (i in 1:10){
	chromodata <- read.table(sprintf("teosinte/forward/teosinte%i.txt",i), header=FALSE, sep=" ")
	homozygous <- matrix(0,nrow=nrow(chromodata),ncol=1) #make a matrix (vector) of values for heterozygous or not. 
	for (j in 1:nrow(chromodata)){ #go through file line by line.
		line<-chromodata[j,] #get jth line from chromodata 
		for (k in 16:ncol(chromodata)){ #start in column 16 where SNP data start
			group=0
			snp <- line[,k]
			first <- substr(snp,1,1)
			last <- substr(snp,3,3)
			if (first=="?" || first=="-") {
				chromodata[j,k]="NA" #replace any ?/? or -/- with NA in dataframe
			}
			if (first!=last) {
				homozygous[j,1]=homozygous[j,1]+1
			}
			if (teosinteheader[,k]=="ZMPBA"){
				group=1
			} else if (teosinteheader[,k]=="ZMPIL"){
				group=2
			} else if (teosinteheader[,k]=="ZMPJA"){
				group=3
			}
			if (group>0 ){ #check group was assigned 
				teosintecount[group, i]<-teosintecount[group, i]+1 #increment every sine instance of a polymorphism.
			}
		}
		if (homozygous[j,1]>0){
			teosinte_total_snp_count[1,i]=teosinte_total_snp_count[1,i]+1 #increment only once per position. 
			total_snp_count[1,i]=total_snp_count[1,i]+1
		}
	}
	#Now we have all the data, with NA replacing ?/? or -/-, and a column called homozygous, with an entry of 0 if homozygous, and >0 otherwise. 
	#We will merge with the chromodata, and then rearrange columns to make homozygous the second column. 
	chromodata<-cbind(homozygous,chromodata)
	chromodata<-chromodata[,c(2,1,3:ncol(chromodata))]
	#Write a new file. 
	filename<-sprintf("teosinte/forward/teosinte.hetero.%i.txt",i)
	write.table(chromodata, file=filename, sep=" ", quote=FALSE, row.names=FALSE, col.names=FALSE)
	#this process takes a while, confirm writing is occuring 
	print(sprintf("Wrote file %s successfully", filename))
}

#We have the number of snps for teosinte and maize, as well as the overall total 
#We also have matrices of total polymorphisms to do plotting on 

#Barchart Corn and Teosinte SNPs
df<-data.frame(y=as.data.frame(t(corn_total_snp_count)),x=(1:10))
colnames(df)[1]<-"y"
ggplot(df, aes(x=x, y=y)) + geom_bar(stat="identity") + 
     labs(x="Chromosome", y="Corn SNP count") + scale_x_discrete(limits=c(1:10)) + scale_y_continuous()


#A barchart showing the chromosome and SNP count
df<-data.frame(y=as.data.frame(t(total_snp_count)),x=(1:10))
colnames(df)[1]<-"y"
ggplot(df, aes(x=x, y=y)) + geom_bar(stat="identity") + 
  labs(x="Chromosome", y="Total SNP count") + scale_x_discrete(limits=c(1:10)) + scale_y_continuous()


#A barchart showing SNP count and Chromosome of Corn and Teosinte
df<-data.frame(y=as.data.frame(t(corn_total_snp_count)),x=(1:10),z=as.data.frame(matrix(1,nrow=10,ncol=1)))
dg<-data.frame(y=as.data.frame(t(teosinte_total_snp_count)),x=(1:10),z=as.data.frame(matrix(2,nrow=10,ncol=1)))
snp_data<-rbind(df,dg)
colnames(snp_data)[1]<-"y"
colnames(snp_data)[3]<-"z"
ggplot(snp_data,aes(x=x,y=y,fill=factor(z)))+
  geom_bar(stat="identity",position="dodge")+
  scale_fill_discrete(name="Species", breaks=c(1, 2),labels=c("Corn", "Teosinte"))+
  xlab("Chromosome")+ylab("SNP count")+ scale_x_discrete() + scale_y_continuous()
