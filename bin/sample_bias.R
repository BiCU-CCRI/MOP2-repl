
#Processing Epinano results:
epinano_processing <- function(sample_file, ivt_file, initial_position, final_position, MZS_thr, chr, exclude_SNP, Coverage) {
  
  #Import and clean data:
  sample <- read_csv_file(sample_file)
  sample <- subset(sample, cov>Coverage)
  sample <- subset(sample, pos>=initial_position) 
  sample <- subset(sample, pos<=final_position)
  sample$reference <- paste(sample$X.Ref, sample$pos, sep='_')
  sample$Difference <- as.numeric(sample$mis)+as.numeric(sample$ins)+as.numeric(sample$del)
  sample <- sample[,c(1,2,13,12)]
  colnames(sample) <- c('Reference', 'Position', 'Difference_sample', 'Merge')
  
  ivt <- read_csv_file(ivt_file)
  ivt <- subset(ivt, cov>Coverage)
  ivt <- subset(ivt, pos>=initial_position) 
  ivt <- subset(ivt, pos<=final_position) 
  ivt$reference <- paste(ivt$X.Ref, ivt$pos, sep='_')
  ivt$Difference <- as.numeric(ivt$mis)+as.numeric(ivt$ins)+as.numeric(ivt$del)
  ivt <- ivt[,c(1,2,13,12)]
  colnames(ivt) <- c('Reference', 'Position', 'Difference_IVT', 'Merge')
  
  if (nrow(sample)!=0 && nrow(ivt)!=0) {
    #Join both dataframes and clean unecessary columns:
    plotting_positions <- join(sample, ivt, by="Merge")
    plotting_positions <- subset(plotting_positions, Reference == chr)
    
    #Exclude SNPs and 10 positions before and after (21mer):
    if (length(exclude_SNP)!=0) {
      excluded_positions <- c()
      
      for (single_position in exclude_SNP){
        excluded_positions <- c(excluded_positions, seq(single_position-10,single_position+10))
      }
      
      plotting_positions <- subset(plotting_positions, !Position %in% unique(excluded_positions))
    } 
    
	# ALTERED! Not ablosute value anymore
    plotting_positions$Difference <- as.numeric(plotting_positions$Difference_sample) - as.numeric(plotting_positions$Difference_IVT)
    plotting_positions$Feature <- "Epinano"
    plotting_positions <- plotting_positions[,c(4,2,8,9)]
    
    #Calculate the threshold:
    median <- median(plotting_positions$Difference, na.rm = TRUE)
  
    #Calculate fold change and re-order:
    plotting_positions$Score <- plotting_positions$Difference/median # why???????
    plotting_positions$Modified_ZScore <- (plotting_positions$Score-median(plotting_positions$Score, na.rm = TRUE))/sd(plotting_positions$Score, na.rm = TRUE)
    
    plotting_positions <- plotting_positions[,c(1,2,5,4,6)]
    colnames(plotting_positions) <- c('Reference', 'Position', 'Score', 'Feature', 'Modified_ZScore')
    
    #Extract significant positions based on the specific threshold:
    significant_positions <- subset(plotting_positions, Modified_ZScore>MZS_thr)
  
  } else {
    plotting_positions <- data.frame(Reference= character(), Position=integer(), Difference=double(), Feature=character())
    significant_positions <- data.frame(Reference= character(), Position=integer(), Difference=double(), Feature=character())
  }

  return(list(plotting_positions,significant_positions))
}

nanopolish_processing <- function(sample_file, ivt_file, initial_position, final_position, MZS_thr, chr, exclude_SNP, Coverage) {
  #Import data:
  sample <- read_csv_file(sample_file)
  
  #Add sample information:
  sample$feature <- 'Nanopolish'
  sample <- subset(sample, coverage>Coverage)
  colnames(sample)<- c("contig_wt","position","reference_kmer_wt", "event_level_median_wt", "coverage", "feature_wt")
  sample<- subset(sample, contig_wt == chr)
  sample$reference <- paste(sample$contig_wt, sample$position, sep='_')
  
  #Import KO: 
  raw_data_ivt <-read_csv_file(ivt_file)
  raw_data_ivt <- subset(raw_data_ivt, coverage>Coverage)
  colnames(raw_data_ivt)<- c("contig_ko","position","reference_kmer_ko", "event_level_median_ko", 'coverage')
  raw_data_ivt <- subset(raw_data_ivt, contig_ko == chr)
  raw_data_ivt$reference <- paste(raw_data_ivt$contig_ko, raw_data_ivt$position, sep='_')
  
  #Join tables, calculate differences between means/medians:
  plotting_data <- join(sample, raw_data_ivt, by="reference", type='inner')
  plotting_data$diff <- plotting_data$event_level_median_ko - plotting_data$event_level_median_wt # ALTERED! Not absolute anymore
  plotting_positions <- data.frame(plotting_data$reference, plotting_data$position, plotting_data$diff, plotting_data$feature_wt)
  colnames(plotting_positions) <- c('Reference', 'Position', 'Difference', 'Feature')

  plotting_positions <- subset(plotting_positions, Position>=initial_position)
  plotting_positions <- subset(plotting_positions, Position<=final_position)
  
  #Exclude SNPs and 10 positions before and after (21mer):
  if (length(exclude_SNP)!=0) {
    excluded_positions <- c()
    
    for (single_position in exclude_SNP){
      excluded_positions <- c(excluded_positions, seq(single_position-10,single_position+10))
    }
    
    plotting_positions <- subset(plotting_positions, !Position %in% unique(excluded_positions))
  } 
  
  #Calculate the threshold:
  threshold <- median(plotting_positions$Difference, na.rm = TRUE)

  #Calculate fold change:
  plotting_positions$Score <- plotting_positions$Difference/threshold
  plotting_positions$Modified_ZScore <- (plotting_positions$Score-median(plotting_positions$Score, na.rm = TRUE))/sd(plotting_positions$Score, na.rm = TRUE)
  
  #Format data for plotting:
  plotting_positions <- plotting_positions[,c(1,2,5,4,6)]
  
  #Extract significant positions:
  significant_positions <- subset(plotting_positions, Modified_ZScore>MZS_thr)
  
  return(list(plotting_positions,significant_positions))
  
}