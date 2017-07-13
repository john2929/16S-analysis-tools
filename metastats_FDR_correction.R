#install the fdrtool set of scripts. You only need to do this once on your machine. This is why I have it commented out
#install.packages('fdrtool')

# FUNCTION DEFINITION IF YOU WANT TO BE FANCY
#get_fdr_cor <- function(){

  
  #YOUR DATA NEED TO BE CONTAINED IN A DIRECTORY (which you set as the working directory)
  #WHICH CONTAINS YOUR TAXONOMY FILE AND THEN SUBDIRECTORY(IES) WITH THE UNCORRECTED METASTATS OUTPUTS FROM MOTHUR
  #IF IT IS ARRANGED LIKE THAT EVERYTHING WILL WORK OUT WITH THE MOST MINIMAL CHANGES TO THIS CODE.
  
  #EDIT THIS LINE TO DIRECT THE COMPUTER TO THE DIRECTORY WITH YOUR DATA
  #THIS IS THE ONLY LINE YOU NEED TO EDIT.
  library(fdrtool)
  working_dir <- "~/Desktop/BMD_turkeys/data/16s_amplicon/RDP_trainingset16/otu_tables/bmd_only/metastats_out/"
  
  
  ##this block of code is to set up the output directories and read taxonomy file
  setwd(working_dir)
  output_dir <- paste0(working_dir, "/fdr.corrected_out1")
  
  directories <- list.dirs(path = ".", full.names = F)
  directories <- directories[-1]  
  
  taxonomy_file <- list.files(recursive = F)
  taxonomy_file <- taxonomy_file[!file.info(taxonomy_file)$isdir]
  taxonomy <- read.table(file = taxonomy_file, header = T)
  taxonomy <- taxonomy[,-2]
  
  #This block of code uses the FDR correction to correct the metastats outputs and saves them
  dir.create(output_dir)
  for(i in 1:length(directories)){
    temp_files <- list.files(directories[i])
    print(paste("working on", directories[i]))
    dir.create(paste(output_dir,"/",directories[i], "_FDR.corrected", sep = ""))
    
    for(j in 1:length(temp_files)){
      metastat <- read.table(file = paste(directories[i],"/",temp_files[j], sep = ""), skip = 6, header = T)
      metastat <- metastat[which(rowSums(metastat[,2:7])>0|rowSums(metastat[,2:7])>NA),]
      if(nrow(metastat)>0){
        metastat$FDR.q.value <- p.adjust(metastat$p.value, method = "BH")
        metastat_tax <- merge(x = metastat, y = taxonomy, by = "OTU", all.x = TRUE)
        metastat_tax <- metastat_tax[order(metastat_tax[,9]), ]
        write.csv(metastat_tax, file = paste(output_dir, "/", directories[i], "_FDR.corrected", "/", temp_files[j], ".csv", sep = ""), row.names = F, quote = F)
      }
    }
  }
#}
