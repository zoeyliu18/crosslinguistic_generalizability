library(gridExtra)
library(ggplot2)
library(tidyverse)
library(ggpubr)
library(lme4)
library(brms)
library(viridis)

prior=prior(student_t(3,0,8), class = b)

####################################
########### Yorem Nokki ############
####################################

mayo <- read.csv('mayo.txt', header = T, sep = '\t')
mayo$Language <- rep('Yorem Nokki', nrow(mayo))

mayo <- subset(mayo,  Index %in% c('Same best model', 'Same model ranking', 'A best model', 'A best model ranking'))
mayo$Index[mayo$Index == 'Same model ranking'] <- 'Same ranking'
mayo$Index[mayo$Index == 'A best model ranking'] <- 'A best ranking'
mayo$Index <- factor(mayo$Index, levels = c('Same best model', 
                                            'Same ranking', 
                                            'A best model', 
                                            'A best ranking'))

mayo_p <-
  ggplot(subset(mayo, Metric == 'F1'&Index %in% c('Same best model', 'Same ranking')), aes(Index, Proportion, fill = Index)) +
  geom_bar(stat = 'identity', alpha = 0.8) +
  geom_text(aes(label=paste(Proportion, '%')), vjust=-1, color="black", size=6)+
  scale_fill_manual(values = c("steelblue", "mediumpurple4")) + #, "darkgreen", "peru")) +
  facet_grid(Replacement ~ Size) +
  
  theme_classic() + 
  theme(text = element_text(size=30, family="Times"),
        axis.text.x=element_blank(),
        axis.text.y=element_text(size=30)) + 
  theme(legend.position="top") +
  ylim(c(0, 100)) +
  xlab("") + 
  ylab("Proportion (%)") +
  guides(fill = guide_legend(nrow = 1)) +
  labs(fill = "") +
  ggtitle('Mayo')


########## Select one language to plot different models ###############

mayo_details <- read.csv('mayo_details.txt', header = T, sep = '\t')
mayo_details <- subset(mayo_details, Model != 'Morfessor')
mayo_details <- subset(mayo_details, Size == 500 & Metric == 'F1') # & Replacement == 'with')


mayo_details %>%
  ggplot(aes(Split, Value, group = Model, color = Model)) +
  geom_line(aes(linetype=Model), alpha = 1) +
  scale_color_manual(values = c("steelblue", "peru", "darkgreen", "darkgrey", "mediumpurple4", "darkred", "black")) +
  scale_x_continuous(breaks=seq(1, 51, 5)) +
  facet_grid( ~ Replacement) +
  theme_classic() + 
  theme(text = element_text(size=16, family="Times")) + 
  theme(legend.position="top") +
  xlab("Data set") + 
  ylab("F1") + 
  xlim(c(1,50)) +
  guides(linetype = guide_legend(nrow = 2)) +
  ggtitle('Mayo 500 F1')


### The variance in the F1 for each model type across data sets ###

ggplot(subset(mayo_details, Metric == 'F1'), aes(x = Value, color = Replacement)) +
  geom_density() + 
  facet_grid(Model ~ Size) +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times"),
        axis.text.x=element_text(size=15),
        axis.text.y=element_text(size=15)) + 
  theme(legend.position="top") +
  labs(fill = "") +
  ggtitle('Yorem Nokki variance in F1')


### Calculating a breakdown ####

samples = unique(mayo_details$Size)

mayo_breakdown <- data.frame(Language=character(), Sample=character(), Replacement=character(), Metric=character(), Model=character(), Proportion=numeric())


for (sample in as.vector(samples)){
  for (replacement in c('with', 'without')){
    
    zero_CRF = 0
    first_CRF = 0
    second_CRF = 0
    third_CRF = 0
    fourth_CRF = 0
    seq = 0
    
    for (i in 1:50){

      data <- subset(mayo_details,Split==as.character(i) & Size == sample & Replacement==replacement & Metric=='F1')
      best <- subset(data, Value == max(data$Value))
      print(best)
      if (best$Model == '0-CRF'){
        zero_CRF = zero_CRF + 1
      }
  
      if (best$Model == '1-CRF'){
        first_CRF = first_CRF + 1
      }
  
      if (best$Model == '2-CRF'){
        second_CRF = second_CRF + 1
      }
  
      if (best$Model == '3-CRF'){
        third_CRF = third_CRF + 1
      }
  
      if (best$Model == '4-CRF'){
        fourth_CRF = fourth_CRF + 1
      }
  
      if (best$Model == 'Seq2seq'){
        seq = seq + 1
      }}
    
      zero_CRF = zero_CRF * 100 / 50
      first_CRF = first_CRF * 100 / 50
      second_CRF = second_CRF * 100 / 50
      third_CRF = third_CRF * 100 / 50
      fourth_CRF = fourth_CRF * 100 / 50
      seq = seq * 100 / 50
      
      mayo_breakdown[nrow(mayo_breakdown) + 1, ] <- c(language, sample, replacement, 'F1', '0-CRF', zero_CRF)
      mayo_breakdown[nrow(mayo_breakdown) + 1, ] <- c(language, sample, replacement, 'F1', '1-CRF', first_CRF)
      mayo_breakdown[nrow(mayo_breakdown) + 1, ] <- c(language, sample, replacement, 'F1', '2-CRF', second_CRF)
      mayo_breakdown[nrow(mayo_breakdown) + 1, ] <- c(language, sample, replacement, 'F1', '3-CRF', third_CRF)
      mayo_breakdown[nrow(mayo_breakdown) + 1, ] <- c(language, sample, replacement, 'F1', '4-CRF', fourth_CRF)
      mayo_breakdown[nrow(mayo_breakdown) + 1, ] <- c(language, sample, replacement, 'F1', 'Seq2seq', seq)
      
}}

write.csv(mayo_breakdown, 'mayo_breakdown.txt', row.names = FALSE)


mayo_breakdown %>%
  ggplot(aes(Model, as.numeric(Proportion), fill = Model)) +
  geom_bar(stat = 'identity', alpha = 0.8) +
  geom_text(aes(label=Proportion), vjust=-2.6, color="black", size=3.5)+
  facet_grid(Replacement ~ Sample) +
  theme_classic() + 
  theme(text = element_text(size=30, family="Times"),
        axis.text.x=element_blank(),
        axis.text.y=element_text(size=30)) + 
  theme(legend.position="none") +
  ylim(c(0, 100)) +
  xlab("") + 
  ylab("Proportion (%)") +
  guides(fill = guide_legend(nrow = 2)) +
  labs(fill = "") +
  ggtitle('Yorem Nokki model statistics')


####### Studying the effects of data characteristics / heuristics #######
####### For original train / test random splits #########

mayo_heuristics <- read.csv('mayo_heuristics.txt', header = T, sep = '\t')
mayo_full <- read.csv('mayo_full.txt', header = T, sep = '\t')

samples = unique(mayo_heuristics$Sample)

language <- unique(mayo_heuristics$Language)

mayo_df <- data.frame(Language=character(), Sample=character(), Replacement=character(), Metric=character(), Model=character(), Feature=character(), Coef=numeric(), Q2.5=numeric(), Q97.5=numeric()) 

for (sample in as.vector(samples)){
  for (replacement in c('with', 'without')){
    for (metric in c('Accuracy', 'Precision', 'Recall', 'F1', 'Avg. Distance')){
      for (model in c('Morfessor', '0-CRF', '1-CRF', '2-CRF', '3-CRF', '4-CRF', 'Seq2seq')){
        for (feature in c('word_overlap', 'morph_overlap', 
                          'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
          
          heuristics <- subset(mayo_heuristics, Feature == feature & Sample == sample & Replacement == replacement)
          results <- subset(mayo_full, Metric == metric & Model == model & Size == sample & Replacement == replacement)
          together = cbind(results, heuristics)
#          spearman_c = cor(together$Score, together$Value, method = c('spearman'))
            
#          regression <- brm(Score ~ Value,
#                              data=together,
#                              warmup=200,
#                              iter = 1000,
#                              chains = 4,
#                              inits="random",
#                              prior=prior,
#                              control = list(adapt_delta = 0.99),
#                              cores = 2)
            
#            summary <- data.frame(fixef(regression))
          
          regression <- lm(Score ~ Value, data = together)
          summary <- data.frame(summary(regression)$coef)
          coef = round(summary$Estimate[2], 2)
          ci = data.frame(confint(regression, 'Value', level = 0.95))
          q2.5 = round(ci$X2.5..[1], 2)
          q97.5 = round(ci$X97.5..[1], 2)
            
#            q2.5 = summary$Q2.5[2]
#            q97.5 = summary$Q97.5[2]
          
          mayo_df[nrow(mayo_df) + 1, ] <- c(language, sample, replacement, metric, model, feature, coef, q2.5, q97.5)
          
          mayo_df[is.na(mayo_df)] <- 0
          
          write.csv(mayo_df, 'mayo_corr.txt',row.names=FALSE)
          
        }}}}}


ggplot(subset(mayo_df, Sample=='1000'&Replacement=='with'& (Q2.5 > 0 | Q97.5 < 0)), aes(Feature, as.numeric(Coef), fill = Feature)) +
  geom_bar(stat = 'identity', alpha = 0.8) +
  geom_errorbar(aes(ymax = as.numeric(Q97.5), ymin = as.numeric(Q2.5)), width=.1, position=position_dodge(.9)) +
  geom_text(aes(label=Coef), vjust=2.6, color="black", size=3.5) +
  facet_grid(Model ~ Metric) +
  theme_classic() + 
  theme(text = element_text(size=10, family="Times"),
        axis.text.x=element_blank(),
        axis.text.y=element_text(size=10)) + 
  theme(legend.position="top") +
  ylim(c(-1, 1)) +
  ylab("Spearman") +
  guides(fill = guide_legend(nrow = 2)) +
  labs(fill = "") +
  ggtitle('Yorem Nokki characteristics 1000 with')


together = 0

for (sample in as.vector(samples)){
  for (replacement in as.vector(unique(mayo_heuristics$Replacement))){
    for (metric in c('Accuracy', 'Precision', 'Recall', 'F1', 'Avg. Distance')){
      for (model in c('Morfessor', '0-CRF', '1-CRF', '2-CRF', '3-CRF', '4-CRF', 'Seq2seq')){
        
        results <- subset(mayo_full, Metric == metric & Model == model & Size == sample & Replacement == replacement)
        heuristics <- subset(mayo_heuristics, Feature == 'word_overlap' & Sample == sample & Replacement == replacement)
        heuristics <- subset(heuristics, select = -Feature)
        names(heuristics) <- c('Language', 'Sample', 'Replacement', 'Split', 'Set', 'word_overlap', 'Caveat')
        
        for (feature in c('morph_overlap',
                          'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
          
          
          if (feature == 'morph_overlap'){
            heuristics$morph_overlap <- subset(mayo_heuristics, Feature == feature & Sample == sample & Replacement == replacement)$Value
          }
          
          if (feature == 'ave_num_morph_ratio'){
            heuristics$ave_num_morph_ratio <- subset(mayo_heuristics, Feature == feature & Sample == sample & Replacement == replacement)$Value
          }
          
          if (feature == 'dist_ave_num_morph'){
            heuristics$dist_ave_num_morph <- subset(mayo_heuristics, Feature == feature & Sample == sample & Replacement == replacement)$Value
          }
          
          if (feature == 'ave_morph_len_ratio'){
            heuristics$ave_morph_len_ratio <- subset(mayo_heuristics, Feature == feature & Sample == sample & Replacement == replacement)$Value
          }
          
        }
        
        together <- rbind(together, cbind(results, heuristics))
        
        
      }}}}

together <- subset(together, Language != 0)
together$Sample <- as.numeric(together$Sample)


regression <- lm(Score ~ word_overlap * morph_overlap * ave_num_morph_ratio * dist_ave_num_morph * ave_morph_len_ratio * Replacement * Sample * Model * Metric, data = together)

regression <- lm(Score ~ word_overlap + morph_overlap + ave_num_morph_ratio + dist_ave_num_morph + ave_morph_len_ratio + Replacement + Sample + Model + Metric, data = together)

regression <- lm(Score ~ (word_overlap + morph_overlap + ave_num_morph_ratio + dist_ave_num_morph + ave_morph_len_ratio)*Replacement + (word_overlap + morph_overlap + ave_num_morph_ratio + dist_ave_num_morph + ave_morph_len_ratio)*Sample + Model + Metric, data = together)

summary <- data.frame(summary(regression)$coef)
summary$Factor <- rownames(summary)

mayo_df <- data.frame(Language=character(), Factor=character(), Coef=numeric(), Q2.5=numeric(), Q97.5=numeric()) 


for (factor in as.vector(summary$Factor)){
  print(factor)
  coef = subset(summary, Factor == factor)$Estimate
  ci = data.frame(confint(regression, factor, level = 0.95))
  q2.5 = ci$X2.5..[1]
  q97.5 = ci$X97.5..[1]
  print(typeof(factor))
  mayo_df[nrow(mayo_df) + 1, ] <- c('mayo', as.character(factor), round(coef, 2), round(q2.5, 2), round(q97.5, 2))
  write.csv(mayo_df, 'mayo_corr_overall.txt', row.names = FALSE)
  
}

mayo_df$Factor<-summary$Factor
mayo_df$P_value<-summary$Pr...t..
mayo_df$Language<-rep('mayo',nrow(mayo_df))


for (feature in c('word_overlap', 'morph_overlap', 
                  'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
  
  data <- subset(together, Model != 'Morfessor' & Feature == feature & Score != 0 & Value != 0)
  print(feature)
  regression <- 0
  
  if (feature %in% c('word_overlap')){
    regression <- lm(Score ~ Value * Sample * Model * Metric, data = data)
    
  }
  else {
    regression <- lm(Score ~ Value * Replacement * Sample * Model * Metric, data = data) 
    
  }
  
  summary <- data.frame(summary(regression)$coef)
  summary$Factor <- rownames(summary)
  
  for (factor in as.vector(summary$Factor)){
    coef = subset(summary, Factor == factor)$Estimate
    ci = data.frame(confint(regression, factor, level = 0.95))
    q2.5 = ci$X2.5..[1]
    q97.5 = ci$X97.5..[1]
    mayo_df[nrow(mayo_df) + 1, ] <- c(language, feature, factor, round(coef, 2), round(q2.5, 2), round(q97.5, 2))
    write.csv(mayo_df, 'mayo_corr_overall.txt', row.names = FALSE)
    
  }
  
}


###### Studying whether data could be split by heuristics or adversarial training ####

mayo_split_len <- read.csv('mayo_split_len.txt', header = T, sep = '\t')

### 0 data sets splittable by number of morphemes ###

mayo_split_adv <- read.csv('mayo_split_adv.txt', header = T, sep = '\t')
mayo_split_adv <- subset(mayo_split_adv, Split != 'EVERYTHING')

### 500, with: min 36; max 66
### 500, without: min 25, max 55.55
### 1000, with: min 46.25; max 70
### 1000, without: min 31; max 56.25

ggplot(mayo_split_adv, aes(x = Overlap)) +
  geom_histogram() + 
  facet_grid(Sample ~ Replacement) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times"),
        axis.text.x=element_text(size=15),
        axis.text.y=element_text(size=15)) + 
  theme(legend.position="top") +
  xlim(c(0, 100)) +
  labs(fill = "") +
  ggtitle('Mayo adversarial')



################################
########### Nahuatl ############
################################

nahuatl <- read.csv('nahuatl.txt', header = T, sep = '\t')
nahuatl$Language <- rep('Nahuatl', nrow(nahuatl))

nahuatl <- subset(nahuatl, Index %in% c('Same best model', 'Same model ranking', 'A best model', 'A best model ranking'))
nahuatl$Index[nahuatl$Index == 'Same model ranking'] <- 'Same ranking'
nahuatl$Index[nahuatl$Index == 'A best model ranking'] <- 'A best ranking'
nahuatl$Index <- factor(nahuatl$Index, levels = c('Same best model', 
                                            'Same ranking', 
                                            'A best model', 
                                            'A best ranking'))

nahuatl_p <-
  ggplot(subset(nahuatl, Metric == 'F1'&Index %in% c('Same best model', 'Same ranking')), aes(Index, Proportion, fill = Index)) +
  geom_bar(stat = 'identity', alpha = 0.8) +
  geom_text(aes(label=paste(Proportion, '%')), vjust=-1, color="black", size=6)+
  scale_fill_manual(values = c("steelblue", "mediumpurple4")) + #, "darkgreen", "peru")) +
  facet_grid(Replacement ~ Size) +
  
  theme_classic() + 
  theme(text = element_text(size=30, family="Times"),
        axis.text.x=element_blank(),
        axis.text.y=element_text(size=30)) + 
  theme(legend.position="top") +
  ylim(c(0, 100)) +
  xlab("") + 
  ylab("Proportion (%)") +
  guides(fill = guide_legend(nrow = 1)) +
  labs(fill = "") +
  ggtitle('Nahuatl')


########## Select one language to plot different models ###############

nahuatl_details <- read.csv('nahuatl_details.txt', header = T, sep = '\t')
nahuatl_details <- subset(nahuatl_details, Model != 'Morfessor')
nahuatl_details <- subset(nahuatl_details, Size == 500 & Metric == 'F1') # & Replacement == 'with')


nahuatl_details %>%
  ggplot(aes(Split, Value, group = Model, color = Model)) +
  geom_line(aes(linetype=Model), alpha = 1) +
  scale_color_manual(values = c("steelblue", "peru", "darkgreen", "darkgrey", "mediumpurple4", "darkred", "black")) +
  scale_x_continuous(breaks=seq(1, 51, 5)) +
  facet_grid( ~ Replacement) +
  theme_classic() + 
  theme(text = element_text(size=16, family="Times")) + 
  theme(legend.position="top") +
  xlab("Data set") + 
  ylab("F1") + 
  xlim(c(1,50)) +
  guides(linetype = guide_legend(nrow = 2)) +
  ggtitle('nahuatl 500 F1')


####### Studying the effects of data characteristics / heuristics #######
####### For original train / test random splits #########

nahuatl_heuristics <- read.csv('nahuatl_heuristics.txt', header = T, sep = '\t')
nahuatl_full <- read.csv('nahuatl_full.txt', header = T, sep = '\t')

samples = unique(nahuatl_heuristics$Sample)

language <- unique(nahuatl_heuristics$Language)

nahuatl_df <- data.frame(Language=character(), Sample=character(), Replacement=character(), Metric=character(), Model=character(), Feature=character(), Coef=numeric(), Q2.5=numeric(), Q97.5=numeric()) 

for (sample in as.vector(samples)){
  for (replacement in c('with', 'without')){
    for (metric in c('Accuracy', 'Precision', 'Recall', 'F1', 'Avg. Distance')){
      for (model in c('Morfessor', '0-CRF', '1-CRF', '2-CRF', '3-CRF', '4-CRF', 'Seq2seq')){
        for (feature in c('word_overlap', 'morph_overlap', 
                          'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
          
          heuristics <- subset(nahuatl_heuristics, Feature == feature & Sample == sample & Replacement == replacement)
          results <- subset(nahuatl_full, Metric == metric & Model == model & Size == sample & Replacement == replacement)
          together = cbind(results, heuristics)
          
          regression <- lm(Score ~ Value, data = together)
          summary <- data.frame(summary(regression)$coef)
          coef = round(summary$Estimate[2], 2)
          ci = data.frame(confint(regression, 'Value', level = 0.95))
          q2.5 = round(ci$X2.5..[1], 2)
          q97.5 = round(ci$X97.5..[1], 2)
          
          #            q2.5 = summary$Q2.5[2]
          #            q97.5 = summary$Q97.5[2]
          
          nahuatl_df[nrow(nahuatl_df) + 1, ] <- c(language, sample, replacement, metric, model, feature, coef, q2.5, q97.5)
          
          nahuatl_df[is.na(nahuatl_df)] <- 0
          
          write.csv(nahuatl_df, 'nahuatl_corr.txt',row.names=FALSE)
          
        }}}}}


ggplot(subset(nahuatl_df, Sample=='1000'&Replacement=='with'& (Q2.5 > 0 | Q97.5 < 0)), aes(Feature, as.numeric(Coef), fill = Feature)) +
  geom_bar(stat = 'identity', alpha = 0.8) +
  geom_errorbar(aes(ymax = as.numeric(Q97.5), ymin = as.numeric(Q2.5)), width=.1, position=position_dodge(.9)) +
  geom_text(aes(label=Coef), vjust=2.6, color="black", size=3.5)+
  facet_grid(Model ~ Metric) +
  theme_classic() + 
  theme(text = element_text(size=10, family="Times"),
        axis.text.x=element_blank(),
        axis.text.y=element_text(size=10)) + 
  theme(legend.position="top") +
  ylim(c(-1, 1)) +
  ylab("Spearman") +
  guides(fill = guide_legend(nrow = 2)) +
  labs(fill = "") +
  ggtitle('Nahuatl characteristics 1000 with')


together = 0

for (sample in as.vector(samples)){
  for (replacement in c('with', 'without')){
    for (metric in c('Accuracy', 'Precision', 'Recall', 'F1', 'Avg. Distance')){
      for (model in c('Morfessor', '0-CRF', '1-CRF', '2-CRF', '3-CRF', '4-CRF', 'Seq2seq')){
        for (feature in c('word_overlap', 'morph_overlap',
                          'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
          
          heuristics <- subset(nahuatl_heuristics, Feature == feature & Sample == sample & Replacement == replacement)
          results <- subset(nahuatl_full, Metric == metric & Model == model & Size == sample & Replacement == replacement)
          together <- rbind(together, cbind(results, heuristics))
          
        }}}}}

together <- subset(together, Language != 0)
together$Sample <- as.numeric(together$Sample)

nahuatl_df <- data.frame(Language=character(), Feature=character(), Factor=character(), Coef=numeric(), Q2.5=numeric(), Q97.5=numeric()) 


for (feature in c('word_overlap', 'morph_overlap', 
                  'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
  
  data <- subset(together, Model != 'Morfessor' & Feature == feature & Score != 0 & Value != 0)
  print(feature)
  regression <- 0
  
  if (feature %in% c('word_overlap')){
    regression <- lm(Score ~ Value * Sample * Model * Metric, data = data)
    
  }
  else {
    regression <- lm(Score ~ Value * Replacement * Sample * Model * Metric, data = data) 
    
  }
  
  summary <- data.frame(summary(regression)$coef)
  summary$Factor <- rownames(summary)
  
  for (factor in as.vector(summary$Factor)){
    coef = subset(summary, Factor == factor)$Estimate
    ci = data.frame(confint(regression, factor, level = 0.95))
    q2.5 = ci$X2.5..[1]
    q97.5 = ci$X97.5..[1]
    nahuatl_df[nrow(nahuatl_df) + 1, ] <- c(language, feature, factor, round(coef, 2), round(q2.5, 2), round(q97.5, 2))
    write.csv(nahuatl_df, 'nahuatl_corr_overall.txt', row.names = FALSE)
    
  }
  
}


###### Studying whether data could be split by heuristics or adversarial training ####

nahuatl_split_len <- read.csv('nahuatl_split_len.txt', header = T, sep = '\t')

### 500, with ###
### 2 data sets splittable by number of morphems ###

nahuatl_split_adv <- read.csv('nahuatl_split_adv.txt', header = T, sep = '\t')
nahuatl_split_adv <- subset(nahuatl_split_adv, Split != 'EVERYTHING')

### 500, with: min 40; max 62
### 500, without: min 31, max 53.5
### 1000, with: min 46.5; max 67.5
### 1000, without: min 36; max 51.5

ggplot(nahuatl_split_adv, aes(x = Overlap)) +
  geom_histogram() + 
  facet_grid(Replacement ~ Sample) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times"),
        axis.text.x=element_text(size=15),
        axis.text.y=element_text(size=15)) + 
  theme(legend.position="top") +
  xlim(c(0, 100)) +
  labs(fill = "") +
  ggtitle('nahuatl adversarial')

################################
########### Wixarika ###########
################################

wixarika <- read.csv('wixarika.txt', header = T, sep = '\t')
wixarika$Language <- rep('wixarika', nrow(wixarika))

wixarika <- subset(wixarika, Index %in% c('Same best model', 'Same model ranking', 'A best model', 'A best model ranking'))
wixarika$Index[wixarika$Index == 'Same model ranking'] <- 'Same ranking'
wixarika$Index[wixarika$Index == 'A best model ranking'] <- 'A best ranking'
wixarika$Index <- factor(wixarika$Index, levels = c('Same best model', 
                                                  'Same ranking', 
                                                  'A best model', 
                                                  'A best ranking'))

wixarika_p <-
  ggplot(subset(wixarika, Metric == 'F1'&Index %in% c('Same best model', 'Same ranking')), aes(Index, Proportion, fill = Index)) +
  geom_bar(stat = 'identity', alpha = 0.8) +
  geom_text(aes(label=paste(Proportion, '%')), vjust=-1, color="black", size=6)+
  scale_fill_manual(values = c("steelblue", "mediumpurple4")) + #, "darkgreen", "peru")) +
  facet_grid(Replacement ~ Size) +
  
  theme_classic() + 
  theme(text = element_text(size=30, family="Times"),
        axis.text.x=element_blank(),
        axis.text.y=element_text(size=30)) + 
  theme(legend.position="top") +
  ylim(c(0, 100)) +
  xlab("") + 
  ylab("Proportion (%)") +
  guides(fill = guide_legend(nrow = 1)) +
  labs(fill = "") +
  ggtitle('Wixarika')


########## Select one language to plot different models ###############

wixarika_details <- read.csv('wixarika_details.txt', header = T, sep = '\t')
wixarika_details <- subset(wixarika_details, Model != 'Morfessor')
wixarika_details <- subset(wixarika_details, Size == 1000 & Metric == 'F1') # & Replacement == 'with')


wixarika_details %>%
  ggplot(aes(Split, Value, group = Model, color = Model)) +
  geom_line(aes(linetype=Model), alpha = 1) +
  scale_color_manual(values = c("steelblue", "peru", "darkgreen", "darkgrey", "mediumpurple4", "darkred", "black")) +
  scale_x_continuous(breaks=seq(1, 51, 5)) +
  facet_grid( ~ Replacement) +
  theme_classic() + 
  theme(text = element_text(size=16, family="Times")) + 
  theme(legend.position="top") +
  xlab("Data set") + 
  ylab("F1") + 
  xlim(c(1,50)) +
  guides(linetype = guide_legend(nrow = 2)) +
  ggtitle('wixarika 1000 F1')


### The variance in the F1 for each model type across data sets ###

ggplot(subset(wixarika_details, Metric == 'F1'), aes(x = Value, color = Replacement)) +
  geom_density() + 
  facet_grid(Model ~ Size) +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times"),
        axis.text.x=element_text(size=15),
        axis.text.y=element_text(size=15)) + 
  theme(legend.position="top") +
  labs(fill = "") +
  ggtitle('Wixarika variance in F1')


### 1000, with ###
### 0-CRF: mean 54.18; min 51.37; max 56.28
### 1-CRF: mean 72.27; min 69.34; max 73.27
### 2-CRF: mean 71.41; min 69.36; max 73.42
### 3-CRF: mean 71.48; min 69.34; max 74.01
### 4-CRF: mean 71.50; min 69.57; max 74.56
### Seq2seq: mean 70.40; min 68.06; max 72.93


### Calculating a breakdown ####

samples = unique(wixarika_details$Size)

wixarika_breakdown <- data.frame(Language=character(), Sample=character(), Replacement=character(), Metric=character(), Model=character(), Proportion=numeric())


for (sample in as.vector(samples)){
  for (replacement in c('with', 'without')){
    
    zero_CRF = 0
    first_CRF = 0
    second_CRF = 0
    third_CRF = 0
    fourth_CRF = 0
    seq = 0
    
    CRF = 0
    
    for (i in 1:50){
      
      data <- subset(wixarika_details,Split==as.character(i) & Size == sample & Replacement==replacement & Metric=='F1')
      best <- subset(data, Value == max(data$Value))
      print(best)
      if (best$Model == '0-CRF'){
        zero_CRF = zero_CRF + 1
        CRF = CRF + 1
      }
      
      if (best$Model == '1-CRF'){
        first_CRF = first_CRF + 1
        CRF = CRF + 1
      }
      
      if (best$Model == '2-CRF'){
        second_CRF = second_CRF + 1
        CRF = CRF + 1
      }
      
      if (best$Model == '3-CRF'){
        third_CRF = third_CRF + 1
        CRF = CRF + 1
      }
      
      if (best$Model == '4-CRF'){
        fourth_CRF = fourth_CRF + 1
        CRF = CRF + 1
      }
      
      if (best$Model == 'Seq2seq'){
        seq = seq + 1
      }}
    
    zero_CRF = zero_CRF * 100 / 50
    first_CRF = first_CRF * 100 / 50
    second_CRF = second_CRF * 100 / 50
    third_CRF = third_CRF * 100 / 50
    fourth_CRF = fourth_CRF * 100 / 50
    seq = seq * 100 / 50
    
    CRF = CRF * 100 / 50
    
    wixarika_breakdown[nrow(wixarika_breakdown) + 1, ] <- c(language, sample, replacement, 'F1', '0-CRF', zero_CRF)
    wixarika_breakdown[nrow(wixarika_breakdown) + 1, ] <- c(language, sample, replacement, 'F1', '1-CRF', first_CRF)
    wixarika_breakdown[nrow(wixarika_breakdown) + 1, ] <- c(language, sample, replacement, 'F1', '2-CRF', second_CRF)
    wixarika_breakdown[nrow(wixarika_breakdown) + 1, ] <- c(language, sample, replacement, 'F1', '3-CRF', third_CRF)
    wixarika_breakdown[nrow(wixarika_breakdown) + 1, ] <- c(language, sample, replacement, 'F1', '4-CRF', fourth_CRF)
    wixarika_breakdown[nrow(wixarika_breakdown) + 1, ] <- c(language, sample, replacement, 'F1', 'Seq2seq', seq)
    wixarika_breakdown[nrow(wixarika_breakdown) + 1, ] <- c(language, sample, replacement, 'F1', 'CRF', CRF)
    
  }}

write.csv(wixarika_breakdown, 'wixarika_breakdown.txt', row.names = FALSE)


wixarika_breakdown %>%
  ggplot(aes(Model, as.numeric(Proportion), fill = Model)) +
  geom_bar(stat = 'identity', alpha = 0.8) +
  geom_text(aes(label=Proportion), vjust=-2.6, color="black", size=3.5)+
  facet_grid(Replacement ~ Sample) +
  theme_classic() + 
  theme(text = element_text(size=30, family="Times"),
        axis.text.x=element_blank(),
        axis.text.y=element_text(size=30)) + 
  theme(legend.position="none") +
  ylim(c(0, 100)) +
  xlab("") + 
  ylab("Proportion (%)") +
  guides(fill = guide_legend(nrow = 2)) +
  ggtitle('Wixarika model statistics')


####### Studying the effects of data characteristics / heuristics #######
####### For original train / test random splits #########

wixarika_heuristics <- read.csv('wixarika_heuristics.txt', header = T, sep = '\t')
wixarika_full <- read.csv('wixarika_full.txt', header = T, sep = '\t')

samples = unique(wixarika_heuristics$Sample)

language <- unique(wixarika_heuristics$Language)

wixarika_df <- data.frame(Language=character(), Sample=character(), Replacement=character(), Metric=character(), Model=character(), Feature=character(), Coef=numeric(), Q2.5=numeric(), Q97.5=numeric()) 

for (sample in as.vector(samples)){
  for (replacement in c('with', 'without')){
    for (metric in c('Accuracy', 'Precision', 'Recall', 'F1', 'Avg. Distance')){
      for (model in c('Morfessor', '0-CRF', '1-CRF', '2-CRF', '3-CRF', '4-CRF', 'Seq2seq')){
        for (feature in c('word_overlap', 'morph_overlap', 
                          'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
          
          heuristics <- subset(wixarika_heuristics, Feature == feature & Sample == sample & Replacement == replacement)
          results <- subset(wixarika_full, Metric == metric & Model == model & Size == sample & Replacement == replacement)
          together = cbind(results, heuristics)
          
          regression <- lm(Score ~ Value, data = together)
          summary <- data.frame(summary(regression)$coef)
          coef = round(summary$Estimate[2], 2)
          ci = data.frame(confint(regression, 'Value', level = 0.95))
          q2.5 = round(ci$X2.5..[1], 2)
          q97.5 = round(ci$X97.5..[1], 2)

          wixarika_df[nrow(wixarika_df) + 1, ] <- c(language, sample, replacement, metric, model, feature, coef, q2.5, q97.5)
          
          wixarika_df[is.na(wixarika_df)] <- 0
          
          write.csv(wixarika_df, 'wixarika_corr.txt',row.names=FALSE)
          
        }}}}}


ggplot(subset(wixarika_df, Sample=='1000'&Replacement=='with'& (Q2.5 > 0 | Q97.5 < 0)), aes(Feature, as.numeric(Coef), fill = Feature)) +
  geom_bar(stat = 'identity', alpha = 0.8) +
  geom_errorbar(aes(ymax = as.numeric(Q97.5), ymin = as.numeric(Q2.5)), width=.1, position=position_dodge(.9)) +
  geom_text(aes(label=Coef), vjust=2.6, color="black", size=3.5)+
  facet_grid(Model ~ Metric) +
  theme_classic() + 
  theme(text = element_text(size=10, family="Times"),
        axis.text.x=element_blank(),
        axis.text.y=element_text(size=10)) + 
  theme(legend.position="top") +
  ylim(c(-1, 1)) +
  ylab("Spearman") +
  guides(fill = guide_legend(nrow = 2)) +
  labs(fill = "") +
  ggtitle('Wikariak characteristics 1000 with')


together = 0

for (sample in as.vector(samples)){
  for (replacement in c('with', 'without')){
    for (metric in c('Accuracy', 'Precision', 'Recall', 'F1', 'Avg. Distance')){
      for (model in c('Morfessor', '0-CRF', '1-CRF', '2-CRF', '3-CRF', '4-CRF', 'Seq2seq')){
        for (feature in c('word_overlap', 'morph_overlap',
                          'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
          
          heuristics <- subset(wixarika_heuristics, Feature == feature & Sample == sample & Replacement == replacement)
          results <- subset(wixarika_full, Metric == metric & Model == model & Size == sample & Replacement == replacement)
          together <- rbind(together, cbind(results, heuristics))
          
        }}}}}

together <- subset(together, Language != 0)
together$Sample <- as.numeric(together$Sample)

wixarika_df <- data.frame(Language=character(), Feature=character(), Factor=character(), Coef=numeric(), Q2.5=numeric(), Q97.5=numeric()) 


for (feature in c('word_overlap', 'morph_overlap', 
                  'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
  
  data <- subset(together, Model != 'Morfessor' & Feature == feature & Score != 0 & Value != 0)
  print(feature)
  regression <- 0
  
  if (feature %in% c('word_overlap')){
    regression <- lm(Score ~ Value * Sample * Model * Metric, data = data)
    
  }
  else {
    regression <- lm(Score ~ Value * Replacement * Sample * Model * Metric, data = data) 
    
  }
  
  summary <- data.frame(summary(regression)$coef)
  summary$Factor <- rownames(summary)
  
  for (factor in as.vector(summary$Factor)){
    coef = subset(summary, Factor == factor)$Estimate
    ci = data.frame(confint(regression, factor, level = 0.95))
    q2.5 = ci$X2.5..[1]
    q97.5 = ci$X97.5..[1]
    wixarika_df[nrow(wixarika_df) + 1, ] <- c(language, feature, factor, round(coef, 2), round(q2.5, 2), round(q97.5, 2))
    write.csv(wixarika_df, 'wixarika_corr_overall.txt', row.names = FALSE)
    
  }
  
}


###### Studying whether data could be split by heuristics or adversarial training ####

wixarika_split_len <- read.csv('wixarika_split_len.txt', header = T, sep = '\t')

### 500, with: 16 data sets splittable by number of morphemes
### 500, without: 17 data sets ###
### 1000, with: 20 data sets ###
### 1000, without: 35 data sets ###

wixarika_split_adv <- read.csv('wixarika_split_adv.txt', header = T, sep = '\t')
wixarika_split_adv <- subset(wixarika_split_adv, Split != 'EVERYTHING')

### 500, with: min 39.5; max 59.5
### 500, without: min 32, max 49
### 1000, with: min 47.25; max 63
### 1000, without: min 35.5; max 47.75

ggplot(wixarika_split_adv, aes(x = Overlap)) +
  geom_histogram() + 
  facet_grid(Sample ~ Replacement) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times"),
        axis.text.x=element_text(size=15),
        axis.text.y=element_text(size=15)) + 
  theme(legend.position="top") +
  xlim(c(0, 100)) +
  labs(fill = "") +
  ggtitle('wixarika adversarial')



########### New test set sizes #################


wixarika_with_500_50 <- read.csv('wixarika_crf_test_with_500_50_results.txt', header = T, sep = ' ')
wixarika_with_500_50$Size <- rep('500', nrow(wixarika_with_500_50))
wixarika_with_500_50$Replacement <- rep('with', nrow(wixarika_with_500_50))

wixarika_with_500_100 <- read.csv('wixarika_crf_test_with_500_100_results.txt', header = T, sep = ' ')
wixarika_with_500_100$Size <- rep('500', nrow(wixarika_with_500_100))
wixarika_with_500_100$Replacement <- rep('with', nrow(wixarika_with_500_100))

wixarika_with_1000_50 <- read.csv('wixarika_seq2seq_test_with_1000_50_results.txt', header = T, sep = ' ')
wixarika_with_1000_50$Size <- rep('1000', nrow(wixarika_with_1000_50))
wixarika_with_1000_50$Replacement <- rep('with', nrow(wixarika_with_1000_50))

wixarika_with_1000_100 <- read.csv('wixarika_seq2seq_test_with_1000_100_results.txt', header = T, sep = ' ')
wixarika_with_1000_100$Size <- rep('1000', nrow(wixarika_with_1000_100))
wixarika_with_1000_100$Replacement <- rep('with', nrow(wixarika_with_1000_100))

wixarika_without_500_50 <- read.csv('wixarika_crf_test_without_500_50_results.txt', header = T, sep = ' ')
wixarika_without_500_50$Size <- rep('500', nrow(wixarika_without_500_50))
wixarika_without_500_50$Replacement <- rep('without', nrow(wixarika_without_500_50))

wixarika_without_500_100 <- read.csv('wixarika_crf_test_without_500_100_results.txt', header = T, sep = ' ')
wixarika_without_500_100$Size <- rep('500', nrow(wixarika_without_500_100))
wixarika_without_500_100$Replacement <- rep('without', nrow(wixarika_without_500_100))

wixarika_without_1000_50 <- read.csv('wixarika_crf_test_without_1000_50_results.txt', header = T, sep = ' ')
wixarika_without_1000_50$Size <- rep('1000', nrow(wixarika_without_1000_50))
wixarika_without_1000_50$Replacement <- rep('without', nrow(wixarika_without_1000_50))

wixarika_without_1000_100 <- read.csv('wixarika_crf_test_without_1000_100_results.txt', header = T, sep = ' ')
wixarika_without_1000_100$Size <- rep('1000', nrow(wixarika_without_1000_100))
wixarika_without_1000_100$Replacement <- rep('without', nrow(wixarika_without_1000_100))


wixarika_500 <- rbind(wixarika_with_500_50, wixarika_with_500_100, wixarika_without_500_50, wixarika_without_500_100)
wixarika_1000 <- rbind(wixarika_with_1000_50, wixarika_with_1000_100, wixarika_without_1000_50, wixarika_without_1000_100)
wixarika_test <- rbind(wixarika_500, wixarika_1000)

wixarika_500_p <-
  ggplot(wixarika_500, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('500 F1')

wixarika_1000_p <-
  ggplot(wixarika_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  #  scale_fill_manual(values = c("steelblue", "mediumpurple4", "darkgreen", "peru")) +
  facet_grid( ~ Sample_size) +
  #      facet_grid(vars(Sample_size)) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  #        axis.text.x=element_blank()) + 
  theme(legend.position="top") +
  #  xlab("") + 
  ylab("Density") +
  ggtitle('1000 F1')


### F1
### 500, 50, with: min 47.8; max 87.33
### 500, 50, without: min 45.04; max 90.06
### 500, 100, with: min 53.15; max 84.1
### 500, 100, without: min 53.18; max 85.28
### 1000, 50, with: min 48.74; max 89.43
### 1000, 50, without: min 53.46; max 91.54
### 1000, 100, with: min 52.63; max 84.04
### 1000, 100, without: min 60.67; max 90.08

ggplot(wixarika_test, aes(x = Recall, color = Replacement)) +
  geom_density() + 
  facet_grid(Sample_size ~ Size) +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times"),
        axis.text.x=element_text(size=15),
        axis.text.y=element_text(size=15)) + 
  theme(legend.position="top") +
  labs(fill = "") +
  ggtitle('Wixarika test Recall')


#grid.arrange(wixarika_500_p, wixarika_1000_p, ncol = 1, nrow = 2)



####### Studying the effects of data characteristics / heuristics #######
####### For new test sets ############


wixarika_new_test_heuristics <- read.csv('wixarika_new_test_heuristics.txt', header = T, sep = '\t')

temp <- subset(wixarika_test, select = -c(Precision, Recall, F1, Distance))
names(temp) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp$Metric <- rep('Accuracy', nrow(temp))

temp1 <- subset(wixarika_test, select = -c(Accuracy, Recall, F1, Distance))
names(temp1) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp1$Metric <- rep('Precision', nrow(temp1))

temp2 <- subset(wixarika_test, select = -c(Accuracy, Precision, F1, Distance))
names(temp2) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp2$Metric <- rep('Recall', nrow(temp2))

temp3 <- subset(wixarika_test, select = -c(Accuracy, Precision, Recall, Distance))
names(temp3) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp3$Metric <- rep('F1', nrow(temp3))

temp4 <- subset(wixarika_test, select = -c(Accuracy, Precision, Recall, F1))
names(temp4) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp4$Metric <- rep('Distance', nrow(temp4))

wixarika_full <- rbind(temp, temp1, temp2, temp3, temp4)

samples = unique(wixarika_new_test_heuristics$Sample)

language <- unique(wixarika_new_test_heuristics$Language)

together = 0


for (sample in as.vector(samples)){
  for (sample_size in as.vector(unique(wixarika_full$Sample_size))){
    for (split in as.vector(unique(wixarika_full$Split))){
      for (replacement in as.vector(unique(wixarika_new_test_heuristics$Replacement))){
        for (metric in c('Accuracy', 'Precision', 'Recall', 'F1', 'Distance')){
          results <- subset(wixarika_full, Metric == metric & Sample_size == sample_size & Split == split & Size == sample & Replacement == replacement)
          new_test_heuristics <- subset(wixarika_new_test_heuristics, Test_size == sample_size & Split == split & Feature == 'morph_overlap' & Sample == sample & Replacement == replacement)
          new_test_heuristics <- subset(new_test_heuristics, select = -Feature)
          names(new_test_heuristics) <- c('Language', 'Sample', 'Replacement', 'Split', 'Test_size', 'Test_id', 'Set', 'morph_overlap', 'Caveat')
          
          for (feature in c('ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
            
            if (feature == 'ave_num_morph_ratio'){
              new_test_heuristics$ave_num_morph_ratio <- subset(wixarika_new_test_heuristics, Test_size == sample_size & Split == split & Feature == feature & Sample == sample & Replacement == replacement)$Value
            }
            
            if (feature == 'dist_ave_num_morph'){
              new_test_heuristics$dist_ave_num_morph <- subset(wixarika_new_test_heuristics, Test_size == sample_size & Split == split & Feature == feature & Sample == sample & Replacement == replacement)$Value
            }
            
            if (feature == 'ave_morph_len_ratio'){
              new_test_heuristics$ave_morph_len_ratio <- subset(wixarika_new_test_heuristics, Test_size == sample_size & Split == split & Feature == feature & Sample == sample & Replacement == replacement)$Value
            }
            
          }
          
          together <- rbind(together, cbind(results, new_test_heuristics))
          
          
        }}}}}

together <- subset(together, Language != 0)
together$Sample <- as.numeric(together$Sample)

together$morph_overlap <- together$morph_overlap / 100



regression <- lm(Score ~ (morph_overlap + ave_num_morph_ratio + dist_ave_num_morph + ave_morph_len_ratio)*Replacement + (morph_overlap + ave_num_morph_ratio + dist_ave_num_morph + ave_morph_len_ratio)*Sample + (morph_overlap + ave_num_morph_ratio + dist_ave_num_morph + ave_morph_len_ratio)*Test_size + Metric, data = together)

summary <- data.frame(summary(regression)$coef)
summary$Factor <- rownames(summary)
print(summary)
wixarika_df <- data.frame(Language=character(), Factor=character(), Coef=numeric(), Q2.5=numeric(), Q97.5=numeric()) 


for (factor in as.vector(summary$Factor)){
  print(factor)
  coef = subset(summary, Factor == factor)$Estimate
  ci = data.frame(confint(regression, factor, level = 0.95))
  q2.5 = ci$X2.5..[1]
  q97.5 = ci$X97.5..[1]
  print(typeof(factor))
  wixarika_df[nrow(wixarika_df) + 1, ] <- c('wixarika', as.character(factor), round(coef, 2), round(q2.5, 2), round(q97.5, 2))
  write.csv(wixarika_df, 'wixarika_corr_new_test.txt', row.names = FALSE)
  
}

wixarika_df$Factor<-summary$Factor
wixarika_df$P_value<-summary$Pr...t..
wixarika_df$Language<-rep('wixarika',nrow(wixarika_df))

write.csv(wixarika_df, 'wixarika_corr_new_test.txt', row.names = FALSE)




################################
########### English ###########
################################

english <- read.csv('english.txt', header = T, sep = '\t')
english$Language <- rep('english', nrow(english))

english <- subset(english, Index %in% c('Same best model', 'Same model ranking', 'A best model', 'A best model ranking'))
english$Index[english$Index == 'Same model ranking'] <- 'Same ranking'
english$Index[english$Index == 'A best model ranking'] <- 'A best ranking'
english$Index <- factor(english$Index, levels = c('Same best model', 
                                                    'Same ranking', 
                                                    'A best model', 
                                                    'A best ranking'))

english_p <-
  ggplot(subset(english, Metric == 'F1'&Index %in% c('Same best model', 'Same ranking')), aes(Index, Proportion, fill = Index)) +
  geom_bar(stat = 'identity', alpha = 0.8) +
  geom_text(aes(label=paste(Proportion, '%')), vjust=-1, color="black", size=6)+
  scale_fill_manual(values = c("steelblue", "mediumpurple4")) + #, "darkgreen", "peru")) +
  facet_grid(Replacement ~ Size) +
  
  theme_classic() + 
  theme(text = element_text(size=30, family="Times"),
        axis.text.x=element_blank(),
        axis.text.y=element_text(size=30)) + 
  theme(legend.position="top") +
  ylim(c(0, 100)) +
  xlab("") + 
  ylab("Proportion (%)") +
  guides(fill = guide_legend(nrow = 1)) +
  labs(fill = "") +
  ggtitle('English')


########## Select one language to plot different models ###############

english_details <- read.csv('english_details.txt', header = T, sep = '\t')
english_details <- subset(english_details, Model != 'Morfessor')
english_details <- subset(english_details, Size == 500 & Metric == 'F1') # & Replacement == 'with')


english_details %>%
  ggplot(aes(Split, Value, group = Model, color = Model)) +
  geom_line(aes(linetype=Model), alpha = 1) +
  scale_color_manual(values = c("steelblue", "peru", "darkgreen", "darkgrey", "mediumpurple4", "darkred", "black")) +
  scale_x_continuous(breaks=seq(1, 51, 5)) +
  facet_grid( ~ Replacement) +
  theme_classic() + 
  theme(text = element_text(size=16, family="Times")) + 
  theme(legend.position="top") +
  xlab("Data set") + 
  ylab("F1") + 
  xlim(c(1,50)) +
  guides(linetype = guide_legend(nrow = 2)) +
  ggtitle('english 500 F1')


####### Studying the effects of data characteristics / heuristics #######
####### For original train / test random splits #########

english_heuristics <- read.csv('eng_heuristics.txt', header = T, sep = '\t')
english_full <- read.csv('english_full.txt', header = T, sep = '\t')

samples = unique(english_heuristics$Sample)

language <- unique(english_heuristics$Language)

english_df <- data.frame(Language=character(), Sample=character(), Replacement=character(), Metric=character(), Model=character(), Feature=character(), Coef=numeric(), Q2.5=numeric(), Q97.5=numeric()) 

for (sample in as.vector(samples)){
  for (replacement in c('with', 'without')){
    for (metric in c('Accuracy', 'Precision', 'Recall', 'F1', 'Avg. Distance')){
      for (model in c('Morfessor', '0-CRF', '1-CRF', '2-CRF', '3-CRF', '4-CRF', 'Seq2seq')){
        for (feature in c('word_overlap', 'morph_overlap', 
                          'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
          
          heuristics <- subset(english_heuristics, Feature == feature & Sample == sample & Replacement == replacement)
          results <- subset(english_full, Metric == metric & Model == model & Size == sample & Replacement == replacement)
          together = cbind(results, heuristics)
          
          regression <- lm(Score ~ Value, data = together)
          summary <- data.frame(summary(regression)$coef)
          coef = round(summary$Estimate[2], 2)
          ci = data.frame(confint(regression, 'Value', level = 0.95))
          q2.5 = round(ci$X2.5..[1], 2)
          q97.5 = round(ci$X97.5..[1], 2)
          
          english_df[nrow(english_df) + 1, ] <- c(language, sample, replacement, metric, model, feature, coef, q2.5, q97.5)
          
          english_df[is.na(english_df)] <- 0
          
          write.csv(english_df, 'english_corr.txt',row.names=FALSE)
          
        }}}}}


ggplot(subset(english_df, Sample=='1000'&Replacement=='with'& (Q2.5 > 0 | Q97.5 < 0)), aes(Feature, as.numeric(Coef), fill = Feature)) +
  geom_bar(stat = 'identity', alpha = 0.8) +
  geom_errorbar(aes(ymax = as.numeric(Q97.5), ymin = as.numeric(Q2.5)), width=.1, position=position_dodge(.9)) +
  geom_text(aes(label=Coef), vjust=2.6, color="black", size=3.5)+
  facet_grid(Model ~ Metric) +
  theme_classic() + 
  theme(text = element_text(size=10, family="Times"),
        axis.text.x=element_blank(),
        axis.text.y=element_text(size=10)) + 
  theme(legend.position="top") +
  ylim(c(-1, 1)) +
  ylab("Spearman") +
  guides(fill = guide_legend(nrow = 2)) +
  labs(fill = "") +
  ggtitle('English characteristics 1000 with')


together = 0

for (sample in as.vector(samples)){
  for (replacement in c('with', 'without')){
    for (metric in c('Accuracy', 'Precision', 'Recall', 'F1', 'Avg. Distance')){
      for (model in c('Morfessor', '0-CRF', '1-CRF', '2-CRF', '3-CRF', '4-CRF', 'Seq2seq')){
        for (feature in c('word_overlap', 'morph_overlap',
                          'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
          
          heuristics <- subset(english_heuristics, Feature == feature & Sample == sample & Replacement == replacement)
          results <- subset(english_full, Metric == metric & Model == model & Size == sample & Replacement == replacement)
          together <- rbind(together, cbind(results, heuristics))
          
        }}}}}

together <- subset(together, Language != 0)
together$Sample <- as.numeric(together$Sample)

english_df <- data.frame(Language=character(), Feature=character(), Factor=character(), Coef=numeric(), Q2.5=numeric(), Q97.5=numeric()) 


for (feature in c('word_overlap', 'morph_overlap', 
                  'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
  
  data <- subset(together, Model != 'Morfessor' & Feature == feature & Score != 0 & Value != 0)
  print(feature)
  regression <- 0
  
  if (feature %in% c('word_overlap')){
    regression <- lm(Score ~ Value * Sample * Model * Metric, data = data)
    
  }
  else {
    regression <- lm(Score ~ Value * Replacement * Sample * Model * Metric, data = data) 
    
  }
  
  summary <- data.frame(summary(regression)$coef)
  summary$Factor <- rownames(summary)
  
  for (factor in as.vector(summary$Factor)){
    coef = subset(summary, Factor == factor)$Estimate
    ci = data.frame(confint(regression, factor, level = 0.95))
    q2.5 = ci$X2.5..[1]
    q97.5 = ci$X97.5..[1]
    english_df[nrow(english_df) + 1, ] <- c(language, feature, factor, round(coef, 2), round(q2.5, 2), round(q97.5, 2))
    write.csv(english_df, 'english_corr_overall.txt', row.names = FALSE)
    
  }
  
}


###### Studying whether data could be split by heuristics or adversarial training ####

english_split_len <- read.csv('eng_split_len.txt', header = T, sep = '\t')
english_split_adv <- read.csv('eng_split_adv.txt', header = T, sep = '\t')
english_split_adv <- subset(english_split_adv, Split != 'EVERYTHING')

### 500, with ###
### 1 data set splittable by number of morphemes ###

### 500, with: min 39.5; max 59.5
### 500, without: min 32, max 49
### 1000, with: min 47.25; max 63
### 1000, without: min 35.5; max 47.75

ggplot(english_split_adv, aes(x = Overlap)) +
  geom_histogram() + 
  facet_grid(Sample ~ Replacement) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times"),
        axis.text.x=element_text(size=15),
        axis.text.y=element_text(size=15)) + 
  theme(legend.position="top") +
  xlim(c(0, 100)) +
  labs(fill = "") +
  ggtitle('English adversarial')



########### New test set sizes #################

english_with_500_50 <- read.csv('eng_crf_test_with_500_50_results.txt', header = T, sep = ' ')
english_with_500_50$Size <- rep('500', nrow(english_with_500_50))
english_with_500_50$Replacement <- rep('with', nrow(english_with_500_50))

english_with_500_100 <- read.csv('eng_crf_test_with_500_100_results.txt', header = T, sep = ' ')
english_with_500_100$Size <- rep('500', nrow(english_with_500_100))
english_with_500_100$Replacement <- rep('with', nrow(english_with_500_100))

english_with_1000_50 <- read.csv('eng_crf_test_with_1000_50_results.txt', header = T, sep = ' ')
english_with_1000_50$Size <- rep('1000', nrow(english_with_1000_50))
english_with_1000_50$Replacement <- rep('with', nrow(english_with_1000_50))

english_with_1000_100 <- read.csv('eng_crf_test_with_1000_100_results.txt', header = T, sep = ' ')
english_with_1000_100$Size <- rep('1000', nrow(english_with_1000_100))
english_with_1000_100$Replacement <- rep('with', nrow(english_with_1000_100))

english_with_1500_50 <- read.csv('eng_seq2seq_test_with_1500_50_results.txt', header = T, sep = ' ')
english_with_1500_50$Size <- rep('1500', nrow(english_with_1500_50))
english_with_1500_50$Replacement <- rep('with', nrow(english_with_1500_50))

english_with_1500_100 <- read.csv('eng_seq2seq_test_with_1500_100_results.txt', header = T, sep = ' ')
english_with_1500_100$Size <- rep('1500', nrow(english_with_1500_100))
english_with_1500_100$Replacement <- rep('with', nrow(english_with_1500_100))


english_without_500_50 <- read.csv('eng_crf_test_without_500_50_results.txt', header = T, sep = ' ')
english_without_500_50$Size <- rep('500', nrow(english_without_500_50))
english_without_500_50$Replacement <- rep('without', nrow(english_without_500_50))

english_without_500_100 <- read.csv('eng_crf_test_without_500_100_results.txt', header = T, sep = ' ')
english_without_500_100$Size <- rep('500', nrow(english_without_500_100))
english_without_500_100$Replacement <- rep('without', nrow(english_without_500_100))

english_without_1000_50 <- read.csv('eng_crf_test_without_1000_50_results.txt', header = T, sep = ' ')
english_without_1000_50$Size <- rep('1000', nrow(english_without_1000_50))
english_without_1000_50$Replacement <- rep('without', nrow(english_without_1000_50))

english_without_1000_100 <- read.csv('eng_crf_test_without_1000_100_results.txt', header = T, sep = ' ')
english_without_1000_100$Size <- rep('1000', nrow(english_without_1000_100))
english_without_1000_100$Replacement <- rep('without', nrow(english_without_1000_100))

english_without_1500_50 <- read.csv('eng_crf_test_without_1500_50_results.txt', header = T, sep = ' ')
english_without_1500_50$Size <- rep('1500', nrow(english_without_1500_50))
english_without_1500_50$Replacement <- rep('without', nrow(english_without_1500_50))

english_without_1500_100 <- read.csv('eng_crf_test_without_1500_100_results.txt', header = T, sep = ' ')
english_without_1500_100$Size <- rep('1500', nrow(english_without_1500_100))
english_without_1500_100$Replacement <- rep('without', nrow(english_without_1500_100))


english_500 <- rbind(english_with_500_50, english_with_500_100, english_without_500_50, english_without_500_100)
english_1000 <- rbind(english_with_1000_50, english_with_1000_100, english_without_1000_50, english_without_1000_100)
english_1500 <- rbind(english_with_1500_50, english_with_1500_100, english_without_1500_50, english_without_1500_100)
english_test <- rbind(english_500, english_1000, english_1500)

### F1
### 500, 50, with: min 43.34; max 87.3
### 500, 50, without: min 41.27; max 89.04
### 500, 100, with: min 47.8; max 81.28
### 500, 100, without: min 49.44; max 82.46
### 1000, 50, with: min 49.64; max 90.44
### 1000, 50, without: min 42.70; max 90.95
### 1000, 100, with: min 55.06; max 85.27
### 1000, 100, without: min 56.79; max 87.73

ggplot(english_test, aes(x = Distance, color = Replacement)) +
  geom_density() + 
  facet_grid(Sample_size ~ Size) +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times"),
        axis.text.x=element_text(size=15),
        axis.text.y=element_text(size=15)) + 
  theme(legend.position="top") +
  labs(fill = "") +
  ggtitle('English test Distance')



english_500_p <-
  ggplot(subset(english_500, Sample_size %in% c('50', '100')), aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('500')

english_1000_p <-
  ggplot(english_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  #  scale_fill_manual(values = c("steelblue", "mediumpurple4", "darkgreen", "peru")) +
  facet_grid( ~ Sample_size) +
  #      facet_grid(vars(Sample_size)) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  #        axis.text.x=element_blank()) + 
  theme(legend.position="top") +
  #  xlab("") + 
  ylab("Density") +
  ggtitle('1000')

english_1500_p <-
  ggplot(english_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  #  scale_fill_manual(values = c("steelblue", "mediumpurple4", "darkgreen", "peru")) +
  facet_grid( ~ Sample_size) +
  #      facet_grid(vars(Sample_size)) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  #        axis.text.x=element_blank()) + 
  theme(legend.position="top") +
  #  xlab("") + 
  ylab("Density") +
  ggtitle('1500')

grid.arrange(english_500_p, english_1000_p, ncol = 1, nrow = 2)



####### Studying the effects of data characteristics / heuristics #######
####### For new test sets ############



english_new_test_heuristics <- read.csv('eng_new_test_heuristics.txt', header = T, sep = '\t')

temp <- subset(english_test, select = -c(Precision, Recall, F1, Distance))
names(temp) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp$Metric <- rep('Accuracy', nrow(temp))

temp1 <- subset(english_test, select = -c(Accuracy, Recall, F1, Distance))
names(temp1) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp1$Metric <- rep('Precision', nrow(temp1))

temp2 <- subset(english_test, select = -c(Accuracy, Precision, F1, Distance))
names(temp2) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp2$Metric <- rep('Recall', nrow(temp2))

temp3 <- subset(english_test, select = -c(Accuracy, Precision, Recall, Distance))
names(temp3) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp3$Metric <- rep('F1', nrow(temp3))

temp4 <- subset(english_test, select = -c(Accuracy, Precision, Recall, F1))
names(temp4) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp4$Metric <- rep('Distance', nrow(temp4))

english_full <- rbind(temp, temp1, temp2, temp3, temp4)

samples = unique(english_new_test_heuristics$Sample)

language <- unique(english_new_test_heuristics$Language)

together = 0


for (sample in as.vector(samples)){
  for (sample_size in as.vector(unique(english_full$Sample_size))){
    for (split in as.vector(unique(english_full$Split))){
      for (replacement in as.vector(unique(english_new_test_heuristics$Replacement))){
        for (metric in c('Accuracy')){#, 'Precision', 'Recall', 'F1', 'Distance')){

          results <- subset(english_full, Metric == metric & Sample_size == sample_size & Split == split & Size == sample & Replacement == replacement)
          new_test_heuristics <- subset(english_new_test_heuristics, Test_size == sample_size & Split == split & Feature == 'morph_overlap' & Sample == sample & Replacement == replacement)
          new_test_heuristics <- subset(new_test_heuristics, select = -Feature)
          names(new_test_heuristics) <- c('Language', 'Sample', 'Replacement', 'Split', 'Test_size', 'Test_id', 'Set', 'morph_overlap', 'Caveat')
          
          for (feature in c('ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
            
            if (feature == 'ave_num_morph_ratio'){
              new_test_heuristics$ave_num_morph_ratio <- subset(english_new_test_heuristics, Test_size == sample_size & Split == split & Feature == feature & Sample == sample & Replacement == replacement)$Value
            }
            
            if (feature == 'dist_ave_num_morph'){
              new_test_heuristics$dist_ave_num_morph <- subset(english_new_test_heuristics, Test_size == sample_size & Split == split & Feature == feature & Sample == sample & Replacement == replacement)$Value
            }
            
            if (feature == 'ave_morph_len_ratio'){
              new_test_heuristics$ave_morph_len_ratio <- subset(english_new_test_heuristics, Test_size == sample_size & Split == split & Feature == feature & Sample == sample & Replacement == replacement)$Value
            }
            
          }

          together <- rbind(together, cbind(results, new_test_heuristics))
          write.csv(together, 'english_together_new_test.txt', row.names = FALSE)
          
        }}}}}

together <- subset(together, Language != 0)
together$Sample <- as.numeric(together$Sample)

together$morph_overlap <- together$morph_overlap / 100


regression <- lm(Score ~ (morph_overlap + ave_num_morph_ratio + dist_ave_num_morph + ave_morph_len_ratio)*Replacement + (morph_overlap + ave_num_morph_ratio + dist_ave_num_morph + ave_morph_len_ratio)*Sample + (morph_overlap + ave_num_morph_ratio + dist_ave_num_morph + ave_morph_len_ratio)*Test_size + Metric, data = together)

summary <- data.frame(summary(regression)$coef)
summary$Factor <- rownames(summary)
print(summary)
english_df <- data.frame(Language=character(), Factor=character(), Coef=numeric(), Q2.5=numeric(), Q97.5=numeric()) 


for (factor in as.vector(summary$Factor)){
  print(factor)
  coef = subset(summary, Factor == factor)$Estimate
  ci = data.frame(confint(regression, factor, level = 0.95))
  q2.5 = ci$X2.5..[1]
  q97.5 = ci$X97.5..[1]
  print(typeof(factor))
  english_df[nrow(english_df) + 1, ] <- c('english', as.character(factor), round(coef, 2), round(q2.5, 2), round(q97.5, 2))
  write.csv(english_df, 'english_corr_new_test.txt', row.names = FALSE)
  
}

english_df$Factor<-summary$Factor
english_df$P_value<-summary$Pr...t..
english_df$Language<-rep('english',nrow(english_df))

write.csv(english_df, 'english_corr_new_test.txt', row.names = FALSE)


################################
########### German ###########
################################

german <- read.csv('german.txt', header = T, sep = '\t')
german$Language <- rep('german', nrow(german))

german <- subset(german, Index %in% c('Same best model', 'Same model ranking', 'A best model', 'A best model ranking'))
german$Index[german$Index == 'Same model ranking'] <- 'Same ranking'
german$Index[german$Index == 'A best model ranking'] <- 'A best ranking'
german$Index <- factor(german$Index, levels = c('Same best model', 
                                                  'Same ranking', 
                                                  'A best model', 
                                                  'A best ranking'))

german_p <-
  ggplot(subset(german, Metric == 'F1'&Index %in% c('Same best model', 'Same ranking')), aes(Index, Proportion, fill = Index)) +
  geom_bar(stat = 'identity', alpha = 0.8) +
  geom_text(aes(label=paste(Proportion, '%')), vjust=-1, color="black", size=6)+
  scale_fill_manual(values = c("steelblue", "mediumpurple4")) + #, "darkgreen", "peru")) +
  facet_grid(Replacement ~ Size) +
  
  theme_classic() + 
  theme(text = element_text(size=30, family="Times"),
        axis.text.x=element_blank(),
        axis.text.y=element_text(size=30)) + 
  theme(legend.position="top") +
  ylim(c(0, 100)) +
  xlab("") + 
  ylab("Proportion (%)") +
  guides(fill = guide_legend(nrow = 1)) +
  labs(fill = "") +
  ggtitle('German')


########## Select one language to plot different models ###############

german_details <- read.csv('german_details.txt', header = T, sep = '\t')
german_details <- subset(german_details, Model != 'Morfessor')
german_details <- subset(german_details, Size == 500 & Metric == 'F1') # & Replacement == 'with')


german_details %>%
  ggplot(aes(Split, Value, group = Model, color = Model)) +
  geom_line(aes(linetype=Model), alpha = 1) +
  scale_color_manual(values = c("steelblue", "peru", "darkgreen", "darkgrey", "mediumpurple4", "darkred", "black")) +
  scale_x_continuous(breaks=seq(1, 51, 5)) +
  facet_grid( ~ Replacement) +
  theme_classic() + 
  theme(text = element_text(size=16, family="Times")) + 
  theme(legend.position="top") +
  xlab("Data set") + 
  ylab("F1") + 
  xlim(c(1,50)) +
  guides(linetype = guide_legend(nrow = 2)) +
  ggtitle('german 500 F1')


####### Studying the effects of data characteristics / heuristics #######
####### For original train / test random splits #########

german_heuristics <- read.csv('ger_heuristics.txt', header = T, sep = '\t')
german_full <- read.csv('german_full.txt', header = T, sep = '\t')

samples = unique(german_heuristics$Sample)

language <- unique(german_heuristics$Language)

german_df <- data.frame(Language=character(), Sample=character(), Replacement=character(), Metric=character(), Model=character(), Feature=character(), Coef=numeric(), Q2.5=numeric(), Q97.5=numeric()) 

for (sample in as.vector(samples)){
  for (replacement in c('with', 'without')){
    for (metric in c('Accuracy', 'Precision', 'Recall', 'F1', 'Avg. Distance')){
      for (model in c('Morfessor', '0-CRF', '1-CRF', '2-CRF', '3-CRF', '4-CRF', 'Seq2seq')){
        for (feature in c('word_overlap', 'morph_overlap', 
                          'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
          
          heuristics <- subset(german_heuristics, Feature == feature & Sample == sample & Replacement == replacement)
          results <- subset(german_full, Metric == metric & Model == model & Size == sample & Replacement == replacement)
          together = cbind(results, heuristics)
          
          regression <- lm(Score ~ Value, data = together)
          summary <- data.frame(summary(regression)$coef)
          coef = round(summary$Estimate[2], 2)
          ci = data.frame(confint(regression, 'Value', level = 0.95))
          q2.5 = round(ci$X2.5..[1], 2)
          q97.5 = round(ci$X97.5..[1], 2)
          
          german_df[nrow(german_df) + 1, ] <- c(language, sample, replacement, metric, model, feature, coef, q2.5, q97.5)
          
          german_df[is.na(german_df)] <- 0
          
          write.csv(german_df, 'german_corr.txt',row.names=FALSE)
          
        }}}}}


ggplot(subset(german_df, Sample=='1000'&Replacement=='with'& (Q2.5 > 0 | Q97.5 < 0)), aes(Feature, as.numeric(Coef), fill = Feature)) +
  geom_bar(stat = 'identity', alpha = 0.8) +
  geom_errorbar(aes(ymax = as.numeric(Q97.5), ymin = as.numeric(Q2.5)), width=.1, position=position_dodge(.9)) +
  geom_text(aes(label=Coef), vjust=2.6, color="black", size=3.5)+
  facet_grid(Model ~ Metric) +
  theme_classic() + 
  theme(text = element_text(size=10, family="Times"),
        axis.text.x=element_blank(),
        axis.text.y=element_text(size=10)) + 
  theme(legend.position="top") +
  ylim(c(-1, 1)) +
  ylab("Spearman") +
  guides(fill = guide_legend(nrow = 2)) +
  labs(fill = "") +
  ggtitle('german characteristics 1000 with')


together = 0

for (sample in as.vector(samples)){
  for (replacement in c('with', 'without')){
    for (metric in c('Accuracy', 'Precision', 'Recall', 'F1', 'Avg. Distance')){
      for (model in c('Morfessor', '0-CRF', '1-CRF', '2-CRF', '3-CRF', '4-CRF', 'Seq2seq')){
        for (feature in c('word_overlap', 'morph_overlap',
                          'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
          
          heuristics <- subset(german_heuristics, Feature == feature & Sample == sample & Replacement == replacement)
          results <- subset(german_full, Metric == metric & Model == model & Size == sample & Replacement == replacement)
          together <- rbind(together, cbind(results, heuristics))
          
        }}}}}

together <- subset(together, Language != 0)
together$Sample <- as.numeric(together$Sample)

german_df <- data.frame(Language=character(), Feature=character(), Factor=character(), Coef=numeric(), Q2.5=numeric(), Q97.5=numeric()) 


for (feature in c('word_overlap', 'morph_overlap', 
                  'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
  
  data <- subset(together, Model != 'Morfessor' & Feature == feature & Score != 0 & Value != 0)
  print(feature)
  regression <- 0
  
  if (feature %in% c('word_overlap')){
    regression <- lm(Score ~ Value * Sample * Model * Metric, data = data)
    
  }
  else {
    regression <- lm(Score ~ Value * Replacement * Sample * Model * Metric, data = data) 
    
  }
  
  summary <- data.frame(summary(regression)$coef)
  summary$Factor <- rownames(summary)
  
  for (factor in as.vector(summary$Factor)){
    coef = subset(summary, Factor == factor)$Estimate
    ci = data.frame(confint(regression, factor, level = 0.95))
    q2.5 = ci$X2.5..[1]
    q97.5 = ci$X97.5..[1]
    german_df[nrow(german_df) + 1, ] <- c(language, feature, factor, round(coef, 2), round(q2.5, 2), round(q97.5, 2))
    write.csv(german_df, 'german_corr_overall.txt', row.names = FALSE)
    
  }
  
}


###### Studying whether data could be split by heuristics or adversarial training ####

german_split_len <- read.csv('ger_split_len.txt', header = T, sep = '\t')
german_split_adv <- read.csv('ger_split_adv.txt', header = T, sep = '\t')
german_split_adv <- subset(german_split_adv, Split != 'EVERYTHING')

### 0 data set splittable by number of morphemes ###

### 500, with: min 35.5; max 58
### 500, without: min 33, max 55.5
### 1000, with: min 44.5; max 65.25
### 1000, without: min 27.75; max 49.5

ggplot(german_split_adv, aes(x = Overlap)) +
  geom_histogram() + 
  facet_grid(Sample ~ Replacement) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times"),
        axis.text.x=element_text(size=15),
        axis.text.y=element_text(size=15)) + 
  theme(legend.position="top") +
  xlim(c(0, 100)) +
  labs(fill = "") +
  ggtitle('German adversarial')


########### New test set sizes #################


german_with_500_50 <- read.csv('ger_crf_test_with_500_50_results.txt', header = T, sep = ' ')
german_with_500_50$Size <- rep('500', nrow(german_with_500_50))
german_with_500_50$Replacement <- rep('with', nrow(german_with_500_50))

german_with_500_100 <- read.csv('ger_crf_test_with_500_100_results.txt', header = T, sep = ' ')
german_with_500_100$Size <- rep('500', nrow(german_with_500_100))
german_with_500_100$Replacement <- rep('with', nrow(german_with_500_100))

german_with_1000_50 <- read.csv('ger_crf_test_with_1000_50_results.txt', header = T, sep = ' ')
german_with_1000_50$Size <- rep('1000', nrow(german_with_1000_50))
german_with_1000_50$Replacement <- rep('with', nrow(german_with_1000_50))

german_with_1000_100 <- read.csv('ger_crf_test_with_1000_100_results.txt', header = T, sep = ' ')
german_with_1000_100$Size <- rep('1000', nrow(german_with_1000_100))
german_with_1000_100$Replacement <- rep('with', nrow(german_with_1000_100))

german_with_1500_50 <- read.csv('ger_seq2seq_test_with_1500_50_results.txt', header = T, sep = ' ')
german_with_1500_50$Size <- rep('1500', nrow(german_with_1500_50))
german_with_1500_50$Replacement <- rep('with', nrow(german_with_1500_50))

german_with_1500_100 <- read.csv('ger_seq2seq_test_with_1500_100_results.txt', header = T, sep = ' ')
german_with_1500_100$Size <- rep('1500', nrow(german_with_1500_100))
german_with_1500_100$Replacement <- rep('with', nrow(german_with_1500_100))

german_without_500_50 <- read.csv('ger_crf_test_without_500_50_results.txt', header = T, sep = ' ')
german_without_500_50$Size <- rep('500', nrow(german_without_500_50))
german_without_500_50$Replacement <- rep('without', nrow(german_without_500_50))

german_without_500_100 <- read.csv('ger_crf_test_without_500_100_results.txt', header = T, sep = ' ')
german_without_500_100$Size <- rep('500', nrow(german_without_500_100))
german_without_500_100$Replacement <- rep('without', nrow(german_without_500_100))

german_without_1000_50 <- read.csv('ger_crf_test_without_1000_50_results.txt', header = T, sep = ' ')
german_without_1000_50$Size <- rep('1000', nrow(german_without_1000_50))
german_without_1000_50$Replacement <- rep('without', nrow(german_without_1000_50))

german_without_1000_100 <- read.csv('ger_crf_test_without_1000_100_results.txt', header = T, sep = ' ')
german_without_1000_100$Size <- rep('1000', nrow(german_without_1000_100))
german_without_1000_100$Replacement <- rep('without', nrow(german_without_1000_100))

german_without_1500_50 <- read.csv('ger_crf_test_without_1500_50_results.txt', header = T, sep = ' ')
german_without_1500_50$Size <- rep('1500', nrow(german_without_1500_50))
german_without_1500_50$Replacement <- rep('without', nrow(german_without_1500_50))

german_without_1500_100 <- read.csv('ger_crf_test_without_1500_100_results.txt', header = T, sep = ' ')
german_without_1500_100$Size <- rep('1500', nrow(german_without_1500_100))
german_without_1500_100$Replacement <- rep('without', nrow(german_without_1500_100))


german_500 <- rbind(german_with_500_50, german_with_500_100, german_without_500_50, german_without_500_100)
german_1000 <- rbind(german_with_1000_50, german_with_1000_100, german_without_1000_50, german_without_1000_100)
german_1500 <- rbind(german_with_1500_50, german_with_1500_100, german_without_1500_50, german_without_1500_100)
german_test <- rbind(german_500, german_1000, german_1500)

### F1
### 500, 50, with: min 47.8; max 87.33
### 500, 50, without: min 45.04; max 90.06
### 500, 100, with: min 53.15; max 84.1
### 500, 100, without: min 53.18; max 85.28
### 1000, 50, with: min 48.74; max 89.43
### 1000, 50, without: min 53.46; max 91.54
### 1000, 100, with: min 52.63; max 84.04
### 1000, 100, without: min 60.67; max 90.08

ggplot(german_test, aes(x = Recall, color = Replacement)) +
  geom_density() + 
  facet_grid(Sample_size ~ Size) +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times"),
        axis.text.x=element_text(size=15),
        axis.text.y=element_text(size=15)) + 
  theme(legend.position="top") +
  labs(fill = "") +
  ggtitle('German test Recall')



german_500_p <-
  ggplot(subset(german_500, Sample_size %in% c('50', '100')), aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('500')

german_1000_p <-
  ggplot(german_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('1000')

german_1500_p <-
  ggplot(german_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('1500')

grid.arrange(german_500_p, german_1000_p, ncol = 1, nrow = 2)



####### Studying the effects of data characteristics / heuristics #######
####### For new test sets ############


german_new_test_heuristics <- read.csv('german_new_test_heuristics.txt', header = T, sep = '\t')
german_test <- german_with_500_100

samples = unique(german_new_test_heuristics$Sample)

language <- unique(german_new_test_heuristics$Language)

df <- data.frame(Language=character(), Sample=character(), Replacement=character(), Metric=character(), Feature=character(),Spearman=numeric(),Pearson=numeric())

for (sample in as.vector(samples)){
  for (replacement in c('with', 'without')){
    for (feature in c('morph_overlap', 'unique_word_type_ratio', 'unique_morph_type_ratio',
                      'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
      
      heuristics <- subset(german_new_test_heuristics, Feature == feature & Sample == sample & Replacement == replacement)
      results <- subset(german_test, Size == sample & Replacement == replacement)
      together = cbind(results, heuristics)
      accuracy_spearman_c = cor(together$Accuracy, together$Value, method = c('spearman'))
      accuracy_pearson_c = cor(together$Accuracy, together$Value, method = c('pearson'))
      df[nrow(df) + 1, ] <- c(language, sample, replacement, 'Accuracy', feature, accuracy_spearman_c, accuracy_pearson_c)
      
      Precision_spearman_c = cor(together$Precision, together$Value, method = c('spearman'))
      Precision_pearson_c = cor(together$Precision, together$Value, method = c('pearson'))
      df[nrow(df) + 1, ] <- c(language, sample, replacement, 'Precision', feature, accuracy_spearman_c, accuracy_pearson_c)
      
      Recall_spearman_c = cor(together$Recall, together$Value, method = c('spearman'))
      Recall_pearson_c = cor(together$Recall, together$Value, method = c('pearson'))
      df[nrow(df) + 1, ] <- c(language, sample, replacement, 'Recall', feature, accuracy_spearman_c, accuracy_pearson_c)
      
      F1_spearman_c = cor(together$F1, together$Value, method = c('spearman'))
      F1_pearson_c = cor(together$F1, together$Value, method = c('pearson'))
      df[nrow(df) + 1, ] <- c(language, sample, replacement, 'F1', feature, accuracy_spearman_c, accuracy_pearson_c)
      
      Distance_spearman_c = cor(together$Distance, together$Value, method = c('spearman'))
      Distance_pearson_c = cor(together$Distance, together$Value, method = c('pearson'))
      df[nrow(df) + 1, ] <- c(language, sample, replacement, 'Distance', feature, accuracy_spearman_c, accuracy_pearson_c)
      
    }}}

#df <- subset(df, Model != 'Morfessor')

write.csv(df, 'german_new_test_corr.txt',row.names=FALSE)



################################
########### Persian ###########
################################

persian <- read.csv('persian.txt', header = T, sep = '\t')
persian$Language <- rep('persian', nrow(persian))

persian <- subset(persian, Index %in% c('Same best model', 'Same model ranking', 'A best model', 'A best model ranking'))
persian$Index[persian$Index == 'Same model ranking'] <- 'Same ranking'
persian$Index[persian$Index == 'A best model ranking'] <- 'A best ranking'
persian$Index <- factor(persian$Index, levels = c('Same best model', 
                                                'Same ranking', 
                                                'A best model', 
                                                'A best ranking'))

persian_p <-
  ggplot(subset(persian, Metric == 'F1'&Index %in% c('Same best model', 'Same ranking')), aes(Index, Proportion, fill = Index)) +
  geom_bar(stat = 'identity', alpha = 0.8) +
  geom_text(aes(label=paste(Proportion, '%')), vjust=-1, color="black", size=6)+
  scale_fill_manual(values = c("steelblue", "mediumpurple4")) + #, "darkgreen", "peru")) +
  facet_grid(Replacement ~ Size) +
  
  theme_classic() + 
  theme(text = element_text(size=30, family="Times"),
        axis.text.x=element_blank(),
        axis.text.y=element_text(size=30)) + 
  theme(legend.position="top") +
  ylim(c(0, 100)) +
  xlab("") + 
  ylab("Proportion (%)") +
  guides(fill = guide_legend(nrow = 1)) +
  labs(fill = "") +
  ggtitle('Persian')


########## Select one language to plot different models ###############

persian_details <- read.csv('persian_details.txt', header = T, sep = '\t')
persian_details <- subset(persian_details, Model != 'Morfessor')
persian_details <- subset(persian_details, Size == 500 & Metric == 'F1') # & Replacement == 'with')


persian_details %>%
  ggplot(aes(Split, Value, group = Model, color = Model)) +
  geom_line(aes(linetype=Model), alpha = 1) +
  scale_color_manual(values = c("steelblue", "peru", "darkgreen", "darkgrey", "mediumpurple4", "darkred", "black")) +
  scale_x_continuous(breaks=seq(1, 51, 5)) +
  facet_grid( ~ Replacement) +
  theme_classic() + 
  theme(text = element_text(size=16, family="Times")) + 
  theme(legend.position="top") +
  xlab("Data set") + 
  ylab("F1") + 
  xlim(c(1,50)) +
  guides(linetype = guide_legend(nrow = 2)) +
  ggtitle('persian 500 F1')


####### Studying the effects of data characteristics / heuristics #######
####### For original train / test random splits #########

persian_heuristics <- read.csv('persian_heuristics.txt', header = T, sep = '\t')
persian_full <- read.csv('persian_full.txt', header = T, sep = '\t')

samples = unique(persian_heuristics$Sample)

language <- unique(persian_heuristics$Language)

persian_df <- data.frame(Language=character(), Sample=character(), Replacement=character(), Metric=character(), Model=character(), Feature=character(), Coef=numeric(), Q2.5=numeric(), Q97.5=numeric()) 

for (sample in as.vector(samples)){
  for (replacement in c('with', 'without')){
    for (metric in c('Accuracy', 'Precision', 'Recall', 'F1', 'Avg. Distance')){
      for (model in c('Morfessor', '0-CRF', '1-CRF', '2-CRF', '3-CRF', '4-CRF', 'Seq2seq')){
        for (feature in c('word_overlap', 'morph_overlap', 
                          'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
          
          heuristics <- subset(persian_heuristics, Feature == feature & Sample == sample & Replacement == replacement)
          results <- subset(persian_full, Metric == metric & Model == model & Size == sample & Replacement == replacement)
          together = cbind(results, heuristics)
          
          regression <- lm(Score ~ Value, data = together)
          summary <- data.frame(summary(regression)$coef)
          coef = round(summary$Estimate[2], 2)
          ci = data.frame(confint(regression, 'Value', level = 0.95))
          q2.5 = round(ci$X2.5..[1], 2)
          q97.5 = round(ci$X97.5..[1], 2)
          
          persian_df[nrow(persian_df) + 1, ] <- c(language, sample, replacement, metric, model, feature, coef, q2.5, q97.5)
          
          persian_df[is.na(persian_df)] <- 0
          
          write.csv(persian_df, 'persian_corr.txt',row.names=FALSE)
          
        }}}}}


ggplot(subset(persian_df, Sample=='1000'&Replacement=='with'& (Q2.5 > 0 | Q97.5 < 0)), aes(Feature, as.numeric(Coef), fill = Feature)) +
  geom_bar(stat = 'identity', alpha = 0.8) +
  geom_errorbar(aes(ymax = as.numeric(Q97.5), ymin = as.numeric(Q2.5)), width=.1, position=position_dodge(.9)) +
  geom_text(aes(label=Coef), vjust=2.6, color="black", size=3.5)+
  facet_grid(Model ~ Metric) +
  theme_classic() + 
  theme(text = element_text(size=10, family="Times"),
        axis.text.x=element_blank(),
        axis.text.y=element_text(size=10)) + 
  theme(legend.position="top") +
  ylim(c(-1, 1)) +
  ylab("Spearman") +
  guides(fill = guide_legend(nrow = 2)) +
  labs(fill = "") +
  ggtitle('persian characteristics 1000 with')


together = 0

for (sample in as.vector(samples)){
  for (replacement in c('with', 'without')){
    for (metric in c('Accuracy', 'Precision', 'Recall', 'F1', 'Avg. Distance')){
      for (model in c('Morfessor', '0-CRF', '1-CRF', '2-CRF', '3-CRF', '4-CRF', 'Seq2seq')){
        for (feature in c('word_overlap', 'morph_overlap',
                          'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
          
          heuristics <- subset(persian_heuristics, Feature == feature & Sample == sample & Replacement == replacement)
          results <- subset(persian_full, Metric == metric & Model == model & Size == sample & Replacement == replacement)
          together <- rbind(together, cbind(results, heuristics))
          
        }}}}}

together <- subset(together, Language != 0)
together$Sample <- as.numeric(together$Sample)

persian_df <- data.frame(Language=character(), Feature=character(), Factor=character(), Coef=numeric(), Q2.5=numeric(), Q97.5=numeric()) 


for (feature in c('word_overlap', 'morph_overlap', 
                  'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
  
  data <- subset(together, Model != 'Morfessor' & Feature == feature & Score != 0 & Value != 0)
  print(feature)
  regression <- 0
  
  if (feature %in% c('word_overlap')){
    regression <- lm(Score ~ Value * Sample * Model * Metric, data = data)
    
  }
  else {
    regression <- lm(Score ~ Value * Replacement * Sample * Model * Metric, data = data) 
    
  }
  
  summary <- data.frame(summary(regression)$coef)
  summary$Factor <- rownames(summary)
  
  for (factor in as.vector(summary$Factor)){
    coef = subset(summary, Factor == factor)$Estimate
    ci = data.frame(confint(regression, factor, level = 0.95))
    q2.5 = ci$X2.5..[1]
    q97.5 = ci$X97.5..[1]
    persian_df[nrow(persian_df) + 1, ] <- c(language, feature, factor, round(coef, 2), round(q2.5, 2), round(q97.5, 2))
    write.csv(persian_df, 'persian_corr_overall.txt', row.names = FALSE)
    
  }
  
}


###### Studying whether data could be split by heuristics or adversarial training ####

persian_split_len <- read.csv('persian_split_len.txt', header = T, sep = '\t')
persian_split_adv <- read.csv('persian_split_adv.txt', header = T, sep = '\t')
persian_split_adv <- subset(persian_split_adv, Split != 'EVERYTHING')

### 0 data set splittable by number of morphemes ###


ggplot(persian_split_adv, aes(x = Overlap)) +
  geom_histogram() + 
  facet_grid(Sample ~ Replacement) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times"),
        axis.text.x=element_text(size=15),
        axis.text.y=element_text(size=15)) + 
  theme(legend.position="top") +
  xlim(c(0, 100)) +
  labs(fill = "") +
  ggtitle('Persian adversarial')



########### New test set sizes #################


persian_with_500_50 <- read.csv('persian_crf_test_with_500_50_results.txt', header = T, sep = ' ')
persian_with_500_50$Size <- rep('500', nrow(persian_with_500_50))
persian_with_500_50$Replacement <- rep('with', nrow(persian_with_500_50))

persian_with_500_100 <- read.csv('persian_crf_test_with_500_100_results.txt', header = T, sep = ' ')
persian_with_500_100$Size <- rep('500', nrow(persian_with_500_100))
persian_with_500_100$Replacement <- rep('with', nrow(persian_with_500_100))

persian_with_500_500 <- read.csv('persian_crf_test_with_500_500_results.txt', header = T, sep = ' ')
persian_with_500_500$Size <- rep('5000', nrow(persian_with_500_500))
persian_with_500_500$Replacement <- rep('with', nrow(persian_with_500_500))

persian_with_500_1000 <- read.csv('persian_crf_test_with_500_1000_results.txt', header = T, sep = ' ')
persian_with_500_1000$Size <- rep('500', nrow(persian_with_500_1000))
persian_with_500_1000$Replacement <- rep('with', nrow(persian_with_500_1000))

persian_with_1000_50 <- read.csv('persian_crf_test_with_1000_50_results.txt', header = T, sep = ' ')
persian_with_1000_50$Size <- rep('1000', nrow(persian_with_1000_50))
persian_with_1000_50$Replacement <- rep('with', nrow(persian_with_1000_50))

persian_with_1000_100 <- read.csv('persian_crf_test_with_1000_100_results.txt', header = T, sep = ' ')
persian_with_1000_100$Size <- rep('1000', nrow(persian_with_1000_100))
persian_with_1000_100$Replacement <- rep('with', nrow(persian_with_1000_100))

persian_with_1000_500 <- read.csv('persian_crf_test_with_1000_500_results.txt', header = T, sep = ' ')
persian_with_1000_500$Size <- rep('1000', nrow(persian_with_1000_500))
persian_with_1000_500$Replacement <- rep('with', nrow(persian_with_1000_500))

persian_with_1000_1000 <- read.csv('persian_crf_test_with_1000_1000_results.txt', header = T, sep = ' ')
persian_with_1000_1000$Size <- rep('1000', nrow(persian_with_1000_1000))
persian_with_1000_1000$Replacement <- rep('with', nrow(persian_with_1000_1000))

persian_with_1500_50 <- read.csv('persian_crf_test_with_1500_50_results.txt', header = T, sep = ' ')
persian_with_1500_50$Size <- rep('1500', nrow(persian_with_1500_50))
persian_with_1500_50$Replacement <- rep('with', nrow(persian_with_1500_50))

persian_with_1500_100 <- read.csv('persian_crf_test_with_1500_100_results.txt', header = T, sep = ' ')
persian_with_1500_100$Size <- rep('1500', nrow(persian_with_1500_100))
persian_with_1500_100$Replacement <- rep('with', nrow(persian_with_1500_100))

persian_with_1500_500 <- read.csv('persian_crf_test_with_1500_500_results.txt', header = T, sep = ' ')
persian_with_1500_500$Size <- rep('1500', nrow(persian_with_1500_500))
persian_with_1500_500$Replacement <- rep('with', nrow(persian_with_1500_500))

persian_with_1500_1000 <- read.csv('persian_crf_test_with_1500_1000_results.txt', header = T, sep = ' ')
persian_with_1500_1000$Size <- rep('1500', nrow(persian_with_1500_1000))
persian_with_1500_1000$Replacement <- rep('with', nrow(persian_with_1500_1000))

persian_with_2000_50 <- read.csv('persian_crf_test_with_2000_50_results.txt', header = T, sep = ' ')
persian_with_2000_50$Size <- rep('2000', nrow(persian_with_2000_50))
persian_with_2000_50$Replacement <- rep('with', nrow(persian_with_2000_50))

persian_with_2000_100 <- read.csv('persian_crf_test_with_2000_100_results.txt', header = T, sep = ' ')
persian_with_2000_100$Size <- rep('2000', nrow(persian_with_2000_100))
persian_with_2000_100$Replacement <- rep('with', nrow(persian_with_2000_100))

persian_with_2000_500 <- read.csv('persian_crf_test_with_2000_500_results.txt', header = T, sep = ' ')
persian_with_2000_500$Size <- rep('2000', nrow(persian_with_2000_500))
persian_with_2000_500$Replacement <- rep('with', nrow(persian_with_2000_500))

persian_with_2000_1000 <- read.csv('persian_crf_test_with_2000_1000_results.txt', header = T, sep = ' ')
persian_with_2000_1000$Size <- rep('2000', nrow(persian_with_2000_1000))
persian_with_2000_1000$Replacement <- rep('with', nrow(persian_with_2000_1000))

persian_with_3000_50 <- read.csv('persian_crf_test_with_3000_50_results.txt', header = T, sep = ' ')
persian_with_3000_50$Size <- rep('3000', nrow(persian_with_3000_50))
persian_with_3000_50$Replacement <- rep('with', nrow(persian_with_3000_50))

persian_with_3000_100 <- read.csv('persian_crf_test_with_3000_100_results.txt', header = T, sep = ' ')
persian_with_3000_100$Size <- rep('3000', nrow(persian_with_3000_100))
persian_with_3000_100$Replacement <- rep('with', nrow(persian_with_3000_100))

persian_with_3000_500 <- read.csv('persian_crf_test_with_3000_500_results.txt', header = T, sep = ' ')
persian_with_3000_500$Size <- rep('3000', nrow(persian_with_3000_500))
persian_with_3000_500$Replacement <- rep('with', nrow(persian_with_3000_500))

persian_with_3000_1000 <- read.csv('persian_crf_test_with_3000_1000_results.txt', header = T, sep = ' ')
persian_with_3000_1000$Size <- rep('3000', nrow(persian_with_3000_1000))
persian_with_3000_1000$Replacement <- rep('with', nrow(persian_with_3000_1000))

persian_with_4000_50 <- read.csv('persian_crf_test_with_4000_50_results.txt', header = T, sep = ' ')
persian_with_4000_50$Size <- rep('4000', nrow(persian_with_4000_50))
persian_with_4000_50$Replacement <- rep('with', nrow(persian_with_4000_50))

persian_with_4000_100 <- read.csv('persian_crf_test_with_4000_100_results.txt', header = T, sep = ' ')
persian_with_4000_100$Size <- rep('4000', nrow(persian_with_4000_100))
persian_with_4000_100$Replacement <- rep('with', nrow(persian_with_4000_100))

persian_with_4000_500 <- read.csv('persian_crf_test_with_4000_500_results.txt', header = T, sep = ' ')
persian_with_4000_500$Size <- rep('4000', nrow(persian_with_4000_500))
persian_with_4000_500$Replacement <- rep('with', nrow(persian_with_4000_500))

persian_with_4000_1000 <- read.csv('persian_crf_test_with_4000_1000_results.txt', header = T, sep = ' ')
persian_with_4000_1000$Size <- rep('4000', nrow(persian_with_4000_1000))
persian_with_4000_1000$Replacement <- rep('with', nrow(persian_with_4000_1000))

persian_without_500_50 <- read.csv('persian_crf_test_without_500_50_results.txt', header = T, sep = ' ')
persian_without_500_50$Size <- rep('500', nrow(persian_without_500_50))
persian_without_500_50$Replacement <- rep('without', nrow(persian_without_500_50))

persian_without_500_100 <- read.csv('persian_crf_test_without_500_100_results.txt', header = T, sep = ' ')
persian_without_500_100$Size <- rep('500', nrow(persian_without_500_100))
persian_without_500_100$Replacement <- rep('without', nrow(persian_without_500_100))

persian_without_500_500 <- read.csv('persian_crf_test_without_500_500_results.txt', header = T, sep = ' ')
persian_without_500_500$Size <- rep('500', nrow(persian_without_500_500))
persian_without_500_500$Replacement <- rep('without', nrow(persian_without_500_500))

persian_without_500_1000 <- read.csv('persian_crf_test_without_500_1000_results.txt', header = T, sep = ' ')
persian_without_500_1000$Size <- rep('500', nrow(persian_without_500_1000))
persian_without_500_1000$Replacement <- rep('without', nrow(persian_without_500_1000))

persian_without_1000_50 <- read.csv('persian_crf_test_without_1000_50_results.txt', header = T, sep = ' ')
persian_without_1000_50$Size <- rep('1000', nrow(persian_without_1000_50))
persian_without_1000_50$Replacement <- rep('without', nrow(persian_without_1000_50))

persian_without_1000_100 <- read.csv('persian_crf_test_without_1000_100_results.txt', header = T, sep = ' ')
persian_without_1000_100$Size <- rep('1000', nrow(persian_without_1000_100))
persian_without_1000_100$Replacement <- rep('without', nrow(persian_without_1000_100))

persian_without_1000_500 <- read.csv('persian_crf_test_without_1000_500_results.txt', header = T, sep = ' ')
persian_without_1000_500$Size <- rep('1000', nrow(persian_without_1000_500))
persian_without_1000_500$Replacement <- rep('without', nrow(persian_without_1000_500))

persian_without_1000_1000 <- read.csv('persian_crf_test_without_1000_1000_results.txt', header = T, sep = ' ')
persian_without_1000_1000$Size <- rep('1000', nrow(persian_without_1000_1000))
persian_without_1000_1000$Replacement <- rep('without', nrow(persian_without_1000_1000))

persian_without_1500_50 <- read.csv('persian_crf_test_without_1500_50_results.txt', header = T, sep = ' ')
persian_without_1500_50$Size <- rep('1500', nrow(persian_without_1500_50))
persian_without_1500_50$Replacement <- rep('without', nrow(persian_without_1500_50))

persian_without_1500_100 <- read.csv('persian_crf_test_without_1500_100_results.txt', header = T, sep = ' ')
persian_without_1500_100$Size <- rep('1500', nrow(persian_without_1500_100))
persian_without_1500_100$Replacement <- rep('without', nrow(persian_without_1500_100))

persian_without_1500_500 <- read.csv('persian_crf_test_without_1500_500_results.txt', header = T, sep = ' ')
persian_without_1500_500$Size <- rep('1500', nrow(persian_without_1500_500))
persian_without_1500_500$Replacement <- rep('without', nrow(persian_without_1500_500))

persian_without_1500_1000 <- read.csv('persian_crf_test_without_1500_1000_results.txt', header = T, sep = ' ')
persian_without_1500_1000$Size <- rep('1500', nrow(persian_without_1500_1000))
persian_without_1500_1000$Replacement <- rep('without', nrow(persian_without_1500_1000))

persian_without_2000_50 <- read.csv('persian_crf_test_without_2000_50_results.txt', header = T, sep = ' ')
persian_without_2000_50$Size <- rep('2000', nrow(persian_without_2000_50))
persian_without_2000_50$Replacement <- rep('without', nrow(persian_without_2000_50))

persian_without_2000_100 <- read.csv('persian_crf_test_without_2000_100_results.txt', header = T, sep = ' ')
persian_without_2000_100$Size <- rep('2000', nrow(persian_without_2000_100))
persian_without_2000_100$Replacement <- rep('without', nrow(persian_without_2000_100))

persian_without_2000_500 <- read.csv('persian_crf_test_without_2000_500_results.txt', header = T, sep = ' ')
persian_without_2000_500$Size <- rep('2000', nrow(persian_without_2000_500))
persian_without_2000_500$Replacement <- rep('without', nrow(persian_without_2000_500))

persian_without_2000_1000 <- read.csv('persian_crf_test_without_2000_1000_results.txt', header = T, sep = ' ')
persian_without_2000_1000$Size <- rep('2000', nrow(persian_without_2000_1000))
persian_without_2000_1000$Replacement <- rep('without', nrow(persian_without_2000_1000))

persian_without_3000_50 <- read.csv('persian_crf_test_without_3000_50_results.txt', header = T, sep = ' ')
persian_without_3000_50$Size <- rep('3000', nrow(persian_without_3000_50))
persian_without_3000_50$Replacement <- rep('without', nrow(persian_without_3000_50))

persian_without_3000_100 <- read.csv('persian_crf_test_without_3000_100_results.txt', header = T, sep = ' ')
persian_without_3000_100$Size <- rep('3000', nrow(persian_without_3000_100))
persian_without_3000_100$Replacement <- rep('without', nrow(persian_without_3000_100))

persian_without_3000_500 <- read.csv('persian_crf_test_without_3000_500_results.txt', header = T, sep = ' ')
persian_without_3000_500$Size <- rep('3000', nrow(persian_without_3000_500))
persian_without_3000_500$Replacement <- rep('without', nrow(persian_without_3000_500))

persian_without_3000_1000 <- read.csv('persian_crf_test_without_3000_1000_results.txt', header = T, sep = ' ')
persian_without_3000_1000$Size <- rep('3000', nrow(persian_without_3000_1000))
persian_without_3000_1000$Replacement <- rep('without', nrow(persian_without_3000_1000))

persian_without_4000_50 <- read.csv('persian_crf_test_without_4000_50_results.txt', header = T, sep = ' ')
persian_without_4000_50$Size <- rep('4000', nrow(persian_without_4000_50))
persian_without_4000_50$Replacement <- rep('without', nrow(persian_without_4000_50))

persian_without_4000_100 <- read.csv('persian_crf_test_without_4000_100_results.txt', header = T, sep = ' ')
persian_without_4000_100$Size <- rep('4000', nrow(persian_without_4000_100))
persian_without_4000_100$Replacement <- rep('without', nrow(persian_without_4000_100))

persian_without_4000_500 <- read.csv('persian_crf_test_without_4000_500_results.txt', header = T, sep = ' ')
persian_without_4000_500$Size <- rep('4000', nrow(persian_without_4000_500))
persian_without_4000_500$Replacement <- rep('without', nrow(persian_without_4000_500))

persian_without_4000_1000 <- read.csv('persian_crf_test_without_4000_1000_results.txt', header = T, sep = ' ')
persian_without_4000_1000$Size <- rep('4000', nrow(persian_without_4000_1000))
persian_without_4000_1000$Replacement <- rep('without', nrow(persian_without_4000_1000))


persian_500 <- rbind(persian_with_500_50, persian_with_500_100, persian_with_500_500, persian_with_500_1000, persian_without_500_50, persian_without_500_100, persian_without_500_500, persian_without_500_1000)
persian_1000 <- rbind(persian_with_1000_50, persian_with_1000_100, persian_with_1000_500, persian_with_1000_1000, persian_without_1000_50, persian_without_1000_100, persian_without_1000_500, persian_without_1000_1000)
persian_1500 <- rbind(persian_with_1500_50, persian_with_1500_100, persian_with_1500_500, persian_with_1500_1000, persian_without_1500_50, persian_without_1500_100, persian_without_1500_500, persian_without_1500_1000)
persian_2000 <- rbind(persian_with_2000_50, persian_with_2000_100, persian_with_2000_500, persian_with_2000_1000, persian_without_2000_50, persian_without_2000_100, persian_without_2000_500, persian_without_2000_1000)
persian_3000 <- rbind(persian_with_3000_50, persian_with_3000_100, persian_with_3000_500, persian_with_3000_1000, persian_without_3000_50, persian_without_3000_100, persian_without_3000_500, persian_without_3000_1000)
persian_4000 <- rbind(persian_with_4000_50, persian_with_4000_100, persian_with_4000_500, persian_with_4000_1000, persian_without_4000_50, persian_without_4000_100, persian_without_4000_500, persian_without_4000_1000)
persian_test <- rbind(persian_500, persian_1000, persian_1500, persian_2000, persian_3000, persian_4000)

### F1
### 500, 50, with: min 28.34; max 76.93
### 500, 50, without: min 30.01; max 80.93
### 500, 100, with: min 36.44; max 72.66
### 500, 100, without: min 36.66; max 71.68

### 1000, 50, with: min 32.70; max 84.92
### 1000, 50, without: min 35.11; max 81.56
### 1000, 100, with: min 39.51; max 76.98
### 1000, 100, without: min 40.93; max 73.81

ggplot(persian_test, aes(x = F1, color = Replacement)) +
  geom_density() + 
  facet_grid(Sample_size ~ Size) +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times"),
        axis.text.x=element_text(size=15),
        axis.text.y=element_text(size=15)) + 
  theme(legend.position="top") +
  labs(fill = "") +
  ggtitle('Persian test F1')



persian_500_p <-
  ggplot(subset(persian_500, Sample_size %in% c('50', '100')), aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('500')

persian_1000_p <-
  ggplot(persian_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('1000')


persian_1500_p <-
  ggplot(persian_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('1500')

persian_2000_p <-
  ggplot(persian_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('2000')

persian_3000_p <-
  ggplot(persian_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('3000')

persian_4000_p <-
  ggplot(persian_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('4000')


grid.arrange(persian_500_p, persian_1000_p, persian_1500_p, persian_2000_p, persian_3000_p, persian_4000_p, ncol = 2, nrow = 3)


persian_compare <- data.frame(Size=character(), Sample_size=character(), Replacement=character(), Mean=numeric(), Variance=numeric()) 

sizes = unique(as.vector(persian_test$Size))
sample_sizes = unique(as.vector(persian_test$Sample_size))

for (size in sizes){
  for (sample_size in sample_sizes){
    for (replacement in c('with', 'without')){
      data <- subset(persian_test, Size==size & Sample_size==sample_size & Replacement=='with')
      mean <- mean(data$F1)
      min <- min(data$F1)
      max <- max(data$F1)
      
      persian_compare[nrow(persian_compare) + 1, ] <- c(size, sample_size, replacement, mean, max-min)
      print(c(size, sample_size, replacement, mean, max-min))
    }
  }
}


####### Studying the effects of data characteristics / heuristics #######
####### For new test sets ############


persian_new_test_heuristics <- read.csv('persian_new_test_heuristics.txt', header = T, sep = '\t')

temp <- subset(persian_test, select = -c(Precision, Recall, F1, Distance))
names(temp) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp$Metric <- rep('Accuracy', nrow(temp))

temp1 <- subset(persian_test, select = -c(Accuracy, Recall, F1, Distance))
names(temp1) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp1$Metric <- rep('Precision', nrow(temp1))

temp2 <- subset(persian_test, select = -c(Accuracy, Precision, F1, Distance))
names(temp2) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp2$Metric <- rep('Recall', nrow(temp2))

temp3 <- subset(persian_test, select = -c(Accuracy, Precision, Recall, Distance))
names(temp3) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp3$Metric <- rep('F1', nrow(temp3))

temp4 <- subset(persian_test, select = -c(Accuracy, Precision, Recall, F1))
names(temp4) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp4$Metric <- rep('Distance', nrow(temp4))

persian_full <- rbind(temp, temp1, temp2, temp3, temp4)

samples = unique(persian_new_test_heuristics$Sample)

language <- unique(persian_new_test_heuristics$Language)

together = 0


for (sample in as.vector(samples)){
  for (sample_size in as.vector(unique(persian_full$Sample_size))){
    for (split in as.vector(unique(persian_full$Split))){
      for (replacement in as.vector(unique(persian_new_test_heuristics$Replacement))){
        for (metric in c('Accuracy', 'Precision', 'Recall', 'F1', 'Avg. Distance')){
          results <- subset(persian_full, Sample_size == sample_size & Split == split & Size == sample & Replacement == replacement)
          new_test_heuristics <- subset(persian_new_test_heuristics, Test_size == sample_size & Split == split & Feature == 'morph_overlap' & Sample == sample & Replacement == replacement)
          new_test_heuristics <- subset(new_test_heuristics, select = -Feature)
          names(new_test_heuristics) <- c('Language', 'Sample', 'Replacement', 'Split', 'Test_size', 'Test_id', 'Set', 'morph_overlap', 'Caveat')
          
          for (feature in c('ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
            
            if (feature == 'ave_num_morph_ratio'){
              new_test_heuristics$ave_num_morph_ratio <- subset(persian_new_test_heuristics, Test_size == sample_size & Split == split & Feature == feature & Sample == sample & Replacement == replacement)$Value
            }
            
            if (feature == 'dist_ave_num_morph'){
              new_test_heuristics$dist_ave_num_morph <- subset(persian_new_test_heuristics, Test_size == sample_size & Split == split & Feature == feature & Sample == sample & Replacement == replacement)$Value
            }
            
            if (feature == 'ave_morph_len_ratio'){
              new_test_heuristics$ave_morph_len_ratio <- subset(persian_new_test_heuristics, Test_size == sample_size & Split == split & Feature == feature & Sample == sample & Replacement == replacement)$Value
            }
            
          }
          
          together <- rbind(together, cbind(results, new_test_heuristics))
          
          
        }}}}}

together <- subset(together, Language != 0)
together$Sample <- as.numeric(together$Sample)

together$morph_overlap <- together$morph_overlap / 100

regression <- lm(Score ~ (morph_overlap + ave_num_morph_ratio + dist_ave_num_morph + ave_morph_len_ratio)*Replacement + (morph_overlap + ave_num_morph_ratio + dist_ave_num_morph + ave_morph_len_ratio)*Sample + (morph_overlap + ave_num_morph_ratio + dist_ave_num_morph + ave_morph_len_ratio)*Test_size + Metric, data = together)

summary <- data.frame(summary(regression)$coef)
summary$Factor <- rownames(summary)

persian_df <- data.frame(Language=character(), Factor=character(), Coef=numeric(), Q2.5=numeric(), Q97.5=numeric()) 


for (factor in as.vector(summary$Factor)){
  print(factor)
  coef = subset(summary, Factor == factor)$Estimate
  ci = data.frame(confint(regression, factor, level = 0.95))
  q2.5 = ci$X2.5..[1]
  q97.5 = ci$X97.5..[1]
  print(typeof(factor))
  persian_df[nrow(persian_df) + 1, ] <- c('persian', as.character(factor), round(coef, 2), round(q2.5, 2), round(q97.5, 2))
  write.csv(persian_df, 'persian_corr_new_test.txt', row.names = FALSE)
  
}

persian_df$Factor<-summary$Factor
persian_df$P_value<-summary$Pr...t..
persian_df$Language<-rep('persian',nrow(persian_df))

write.csv(persian_df, 'persian_corr_new_test.txt', row.names = FALSE)



################################
########### Russian ###########
################################

russian <- read.csv('russian.txt', header = T, sep = '\t')
russian$Language <- rep('russian', nrow(russian))

russian <- subset(russian, Index %in% c('Same best model', 'Same model ranking', 'A best model', 'A best model ranking'))
russian$Index[russian$Index == 'Same model ranking'] <- 'Same ranking'
russian$Index[russian$Index == 'A best model ranking'] <- 'A best ranking'
russian$Index <- factor(russian$Index, levels = c('Same best model', 
                                                  'Same ranking', 
                                                  'A best model', 
                                                  'A best ranking'))


subset(russian, Replacement == 'with'&Size=='2000') %>%
  ggplot(aes(Metric, as.numeric(Proportion), fill = Metric)) +
  geom_bar(stat = 'identity', alpha = 0.8) +
  geom_text(aes_q(label=~(paste(Summary, Proportion))), vjust=-2.6, color="black", size=3.5)+
  facet_grid(Index ~ Size) +
  theme_classic() + 
  theme(text = element_text(size=30, family="Times"),
        axis.text.x=element_blank(),
        axis.text.y=element_text(size=30)) + 
  theme(legend.position="none") +
  ylim(c(0, 100)) +
  xlab("") + 
  ylab("Proportion (%)") +
  guides(fill = guide_legend(nrow = 2)) +
  ggtitle('Russian best models')


russian_p <-
  ggplot(subset(russian, Metric == 'F1'&Index %in% c('Same best model', 'Same ranking')), aes(Index, Proportion, fill = Index)) +
  geom_bar(stat = 'identity', alpha = 0.8) +
  geom_text(aes(label=paste(Proportion, '%')), vjust=-1, color="black", size=6)+
  scale_fill_manual(values = c("steelblue", "mediumpurple4")) + #, "darkgreen", "peru")) +
  facet_grid(Replacement ~ Size) +

  theme_classic() + 
  theme(text = element_text(size=30, family="Times"),
        axis.text.x=element_blank(),
        axis.text.y=element_text(size=30)) + 
  theme(legend.position="top") +
  ylim(c(0, 100)) +
  xlab("") + 
  ylab("Proportion (%)") +
  guides(fill = guide_legend(nrow = 1)) +
  labs(fill = "") +
  ggtitle('Russian')


########## Select one language to plot different models ###############

russian_details <- read.csv('russian_details.txt', header = T, sep = '\t')
#russian_details <- subset(russian_details, Model != 'Morfessor')
russian_details <- subset(russian_details, Size == 2000 & Metric == 'Avg. Distance') # & Replacement == 'with')


russian_details %>%
  ggplot(aes(Split, Value, group = Model, color = Model)) +
  geom_line(aes(linetype=Model), alpha = 1) +
  scale_color_manual(values = c("steelblue", "peru", "darkgreen", "darkgrey", "mediumpurple4", "darkred", "black")) +
  scale_x_continuous(breaks=seq(1, 51, 5)) +
  facet_grid( ~ Replacement) +
  theme_classic() + 
  theme(text = element_text(size=16, family="Times")) + 
  theme(legend.position="top") +
  xlab("Data set") + 
  ylab("Precision") + 
  xlim(c(1,50)) +
  guides(linetype = guide_legend(nrow = 2)) +
  ggtitle('russian 2000 Precision')


russian_details_summary <- data.frame(Size=character(), Model=character(), Replacement=character(), Metric=character(), Mean=numeric(), Variance=numeric(), Std=numeric()) 

sizes = unique(as.vector(russian_details$Size))
models = unique(as.vector(russian_details$Model))
metrics = unique(as.vector(russian_details$Metric))

for (size in sizes){
  for (model in models){
    for (replacement in c('with', 'without')){
      for (metric in metrics){
        data <- subset(russian_details, Size==size &  Replacement==replacement & Metric==metric)
        mean <- mean(as.numeric(data$Value))
        min <- min(as.numeric(data$Value))
        max <- max(as.numeric(data$Value))
        sd <- sd(as.vector(as.numeric(data$Value)))
        
        russian_details_summary[nrow(russian_details_summary) + 1, ] <- c(size, model, replacement, metric, mean, max-min, sd)
        print(c(size, model, replacement, metric, mean, max-min, sd))
        
      }
    }
  }
}

write.csv(russian_details_summary, 'russian_adversarial_details_summary.txt', row.names=FALSE)


### The variance in the F1 for each model type across data sets ###

ggplot(subset(russian_details, Metric == 'F1'), aes(x = Value, color = Replacement)) +
  geom_density() + 
  facet_grid(Model ~ Size) +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times"),
        axis.text.x=element_text(size=15),
        axis.text.y=element_text(size=15)) + 
  theme(legend.position="top") +
  labs(fill = "") +
  ggtitle('Russian variance in F1')


### 500, with ###
### 0-CRF: mean 48.55; min 44.64; max 53.29
### 1-CRF: mean 66.42; min 69.69; max 62.85
### 2-CRF: mean 66.46; min 62.32; max 70.35
### 3-CRF: mean 66.59; min 62.89; max 69.82
### 4-CRF: mean 66.62; min 62.65; max 69.95
### Seq2seq: mean 62.95; min 58.31; max 67.58


### 500, without ###
### 0-CRF: mean 48.09; min 45.25; max 52.68
### 1-CRF: mean 66.75; min 62.83; max 69.45
### 2-CRF: mean 66.99; min 63.20; max 70.36
### 3-CRF: mean 66.96; min 62.77; max 70.66
### 4-CRF: mean 66.91; min 62.57; max 71.00
### Seq2seq: mean 61.78; min 58.07; max 66.04


### 2000, with ###
### 0-CRF: mean 59.59; min 57.83; max 62.65
### 1-CRF: mean 75.38; min 73.93; max 76.66
### 2-CRF: mean 75.46; min 74.02; max 76.68
### 3-CRF: mean 75.48; min 73.71; max 76.52
### 4-CRF: mean 75.54; min 74.06; max 76.73
### Seq2seq: mean 74.86; min 73.48; max 76.45

### 2000, without ###
### 0-CRF: mean 59.41; min 57.15; max 60.95
### 1-CRF: mean 75.08; min 73.72; max 76.72
### 2-CRF: mean 75.15; min 73.75; max 76.89
### 3-CRF: mean 75.18; min 73.77; max 76.76
### 4-CRF: mean 75.21; min 73.79; max 77.14
### Seq2seq: mean 74.39; min 72.54; max: 76.99


### Calculating a breakdown ####

samples = unique(russian_details$Size)

russian_breakdown <- data.frame(Language=character(), Sample=character(), Replacement=character(), Metric=character(), Model=character(), Proportion=numeric())


for (sample in as.vector(samples)){
  for (replacement in c('with', 'without')){
    
    zero_CRF = 0
    first_CRF = 0
    second_CRF = 0
    third_CRF = 0
    fourth_CRF = 0
    seq = 0
    
    CRF = 0
    
    for (i in 1:50){
      
      data <- subset(russian_details,  Split==as.character(i) & Size == sample & Replacement==replacement)
      best <- subset(data, Value == max(data$Value))
      print(best)
      if (best$Model == '0-CRF'){
        zero_CRF = zero_CRF + 1
        CRF = CRF + 1
      }
      
      if (best$Model == '1-CRF'){
        first_CRF = first_CRF + 1
        CRF = CRF + 1
      }
      
      if (best$Model == '2-CRF'){
        second_CRF = second_CRF + 1
        CRF = CRF + 1
      }
      
      if (best$Model == '3-CRF'){
        third_CRF = third_CRF + 1
        CRF = CRF + 1
      }
      
      if (best$Model == '4-CRF'){
        fourth_CRF = fourth_CRF + 1
        CRF = CRF + 1
      }
      
      if (best$Model == 'Seq2seq'){
        seq = seq + 1
      }}
    
    zero_CRF = zero_CRF * 100 / 50
    first_CRF = first_CRF * 100 / 50
    second_CRF = second_CRF * 100 / 50
    third_CRF = third_CRF * 100 / 50
    fourth_CRF = fourth_CRF * 100 / 50
    seq = seq * 100 / 50
    
    CRF = CRF * 100 / 50
    
    russian_breakdown[nrow(russian_breakdown) + 1, ] <- c(language, sample, replacement, 'F1', '0-CRF', zero_CRF)
    russian_breakdown[nrow(russian_breakdown) + 1, ] <- c(language, sample, replacement, 'F1', '1-CRF', first_CRF)
    russian_breakdown[nrow(russian_breakdown) + 1, ] <- c(language, sample, replacement, 'F1', '2-CRF', second_CRF)
    russian_breakdown[nrow(russian_breakdown) + 1, ] <- c(language, sample, replacement, 'F1', '3-CRF', third_CRF)
    russian_breakdown[nrow(russian_breakdown) + 1, ] <- c(language, sample, replacement, 'F1', '4-CRF', fourth_CRF)
    russian_breakdown[nrow(russian_breakdown) + 1, ] <- c(language, sample, replacement, 'F1', 'Seq2seq', seq)
    russian_breakdown[nrow(russian_breakdown) + 1, ] <- c(language, sample, replacement, 'F1', 'CRF', CRF)
    
  }}

write.csv(russian_breakdown, 'russian_breakdown.txt', row.names = FALSE)


russian_breakdown %>%
  ggplot(aes(Model, as.numeric(Proportion), fill = Model)) +
  geom_bar(stat = 'identity', alpha = 0.8) +
  geom_text(aes(label=Proportion), vjust=-2.6, color="black", size=3.5)+
  facet_grid(Replacement ~ Sample) +
  theme_classic() + 
  theme(text = element_text(size=30, family="Times"),
        axis.text.x=element_text(size=15),
        axis.text.y=element_text(size=30)) + 
  theme(legend.position="none") +
  ylim(c(0, 100)) +
  xlab("") + 
  ylab("Proportion (%)") +
  guides(fill = guide_legend(nrow = 2)) +
  ggtitle('Russian model statistics')



####### Studying the effects of data characteristics / heuristics #######
####### For original train / test random splits #########

russian_heuristics <- read.csv('ru_heuristics.txt', header = T, sep = '\t')
russian_full <- read.csv('russian_full.txt', header = T, sep = '\t')

samples = unique(russian_heuristics$Sample)

language <- unique(russian_heuristics$Language)

russian_df <- data.frame(Language=character(), Sample=character(), Replacement=character(), Metric=character(), Model=character(), Feature=character(), Coef=numeric(), Q2.5=numeric(), Q97.5=numeric()) 

for (sample in as.vector(samples)){
  for (replacement in c('with', 'without')){
    for (metric in c('Accuracy', 'Precision', 'Recall', 'F1', 'Avg. Distance')){
      for (model in c('Morfessor', '0-CRF', '1-CRF', '2-CRF', '3-CRF', '4-CRF', 'Seq2seq')){
        for (feature in c('word_overlap', 'morph_overlap', 
                          'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
          
          heuristics <- subset(russian_heuristics, Feature == feature & Sample == sample & Replacement == replacement)
          results <- subset(russian_full, Metric == metric & Model == model & Size == sample & Replacement == replacement)
          together = cbind(results, heuristics)
          
          regression <- lm(Score ~ Value, data = together)
          summary <- data.frame(summary(regression)$coef)
          coef = round(summary$Estimate[2], 2)
          ci = data.frame(confint(regression, 'Value', level = 0.95))
          q2.5 = round(ci$X2.5..[1], 2)
          q97.5 = round(ci$X97.5..[1], 2)
          
          russian_df[nrow(russian_df) + 1, ] <- c(language, sample, replacement, metric, model, feature, coef, q2.5, q97.5)
          
          russian_df[is.na(russian_df)] <- 0
          
          write.csv(russian_df, 'russian_corr.txt',row.names=FALSE)
          
        }}}}}


ggplot(subset(russian_df, Sample=='1000'&Replacement=='with'& (Q2.5 > 0 | Q97.5 < 0)), aes(Feature, as.numeric(Coef), fill = Feature)) +
  geom_bar(stat = 'identity', alpha = 0.8) +
  geom_errorbar(aes(ymax = as.numeric(Q97.5), ymin = as.numeric(Q2.5)), width=.1, position=position_dodge(.9)) +
  geom_text(aes(label=Coef), vjust=2.6, color="black", size=3.5)+
  facet_grid(Model ~ Metric) +
  theme_classic() + 
  theme(text = element_text(size=10, family="Times"),
        axis.text.x=element_blank(),
        axis.text.y=element_text(size=10)) + 
  theme(legend.position="top") +
  ylim(c(-1, 1)) +
  ylab("Spearman") +
  guides(fill = guide_legend(nrow = 2)) +
  labs(fill = "") +
  ggtitle('russian characteristics 1000 with')


samples = unique(russian_heuristics$Sample)

language <- unique(russian_heuristics$Language)

together = 0

for (sample in as.vector(samples)){
  for (replacement in as.vector(unique(russian_heuristics$Replacement))){
    for (metric in c('Accuracy', 'Precision', 'Recall', 'F1', 'Avg. Distance')){
      for (model in c('Morfessor', '0-CRF', '1-CRF', '2-CRF', '3-CRF', '4-CRF', 'Seq2seq')){
        
        results <- subset(russian_full, Metric == metric & Model == model & Size == sample & Replacement == replacement)
        heuristics <- subset(russian_heuristics, Feature == 'word_overlap' & Sample == sample & Replacement == replacement)
        heuristics <- subset(heuristics, select = -Feature)
        names(heuristics) <- c('Language', 'Sample', 'Replacement', 'Split', 'Set', 'word_overlap', 'Caveat')
        
        for (feature in c('morph_overlap',
                          'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
          
          
          if (feature == 'morph_overlap'){
            heuristics$morph_overlap <- subset(russian_heuristics, Feature == feature & Sample == sample & Replacement == replacement)$Value
          }
          
          if (feature == 'ave_num_morph_ratio'){
            heuristics$ave_num_morph_ratio <- subset(russian_heuristics, Feature == feature & Sample == sample & Replacement == replacement)$Value
          }
          
          if (feature == 'dist_ave_num_morph'){
            heuristics$dist_ave_num_morph <- subset(russian_heuristics, Feature == feature & Sample == sample & Replacement == replacement)$Value
          }
          
          if (feature == 'ave_morph_len_ratio'){
            heuristics$ave_morph_len_ratio <- subset(russian_heuristics, Feature == feature & Sample == sample & Replacement == replacement)$Value
          }
          
        }
        
        together <- rbind(together, cbind(results, heuristics))
        
        
      }}}}

together <- subset(together, Language != 0)
together$Sample <- as.numeric(together$Sample)

together$word_overlap <- together$word_overlap / 100
together$morph_overlap <- together$morph_overlap / 100

regression <- lm(Score ~ (word_overlap + morph_overlap + ave_num_morph_ratio + dist_ave_num_morph + ave_morph_len_ratio)*Replacement + (word_overlap + morph_overlap + ave_num_morph_ratio + dist_ave_num_morph + ave_morph_len_ratio)*Sample + Model + Metric, data = together)

summary <- data.frame(summary(regression)$coef)
summary$Factor <- rownames(summary)

russian_df <- data.frame(Language=character(), Factor=character(), Coef=numeric(), Q2.5=numeric(), Q97.5=numeric()) 


for (factor in as.vector(summary$Factor)){
  print(factor)
  coef = subset(summary, Factor == factor)$Estimate
  ci = data.frame(confint(regression, factor, level = 0.95))
  q2.5 = ci$X2.5..[1]
  q97.5 = ci$X97.5..[1]
  print(typeof(factor))
  russian_df[nrow(russian_df) + 1, ] <- c('russian', as.character(factor), round(coef, 2), round(q2.5, 2), round(q97.5, 2))
  write.csv(russian_df, 'russian_corr_overall.txt', row.names = FALSE)
  
}

russian_df$Factor<-summary$Factor
russian_df$P_value<-summary$Pr...t..
russian_df$Language<-rep('russian',nrow(russian_df))

write.csv(russian_df, 'russian_corr_overall.txt', row.names = FALSE)




###### Studying whether data could be split by heuristics or adversarial training ####

russian_split_len <- read.csv('ru_split_len.txt', header = T, sep = '\t')
russian_split_adv <- read.csv('ru_split_adv.txt', header = T, sep = '\t')
russian_split_adv <- subset(russian_split_adv, Split != 'EVERYTHING')

### 0 data set splittable by number of morphemes ###


ggplot(russian_split_adv, aes(x = Overlap)) +
  geom_histogram() + 
  facet_grid(Sample ~ Replacement) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times"),
        axis.text.x=element_text(size=15),
        axis.text.y=element_text(size=15)) + 
  theme(legend.position="top") +
  xlim(c(0, 100)) +
  labs(fill = "") +
  ggtitle('Russian adversarial')



########### New test set sizes #################

russian_with_500_50 <- read.csv('ru_crf_test_with_500_50_results.txt', header = T, sep = ' ')
russian_with_500_50$Size <- rep('500', nrow(russian_with_500_50))
russian_with_500_50$Replacement <- rep('with', nrow(russian_with_500_50))

russian_with_500_100 <- read.csv('ru_crf_test_with_500_100_results.txt', header = T, sep = ' ')
russian_with_500_100$Size <- rep('500', nrow(russian_with_500_100))
russian_with_500_100$Replacement <- rep('with', nrow(russian_with_500_100))

russian_with_500_500 <- read.csv('ru_crf_test_with_500_500_results.txt', header = T, sep = ' ')
russian_with_500_500$Size <- rep('5000', nrow(russian_with_500_500))
russian_with_500_500$Replacement <- rep('with', nrow(russian_with_500_500))

russian_with_500_1000 <- read.csv('ru_crf_test_with_500_1000_results.txt', header = T, sep = ' ')
russian_with_500_1000$Size <- rep('500', nrow(russian_with_500_1000))
russian_with_500_1000$Replacement <- rep('with', nrow(russian_with_500_1000))

russian_with_1000_50 <- read.csv('ru_crf_test_with_1000_50_results.txt', header = T, sep = ' ')
russian_with_1000_50$Size <- rep('1000', nrow(russian_with_1000_50))
russian_with_1000_50$Replacement <- rep('with', nrow(russian_with_1000_50))

russian_with_1000_100 <- read.csv('ru_crf_test_with_1000_100_results.txt', header = T, sep = ' ')
russian_with_1000_100$Size <- rep('1000', nrow(russian_with_1000_100))
russian_with_1000_100$Replacement <- rep('with', nrow(russian_with_1000_100))

russian_with_1000_500 <- read.csv('ru_crf_test_with_1000_500_results.txt', header = T, sep = ' ')
russian_with_1000_500$Size <- rep('1000', nrow(russian_with_1000_500))
russian_with_1000_500$Replacement <- rep('with', nrow(russian_with_1000_500))

russian_with_1000_1000 <- read.csv('ru_crf_test_with_1000_1000_results.txt', header = T, sep = ' ')
russian_with_1000_1000$Size <- rep('1000', nrow(russian_with_1000_1000))
russian_with_1000_1000$Replacement <- rep('with', nrow(russian_with_1000_1000))

russian_with_1500_50 <- read.csv('ru_crf_test_with_1500_50_results.txt', header = T, sep = ' ')
russian_with_1500_50$Size <- rep('1500', nrow(russian_with_1500_50))
russian_with_1500_50$Replacement <- rep('with', nrow(russian_with_1500_50))

russian_with_1500_100 <- read.csv('ru_crf_test_with_1500_100_results.txt', header = T, sep = ' ')
russian_with_1500_100$Size <- rep('1500', nrow(russian_with_1500_100))
russian_with_1500_100$Replacement <- rep('with', nrow(russian_with_1500_100))

russian_with_1500_500 <- read.csv('ru_crf_test_with_1500_500_results.txt', header = T, sep = ' ')
russian_with_1500_500$Size <- rep('1500', nrow(russian_with_1500_500))
russian_with_1500_500$Replacement <- rep('with', nrow(russian_with_1500_500))

russian_with_1500_1000 <- read.csv('ru_crf_test_with_1500_1000_results.txt', header = T, sep = ' ')
russian_with_1500_1000$Size <- rep('1500', nrow(russian_with_1500_1000))
russian_with_1500_1000$Replacement <- rep('with', nrow(russian_with_1500_1000))

russian_with_2000_50 <- read.csv('ru_crf_test_with_2000_50_results.txt', header = T, sep = ' ')
russian_with_2000_50$Size <- rep('2000', nrow(russian_with_2000_50))
russian_with_2000_50$Replacement <- rep('with', nrow(russian_with_2000_50))

russian_with_2000_100 <- read.csv('ru_crf_test_with_2000_100_results.txt', header = T, sep = ' ')
russian_with_2000_100$Size <- rep('2000', nrow(russian_with_2000_100))
russian_with_2000_100$Replacement <- rep('with', nrow(russian_with_2000_100))

russian_with_2000_500 <- read.csv('ru_crf_test_with_2000_500_results.txt', header = T, sep = ' ')
russian_with_2000_500$Size <- rep('2000', nrow(russian_with_2000_500))
russian_with_2000_500$Replacement <- rep('with', nrow(russian_with_2000_500))

russian_with_2000_1000 <- read.csv('ru_crf_test_with_2000_1000_results.txt', header = T, sep = ' ')
russian_with_2000_1000$Size <- rep('2000', nrow(russian_with_2000_1000))
russian_with_2000_1000$Replacement <- rep('with', nrow(russian_with_2000_1000))

russian_with_3000_50 <- read.csv('ru_crf_test_with_3000_50_results.txt', header = T, sep = ' ')
russian_with_3000_50$Size <- rep('3000', nrow(russian_with_3000_50))
russian_with_3000_50$Replacement <- rep('with', nrow(russian_with_3000_50))

russian_with_3000_100 <- read.csv('ru_crf_test_with_3000_100_results.txt', header = T, sep = ' ')
russian_with_3000_100$Size <- rep('3000', nrow(russian_with_3000_100))
russian_with_3000_100$Replacement <- rep('with', nrow(russian_with_3000_100))

russian_with_3000_500 <- read.csv('ru_crf_test_with_3000_500_results.txt', header = T, sep = ' ')
russian_with_3000_500$Size <- rep('3000', nrow(russian_with_3000_500))
russian_with_3000_500$Replacement <- rep('with', nrow(russian_with_3000_500))

russian_with_3000_1000 <- read.csv('ru_crf_test_with_3000_1000_results.txt', header = T, sep = ' ')
russian_with_3000_1000$Size <- rep('3000', nrow(russian_with_3000_1000))
russian_with_3000_1000$Replacement <- rep('with', nrow(russian_with_3000_1000))

russian_with_4000_50 <- read.csv('ru_crf_test_with_4000_50_results.txt', header = T, sep = ' ')
russian_with_4000_50$Size <- rep('4000', nrow(russian_with_4000_50))
russian_with_4000_50$Replacement <- rep('with', nrow(russian_with_4000_50))

russian_with_4000_100 <- read.csv('ru_crf_test_with_4000_100_results.txt', header = T, sep = ' ')
russian_with_4000_100$Size <- rep('4000', nrow(russian_with_4000_100))
russian_with_4000_100$Replacement <- rep('with', nrow(russian_with_4000_100))

russian_with_4000_500 <- read.csv('ru_crf_test_with_4000_500_results.txt', header = T, sep = ' ')
russian_with_4000_500$Size <- rep('4000', nrow(russian_with_4000_500))
russian_with_4000_500$Replacement <- rep('with', nrow(russian_with_4000_500))

russian_with_4000_1000 <- read.csv('ru_crf_test_with_4000_1000_results.txt', header = T, sep = ' ')
russian_with_4000_1000$Size <- rep('4000', nrow(russian_with_4000_1000))
russian_with_4000_1000$Replacement <- rep('with', nrow(russian_with_4000_1000))

russian_without_500_50 <- read.csv('ru_crf_test_without_500_50_results.txt', header = T, sep = ' ')
russian_without_500_50$Size <- rep('500', nrow(russian_without_500_50))
russian_without_500_50$Replacement <- rep('without', nrow(russian_without_500_50))

russian_without_500_100 <- read.csv('ru_crf_test_without_500_100_results.txt', header = T, sep = ' ')
russian_without_500_100$Size <- rep('500', nrow(russian_without_500_100))
russian_without_500_100$Replacement <- rep('without', nrow(russian_without_500_100))

russian_without_500_500 <- read.csv('ru_crf_test_without_500_500_results.txt', header = T, sep = ' ')
russian_without_500_500$Size <- rep('500', nrow(russian_without_500_500))
russian_without_500_500$Replacement <- rep('without', nrow(russian_without_500_500))

russian_without_500_1000 <- read.csv('ru_crf_test_without_500_1000_results.txt', header = T, sep = ' ')
russian_without_500_1000$Size <- rep('500', nrow(russian_without_500_1000))
russian_without_500_1000$Replacement <- rep('without', nrow(russian_without_500_1000))

russian_without_1000_50 <- read.csv('ru_crf_test_without_1000_50_results.txt', header = T, sep = ' ')
russian_without_1000_50$Size <- rep('1000', nrow(russian_without_1000_50))
russian_without_1000_50$Replacement <- rep('without', nrow(russian_without_1000_50))

russian_without_1000_100 <- read.csv('ru_crf_test_without_1000_100_results.txt', header = T, sep = ' ')
russian_without_1000_100$Size <- rep('1000', nrow(russian_without_1000_100))
russian_without_1000_100$Replacement <- rep('without', nrow(russian_without_1000_100))

russian_without_1000_500 <- read.csv('ru_crf_test_without_1000_500_results.txt', header = T, sep = ' ')
russian_without_1000_500$Size <- rep('1000', nrow(russian_without_1000_500))
russian_without_1000_500$Replacement <- rep('without', nrow(russian_without_1000_500))

russian_without_1000_1000 <- read.csv('ru_crf_test_without_1000_1000_results.txt', header = T, sep = ' ')
russian_without_1000_1000$Size <- rep('1000', nrow(russian_without_1000_1000))
russian_without_1000_1000$Replacement <- rep('without', nrow(russian_without_1000_1000))

russian_without_1500_50 <- read.csv('ru_crf_test_without_1500_50_results.txt', header = T, sep = ' ')
russian_without_1500_50$Size <- rep('1500', nrow(russian_without_1500_50))
russian_without_1500_50$Replacement <- rep('without', nrow(russian_without_1500_50))

russian_without_1500_100 <- read.csv('ru_crf_test_without_1500_100_results.txt', header = T, sep = ' ')
russian_without_1500_100$Size <- rep('1500', nrow(russian_without_1500_100))
russian_without_1500_100$Replacement <- rep('without', nrow(russian_without_1500_100))

russian_without_1500_500 <- read.csv('ru_crf_test_without_1500_500_results.txt', header = T, sep = ' ')
russian_without_1500_500$Size <- rep('1500', nrow(russian_without_1500_500))
russian_without_1500_500$Replacement <- rep('without', nrow(russian_without_1500_500))

russian_without_1500_1000 <- read.csv('ru_crf_test_without_1500_1000_results.txt', header = T, sep = ' ')
russian_without_1500_1000$Size <- rep('1500', nrow(russian_without_1500_1000))
russian_without_1500_1000$Replacement <- rep('without', nrow(russian_without_1500_1000))

russian_without_2000_50 <- read.csv('ru_crf_test_without_2000_50_results.txt', header = T, sep = ' ')
russian_without_2000_50$Size <- rep('2000', nrow(russian_without_2000_50))
russian_without_2000_50$Replacement <- rep('without', nrow(russian_without_2000_50))

russian_without_2000_100 <- read.csv('ru_crf_test_without_2000_100_results.txt', header = T, sep = ' ')
russian_without_2000_100$Size <- rep('2000', nrow(russian_without_2000_100))
russian_without_2000_100$Replacement <- rep('without', nrow(russian_without_2000_100))

russian_without_2000_500 <- read.csv('ru_crf_test_without_2000_500_results.txt', header = T, sep = ' ')
russian_without_2000_500$Size <- rep('2000', nrow(russian_without_2000_500))
russian_without_2000_500$Replacement <- rep('without', nrow(russian_without_2000_500))

russian_without_2000_1000 <- read.csv('ru_crf_test_without_2000_1000_results.txt', header = T, sep = ' ')
russian_without_2000_1000$Size <- rep('2000', nrow(russian_without_2000_1000))
russian_without_2000_1000$Replacement <- rep('without', nrow(russian_without_2000_1000))

russian_without_3000_50 <- read.csv('ru_crf_test_without_3000_50_results.txt', header = T, sep = ' ')
russian_without_3000_50$Size <- rep('3000', nrow(russian_without_3000_50))
russian_without_3000_50$Replacement <- rep('without', nrow(russian_without_3000_50))

russian_without_3000_100 <- read.csv('ru_crf_test_without_3000_100_results.txt', header = T, sep = ' ')
russian_without_3000_100$Size <- rep('3000', nrow(russian_without_3000_100))
russian_without_3000_100$Replacement <- rep('without', nrow(russian_without_3000_100))

russian_without_3000_500 <- read.csv('ru_crf_test_without_3000_500_results.txt', header = T, sep = ' ')
russian_without_3000_500$Size <- rep('3000', nrow(russian_without_3000_500))
russian_without_3000_500$Replacement <- rep('without', nrow(russian_without_3000_500))

russian_without_3000_1000 <- read.csv('ru_crf_test_without_3000_1000_results.txt', header = T, sep = ' ')
russian_without_3000_1000$Size <- rep('3000', nrow(russian_without_3000_1000))
russian_without_3000_1000$Replacement <- rep('without', nrow(russian_without_3000_1000))

russian_without_4000_50 <- read.csv('ru_crf_test_without_4000_50_results.txt', header = T, sep = ' ')
russian_without_4000_50$Size <- rep('4000', nrow(russian_without_4000_50))
russian_without_4000_50$Replacement <- rep('without', nrow(russian_without_4000_50))

russian_without_4000_100 <- read.csv('ru_crf_test_without_4000_100_results.txt', header = T, sep = ' ')
russian_without_4000_100$Size <- rep('4000', nrow(russian_without_4000_100))
russian_without_4000_100$Replacement <- rep('without', nrow(russian_without_4000_100))

russian_without_4000_500 <- read.csv('ru_crf_test_without_4000_500_results.txt', header = T, sep = ' ')
russian_without_4000_500$Size <- rep('4000', nrow(russian_without_4000_500))
russian_without_4000_500$Replacement <- rep('without', nrow(russian_without_4000_500))

russian_without_4000_1000 <- read.csv('ru_crf_test_without_4000_1000_results.txt', header = T, sep = ' ')
russian_without_4000_1000$Size <- rep('4000', nrow(russian_without_4000_1000))
russian_without_4000_1000$Replacement <- rep('without', nrow(russian_without_4000_1000))


russian_500 <- rbind(russian_with_500_50, russian_with_500_100, russian_with_500_500, russian_with_500_1000, russian_without_500_50, russian_without_500_100, russian_without_500_500, russian_without_500_1000)
russian_1000 <- rbind(russian_with_1000_50, russian_with_1000_100, russian_with_1000_500, russian_with_1000_1000, russian_without_1000_50, russian_without_1000_100, russian_without_1000_500, russian_without_1000_1000)
russian_1500 <- rbind(russian_with_1500_50, russian_with_1500_100, russian_with_1500_500, russian_with_1500_1000, russian_without_1500_50, russian_without_1500_100, russian_without_1500_500, russian_without_1500_1000)
russian_2000 <- rbind(russian_with_2000_50, russian_with_2000_100, russian_with_2000_500, russian_with_2000_1000, russian_without_2000_50, russian_without_2000_100, russian_without_2000_500, russian_without_2000_1000)
russian_3000 <- rbind(russian_with_3000_50, russian_with_3000_100, russian_with_3000_500, russian_with_3000_1000, russian_without_3000_50, russian_without_3000_100, russian_without_3000_500, russian_without_3000_1000)
russian_4000 <- rbind(russian_with_4000_50, russian_with_4000_100, russian_with_4000_500, russian_with_4000_1000, russian_without_4000_50, russian_without_4000_100, russian_without_4000_500, russian_without_4000_1000)
russian_test <- rbind(russian_500, russian_1000, russian_1500, russian_2000, russian_3000, russian_4000)


ggplot(russian_test, aes(x = F1, color = Replacement)) +
  geom_density() + 
  facet_grid(Size ~ Sample_size) +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times"),
        axis.text.x=element_text(size=15),
        axis.text.y=element_text(size=15)) + 
  theme(legend.position="top") +
  labs(fill = "") +
  ggtitle('Russian test F1')




russian_500_p <-
  ggplot(subset(russian_500, Sample_size %in% c('50', '100')), aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('500')


russian_1000_p <-
  ggplot(russian_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('1000')


russian_1500_p <-
  ggplot(russian_1500, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('1500')

russian_2000_p <-
  ggplot(russian_2000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid(Replacement ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=20, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") 

### 2000 F1

### with 50: mean 75.41; min 57.44; max 90.46
### with 100: mean 75.36; min 62.06; max 87.6
### with 500: mean 75.30; min 69.68; max 80.88
### with 1000: mean 75.33; min 70.62; max 79.36

### without 50: mean 75.30; min 54.46; max 91.99
### without 100: mean 75.36; min 62.75; max 86.42
### without 500: mean 75.33; min 69.74; max 82.03
### without 1000: mean 75.35; min 71.20; max 79.37

russian_2000_p <-
  ggplot(russian_2000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid(Replacement ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('2000')

russian_3000_p <-
  ggplot(russian_3000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('3000')

russian_4000_p <-
  ggplot(russian_4000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('4000')


grid.arrange(russian_500_p, russian_1000_p, russian_1500_p, russian_2000_p, russian_3000_p, russian_4000_p, ncol = 2, nrow = 3)



russian_compare <- data.frame(Size=character(), Sample_size=character(), Replacement=character(), Mean=numeric(), Variance=numeric()) 

sizes = unique(as.vector(russian_test$Size))
sample_sizes = unique(as.vector(russian_test$Sample_size))

for (size in sizes){
  for (sample_size in sample_sizes){
    for (replacement in c('with', 'without')){
      data <- subset(russian_test, Size==size & Sample_size==sample_size & Replacement=='with')
      mean <- mean(data$F1)
      min <- min(data$F1)
      max <- max(data$F1)
      
      russian_compare[nrow(russian_compare) + 1, ] <- c(size, sample_size, replacement, mean, max-min)
      print(c(size, sample_size, replacement, mean, max-min))
    }
  }
}



####### Studying the effects of data characteristics / heuristics #######
####### For new test sets ############


russian_new_test_heuristics <- read.csv('ru_new_test_heuristics.txt', header = T, sep = '\t')

temp <- subset(russian_test, select = -c(Precision, Recall, F1, Distance))
names(temp) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp$Metric <- rep('Accuracy', nrow(temp))

temp1 <- subset(russian_test, select = -c(Accuracy, Recall, F1, Distance))
names(temp1) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp1$Metric <- rep('Precision', nrow(temp1))

temp2 <- subset(russian_test, select = -c(Accuracy, Precision, F1, Distance))
names(temp2) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp2$Metric <- rep('Recall', nrow(temp2))

temp3 <- subset(russian_test, select = -c(Accuracy, Precision, Recall, Distance))
names(temp3) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp3$Metric <- rep('F1', nrow(temp3))

temp4 <- subset(russian_test, select = -c(Accuracy, Precision, Recall, F1))
names(temp4) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp4$Metric <- rep('Distance', nrow(temp4))

russian_full <- rbind(temp, temp1, temp2, temp3, temp4)

samples = unique(russian_new_test_heuristics$Sample)

language <- unique(russian_new_test_heuristics$Language)

together = 0


for (sample in as.vector(samples)){
  for (sample_size in as.vector(unique(russian_full$Sample_size))){
    for (split in as.vector(unique(russian_full$Split))){
      for (replacement in as.vector(unique(russian_new_test_heuristics$Replacement))){
        for (metric in c('Accuracy', 'Precision', 'Recall', 'F1', 'Avg. Distance')){
          results <- subset(russian_full, Sample_size == sample_size & Split == split & Size == sample & Replacement == replacement)
          new_test_heuristics <- subset(russian_new_test_heuristics, Test_size == sample_size & Split == split & Feature == 'morph_overlap' & Sample == sample & Replacement == replacement)
          new_test_heuristics <- subset(new_test_heuristics, select = -Feature)
          names(new_test_heuristics) <- c('Language', 'Sample', 'Replacement', 'Split', 'Test_size', 'Test_id', 'Set', 'morph_overlap', 'Caveat')
          
          for (feature in c('ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
            
            if (feature == 'ave_num_morph_ratio'){
              new_test_heuristics$ave_num_morph_ratio <- subset(russian_new_test_heuristics, Test_size == sample_size & Split == split & Feature == feature & Sample == sample & Replacement == replacement)$Value
            }
            
            if (feature == 'dist_ave_num_morph'){
              new_test_heuristics$dist_ave_num_morph <- subset(russian_new_test_heuristics, Test_size == sample_size & Split == split & Feature == feature & Sample == sample & Replacement == replacement)$Value
            }
            
            if (feature == 'ave_morph_len_ratio'){
              new_test_heuristics$ave_morph_len_ratio <- subset(russian_new_test_heuristics, Test_size == sample_size & Split == split & Feature == feature & Sample == sample & Replacement == replacement)$Value
            }
            
          }
          
          together <- rbind(together, cbind(results, new_test_heuristics))
          
          
        }}}}}

together <- subset(together, Language != 0)
together$Sample <- as.numeric(together$Sample)

together$morph_overlap <- together$morph_overlap / 100

regression <- lm(Score ~ (morph_overlap + ave_num_morph_ratio + dist_ave_num_morph + ave_morph_len_ratio)*Replacement + (morph_overlap + ave_num_morph_ratio + dist_ave_num_morph + ave_morph_len_ratio)*Sample + (morph_overlap + ave_num_morph_ratio + dist_ave_num_morph + ave_morph_len_ratio)*Test_size + Metric, data = together)

summary <- data.frame(summary(regression)$coef)
summary$Factor <- rownames(summary)

russian_df <- data.frame(Language=character(), Factor=character(), Coef=numeric(), Q2.5=numeric(), Q97.5=numeric()) 


for (factor in as.vector(summary$Factor)){
  print(factor)
  coef = subset(summary, Factor == factor)$Estimate
  ci = data.frame(confint(regression, factor, level = 0.95))
  q2.5 = ci$X2.5..[1]
  q97.5 = ci$X97.5..[1]
  print(typeof(factor))
  russian_df[nrow(russian_df) + 1, ] <- c('russian', as.character(factor), round(coef, 2), round(q2.5, 2), round(q97.5, 2))
  write.csv(russian_df, 'russian_corr_new_test.txt', row.names = FALSE)
  
}

russian_df$Factor<-summary$Factor
russian_df$P_value<-summary$Pr...t..
russian_df$Language<-rep('russian',nrow(russian_df))

write.csv(russian_df, 'russian_corr_new_test.txt', row.names = FALSE)




################################
########### Turkish ###########
################################

turkish <- read.csv('turkish.txt', header = T, sep = '\t')
turkish$Language <- rep('turkish', nrow(turkish))

turkish <- subset(turkish, Index %in% c('Same best model', 'Same model ranking', 'A best model', 'A best model ranking'))
turkish$Index[turkish$Index == 'Same model ranking'] <- 'Same ranking'
turkish$Index[turkish$Index == 'A best model ranking'] <- 'A best ranking'
turkish$Index <- factor(turkish$Index, levels = c('Same best model', 
                                                  'Same ranking', 
                                                  'A best model', 
                                                  'A best ranking'))

turkish_p <-
  ggplot(subset(turkish, Metric == 'F1'&Index %in% c('Same best model', 'Same ranking')), aes(Index, Proportion, fill = Index)) +
  geom_bar(stat = 'identity', alpha = 0.8) +
  geom_text(aes(label=paste(Proportion, '%')), vjust=-1, color="black", size=6)+
  scale_fill_manual(values = c("steelblue", "mediumpurple4")) + #, "darkgreen", "peru")) +
  facet_grid(Replacement ~ Size) +
  
  theme_classic() + 
  theme(text = element_text(size=30, family="Times"),
        axis.text.x=element_blank(),
        axis.text.y=element_text(size=30)) + 
  theme(legend.position="top") +
  ylim(c(0, 100)) +
  xlab("") + 
  ylab("Proportion (%)") +
  guides(fill = guide_legend(nrow = 1)) +
  labs(fill = "") +
  ggtitle('Turkish')


########## Select one language to plot different models ###############

turkish_details <- read.csv('turkish_details.txt', header = T, sep = '\t')
turkish_details <- subset(turkish_details, Model != 'Morfessor')
turkish_details <- subset(turkish_details, Size == 500 & Metric == 'F1') # & Replacement == 'with')


turkish_details %>%
  ggplot(aes(Split, Value, group = Model, color = Model)) +
  geom_line(aes(linetype=Model), alpha = 1) +
  scale_color_manual(values = c("steelblue", "peru", "darkgreen", "darkgrey", "mediumpurple4", "darkred", "black")) +
  scale_x_continuous(breaks=seq(1, 51, 5)) +
  facet_grid( ~ Replacement) +
  theme_classic() + 
  theme(text = element_text(size=16, family="Times")) + 
  theme(legend.position="top") +
  xlab("Data set") + 
  ylab("F1") + 
  xlim(c(1,50)) +
  guides(linetype = guide_legend(nrow = 2)) +
  ggtitle('turkish 500 F1')


####### Studying the effects of data characteristics / heuristics #######
####### For original train / test random splits #########

turkish_heuristics <- read.csv('tur_heuristics.txt', header = T, sep = '\t')
turkish_full <- read.csv('turkish_full.txt', header = T, sep = '\t')

samples = unique(turkish_heuristics$Sample)

language <- unique(turkish_heuristics$Language)

turkish_df <- data.frame(Language=character(), Sample=character(), Replacement=character(), Metric=character(), Model=character(), Feature=character(), Coef=numeric(), Q2.5=numeric(), Q97.5=numeric()) 

for (sample in as.vector(samples)){
  for (replacement in c('with', 'without')){
    for (metric in c('Accuracy', 'Precision', 'Recall', 'F1', 'Avg. Distance')){
      for (model in c('Morfessor', '0-CRF', '1-CRF', '2-CRF', '3-CRF', '4-CRF', 'Seq2seq')){
        for (feature in c('word_overlap', 'morph_overlap', 
                          'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
          
          heuristics <- subset(turkish_heuristics, Feature == feature & Sample == sample & Replacement == replacement)
          results <- subset(turkish_full, Metric == metric & Model == model & Size == sample & Replacement == replacement)
          together = cbind(results, heuristics)
          
          regression <- lm(Score ~ Value, data = together)
          summary <- data.frame(summary(regression)$coef)
          coef = round(summary$Estimate[2], 2)
          ci = data.frame(confint(regression, 'Value', level = 0.95))
          q2.5 = round(ci$X2.5..[1], 2)
          q97.5 = round(ci$X97.5..[1], 2)
          
          turkish_df[nrow(turkish_df) + 1, ] <- c(language, sample, replacement, metric, model, feature, coef, q2.5, q97.5)
          
          turkish_df[is.na(turkish_df)] <- 0
          
          write.csv(turkish_df, 'turkish_corr.txt',row.names=FALSE)
          
        }}}}}


ggplot(subset(turkish_df, Sample=='1000'&Replacement=='with'& (Q2.5 > 0 | Q97.5 < 0)), aes(Feature, as.numeric(Coef), fill = Feature)) +
  geom_bar(stat = 'identity', alpha = 0.8) +
  geom_errorbar(aes(ymax = as.numeric(Q97.5), ymin = as.numeric(Q2.5)), width=.1, position=position_dodge(.9)) +
  geom_text(aes(label=Coef), vjust=2.6, color="black", size=3.5)+
  facet_grid(Model ~ Metric) +
  theme_classic() + 
  theme(text = element_text(size=10, family="Times"),
        axis.text.x=element_blank(),
        axis.text.y=element_text(size=10)) + 
  theme(legend.position="top") +
  ylim(c(-1, 1)) +
  ylab("Spearman") +
  guides(fill = guide_legend(nrow = 2)) +
  labs(fill = "") +
  ggtitle('turkish characteristics 1000 with')


together = 0

for (sample in as.vector(samples)){
  for (replacement in c('with', 'without')){
    for (metric in c('Accuracy', 'Precision', 'Recall', 'F1', 'Avg. Distance')){
      for (model in c('Morfessor', '0-CRF', '1-CRF', '2-CRF', '3-CRF', '4-CRF', 'Seq2seq')){
        for (feature in c('word_overlap', 'morph_overlap',
                          'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
          
          heuristics <- subset(turkish_heuristics, Feature == feature & Sample == sample & Replacement == replacement)
          results <- subset(turkish_full, Metric == metric & Model == model & Size == sample & Replacement == replacement)
          together <- rbind(together, cbind(results, heuristics))
          
        }}}}}

together <- subset(together, Language != 0)
together$Sample <- as.numeric(together$Sample)

turkish_df <- data.frame(Language=character(), Feature=character(), Factor=character(), Coef=numeric(), Q2.5=numeric(), Q97.5=numeric()) 


for (feature in c('word_overlap', 'morph_overlap', 
                  'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
  
  data <- subset(together, Model != 'Morfessor' & Feature == feature & Score != 0 & Value != 0)
  print(feature)
  regression <- 0
  
  if (feature %in% c('word_overlap')){
    regression <- lm(Score ~ Value * Sample * Model * Metric, data = data)
    
  }
  else {
    regression <- lm(Score ~ Value * Replacement * Sample * Model * Metric, data = data) 
    
  }
  
  summary <- data.frame(summary(regression)$coef)
  summary$Factor <- rownames(summary)
  
  for (factor in as.vector(summary$Factor)){
    coef = subset(summary, Factor == factor)$Estimate
    ci = data.frame(confint(regression, factor, level = 0.95))
    q2.5 = ci$X2.5..[1]
    q97.5 = ci$X97.5..[1]
    turkish_df[nrow(turkish_df) + 1, ] <- c(language, feature, factor, round(coef, 2), round(q2.5, 2), round(q97.5, 2))
    write.csv(turkish_df, 'turkish_corr_overall.txt', row.names = FALSE)
    
  }
  
}


###### Studying whether data could be split by heuristics or adversarial training ####

turkish_split_len <- read.csv('tur_split_len.txt', header = T, sep = '\t')
turkish_split_adv <- read.csv('tur_split_adv.txt', header = T, sep = '\t')
turkish_split_adv <- subset(turkish_split_adv, Split != 'EVERYTHING')

### 1 data set splittable by number of morphemes ###


ggplot(turkish_split_adv, aes(x = Overlap)) +
  geom_histogram() + 
  facet_grid(Sample ~ Replacement) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times"),
        axis.text.x=element_text(size=15),
        axis.text.y=element_text(size=15)) + 
  theme(legend.position="top") +
  xlim(c(0, 100)) +
  labs(fill = "") +
  ggtitle('Turkish adversarial')




########### New test set sizes #################

turkish_with_500_50 <- read.csv('tur_crf_test_with_500_50_results.txt', header = T, sep = ' ')
turkish_with_500_50$Size <- rep('500', nrow(turkish_with_500_50))
turkish_with_500_50$Replacement <- rep('with', nrow(turkish_with_500_50))

turkish_with_500_100 <- read.csv('tur_crf_test_with_500_100_results.txt', header = T, sep = ' ')
turkish_with_500_100$Size <- rep('500', nrow(turkish_with_500_100))
turkish_with_500_100$Replacement <- rep('with', nrow(turkish_with_500_100))

turkish_with_1000_50 <- read.csv('tur_crf_test_with_1000_50_results.txt', header = T, sep = ' ')
turkish_with_1000_50$Size <- rep('1000', nrow(turkish_with_1000_50))
turkish_with_1000_50$Replacement <- rep('with', nrow(turkish_with_1000_50))

turkish_with_1000_100 <- read.csv('tur_crf_test_with_1000_100_results.txt', header = T, sep = ' ')
turkish_with_1000_100$Size <- rep('1000', nrow(turkish_with_1000_100))
turkish_with_1000_100$Replacement <- rep('with', nrow(turkish_with_1000_100))

turkish_with_1500_50 <- read.csv('tur_seq2seq_test_with_1500_50_results.txt', header = T, sep = ' ')
turkish_with_1500_50$Size <- rep('1500', nrow(turkish_with_1500_50))
turkish_with_1500_50$Replacement <- rep('with', nrow(turkish_with_1500_50))

turkish_with_1500_100 <- read.csv('tur_seq2seq_test_with_1500_100_results.txt', header = T, sep = ' ')
turkish_with_1500_100$Size <- rep('1500', nrow(turkish_with_1500_100))
turkish_with_1500_100$Replacement <- rep('with', nrow(turkish_with_1500_100))


turkish_without_500_50 <- read.csv('tur_crf_test_without_500_50_results.txt', header = T, sep = ' ')
turkish_without_500_50$Size <- rep('500', nrow(turkish_without_500_50))
turkish_without_500_50$Replacement <- rep('without', nrow(turkish_without_500_50))

turkish_without_500_100 <- read.csv('tur_crf_test_without_500_100_results.txt', header = T, sep = ' ')
turkish_without_500_100$Size <- rep('500', nrow(turkish_without_500_100))
turkish_without_500_100$Replacement <- rep('without', nrow(turkish_without_500_100))

turkish_without_1000_50 <- read.csv('tur_crf_test_without_1000_50_results.txt', header = T, sep = ' ')
turkish_without_1000_50$Size <- rep('1000', nrow(turkish_without_1000_50))
turkish_without_1000_50$Replacement <- rep('without', nrow(turkish_without_1000_50))

turkish_without_1000_100 <- read.csv('tur_crf_test_without_1000_100_results.txt', header = T, sep = ' ')
turkish_without_1000_100$Size <- rep('1000', nrow(turkish_without_1000_100))
turkish_without_1000_100$Replacement <- rep('without', nrow(turkish_without_1000_100))

turkish_without_1500_50 <- read.csv('tur_seq2seq_test_without_1500_50_results.txt', header = T, sep = ' ')
turkish_without_1500_50$Size <- rep('1500', nrow(turkish_without_1500_50))
turkish_without_1500_50$Replacement <- rep('without', nrow(turkish_without_1500_50))

turkish_without_1500_100 <- read.csv('tur_seq2seq_test_without_1500_100_results.txt', header = T, sep = ' ')
turkish_without_1500_100$Size <- rep('1500', nrow(turkish_without_1500_100))
turkish_without_1500_100$Replacement <- rep('without', nrow(turkish_without_1500_100))



turkish_500 <- rbind(turkish_with_500_50, turkish_with_500_100, turkish_without_500_50, turkish_without_500_100)
turkish_1000 <- rbind(turkish_with_1000_50, turkish_with_1000_100, turkish_without_1000_50, turkish_without_1000_100)
turkish_1500 <- rbind(turkish_with_1500_50, turkish_with_1500_100, turkish_without_1500_50, turkish_without_1500_100)
turkish_test <- rbind(turkish_500, turkish_1000, turkish_1500)

### F1
### 500, 50, with: min 47.8; max 87.33
### 500, 50, without: min 45.04; max 90.06
### 500, 100, with: min 53.15; max 84.1
### 500, 100, without: min 53.18; max 85.28
### 1000, 50, with: min 48.74; max 89.43
### 1000, 50, without: min 53.46; max 91.54
### 1000, 100, with: min 52.63; max 84.04
### 1000, 100, without: min 60.67; max 90.08

ggplot(turkish_test, aes(x = Recall, color = Replacement)) +
  geom_density() + 
  facet_grid(Sample_size ~ Size) +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times"),
        axis.text.x=element_text(size=15),
        axis.text.y=element_text(size=15)) + 
  theme(legend.position="top") +
  labs(fill = "") +
  ggtitle('Turkish test Recall')



turkish_500_p <-
  ggplot(subset(turkish_500, Sample_size %in% c('50', '100')), aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('500')


turkish_1000_p <-
  ggplot(turkish_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('1000')


turkish_1500_p <-
  ggplot(turkish_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('1500')

turkish_2000_p <-
  ggplot(turkish_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('2000')

turkish_3000_p <-
  ggplot(turkish_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('3000')

turkish_4000_p <-
  ggplot(turkish_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('4000')


grid.arrange(turkish_500_p, turkish_1000_p, turkish_1500_p, turkish_2000_p, turkish_3000_p, turkish_4000_p, ncol = 2, nrow = 3)



####### Studying the effects of data characteristics / heuristics #######
####### For new test sets ############



turkish_new_test_heuristics <- read.csv('tur_new_test_heuristics.txt', header = T, sep = '\t')

temp <- subset(turkish_test, select = -c(Precision, Recall, F1, Distance))
names(temp) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp$Metric <- rep('Accuracy', nrow(temp))

temp1 <- subset(turkish_test, select = -c(Accuracy, Recall, F1, Distance))
names(temp1) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp1$Metric <- rep('Precision', nrow(temp1))

temp2 <- subset(turkish_test, select = -c(Accuracy, Precision, F1, Distance))
names(temp2) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp2$Metric <- rep('Recall', nrow(temp2))

temp3 <- subset(turkish_test, select = -c(Accuracy, Precision, Recall, Distance))
names(temp3) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp3$Metric <- rep('F1', nrow(temp3))

temp4 <- subset(turkish_test, select = -c(Accuracy, Precision, Recall, F1))
names(temp4) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp4$Metric <- rep('Distance', nrow(temp4))

turkish_full <- rbind(temp, temp1, temp2, temp3, temp4)

samples = unique(turkish_new_test_heuristics$Sample)

language <- unique(turkish_new_test_heuristics$Language)

together = 0


for (sample in as.vector(samples)){
  for (sample_size in as.vector(unique(turkish_full$Sample_size))){
    for (split in as.vector(unique(turkish_full$Split))){
      for (replacement in as.vector(unique(turkish_new_test_heuristics$Replacement))){
        for (metric in c('Accuracy', 'Precision', 'Recall', 'F1', 'Avg. Distance')){
          results <- subset(turkish_full, Sample_size == sample_size & Split == split & Size == sample & Replacement == replacement)
          new_test_heuristics <- subset(turkish_new_test_heuristics, Test_size == sample_size & Split == split & Feature == 'morph_overlap' & Sample == sample & Replacement == replacement)
          new_test_heuristics <- subset(new_test_heuristics, select = -Feature)
          names(new_test_heuristics) <- c('Language', 'Sample', 'Replacement', 'Split', 'Test_size', 'Test_id', 'Set', 'morph_overlap', 'Caveat')
          
          for (feature in c('ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
            
            if (feature == 'ave_num_morph_ratio'){
              new_test_heuristics$ave_num_morph_ratio <- subset(turkish_new_test_heuristics, Test_size == sample_size & Split == split & Feature == feature & Sample == sample & Replacement == replacement)$Value
            }
            
            if (feature == 'dist_ave_num_morph'){
              new_test_heuristics$dist_ave_num_morph <- subset(turkish_new_test_heuristics, Test_size == sample_size & Split == split & Feature == feature & Sample == sample & Replacement == replacement)$Value
            }
            
            if (feature == 'ave_morph_len_ratio'){
              new_test_heuristics$ave_morph_len_ratio <- subset(turkish_new_test_heuristics, Test_size == sample_size & Split == split & Feature == feature & Sample == sample & Replacement == replacement)$Value
            }
            
          }
          
          together <- rbind(together, cbind(results, new_test_heuristics))
          
          
        }}}}}

together <- subset(together, Language != 0)
together$Sample <- as.numeric(together$Sample)

together$morph_overlap <- together$morph_overlap / 100

regression <- lm(Score ~ (morph_overlap + ave_num_morph_ratio + dist_ave_num_morph + ave_morph_len_ratio)*Replacement + (morph_overlap + ave_num_morph_ratio + dist_ave_num_morph + ave_morph_len_ratio)*Sample + (morph_overlap + ave_num_morph_ratio + dist_ave_num_morph + ave_morph_len_ratio)*Test_size + Metric, data = together)

summary <- data.frame(summary(regression)$coef)
summary$Factor <- rownames(summary)

turkish_df <- data.frame(Language=character(), Factor=character(), Coef=numeric(), Q2.5=numeric(), Q97.5=numeric()) 


for (factor in as.vector(summary$Factor)){
  print(factor)
  coef = subset(summary, Factor == factor)$Estimate
  ci = data.frame(confint(regression, factor, level = 0.95))
  q2.5 = ci$X2.5..[1]
  q97.5 = ci$X97.5..[1]
  print(typeof(factor))
  turkish_df[nrow(turkish_df) + 1, ] <- c('turkish', as.character(factor), round(coef, 2), round(q2.5, 2), round(q97.5, 2))
  write.csv(turkish_df, 'turkish_corr_new_test.txt', row.names = FALSE)
  
}

turkish_df$Factor<-summary$Factor
turkish_df$P_value<-summary$Pr...t..
turkish_df$Language<-rep('turkish',nrow(turkish_df))

write.csv(turkish_df, 'turkish_corr_new_test.txt', row.names = FALSE)






################################
########### Finnish ###########
################################

finnish <- read.csv('finnish.txt', header = T, sep = '\t')
finnish$Language <- rep('finnish', nrow(finnish))

finnish <- subset(finnish, Index %in% c('Same best model', 'Same model ranking', 'A best model', 'A best model ranking'))
finnish$Index[finnish$Index == 'Same model ranking'] <- 'Same ranking'
finnish$Index[finnish$Index == 'A best model ranking'] <- 'A best ranking'
finnish$Index <- factor(finnish$Index, levels = c('Same best model', 
                                                  'Same ranking', 
                                                  'A best model', 
                                                  'A best ranking'))

finnish_p <-
  ggplot(subset(finnish, Metric == 'F1'&Index %in% c('Same best model', 'Same ranking')), aes(Index, Proportion, fill = Index)) +
  geom_bar(stat = 'identity', alpha = 0.8) +
  geom_text(aes(label=paste(Proportion, '%')), vjust=-1, color="black", size=6)+
  scale_fill_manual(values = c("steelblue", "mediumpurple4")) + #, "darkgreen", "peru")) +
  facet_grid(Replacement ~ Size) +
  
  theme_classic() + 
  theme(text = element_text(size=30, family="Times"),
        axis.text.x=element_blank(),
        axis.text.y=element_text(size=30)) + 
  theme(legend.position="top") +
  ylim(c(0, 100)) +
  xlab("") + 
  ylab("Proportion (%)") +
  guides(fill = guide_legend(nrow = 1)) +
  labs(fill = "") +
  ggtitle('Finnish')


########## Select one language to plot different models ###############

finnish_details <- read.csv('finnish_details.txt', header = T, sep = '\t')
finnish_details <- subset(finnish_details, Model != 'Morfessor')
finnish_details <- subset(finnish_details, Size == 500 & Metric == 'F1') # & Replacement == 'with')


finnish_details %>%
  ggplot(aes(Split, Value, group = Model, color = Model)) +
  geom_line(aes(linetype=Model), alpha = 1) +
  scale_color_manual(values = c("steelblue", "peru", "darkgreen", "darkgrey", "mediumpurple4", "darkred", "black")) +
  scale_x_continuous(breaks=seq(1, 51, 5)) +
  facet_grid( ~ Replacement) +
  theme_classic() + 
  theme(text = element_text(size=16, family="Times")) + 
  theme(legend.position="top") +
  xlab("Data set") + 
  ylab("F1") + 
  xlim(c(1,50)) +
  guides(linetype = guide_legend(nrow = 2)) +
  ggtitle('finnish 500 F1')


####### Studying the effects of data characteristics / heuristics #######
####### For original train / test random splits #########

finnish_heuristics <- read.csv('fin_heuristics.txt', header = T, sep = '\t')
finnish_full <- read.csv('finnish_full.txt', header = T, sep = '\t')

samples = unique(finnish_heuristics$Sample)

language <- unique(finnish_heuristics$Language)


finnish_df <- data.frame(Language=character(), Sample=character(), Replacement=character(), Metric=character(), Model=character(), Feature=character(), Coef=numeric(), Q2.5=numeric(), Q97.5=numeric()) 

for (sample in as.vector(samples)){
  for (replacement in c('with', 'without')){
    for (metric in c('Accuracy', 'Precision', 'Recall', 'F1', 'Avg. Distance')){
      for (model in c('Morfessor', '0-CRF', '1-CRF', '2-CRF', '3-CRF', '4-CRF', 'Seq2seq')){
        for (feature in c('word_overlap', 'morph_overlap', 
                          'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
          
          heuristics <- subset(finnish_heuristics, Feature == feature & Sample == sample & Replacement == replacement)
          results <- subset(finnish_full, Metric == metric & Model == model & Size == sample & Replacement == replacement)
          together = cbind(results, heuristics)
          
          regression <- lm(Score ~ Value, data = together)
          summary <- data.frame(summary(regression)$coef)
          coef = round(summary$Estimate[2], 2)
          ci = data.frame(confint(regression, 'Value', level = 0.95))
          q2.5 = round(ci$X2.5..[1], 2)
          q97.5 = round(ci$X97.5..[1], 2)
          
          finnish_df[nrow(finnish_df) + 1, ] <- c(language, sample, replacement, metric, model, feature, coef, q2.5, q97.5)
          
          finnish_df[is.na(finnish_df)] <- 0
          
          write.csv(finnish_df, 'finnish_corr.txt',row.names=FALSE)
          
        }}}}}


ggplot(subset(finnish_df, Sample=='1000'&Replacement=='with'& (Q2.5 > 0 | Q97.5 < 0)), aes(Feature, as.numeric(Coef), fill = Feature)) +
  geom_bar(stat = 'identity', alpha = 0.8) +
  geom_errorbar(aes(ymax = as.numeric(Q97.5), ymin = as.numeric(Q2.5)), width=.1, position=position_dodge(.9)) +
  geom_text(aes(label=Coef), vjust=2.6, color="black", size=3.5)+
  facet_grid(Model ~ Metric) +
  theme_classic() + 
  theme(text = element_text(size=10, family="Times"),
        axis.text.x=element_blank(),
        axis.text.y=element_text(size=10)) + 
  theme(legend.position="top") +
  ylim(c(-1, 1)) +
  ylab("Spearman") +
  guides(fill = guide_legend(nrow = 2)) +
  labs(fill = "") +
  ggtitle('finnish characteristics 1000 with')


together = 0

for (sample in as.vector(samples)){
  for (replacement in c('with', 'without')){
    for (metric in c('Accuracy', 'Precision', 'Recall', 'F1', 'Avg. Distance')){
      for (model in c('Morfessor', '0-CRF', '1-CRF', '2-CRF', '3-CRF', '4-CRF', 'Seq2seq')){
        for (feature in c('word_overlap', 'morph_overlap',
                          'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
          
          heuristics <- subset(finnish_heuristics, Feature == feature & Sample == sample & Replacement == replacement)
          results <- subset(finnish_full, Metric == metric & Model == model & Size == sample & Replacement == replacement)
          together <- rbind(together, cbind(results, heuristics))
          
        }}}}}

together <- subset(together, Language != 0)
together$Sample <- as.numeric(together$Sample)

finnish_df <- data.frame(Language=character(), Feature=character(), Factor=character(), Coef=numeric(), Q2.5=numeric(), Q97.5=numeric()) 


for (feature in c('word_overlap', 'morph_overlap', 
                  'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
  
  data <- subset(together, Model != 'Morfessor' & Feature == feature & Score != 0 & Value != 0)
  print(feature)
  regression <- 0
  
  if (feature %in% c('word_overlap')){
    regression <- lm(Score ~ Value * Sample * Model * Metric, data = data)
    
  }
  else {
    regression <- lm(Score ~ Value * Replacement * Sample * Model * Metric, data = data) 
    
  }
  
  summary <- data.frame(summary(regression)$coef)
  summary$Factor <- rownames(summary)
  
  for (factor in as.vector(summary$Factor)){
    coef = subset(summary, Factor == factor)$Estimate
    ci = data.frame(confint(regression, factor, level = 0.95))
    q2.5 = ci$X2.5..[1]
    q97.5 = ci$X97.5..[1]
    finnish_df[nrow(finnish_df) + 1, ] <- c(language, feature, factor, round(coef, 2), round(q2.5, 2), round(q97.5, 2))
    write.csv(finnish_df, 'finnish_corr_overall.txt', row.names = FALSE)
    
  }
  
}


###### Studying whether data could be split by heuristics or adversarial training ####

finnish_split_len <- read.csv('fin_split_len.txt', header = T, sep = '\t')
finnish_split_adv <- read.csv('fin_split_adv.txt', header = T, sep = '\t')
finnish_split_adv <- subset(finnish_split_adv, Split != 'EVERYTHING')

### 500, with
### 11 data sets splittable by number of morphemes ###

### 500, without
### 7 data sets

### 1000, with
### 2 data sets

### 1000, without
### 0 data set

### 1500, with / 1500, without
### 0 data set


ggplot(finnish_split_adv, aes(x = Overlap)) +
  geom_histogram() + 
  facet_grid(Sample ~ Replacement) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times"),
        axis.text.x=element_text(size=15),
        axis.text.y=element_text(size=15)) + 
  theme(legend.position="top") +
  xlim(c(0, 100)) +
  labs(fill = "") +
  ggtitle('Finnish adversarial')




########### New test set sizes #################

finnish_with_500_50 <- read.csv('fin_crf_test_with_500_50_results.txt', header = T, sep = ' ')
finnish_with_500_50$Size <- rep('500', nrow(finnish_with_500_50))
finnish_with_500_50$Replacement <- rep('with', nrow(finnish_with_500_50))

finnish_with_500_100 <- read.csv('fin_crf_test_with_500_100_results.txt', header = T, sep = ' ')
finnish_with_500_100$Size <- rep('500', nrow(finnish_with_500_100))
finnish_with_500_100$Replacement <- rep('with', nrow(finnish_with_500_100))

finnish_with_1000_50 <- read.csv('fin_crf_test_with_1000_50_results.txt', header = T, sep = ' ')
finnish_with_1000_50$Size <- rep('1000', nrow(finnish_with_1000_50))
finnish_with_1000_50$Replacement <- rep('with', nrow(finnish_with_1000_50))

finnish_with_1000_100 <- read.csv('fin_crf_test_with_1000_100_results.txt', header = T, sep = ' ')
finnish_with_1000_100$Size <- rep('1000', nrow(finnish_with_1000_100))
finnish_with_1000_100$Replacement <- rep('with', nrow(finnish_with_1000_100))

finnish_with_1500_50 <- read.csv('fin_seq2seq_test_with_1500_50_results.txt', header = T, sep = ' ')
finnish_with_1500_50$Size <- rep('1500', nrow(finnish_with_1500_50))
finnish_with_1500_50$Replacement <- rep('with', nrow(finnish_with_1500_50))

finnish_with_1500_100 <- read.csv('fin_seq2seq_test_with_1500_100_results.txt', header = T, sep = ' ')
finnish_with_1500_100$Size <- rep('1500', nrow(finnish_with_1500_100))
finnish_with_1500_100$Replacement <- rep('with', nrow(finnish_with_1500_100))


finnish_without_500_50 <- read.csv('fin_crf_test_without_500_50_results.txt', header = T, sep = ' ')
finnish_without_500_50$Size <- rep('500', nrow(finnish_without_500_50))
finnish_without_500_50$Replacement <- rep('without', nrow(finnish_without_500_50))

finnish_without_500_100 <- read.csv('fin_crf_test_without_500_100_results.txt', header = T, sep = ' ')
finnish_without_500_100$Size <- rep('500', nrow(finnish_without_500_100))
finnish_without_500_100$Replacement <- rep('without', nrow(finnish_without_500_100))

finnish_without_1000_50 <- read.csv('fin_crf_test_without_1000_50_results.txt', header = T, sep = ' ')
finnish_without_1000_50$Size <- rep('1000', nrow(finnish_without_1000_50))
finnish_without_1000_50$Replacement <- rep('without', nrow(finnish_without_1000_50))

finnish_without_1000_100 <- read.csv('fin_crf_test_without_1000_100_results.txt', header = T, sep = ' ')
finnish_without_1000_100$Size <- rep('1000', nrow(finnish_without_1000_100))
finnish_without_1000_100$Replacement <- rep('without', nrow(finnish_without_1000_100))

finnish_without_1500_50 <- read.csv('fin_seq2seq_test_without_1500_50_results.txt', header = T, sep = ' ')
finnish_without_1500_50$Size <- rep('1500', nrow(finnish_without_1500_50))
finnish_without_1500_50$Replacement <- rep('without', nrow(finnish_without_1500_50))

finnish_without_1500_100 <- read.csv('fin_seq2seq_test_without_1500_100_results.txt', header = T, sep = ' ')
finnish_without_1500_100$Size <- rep('1500', nrow(finnish_without_1500_100))
finnish_without_1500_100$Replacement <- rep('without', nrow(finnish_without_1500_100))



finnish_500 <- rbind(finnish_with_500_50, finnish_with_500_100, finnish_without_500_50, finnish_without_500_100)
finnish_1000 <- rbind(finnish_with_1000_50, finnish_with_1000_100, finnish_without_1000_50, finnish_without_1000_100)
finnish_1500 <- rbind(finnish_with_1500_50, finnish_with_1500_100, finnish_without_1500_50, finnish_without_1500_100)
finnish_test <- rbind(finnish_500, finnish_1000, finnish_1500)


### F1
### 500, 50, with: min 47.8; max 87.33
### 500, 50, without: min 45.04; max 90.06
### 500, 100, with: min 53.15; max 84.1
### 500, 100, without: min 53.18; max 85.28
### 1000, 50, with: min 48.74; max 89.43
### 1000, 50, without: min 53.46; max 91.54
### 1000, 100, with: min 52.63; max 84.04
### 1000, 100, without: min 60.67; max 90.08

ggplot(finnish_test, aes(x = Recall, color = Replacement)) +
  geom_density() + 
  facet_grid(Sample_size ~ Size) +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times"),
        axis.text.x=element_text(size=15),
        axis.text.y=element_text(size=15)) + 
  theme(legend.position="top") +
  labs(fill = "") +
  ggtitle('Finnish test Recall')



finnish_500_p <-
  ggplot(subset(finnish_500, Sample_size %in% c('50', '100')), aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('500')


finnish_1000_p <-
  ggplot(finnish_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('1000')


finnish_1500_p <-
  ggplot(finnish_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('1500')

finnish_2000_p <-
  ggplot(finnish_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('2000')

finnish_3000_p <-
  ggplot(finnish_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('3000')

finnish_4000_p <-
  ggplot(finnish_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('4000')


grid.arrange(finnish_500_p, finnish_1000_p, finnish_1500_p, finnish_2000_p, finnish_3000_p, finnish_4000_p, ncol = 2, nrow = 3)



####### Studying the effects of data characteristics / heuristics #######
####### For new test sets ############


finnish_new_test_heuristics <- read.csv('fin_new_test_heuristics.txt', header = T, sep = '\t')

temp <- subset(finnish_test, select = -c(Precision, Recall, F1, Distance))
names(temp) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp$Metric <- rep('Accuracy', nrow(temp))

temp1 <- subset(finnish_test, select = -c(Accuracy, Recall, F1, Distance))
names(temp1) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp1$Metric <- rep('Precision', nrow(temp1))

temp2 <- subset(finnish_test, select = -c(Accuracy, Precision, F1, Distance))
names(temp2) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp2$Metric <- rep('Recall', nrow(temp2))

temp3 <- subset(finnish_test, select = -c(Accuracy, Precision, Recall, Distance))
names(temp3) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp3$Metric <- rep('F1', nrow(temp3))

temp4 <- subset(finnish_test, select = -c(Accuracy, Precision, Recall, F1))
names(temp4) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp4$Metric <- rep('Distance', nrow(temp4))

finnish_full <- rbind(temp, temp1, temp2, temp3, temp4)

samples = unique(finnish_new_test_heuristics$Sample)

language <- unique(finnish_new_test_heuristics$Language)

together = 0


for (sample in as.vector(samples)){
  for (sample_size in as.vector(unique(finnish_full$Sample_size))){
    for (split in as.vector(unique(finnish_full$Split))){
      for (replacement in as.vector(unique(finnish_new_test_heuristics$Replacement))){
        for (metric in c('Accuracy', 'Precision', 'Recall', 'F1', 'Distance')){
          results <- subset(finnish_full, Sample_size == sample_size & Split == split & Size == sample & Replacement == replacement)
          new_test_heuristics <- subset(finnish_new_test_heuristics, Test_size == sample_size & Split == split & Feature == 'morph_overlap' & Sample == sample & Replacement == replacement)
          new_test_heuristics <- subset(new_test_heuristics, select = -Feature)
          names(new_test_heuristics) <- c('Language', 'Sample', 'Replacement', 'Split', 'Test_size', 'Test_id', 'Set', 'morph_overlap', 'Caveat')
          
          for (feature in c('ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
            
            if (feature == 'ave_num_morph_ratio'){
              new_test_heuristics$ave_num_morph_ratio <- subset(finnish_new_test_heuristics, Test_size == sample_size & Split == split & Feature == feature & Sample == sample & Replacement == replacement)$Value
            }
            
            if (feature == 'dist_ave_num_morph'){
              new_test_heuristics$dist_ave_num_morph <- subset(finnish_new_test_heuristics, Test_size == sample_size & Split == split & Feature == feature & Sample == sample & Replacement == replacement)$Value
            }
            
            if (feature == 'ave_morph_len_ratio'){
              new_test_heuristics$ave_morph_len_ratio <- subset(finnish_new_test_heuristics, Test_size == sample_size & Split == split & Feature == feature & Sample == sample & Replacement == replacement)$Value
            }
            
          }
          
          together <- rbind(together, cbind(results, new_test_heuristics))
          write.csv(together, 'finnish_together_new_test.txt', row.names = FALSE)
          
        }}}}}

together <- subset(together, Language != 0)
together$Sample <- as.numeric(together$Sample)

together$morph_overlap <- together$morph_overlap / 100

regression <- lm(Score ~ (morph_overlap + ave_num_morph_ratio + dist_ave_num_morph + ave_morph_len_ratio)*Replacement + (morph_overlap + ave_num_morph_ratio + dist_ave_num_morph + ave_morph_len_ratio)*Sample + (morph_overlap + ave_num_morph_ratio + dist_ave_num_morph + ave_morph_len_ratio)*Test_size + Metric, data = together)

summary <- data.frame(summary(regression)$coef)
summary$Factor <- rownames(summary)

finnish_df <- data.frame(Language=character(), Factor=character(), Coef=numeric(), Q2.5=numeric(), Q97.5=numeric()) 


for (factor in as.vector(summary$Factor)){
  print(factor)
  coef = subset(summary, Factor == factor)$Estimate
  ci = data.frame(confint(regression, factor, level = 0.95))
  q2.5 = ci$X2.5..[1]
  q97.5 = ci$X97.5..[1]
  print(typeof(factor))
  finnish_df[nrow(finnish_df) + 1, ] <- c('finnish', as.character(factor), round(coef, 2), round(q2.5, 2), round(q97.5, 2))
  write.csv(finnish_df, 'finnish_corr_new_test.txt', row.names = FALSE)
  
}

finnish_df$Factor<-summary$Factor
finnish_df$P_value<-summary$Pr...t..
finnish_df$Language<-rep('finnish',nrow(finnish_df))

write.csv(finnish_df, 'finnish_corr_new_test.txt', row.names = FALSE)




################################
########### Zulu ###############
################################

zulu <- read.csv('zulu.txt', header = T, sep = '\t')
zulu$Language <- rep('zulu', nrow(zulu))

zulu <- subset(zulu, Index %in% c('Same best model', 'Same model ranking', 'A best model', 'A best model ranking'))
zulu$Index[zulu$Index == 'Same model ranking'] <- 'Same ranking'
zulu$Index[zulu$Index == 'A best model ranking'] <- 'A best ranking'
zulu$Index <- factor(zulu$Index, levels = c('Same best model', 
                                                  'Same ranking', 
                                                  'A best model', 
                                                  'A best ranking'))

zulu_p <-
  ggplot(subset(zulu, Metric == 'F1'&Index %in% c('Same best model', 'Same ranking')), aes(Index, Proportion, fill = Index)) +
  geom_bar(stat = 'identity', alpha = 0.8) +
  geom_text(aes(label=paste(Proportion, '%')), vjust=-1, color="black", size=6)+
  scale_fill_manual(values = c("steelblue", "mediumpurple4")) + #, "darkgreen", "peru")) +
  facet_grid(Replacement ~ Size) +
  
  theme_classic() + 
  theme(text = element_text(size=30, family="Times"),
        axis.text.x=element_blank(),
        axis.text.y=element_text(size=30)) + 
  theme(legend.position="top") +
  ylim(c(0, 100)) +
  xlab("") + 
  ylab("Proportion (%)") +
  guides(fill = guide_legend(nrow = 1)) +
  labs(fill = "") +
  ggtitle('Zulu')


########## Select one language to plot different models ###############

zulu_details <- read.csv('zulu_details.txt', header = T, sep = '\t')
zulu_details <- subset(zulu_details, Model != 'Morfessor')
zulu_details <- subset(zulu_details, Size == 500 & Metric == 'F1') # & Replacement == 'with')


zulu_details %>%
  ggplot(aes(Split, Value, group = Model, color = Model)) +
  geom_line(aes(linetype=Model), alpha = 1) +
  scale_color_manual(values = c("steelblue", "peru", "darkgreen", "darkgrey", "mediumpurple4", "darkred", "black")) +
  scale_x_continuous(breaks=seq(1, 51, 5)) +
  facet_grid( ~ Replacement) +
  theme_classic() + 
  theme(text = element_text(size=16, family="Times")) + 
  theme(legend.position="top") +
  xlab("Data set") + 
  ylab("F1") + 
  xlim(c(1,50)) +
  guides(linetype = guide_legend(nrow = 2)) +
  ggtitle('zulu 500 F1')


zulu_details_summary <- data.frame(Size=character(), Model=character(), Replacement=character(), Metric=character(), Mean=numeric(), Variance=numeric(), Std=numeric()) 

sizes = unique(as.vector(zulu_details$Size))
models = unique(as.vector(zulu_details$Model))
metrics = unique(as.vector(zulu_details$Metric))

for (size in sizes){
  for (model in models){
    for (replacement in c('with', 'without')){
      for (metric in metrics){
        data <- subset(zulu_details, Size==size &  Replacement==replacement & Metric==metric)
        mean <- mean(as.numeric(data$Value))
        min <- min(as.numeric(data$Value))
        max <- max(as.numeric(data$Value))
        sd <- sd(as.vector(as.numeric(data$Value)))
        
        zulu_details_summary[nrow(zulu_details_summary) + 1, ] <- c(size, model, replacement, metric, mean, max-min, sd)
        print(c(size, model, replacement, metric, mean, max-min, sd))
        
      }
    }
  }
}

write.csv(zulu_details_summary, 'zulu_adversarial_details_summary.txt', row.names=FALSE)


####### Studying the effects of data characteristics / heuristics #######
####### For original train / test random splits #########

zulu_heuristics <- read.csv('zul_heuristics.txt', header = T, sep = '\t')
zulu_full <- read.csv('zulu_full.txt', header = T, sep = '\t')

samples = unique(zulu_heuristics$Sample)

language <- unique(zulu_heuristics$Language)

zulu_df <- data.frame(Language=character(), Sample=character(), Replacement=character(), Metric=character(), Model=character(), Feature=character(), Coef=numeric(), Q2.5=numeric(), Q97.5=numeric()) 

for (sample in as.vector(samples)){
  for (replacement in c('with', 'without')){
    for (metric in c('Accuracy', 'Precision', 'Recall', 'F1', 'Avg. Distance')){
      for (model in c('Morfessor', '0-CRF', '1-CRF', '2-CRF', '3-CRF', '4-CRF', 'Seq2seq')){
        for (feature in c('word_overlap', 'morph_overlap', 
                          'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
          
          heuristics <- subset(zulu_heuristics, Feature == feature & Sample == sample & Replacement == replacement)
          results <- subset(zulu_full, Metric == metric & Model == model & Size == sample & Replacement == replacement)
          together = cbind(results, heuristics)
          
          regression <- lm(Score ~ Value, data = together)
          summary <- data.frame(summary(regression)$coef)
          coef = round(summary$Estimate[2], 2)
          ci = data.frame(confint(regression, 'Value', level = 0.95))
          q2.5 = round(ci$X2.5..[1], 2)
          q97.5 = round(ci$X97.5..[1], 2)
          
          zulu_df[nrow(zulu_df) + 1, ] <- c(language, sample, replacement, metric, model, feature, coef, q2.5, q97.5)
          
          zulu_df[is.na(zulu_df)] <- 0
          
          write.csv(zulu_df, 'zulu_corr.txt',row.names=FALSE)
          
        }}}}}


ggplot(subset(zulu_df, Sample=='1000'&Replacement=='with'& (Q2.5 > 0 | Q97.5 < 0)), aes(Feature, as.numeric(Coef), fill = Feature)) +
  geom_bar(stat = 'identity', alpha = 0.8) +
  geom_errorbar(aes(ymax = as.numeric(Q97.5), ymin = as.numeric(Q2.5)), width=.1, position=position_dodge(.9)) +
  geom_text(aes(label=Coef), vjust=2.6, color="black", size=3.5)+
  facet_grid(Model ~ Metric) +
  theme_classic() + 
  theme(text = element_text(size=10, family="Times"),
        axis.text.x=element_blank(),
        axis.text.y=element_text(size=10)) + 
  theme(legend.position="top") +
  ylim(c(-1, 1)) +
  ylab("Spearman") +
  guides(fill = guide_legend(nrow = 2)) +
  labs(fill = "") +
  ggtitle('zulu characteristics 1000 with')


together = 0

for (sample in as.vector(samples)){
  for (replacement in c('with', 'without')){
    for (metric in c('Accuracy', 'Precision', 'Recall', 'F1', 'Avg. Distance')){
      for (model in c('Morfessor', '0-CRF', '1-CRF', '2-CRF', '3-CRF', '4-CRF', 'Seq2seq')){
        for (feature in c('word_overlap', 'morph_overlap',
                          'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
          
          heuristics <- subset(zulu_heuristics, Feature == feature & Sample == sample & Replacement == replacement)
          results <- subset(zulu_full, Metric == metric & Model == model & Size == sample & Replacement == replacement)
          together <- rbind(together, cbind(results, heuristics))
          
        }}}}}

together <- subset(together, Language != 0)
together$Sample <- as.numeric(together$Sample)

zulu_df <- data.frame(Language=character(), Feature=character(), Factor=character(), Coef=numeric(), Q2.5=numeric(), Q97.5=numeric()) 


for (feature in c('word_overlap', 'morph_overlap', 
                  'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
  
  data <- subset(together, Model != 'Morfessor' & Feature == feature & Score != 0 & Value != 0)
  print(feature)
  regression <- 0
  
  if (feature %in% c('word_overlap')){
    regression <- lm(Score ~ Value * Sample * Model * Metric, data = data)
    
  }
  else {
    regression <- lm(Score ~ Value * Replacement * Sample * Model * Metric, data = data) 
    
  }
  
  summary <- data.frame(summary(regression)$coef)
  summary$Factor <- rownames(summary)
  
  for (factor in as.vector(summary$Factor)){
    coef = subset(summary, Factor == factor)$Estimate
    ci = data.frame(confint(regression, factor, level = 0.95))
    q2.5 = ci$X2.5..[1]
    q97.5 = ci$X97.5..[1]
    zulu_df[nrow(zulu_df) + 1, ] <- c(language, feature, factor, round(coef, 2), round(q2.5, 2), round(q97.5, 2))
    write.csv(zulu_df, 'zulu_corr_overall.txt', row.names = FALSE)
    
  }
  
}

sizes=unique(as.vector(zulu_details_summary$Size))

for (replacement in c('with', 'without')){
  for (model in c('2-CRF', '4-CRF')){
    total = 0
    for (size in sizes){
      random <- subset(zulu_details_summary, Size==size&Model==model&Replacement==replacement&Metric=='F1')
      adversarial <- subset(zulu_adversarial_details_summary, Size==size&Model==model&Replacement==replacement&Metric=='F1')
      print(c(size, replacement, model, as.numeric(random$Mean) - as.numeric(adversarial$Mean)))
      total = total + as.numeric(random$Mean) - as.numeric(adversarial$Mean)
    }
    print(total / 6)
  }
}

sizes=unique(as.vector(russian_details_summary$Size))

for (replacement in c('with', 'without')){
  for (model in c('2-CRF', '4-CRF')){
    total = 0
    for (size in sizes){
      random <- subset(russian_details_summary, Size==size&Model==model&Replacement==replacement&Metric=='F1')
      adversarial <- subset(russian_adversarial_details_summary, Size==size&Model==model&Replacement==replacement&Metric=='F1')
      print(c(size, replacement, model, as.numeric(random$Mean) - as.numeric(adversarial$Mean)))
      total = total + as.numeric(random$Mean) - as.numeric(adversarial$Mean)
    }
    print(total / 6)
  }
}


###### Studying whether data could be split by heuristics or adversarial training ####

zulu_split_len <- read.csv('zul_split_len.txt', header = T, sep = '\t')
zulu_split_adv <- read.csv('zul_split_adv.txt', header = T, sep = '\t')
zulu_split_adv <- subset(zulu_split_adv, Split != 'EVERYTHING')

### 0 data set splittable by number of morphemes ###


ggplot(zulu_split_adv, aes(x = Overlap)) +
  geom_histogram() + 
  facet_grid(Sample ~ Replacement) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times"),
        axis.text.x=element_text(size=15),
        axis.text.y=element_text(size=15)) + 
  theme(legend.position="top") +
  xlim(c(0, 100)) +
  labs(fill = "") +
  ggtitle('Zulu adversarial')


###### Results for Adversarial Splits ######

zulu_adversarial_details <- read.csv('zulu_adversarial_details.txt', header = T, sep = '\t')

samples = unique(zulu_adversarial_details$Size)

zulu_adversarial_breakdown <- data.frame(Language=character(), Sample=character(), Replacement=character(), Metric=character(), Model=character(), Proportion=numeric())

language = 'zul'
  
for (sample in as.vector(samples)){
  for (replacement in c('with', 'without')){
    
    zero_CRF = 0
    first_CRF = 0
    second_CRF = 0
    third_CRF = 0
    fourth_CRF = 0
    seq = 0
    
    CRF = 0
    
    for (i in 1:50){
      
      data <- subset(zulu_adversarial_details,  Split==as.character(i) & Size == sample & Replacement==replacement)
      best <- subset(data, Value == max(data$Value))

      if (best$Model == '0-CRF'){
        zero_CRF = zero_CRF + 1
        CRF = CRF + 1
      }
      
      if (best$Model == '1-CRF'){
        first_CRF = first_CRF + 1
        CRF = CRF + 1
      }
      
      if (best$Model == '2-CRF'){
        second_CRF = second_CRF + 1
        CRF = CRF + 1
      }
      
      if (best$Model == '3-CRF'){
        third_CRF = third_CRF + 1
        CRF = CRF + 1
      }
      
      if (best$Model == '4-CRF'){
        fourth_CRF = fourth_CRF + 1
        CRF = CRF + 1
      }
      
      if (best$Model == 'Seq2seq'){
        seq = seq + 1
      }}
    
    zero_CRF = zero_CRF * 100 / 50
    first_CRF = first_CRF * 100 / 50
    second_CRF = second_CRF * 100 / 50
    third_CRF = third_CRF * 100 / 50
    fourth_CRF = fourth_CRF * 100 / 50
    seq = seq * 100 / 50
    
    CRF = CRF * 100 / 50
    
    zulu_adversarial_breakdown[nrow(zulu_adversarial_breakdown) + 1, ] <- c(language, sample, replacement, 'F1', '0-CRF', zero_CRF)
    zulu_adversarial_breakdown[nrow(zulu_adversarial_breakdown) + 1, ] <- c(language, sample, replacement, 'F1', '1-CRF', first_CRF)
    zulu_adversarial_breakdown[nrow(zulu_adversarial_breakdown) + 1, ] <- c(language, sample, replacement, 'F1', '2-CRF', second_CRF)
    zulu_adversarial_breakdown[nrow(zulu_adversarial_breakdown) + 1, ] <- c(language, sample, replacement, 'F1', '3-CRF', third_CRF)
    zulu_adversarial_breakdown[nrow(zulu_adversarial_breakdown) + 1, ] <- c(language, sample, replacement, 'F1', '4-CRF', fourth_CRF)
    zulu_adversarial_breakdown[nrow(zulu_adversarial_breakdown) + 1, ] <- c(language, sample, replacement, 'F1', 'Seq2seq', seq)
    zulu_adversarial_breakdown[nrow(zulu_adversarial_breakdown) + 1, ] <- c(language, sample, replacement, 'F1', 'CRF', CRF)
    
  }}

write.csv(zulu_adversarial_breakdown, 'zulu_adversarial_breakdown.txt', row.names = FALSE)


zulu_adversarial_breakdown %>%
  ggplot(aes(Model, as.numeric(Proportion), fill = Model)) +
  geom_bar(stat = 'identity', alpha = 0.8) +
  geom_text(aes(label=Proportion), vjust=-2.6, color="black", size=3.5)+
  facet_grid(Replacement ~ Sample) +
  theme_classic() + 
  theme(text = element_text(size=30, family="Times"),
        axis.text.x=element_text(size=15),
        axis.text.y=element_text(size=30)) + 
  theme(legend.position="none") +
  ylim(c(0, 100)) +
  xlab("") + 
  ylab("Proportion (%)") +
  guides(fill = guide_legend(nrow = 2)) +
  ggtitle('zulu model statistics')


zulu_adversarial_details$Value <- as.numeric(zulu_adversarial_details$Value)

languages = unique(zulu_adversarial_details$Language)
models = unique(zulu_adversarial_details$Model)
metrics = unique(zulu_adversarial_details$Metric)
samples <- unique(zulu_adversarial_details$Size)

zulu_adversarial_details_info <- data.frame(Language=character(), Sample=character(), Replacement=character(), Metric=character(), Model=character(), Value=numeric(), First_best=character(), Overall_best=character(), Data_mean=numeric(), Data_min=numeric(), Data_max=numeric(), Data_variance=numeric(), First_variance=numeric(), Ave_diff=numeric(), Proportion=numeric())  
  
for (sample in as.vector(samples)){
    for (replacement in c('with', 'without')){
      for (metric in as.vector(metrics)){
        data <- subset(zulu_adversarial_details, Size==sample & Replacement==replacement & Metric==metric)
        first_data <- subset(data, Split=='1')
        best_first <- unique((subset(first_data, Value == max(first_data$Value)))$Model)
        
        zero_CRF = 0
        first_CRF = 0
        second_CRF = 0
        third_CRF = 0
        fourth_CRF = 0
        seq = 0
        
        CRF = 0
        
        for (i in 1:50){
          
          split_data <- subset(data, Split==as.character(i))
          best <- subset(split_data, Value == max(split_data$Value))
          
          if (best$Model == '0-CRF'){
            zero_CRF = zero_CRF + 1
            CRF = CRF + 1
          }
          
          if (best$Model == '1-CRF'){
            first_CRF = first_CRF + 1
            CRF = CRF + 1
          }
          
          if (best$Model == '2-CRF'){
            second_CRF = second_CRF + 1
            CRF = CRF + 1
          }
          
          if (best$Model == '3-CRF'){
            third_CRF = third_CRF + 1
            CRF = CRF + 1
          }
          
          if (best$Model == '4-CRF'){
            fourth_CRF = fourth_CRF + 1
            CRF = CRF + 1
          }
          
          if (best$Model == 'Seq2seq'){
            seq = seq + 1
          }}
        
        zero_CRF = zero_CRF * 100 / 50
        first_CRF = first_CRF * 100 / 50
        second_CRF = second_CRF * 100 / 50
        third_CRF = third_CRF * 100 / 50
        fourth_CRF = fourth_CRF * 100 / 50
        seq = seq * 100 / 50
        
        CRF = CRF * 100 / 50
        
        overall_best = 0
        
        if (max(zero_CRF, first_CRF, second_CRF, third_CRF, fourth_CRF, seq) == zero_CRF){
          overall_best = '0-CRF'
        }
        
        if (max(zero_CRF, first_CRF, second_CRF, third_CRF, fourth_CRF, seq) == first_CRF){
          overall_best = '1-CRF'
        }
        
        if (max(zero_CRF, first_CRF, second_CRF, third_CRF, fourth_CRF, seq) == second_CRF){
          overall_best = '2-CRF'
        }
        
        if (max(zero_CRF, first_CRF, second_CRF, third_CRF, fourth_CRF, seq) == third_CRF){
          overall_best = '3-CRF'
        }
        
        if (max(zero_CRF, first_CRF, second_CRF, third_CRF, fourth_CRF, seq) == fourth_CRF){
          overall_best = '4-CRF'
        }
        
        if (max(zero_CRF, first_CRF, second_CRF, third_CRF, fourth_CRF, seq) == seq){
          overall_best = 'Seq2seq'
        }
        
        proportion <- 0
        
        for (model in as.vector(models)){
          model_data <- subset(data, Model == model)
          data_mean <- mean(model_data$Value)
          data_min <- min(model_data$Value)
          data_max <- max(model_data$Value)
          data_variance <- data_max - data_min
          first_variance <- data_max - (subset(first_data, Model==model))$Value
          ave_diff <- data_mean - (subset(first_data, Model==model))$Value
          
          if (model=='Morfessor'){
            proportion <- 0
          }
          
          if (model=='0-CRF'){
            proportion <- zero_CRF
          }
          
          if (model=='1-CRF'){
            proportion <- first_CRF
          }
          
          if (model=='2-CRF'){
            proportion <- second_CRF
          }
          
          if (model=='3-CRF'){
            proportion <- third_CRF
          }
          
          if (model=='4-CRF'){
            proportion <- fourth_CRF
          }
          
          if (model=='Seq2seq'){
            proportion <- seq
          }
          
          
          
          if (model == best_first & model == overall_best){
            zulu_adversarial_details_info[nrow(zulu_adversarial_details_info) + 1, ] <- c(language, sample, replacement, metric, model, unique(subset(first_data, Model==model)$Value), model, overall_best, round(data_mean,2), round(data_min, 2), round(data_max,2), round(data_variance,2), round(first_variance,2), round(ave_diff,2), round(proportion,2))
          }
          
          if (model == best_first & model != overall_best){
            zulu_adversarial_details_info[nrow(zulu_adversarial_details_info) + 1, ] <- c(language, sample, replacement, metric, model, unique(subset(first_data, Model==model)$Value), model, 'None', round(data_mean,2), round(data_min, 2), round(data_max,2), round(data_variance,2), round(first_variance,2), round(ave_diff,2), round(proportion,2))
          }
          
          if (model != best_first & model == overall_best){
            zulu_adversarial_details_info[nrow(zulu_adversarial_details_info) + 1, ] <- c(language, sample, replacement, metric, model, unique(subset(first_data, Model==model)$Value), 'None', overall_best, round(data_mean,2), round(data_min, 2), round(data_max,2), round(data_variance,2), round(first_variance,2), round(ave_diff,2), round(proportion,2))
          }
          
          if (model != best_first & model != overall_best){
            zulu_adversarial_details_info[nrow(zulu_adversarial_details_info) + 1, ] <- c(language, sample, replacement, metric, model, unique(subset(first_data, Model==model)$Value), 'None', 'None', round(data_mean,2), round(data_min, 2), round(data_max,2), round(data_variance,2), round(first_variance,2), round(ave_diff,2), round(proportion,2))
          }
          
          
        }
      }
    }
  }



write.csv(zulu_adversarial_details_info, 'zulu_adversarial_details_info.txt',row.names=FALSE)


zulu_adversarial_details_info$Data_max <- as.numeric(zulu_adversarial_details_info$Data_max)
zulu_adversarial_details_info$Data_mean <- as.numeric(zulu_adversarial_details_info$Data_mean)
zulu_adversarial_details_info$Data_min <- as.numeric((zulu_adversarial_details_info$Data_min))
zulu_adversarial_details_info$Data_variance <- as.numeric((zulu_adversarial_details_info$Data_variance))
zulu_adversarial_details_info$First_variance <- as.numeric((zulu_adversarial_details_info$First_variance))
zulu_adversarial_details_info$Ave_diff <- as.numeric((zulu_adversarial_details_info$Ave_diff))
zulu_adversarial_details_info$Proportion <- as.numeric((zulu_adversarial_details_info$Proportion))

zulu_adversarial_details_info$Sample <- factor(zulu_adversarial_details_info$Sample,levels=c('500', '1000', '1500', '2000', '3000', '4000')) 


ggplot(subset(zulu_adversarial_details_info, Metric=='F1'),  aes(x=Data_variance, color=Replacement, fill=Replacement)) +
  geom_histogram(aes(y = ..density..), alpha=0.6, binwidth = 2) +
  scale_fill_manual(values=c("darkgrey", "darkgreen")) +
  scale_color_manual(values=c("darkgrey", "darkgreen")) +
  theme_classic() +
  theme(
    legend.position="none",
    panel.spacing = unit(0.8, "lines"),
    text = element_text(size=16, family="Times")
  ) +
  xlab("") +
  ylab("Density") +
  facet_grid(Replacement ~ Sample)

ggplot(subset(zulu_adversarial_details_info, Metric=='F1'),  aes(x=Ave_diff, color=Replacement, fill=Replacement)) +
  geom_histogram(aes(y = ..density..), alpha=0.6, binwidth = 2) +
  scale_fill_manual(values=c("darkblue", "darkred")) +
  scale_color_manual(values=c("darkblue", "darkred")) +
  theme_classic() +
  theme(
    legend.position="none",
    panel.spacing = unit(0.8, "lines"),
    text = element_text(size=16, family="Times")
  ) +
  #  xlim(-5, 4.8) +
  xlab("") +
  ylab("Density") +
  facet_grid(Replacement ~ Sample)


########### New test set sizes #################


zulu_with_500_50 <- read.csv('zul_seq2seq_test_with_500_50_results.txt', header = T, sep = ' ')
zulu_with_500_50$Size <- rep('500', nrow(zulu_with_500_50))
zulu_with_500_50$Replacement <- rep('with', nrow(zulu_with_500_50))

zulu_with_500_100 <- read.csv('zul_seq2seq_test_with_500_100_results.txt', header = T, sep = ' ')
zulu_with_500_100$Size <- rep('500', nrow(zulu_with_500_100))
zulu_with_500_100$Replacement <- rep('with', nrow(zulu_with_500_100))

zulu_with_500_500 <- read.csv('zul_seq2seq_test_with_500_500_results.txt', header = T, sep = ' ')
zulu_with_500_500$Size <- rep('5000', nrow(zulu_with_500_500))
zulu_with_500_500$Replacement <- rep('with', nrow(zulu_with_500_500))

zulu_with_500_1000 <- read.csv('zul_seq2seq_test_with_500_1000_results.txt', header = T, sep = ' ')
zulu_with_500_1000$Size <- rep('500', nrow(zulu_with_500_1000))
zulu_with_500_1000$Replacement <- rep('with', nrow(zulu_with_500_1000))

zulu_with_1000_50 <- read.csv('zul_seq2seq_test_with_1000_50_results.txt', header = T, sep = ' ')
zulu_with_1000_50$Size <- rep('1000', nrow(zulu_with_1000_50))
zulu_with_1000_50$Replacement <- rep('with', nrow(zulu_with_1000_50))

zulu_with_1000_100 <- read.csv('zul_seq2seq_test_with_1000_100_results.txt', header = T, sep = ' ')
zulu_with_1000_100$Size <- rep('1000', nrow(zulu_with_1000_100))
zulu_with_1000_100$Replacement <- rep('with', nrow(zulu_with_1000_100))

zulu_with_1000_500 <- read.csv('zul_seq2seq_test_with_1000_500_results.txt', header = T, sep = ' ')
zulu_with_1000_500$Size <- rep('1000', nrow(zulu_with_1000_500))
zulu_with_1000_500$Replacement <- rep('with', nrow(zulu_with_1000_500))

zulu_with_1000_1000 <- read.csv('zul_seq2seq_test_with_1000_1000_results.txt', header = T, sep = ' ')
zulu_with_1000_1000$Size <- rep('1000', nrow(zulu_with_1000_1000))
zulu_with_1000_1000$Replacement <- rep('with', nrow(zulu_with_1000_1000))

zulu_with_1500_50 <- read.csv('zul_seq2seq_test_with_1500_50_results.txt', header = T, sep = ' ')
zulu_with_1500_50$Size <- rep('1500', nrow(zulu_with_1500_50))
zulu_with_1500_50$Replacement <- rep('with', nrow(zulu_with_1500_50))

zulu_with_1500_100 <- read.csv('zul_seq2seq_test_with_1500_100_results.txt', header = T, sep = ' ')
zulu_with_1500_100$Size <- rep('1500', nrow(zulu_with_1500_100))
zulu_with_1500_100$Replacement <- rep('with', nrow(zulu_with_1500_100))

zulu_with_1500_500 <- read.csv('zul_seq2seq_test_with_1500_500_results.txt', header = T, sep = ' ')
zulu_with_1500_500$Size <- rep('1500', nrow(zulu_with_1500_500))
zulu_with_1500_500$Replacement <- rep('with', nrow(zulu_with_1500_500))

zulu_with_1500_1000 <- read.csv('zul_seq2seq_test_with_1500_1000_results.txt', header = T, sep = ' ')
zulu_with_1500_1000$Size <- rep('1500', nrow(zulu_with_1500_1000))
zulu_with_1500_1000$Replacement <- rep('with', nrow(zulu_with_1500_1000))

zulu_with_2000_50 <- read.csv('zul_seq2seq_test_with_2000_50_results.txt', header = T, sep = ' ')
zulu_with_2000_50$Size <- rep('2000', nrow(zulu_with_2000_50))
zulu_with_2000_50$Replacement <- rep('with', nrow(zulu_with_2000_50))

zulu_with_2000_100 <- read.csv('zul_seq2seq_test_with_2000_100_results.txt', header = T, sep = ' ')
zulu_with_2000_100$Size <- rep('2000', nrow(zulu_with_2000_100))
zulu_with_2000_100$Replacement <- rep('with', nrow(zulu_with_2000_100))

zulu_with_2000_500 <- read.csv('zul_seq2seq_test_with_2000_500_results.txt', header = T, sep = ' ')
zulu_with_2000_500$Size <- rep('2000', nrow(zulu_with_2000_500))
zulu_with_2000_500$Replacement <- rep('with', nrow(zulu_with_2000_500))

zulu_with_2000_1000 <- read.csv('zul_seq2seq_test_with_2000_1000_results.txt', header = T, sep = ' ')
zulu_with_2000_1000$Size <- rep('2000', nrow(zulu_with_2000_1000))
zulu_with_2000_1000$Replacement <- rep('with', nrow(zulu_with_2000_1000))

zulu_with_3000_50 <- read.csv('zul_seq2seq_test_with_3000_50_results.txt', header = T, sep = ' ')
zulu_with_3000_50$Size <- rep('3000', nrow(zulu_with_3000_50))
zulu_with_3000_50$Replacement <- rep('with', nrow(zulu_with_3000_50))

zulu_with_3000_100 <- read.csv('zul_seq2seq_test_with_3000_100_results.txt', header = T, sep = ' ')
zulu_with_3000_100$Size <- rep('3000', nrow(zulu_with_3000_100))
zulu_with_3000_100$Replacement <- rep('with', nrow(zulu_with_3000_100))

zulu_with_3000_500 <- read.csv('zul_seq2seq_test_with_3000_500_results.txt', header = T, sep = ' ')
zulu_with_3000_500$Size <- rep('3000', nrow(zulu_with_3000_500))
zulu_with_3000_500$Replacement <- rep('with', nrow(zulu_with_3000_500))

zulu_with_3000_1000 <- read.csv('zul_seq2seq_test_with_3000_1000_results.txt', header = T, sep = ' ')
zulu_with_3000_1000$Size <- rep('3000', nrow(zulu_with_3000_1000))
zulu_with_3000_1000$Replacement <- rep('with', nrow(zulu_with_3000_1000))

zulu_with_4000_50 <- read.csv('zul_seq2seq_test_with_4000_50_results.txt', header = T, sep = ' ')
zulu_with_4000_50$Size <- rep('4000', nrow(zulu_with_4000_50))
zulu_with_4000_50$Replacement <- rep('with', nrow(zulu_with_4000_50))

zulu_with_4000_100 <- read.csv('zul_seq2seq_test_with_4000_100_results.txt', header = T, sep = ' ')
zulu_with_4000_100$Size <- rep('4000', nrow(zulu_with_4000_100))
zulu_with_4000_100$Replacement <- rep('with', nrow(zulu_with_4000_100))

zulu_with_4000_500 <- read.csv('zul_seq2seq_test_with_4000_500_results.txt', header = T, sep = ' ')
zulu_with_4000_500$Size <- rep('4000', nrow(zulu_with_4000_500))
zulu_with_4000_500$Replacement <- rep('with', nrow(zulu_with_4000_500))

zulu_with_4000_1000 <- read.csv('zul_seq2seq_test_with_4000_1000_results.txt', header = T, sep = ' ')
zulu_with_4000_1000$Size <- rep('4000', nrow(zulu_with_4000_1000))
zulu_with_4000_1000$Replacement <- rep('with', nrow(zulu_with_4000_1000))

zulu_without_500_50 <- read.csv('zul_seq2seq_test_without_500_50_results.txt', header = T, sep = ' ')
zulu_without_500_50$Size <- rep('500', nrow(zulu_without_500_50))
zulu_without_500_50$Replacement <- rep('without', nrow(zulu_without_500_50))

zulu_without_500_100 <- read.csv('zul_seq2seq_test_without_500_100_results.txt', header = T, sep = ' ')
zulu_without_500_100$Size <- rep('500', nrow(zulu_without_500_100))
zulu_without_500_100$Replacement <- rep('without', nrow(zulu_without_500_100))

zulu_without_500_500 <- read.csv('zul_seq2seq_test_without_500_500_results.txt', header = T, sep = ' ')
zulu_without_500_500$Size <- rep('500', nrow(zulu_without_500_500))
zulu_without_500_500$Replacement <- rep('without', nrow(zulu_without_500_500))

zulu_without_500_1000 <- read.csv('zul_seq2seq_test_without_500_1000_results.txt', header = T, sep = ' ')
zulu_without_500_1000$Size <- rep('500', nrow(zulu_without_500_1000))
zulu_without_500_1000$Replacement <- rep('without', nrow(zulu_without_500_1000))

zulu_without_1000_50 <- read.csv('zul_seq2seq_test_without_1000_50_results.txt', header = T, sep = ' ')
zulu_without_1000_50$Size <- rep('1000', nrow(zulu_without_1000_50))
zulu_without_1000_50$Replacement <- rep('without', nrow(zulu_without_1000_50))

zulu_without_1000_100 <- read.csv('zul_seq2seq_test_without_1000_100_results.txt', header = T, sep = ' ')
zulu_without_1000_100$Size <- rep('1000', nrow(zulu_without_1000_100))
zulu_without_1000_100$Replacement <- rep('without', nrow(zulu_without_1000_100))

zulu_without_1000_500 <- read.csv('zul_seq2seq_test_without_1000_500_results.txt', header = T, sep = ' ')
zulu_without_1000_500$Size <- rep('1000', nrow(zulu_without_1000_500))
zulu_without_1000_500$Replacement <- rep('without', nrow(zulu_without_1000_500))

zulu_without_1000_1000 <- read.csv('zul_seq2seq_test_without_1000_1000_results.txt', header = T, sep = ' ')
zulu_without_1000_1000$Size <- rep('1000', nrow(zulu_without_1000_1000))
zulu_without_1000_1000$Replacement <- rep('without', nrow(zulu_without_1000_1000))

zulu_without_1500_50 <- read.csv('zul_seq2seq_test_without_1500_50_results.txt', header = T, sep = ' ')
zulu_without_1500_50$Size <- rep('1500', nrow(zulu_without_1500_50))
zulu_without_1500_50$Replacement <- rep('without', nrow(zulu_without_1500_50))

zulu_without_1500_100 <- read.csv('zul_seq2seq_test_without_1500_100_results.txt', header = T, sep = ' ')
zulu_without_1500_100$Size <- rep('1500', nrow(zulu_without_1500_100))
zulu_without_1500_100$Replacement <- rep('without', nrow(zulu_without_1500_100))

zulu_without_1500_500 <- read.csv('zul_seq2seq_test_without_1500_500_results.txt', header = T, sep = ' ')
zulu_without_1500_500$Size <- rep('1500', nrow(zulu_without_1500_500))
zulu_without_1500_500$Replacement <- rep('without', nrow(zulu_without_1500_500))

zulu_without_1500_1000 <- read.csv('zul_seq2seq_test_without_1500_1000_results.txt', header = T, sep = ' ')
zulu_without_1500_1000$Size <- rep('1500', nrow(zulu_without_1500_1000))
zulu_without_1500_1000$Replacement <- rep('without', nrow(zulu_without_1500_1000))

zulu_without_2000_50 <- read.csv('zul_seq2seq_test_without_2000_50_results.txt', header = T, sep = ' ')
zulu_without_2000_50$Size <- rep('2000', nrow(zulu_without_2000_50))
zulu_without_2000_50$Replacement <- rep('without', nrow(zulu_without_2000_50))

zulu_without_2000_100 <- read.csv('zul_seq2seq_test_without_2000_100_results.txt', header = T, sep = ' ')
zulu_without_2000_100$Size <- rep('2000', nrow(zulu_without_2000_100))
zulu_without_2000_100$Replacement <- rep('without', nrow(zulu_without_2000_100))

zulu_without_2000_500 <- read.csv('zul_seq2seq_test_without_2000_500_results.txt', header = T, sep = ' ')
zulu_without_2000_500$Size <- rep('2000', nrow(zulu_without_2000_500))
zulu_without_2000_500$Replacement <- rep('without', nrow(zulu_without_2000_500))

zulu_without_2000_1000 <- read.csv('zul_seq2seq_test_without_2000_1000_results.txt', header = T, sep = ' ')
zulu_without_2000_1000$Size <- rep('2000', nrow(zulu_without_2000_1000))
zulu_without_2000_1000$Replacement <- rep('without', nrow(zulu_without_2000_1000))

zulu_without_3000_50 <- read.csv('zul_seq2seq_test_without_3000_50_results.txt', header = T, sep = ' ')
zulu_without_3000_50$Size <- rep('3000', nrow(zulu_without_3000_50))
zulu_without_3000_50$Replacement <- rep('without', nrow(zulu_without_3000_50))

zulu_without_3000_100 <- read.csv('zul_seq2seq_test_without_3000_100_results.txt', header = T, sep = ' ')
zulu_without_3000_100$Size <- rep('3000', nrow(zulu_without_3000_100))
zulu_without_3000_100$Replacement <- rep('without', nrow(zulu_without_3000_100))

zulu_without_3000_500 <- read.csv('zul_seq2seq_test_without_3000_500_results.txt', header = T, sep = ' ')
zulu_without_3000_500$Size <- rep('3000', nrow(zulu_without_3000_500))
zulu_without_3000_500$Replacement <- rep('without', nrow(zulu_without_3000_500))

zulu_without_3000_1000 <- read.csv('zul_seq2seq_test_without_3000_1000_results.txt', header = T, sep = ' ')
zulu_without_3000_1000$Size <- rep('3000', nrow(zulu_without_3000_1000))
zulu_without_3000_1000$Replacement <- rep('without', nrow(zulu_without_3000_1000))

zulu_without_4000_50 <- read.csv('zul_seq2seq_test_without_4000_50_results.txt', header = T, sep = ' ')
zulu_without_4000_50$Size <- rep('4000', nrow(zulu_without_4000_50))
zulu_without_4000_50$Replacement <- rep('without', nrow(zulu_without_4000_50))

zulu_without_4000_100 <- read.csv('zul_seq2seq_test_without_4000_100_results.txt', header = T, sep = ' ')
zulu_without_4000_100$Size <- rep('4000', nrow(zulu_without_4000_100))
zulu_without_4000_100$Replacement <- rep('without', nrow(zulu_without_4000_100))

zulu_without_4000_500 <- read.csv('zul_seq2seq_test_without_4000_500_results.txt', header = T, sep = ' ')
zulu_without_4000_500$Size <- rep('4000', nrow(zulu_without_4000_500))
zulu_without_4000_500$Replacement <- rep('without', nrow(zulu_without_4000_500))

zulu_without_4000_1000 <- read.csv('zul_seq2seq_test_without_4000_1000_results.txt', header = T, sep = ' ')
zulu_without_4000_1000$Size <- rep('4000', nrow(zulu_without_4000_1000))
zulu_without_4000_1000$Replacement <- rep('without', nrow(zulu_without_4000_1000))


zulu_500 <- rbind(zulu_with_500_50, zulu_with_500_100, zulu_without_500_50, zulu_without_500_100)
zulu_1000 <- rbind(zulu_with_1000_50, zulu_with_1000_100, zulu_without_1000_50, zulu_without_1000_100)
zulu_1500 <- rbind(zulu_with_1500_50, zulu_with_1500_100, zulu_without_1500_50, zulu_without_1500_100)
zulu_2000 <- rbind(zulu_with_2000_50, zulu_with_2000_100, zulu_without_2000_50, zulu_without_2000_100)
zulu_3000 <- rbind(zulu_with_3000_50, zulu_with_3000_100, zulu_without_3000_50, zulu_without_3000_100)
zulu_4000 <- rbind(zulu_with_4000_50, zulu_with_4000_100, zulu_without_4000_50, zulu_without_4000_100)
zulu_test <- rbind(zulu_500, zulu_1000, zulu_1500, zulu_2000, zulu_3000, zulu_4000)


### F1
### 500, 50, with: min 47.8; max 87.33
### 500, 50, without: min 45.04; max 90.06
### 500, 100, with: min 53.15; max 84.1
### 500, 100, without: min 53.18; max 85.28
### 1000, 50, with: min 48.74; max 89.43
### 1000, 50, without: min 53.46; max 91.54
### 1000, 100, with: min 52.63; max 84.04
### 1000, 100, without: min 60.67; max 90.08

ggplot(zulu_test, aes(x = Recall, color = Replacement)) +
  geom_density() + 
  facet_grid(Sample_size ~ Size) +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times"),
        axis.text.x=element_text(size=15),
        axis.text.y=element_text(size=15)) + 
  theme(legend.position="top") +
  labs(fill = "") +
  ggtitle('Zulu test Recall')



zulu_500_p <-
  ggplot(subset(zulu_500, Sample_size %in% c('50', '100')), aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('500')

zulu_1000_p <-
  ggplot(zulu_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('1000')


zulu_1500_p <-
  ggplot(zulu_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('1500')

zulu_2000_p <-
  ggplot(zulu_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('2000')

zulu_3000_p <-
  ggplot(zulu_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('3000')

zulu_4000_p <-
  ggplot(zulu_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('4000')


grid.arrange(zulu_500_p, zulu_1000_p, zulu_1500_p, zulu_2000_p, zulu_3000_p, zulu_4000_p, ncol = 2, nrow = 3)


zulu_compare <- data.frame(Size=character(), Sample_size=character(), Replacement=character(), Mean=numeric(), Variance=numeric()) 

sizes = unique(as.vector(zulu_test$Size))
sample_sizes = unique(as.vector(zulu_test$Sample_size))

for (size in sizes){
  for (sample_size in sample_sizes){
    for (replacement in c('with', 'without')){
      data <- subset(zulu_test, Size==size & Sample_size==sample_size & Replacement=='with')
      mean <- mean(data$F1)
      min <- min(data$F1)
      max <- max(data$F1)
      
      zulu_compare[nrow(zulu_compare) + 1, ] <- c(size, sample_size, replacement, mean, max-min)
      print(c(size, sample_size, replacement, mean, max-min))
    }
  }
}



####### Studying the effects of data characteristics / heuristics #######
####### For new test sets ############


zulu_new_test_heuristics <- read.csv('zulu_new_test_heuristics.txt', header = T, sep = '\t')
zulu_test <- zulu_with_500_100

samples = unique(zulu_new_test_heuristics$Sample)

language <- unique(zulu_new_test_heuristics$Language)

df <- data.frame(Language=character(), Sample=character(), Replacement=character(), Metric=character(), Feature=character(),Spearman=numeric(),Pearson=numeric())

for (sample in as.vector(samples)){
  for (replacement in c('with', 'without')){
    for (feature in c('morph_overlap', 'unique_word_type_ratio', 'unique_morph_type_ratio',
                      'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
      
      heuristics <- subset(zulu_new_test_heuristics, Feature == feature & Sample == sample & Replacement == replacement)
      results <- subset(zulu_test, Size == sample & Replacement == replacement)
      together = cbind(results, heuristics)
      accuracy_spearman_c = cor(together$Accuracy, together$Value, method = c('spearman'))
      accuracy_pearson_c = cor(together$Accuracy, together$Value, method = c('pearson'))
      df[nrow(df) + 1, ] <- c(language, sample, replacement, 'Accuracy', feature, accuracy_spearman_c, accuracy_pearson_c)
      
      Precision_spearman_c = cor(together$Precision, together$Value, method = c('spearman'))
      Precision_pearson_c = cor(together$Precision, together$Value, method = c('pearson'))
      df[nrow(df) + 1, ] <- c(language, sample, replacement, 'Precision', feature, accuracy_spearman_c, accuracy_pearson_c)
      
      Recall_spearman_c = cor(together$Recall, together$Value, method = c('spearman'))
      Recall_pearson_c = cor(together$Recall, together$Value, method = c('pearson'))
      df[nrow(df) + 1, ] <- c(language, sample, replacement, 'Recall', feature, accuracy_spearman_c, accuracy_pearson_c)
      
      F1_spearman_c = cor(together$F1, together$Value, method = c('spearman'))
      F1_pearson_c = cor(together$F1, together$Value, method = c('pearson'))
      df[nrow(df) + 1, ] <- c(language, sample, replacement, 'F1', feature, accuracy_spearman_c, accuracy_pearson_c)
      
      Distance_spearman_c = cor(together$Distance, together$Value, method = c('spearman'))
      Distance_pearson_c = cor(together$Distance, together$Value, method = c('pearson'))
      df[nrow(df) + 1, ] <- c(language, sample, replacement, 'Distance', feature, accuracy_spearman_c, accuracy_pearson_c)
      
    }}}

#df <- subset(df, Model != 'Morfessor')

write.csv(df, 'zulu_new_test_corr.txt',row.names=FALSE)



##################################
########### Indonesian ###########
##################################

indonesian <- read.csv('indonesian.txt', header = T, sep = '\t')
indonesian$Language <- rep('indonesian', nrow(indonesian))

indonesian <- subset(indonesian, Index %in% c('Same best model', 'Same model ranking', 'A best model', 'A best model ranking'))
indonesian$Index[indonesian$Index == 'Same model ranking'] <- 'Same ranking'
indonesian$Index[indonesian$Index == 'A best model ranking'] <- 'A best ranking'
indonesian$Index <- factor(indonesian$Index, levels = c('Same best model', 
                                                  'Same ranking', 
                                                  'A best model', 
                                                  'A best ranking'))

indonesian_p <-
  ggplot(subset(indonesian, Metric == 'F1'&Index %in% c('Same best model', 'Same ranking')), aes(Index, Proportion, fill = Index)) +
  geom_bar(stat = 'identity', alpha = 0.8) +
  geom_text(aes(label=paste(Proportion, '%')), vjust=-1, color="black", size=6)+
  scale_fill_manual(values = c("steelblue", "mediumpurple4")) + #, "darkgreen", "peru")) +
  facet_grid(Replacement ~ Size) +
  
  theme_classic() + 
  theme(text = element_text(size=30, family="Times"),
        axis.text.x=element_blank(),
        axis.text.y=element_text(size=30)) + 
  theme(legend.position="top") +
  ylim(c(0, 100)) +
  xlab("") + 
  ylab("Proportion (%)") +
  guides(fill = guide_legend(nrow = 1)) +
  labs(fill = "") +
  ggtitle('Indonesian')


########## Select one language to plot different models ###############

indonesian_details <- read.csv('indonesian_details.txt', header = T, sep = '\t')
indonesian_details <- subset(indonesian_details, Model != 'Morfessor')
indonesian_details <- subset(indonesian_details, Size == 500 & Metric == 'F1') # & Replacement == 'with')


indonesian_details %>%
  ggplot(aes(Split, Value, group = Model, color = Model)) +
  geom_line(aes(linetype=Model), alpha = 1) +
  scale_color_manual(values = c("steelblue", "peru", "darkgreen", "darkgrey", "mediumpurple4", "darkred", "black")) +
  scale_x_continuous(breaks=seq(1, 51, 5)) +
  facet_grid( ~ Replacement) +
  theme_classic() + 
  theme(text = element_text(size=16, family="Times")) + 
  theme(legend.position="top") +
  xlab("Data set") + 
  ylab("F1") + 
  xlim(c(1,50)) +
  guides(linetype = guide_legend(nrow = 2)) +
  ggtitle('indonesian 500 F1')


####### Studying the effects of data characteristics / heuristics #######
####### For original train / test random splits #########

indonesian_heuristics <- read.csv('ind_heuristics.txt', header = T, sep = '\t')
indonesian_full <- read.csv('indonesian_full.txt', header = T, sep = '\t')

samples = unique(indonesian_heuristics$Sample)

language <- unique(indonesian_heuristics$Language)

indonesian_df <- data.frame(Language=character(), Sample=character(), Replacement=character(), Metric=character(), Model=character(), Feature=character(), Coef=numeric(), Q2.5=numeric(), Q97.5=numeric()) #Spearman=numeric(),Pearson=numeric())

for (sample in as.vector(samples)){
  for (replacement in c('with', 'without')){
    for (metric in c('Accuracy', 'Precision', 'Recall', 'F1', 'Avg. Distance')){
      for (model in c('Morfessor', '0-CRF', '1-CRF', '2-CRF', '3-CRF', '4-CRF', 'Seq2seq')){
        for (feature in c('word_overlap', 'morph_overlap', 'unique_word_type_ratio', 'unique_morph_type_ratio',
                          'ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
          
          heuristics <- subset(indonesian_heuristics, Feature == feature & Sample == sample & Replacement == replacement)
          results <- subset(indonesian_full, Metric == metric & Model == model & Size == sample & Replacement == replacement)
          together = cbind(results, heuristics)
          spearman_c = cor(together$Score, together$Value, method = c('spearman'))
       #   pearson_c = cor(together$Score, together$Value, method = c('pearson'))
          
          coef = 'NONE'
          q2.5 = 'NONE'
          q97.5 = 'NONE'
          
          if (!is.na(spearman_c) & (spearman_c >= 0.1 | spearman_c <= -0.1)){
            
            regression <- brm(Score ~ Value,
                              data=together,
                              warmup=200,
                              iter = 1000,
                              chains = 4,
                              inits="random",
                              prior=prior,
                              control = list(adapt_delta = 0.99),
                              cores = 1)
            
            summary <- data.frame(fixef(regression))
            coef = summary$Estimate[2]
            q2.5 = summary$Q2.5[2]
            q97.5 = summary$Q97.5[2]
            
          }
         
          indonesian_df[nrow(indonesian_df) + 1, ] <- c(language, sample, replacement, metric, model, feature, coef, q2.5, q97.5)
          
        }}}}}

#df <- subset(df, Model != 'Morfessor')

write.csv(indonesian_df, 'indonesian_corr.txt',row.names=FALSE)


ggplot(subset(indonesian_df, Sample=='1000'&Replacement=='without'), aes(Feature, round(as.numeric(Spearman),2), fill = Feature)) +
  geom_bar(stat = 'identity', alpha = 0.8) +
  #  scale_fill_manual(values = c("steelblue", "mediumpurple4", "darkgreen", "peru")) +
  facet_grid(Model ~ Metric) +
  #    facet_grid(vars(Replacement)) +
  theme_classic() + 
  theme(text = element_text(size=10, family="Times"),
        axis.text.x=element_blank(),
        axis.text.y=element_text(size=10)) + 
  theme(legend.position="top") +
  ylim(c(-1, 1)) +
  ylab("Spearman") +
  guides(fill = guide_legend(nrow = 2)) +
  labs(fill = "") +
  ggtitle('indonesian heuristics 1000 without')



###### Studying whether data could be split by heuristics or adversarial training ####

indonesian_split_len <- read.csv('ind_split_len.txt', header = T, sep = '\t')

### 0 data set splittable by average number of morphemes ###

indonesian_split_adv <- read.csv('ind_split_adv.txt', header = T, sep = '\t')


a<-subset(indonesian_split_adv,Sample=='500'&Replacement=='without' & Split != 'EVERYTHING')
hist(a$Overlap,main='indonesian 1000 without',xlim=c(0,100))



########### New test set sizes #################


indonesian_with_500_50 <- read.csv('ind_crf_test_with_500_50_results.txt', header = T, sep = ' ')
indonesian_with_500_50$Size <- rep('500', nrow(indonesian_with_500_50))
indonesian_with_500_50$Replacement <- rep('with', nrow(indonesian_with_500_50))

indonesian_with_500_100 <- read.csv('ind_crf_test_with_500_100_results.txt', header = T, sep = ' ')
indonesian_with_500_100$Size <- rep('500', nrow(indonesian_with_500_100))
indonesian_with_500_100$Replacement <- rep('with', nrow(indonesian_with_500_100))

indonesian_with_500_500 <- read.csv('ind_crf_test_with_500_500_results.txt', header = T, sep = ' ')
indonesian_with_500_500$Size <- rep('5000', nrow(indonesian_with_500_500))
indonesian_with_500_500$Replacement <- rep('with', nrow(indonesian_with_500_500))

indonesian_with_1000_50 <- read.csv('ind_crf_test_with_1000_50_results.txt', header = T, sep = ' ')
indonesian_with_1000_50$Size <- rep('1000', nrow(indonesian_with_1000_50))
indonesian_with_1000_50$Replacement <- rep('with', nrow(indonesian_with_1000_50))

indonesian_with_1000_100 <- read.csv('ind_crf_test_with_1000_100_results.txt', header = T, sep = ' ')
indonesian_with_1000_100$Size <- rep('1000', nrow(indonesian_with_1000_100))
indonesian_with_1000_100$Replacement <- rep('with', nrow(indonesian_with_1000_100))

indonesian_with_1000_500 <- read.csv('ind_crf_test_with_1000_500_results.txt', header = T, sep = ' ')
indonesian_with_1000_500$Size <- rep('1000', nrow(indonesian_with_1000_500))
indonesian_with_1000_500$Replacement <- rep('with', nrow(indonesian_with_1000_500))

indonesian_with_1500_50 <- read.csv('ind_crf_test_with_1500_50_results.txt', header = T, sep = ' ')
indonesian_with_1500_50$Size <- rep('1500', nrow(indonesian_with_1500_50))
indonesian_with_1500_50$Replacement <- rep('with', nrow(indonesian_with_1500_50))

indonesian_with_1500_100 <- read.csv('ind_crf_test_with_1500_100_results.txt', header = T, sep = ' ')
indonesian_with_1500_100$Size <- rep('1500', nrow(indonesian_with_1500_100))
indonesian_with_1500_100$Replacement <- rep('with', nrow(indonesian_with_1500_100))

indonesian_with_1500_500 <- read.csv('ind_crf_test_with_1500_500_results.txt', header = T, sep = ' ')
indonesian_with_1500_500$Size <- rep('1500', nrow(indonesian_with_1500_500))
indonesian_with_1500_500$Replacement <- rep('with', nrow(indonesian_with_1500_500))

indonesian_with_2000_50 <- read.csv('ind_seq2seq_test_with_2000_50_results.txt', header = T, sep = ' ')
indonesian_with_2000_50$Size <- rep('2000', nrow(indonesian_with_2000_50))
indonesian_with_2000_50$Replacement <- rep('with', nrow(indonesian_with_2000_50))

indonesian_with_2000_100 <- read.csv('ind_seq2seq_test_with_2000_100_results.txt', header = T, sep = ' ')
indonesian_with_2000_100$Size <- rep('2000', nrow(indonesian_with_2000_100))
indonesian_with_2000_100$Replacement <- rep('with', nrow(indonesian_with_2000_100))

indonesian_with_2000_500 <- read.csv('ind_seq2seq_test_with_2000_500_results.txt', header = T, sep = ' ')
indonesian_with_2000_500$Size <- rep('2000', nrow(indonesian_with_2000_500))
indonesian_with_2000_500$Replacement <- rep('with', nrow(indonesian_with_2000_500))

indonesian_with_3000_50 <- read.csv('ind_seq2seq_test_with_3000_50_results.txt', header = T, sep = ' ')
indonesian_with_3000_50$Size <- rep('3000', nrow(indonesian_with_3000_50))
indonesian_with_3000_50$Replacement <- rep('with', nrow(indonesian_with_3000_50))

indonesian_with_3000_100 <- read.csv('ind_seq2seq_test_with_3000_100_results.txt', header = T, sep = ' ')
indonesian_with_3000_100$Size <- rep('3000', nrow(indonesian_with_3000_100))
indonesian_with_3000_100$Replacement <- rep('with', nrow(indonesian_with_3000_100))

indonesian_with_3000_500 <- read.csv('ind_seq2seq_test_with_3000_500_results.txt', header = T, sep = ' ')
indonesian_with_3000_500$Size <- rep('3000', nrow(indonesian_with_3000_500))
indonesian_with_3000_500$Replacement <- rep('with', nrow(indonesian_with_3000_500))

indonesian_without_500_50 <- read.csv('ind_crf_test_without_500_50_results.txt', header = T, sep = ' ')
indonesian_without_500_50$Size <- rep('500', nrow(indonesian_without_500_50))
indonesian_without_500_50$Replacement <- rep('without', nrow(indonesian_without_500_50))

indonesian_without_500_100 <- read.csv('ind_crf_test_without_500_100_results.txt', header = T, sep = ' ')
indonesian_without_500_100$Size <- rep('500', nrow(indonesian_without_500_100))
indonesian_without_500_100$Replacement <- rep('without', nrow(indonesian_without_500_100))

indonesian_without_500_500 <- read.csv('ind_crf_test_without_500_500_results.txt', header = T, sep = ' ')
indonesian_without_500_500$Size <- rep('500', nrow(indonesian_without_500_500))
indonesian_without_500_500$Replacement <- rep('without', nrow(indonesian_without_500_500))

indonesian_without_1000_50 <- read.csv('ind_crf_test_without_1000_50_results.txt', header = T, sep = ' ')
indonesian_without_1000_50$Size <- rep('1000', nrow(indonesian_without_1000_50))
indonesian_without_1000_50$Replacement <- rep('without', nrow(indonesian_without_1000_50))

indonesian_without_1000_100 <- read.csv('ind_crf_test_without_1000_100_results.txt', header = T, sep = ' ')
indonesian_without_1000_100$Size <- rep('1000', nrow(indonesian_without_1000_100))
indonesian_without_1000_100$Replacement <- rep('without', nrow(indonesian_without_1000_100))

indonesian_without_1000_500 <- read.csv('ind_crf_test_without_1000_500_results.txt', header = T, sep = ' ')
indonesian_without_1000_500$Size <- rep('1000', nrow(indonesian_without_1000_500))
indonesian_without_1000_500$Replacement <- rep('without', nrow(indonesian_without_1000_500))

indonesian_without_1500_50 <- read.csv('ind_crf_test_without_1500_50_results.txt', header = T, sep = ' ')
indonesian_without_1500_50$Size <- rep('1500', nrow(indonesian_without_1500_50))
indonesian_without_1500_50$Replacement <- rep('without', nrow(indonesian_without_1500_50))

indonesian_without_1500_100 <- read.csv('ind_crf_test_without_1500_100_results.txt', header = T, sep = ' ')
indonesian_without_1500_100$Size <- rep('1500', nrow(indonesian_without_1500_100))
indonesian_without_1500_100$Replacement <- rep('without', nrow(indonesian_without_1500_100))

indonesian_without_1500_500 <- read.csv('ind_crf_test_without_1500_500_results.txt', header = T, sep = ' ')
indonesian_without_1500_500$Size <- rep('1500', nrow(indonesian_without_1500_500))
indonesian_without_1500_500$Replacement <- rep('without', nrow(indonesian_without_1500_500))

indonesian_without_2000_50 <- read.csv('ind_crf_test_without_2000_50_results.txt', header = T, sep = ' ')
indonesian_without_2000_50$Size <- rep('2000', nrow(indonesian_without_2000_50))
indonesian_without_2000_50$Replacement <- rep('without', nrow(indonesian_without_2000_50))

indonesian_without_2000_100 <- read.csv('ind_crf_test_without_2000_100_results.txt', header = T, sep = ' ')
indonesian_without_2000_100$Size <- rep('2000', nrow(indonesian_without_2000_100))
indonesian_without_2000_100$Replacement <- rep('without', nrow(indonesian_without_2000_100))

indonesian_without_2000_500 <- read.csv('ind_crf_test_without_2000_500_results.txt', header = T, sep = ' ')
indonesian_without_2000_500$Size <- rep('2000', nrow(indonesian_without_2000_500))
indonesian_without_2000_500$Replacement <- rep('without', nrow(indonesian_without_2000_500))

indonesian_without_3000_50 <- read.csv('ind_seq2seq_test_without_3000_50_results.txt', header = T, sep = ' ')
indonesian_without_3000_50$Size <- rep('3000', nrow(indonesian_without_3000_50))
indonesian_without_3000_50$Replacement <- rep('without', nrow(indonesian_without_3000_50))

indonesian_without_3000_100 <- read.csv('ind_seq2seq_test_without_3000_100_results.txt', header = T, sep = ' ')
indonesian_without_3000_100$Size <- rep('3000', nrow(indonesian_without_3000_100))
indonesian_without_3000_100$Replacement <- rep('without', nrow(indonesian_without_3000_100))

indonesian_without_3000_500 <- read.csv('ind_seq2seq_test_without_3000_500_results.txt', header = T, sep = ' ')
indonesian_without_3000_500$Size <- rep('3000', nrow(indonesian_without_3000_500))
indonesian_without_3000_500$Replacement <- rep('without', nrow(indonesian_without_3000_500))

indonesian_500 <- rbind(indonesian_with_500_50, indonesian_with_500_100, indonesian_with_500_500, indonesian_without_500_50, indonesian_without_500_100, indonesian_without_500_500)
indonesian_1000 <- rbind(indonesian_with_1000_50, indonesian_with_1000_100, indonesian_with_1000_500, indonesian_without_1000_50, indonesian_without_1000_100, indonesian_without_1000_500)
indonesian_1500 <- rbind(indonesian_with_1500_50, indonesian_with_1500_100, indonesian_with_1500_500, indonesian_without_1500_50, indonesian_without_1500_100, indonesian_without_1500_500)
indonesian_2000 <- rbind(indonesian_with_2000_50, indonesian_with_2000_100, indonesian_with_2000_500, indonesian_without_2000_50, indonesian_without_2000_100, indonesian_without_2000_500)
indonesian_3000 <- rbind(indonesian_with_3000_50, indonesian_with_3000_100, indonesian_with_3000_500, indonesian_without_3000_50, indonesian_without_3000_100, indonesian_without_3000_500)
indonesian_test <- rbind(indonesian_500, indonesian_1000, indonesian_1500, indonesian_2000, indonesian_3000)


### F1
### 500, 50, with: min 47.8; max 87.33
### 500, 50, without: min 45.04; max 90.06
### 500, 100, with: min 53.15; max 84.1
### 500, 100, without: min 53.18; max 85.28
### 1000, 50, with: min 48.74; max 89.43
### 1000, 50, without: min 53.46; max 91.54
### 1000, 100, with: min 52.63; max 84.04
### 1000, 100, without: min 60.67; max 90.08

ggplot(indonesian_test, aes(x = Recall, color = Replacement)) +
  geom_density() + 
  facet_grid(Sample_size ~ Size) +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times"),
        axis.text.x=element_text(size=15),
        axis.text.y=element_text(size=15)) + 
  theme(legend.position="top") +
  labs(fill = "") +
  ggtitle('Indonesian test Recall')



indonesian_500_p <-
  ggplot(subset(indonesian_500, Sample_size %in% c('50', '100')), aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('500')

indonesian_1000_p <-
  ggplot(indonesian_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('1000')


indonesian_1500_p <-
  ggplot(indonesian_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('1500')

indonesian_2000_p <-
  ggplot(indonesian_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('2000')

indonesian_3000_p <-
  ggplot(indonesian_1000, aes(x = F1, color = Replacement)) +
  geom_density() +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  facet_grid( ~ Sample_size) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times")) +
  theme(legend.position="top") +
  ylab("Density") +
  ggtitle('3000')



grid.arrange(indonesian_500_p, indonesian_1000_p, indonesian_1500_p, indonesian_2000_p, indonesian_3000_p, indonesian_4000_p, ncol = 2, nrow = 3)



####### Studying the effects of data characteristics / heuristics #######
####### For new test sets ############


indonesian_new_test_heuristics <- read.csv('ind_new_test_heuristics.txt', header = T, sep = '\t')

temp <- subset(indonesian_test, select = -c(Precision, Recall, F1, Distance))
names(temp) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp$Metric <- rep('Accuracy', nrow(temp))

temp1 <- subset(indonesian_test, select = -c(Accuracy, Recall, F1, Distance))
names(temp1) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp1$Metric <- rep('Precision', nrow(temp1))

temp2 <- subset(indonesian_test, select = -c(Accuracy, Precision, F1, Distance))
names(temp2) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp2$Metric <- rep('Recall', nrow(temp2))

temp3 <- subset(indonesian_test, select = -c(Accuracy, Precision, Recall, Distance))
names(temp3) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp3$Metric <- rep('F1', nrow(temp3))

temp4 <- subset(indonesian_test, select = -c(Accuracy, Precision, Recall, F1))
names(temp4) <- c('Split', 'N', 'Score', 'Copy', 'Sample_size', 'Size', 'Replacement')
temp4$Metric <- rep('Distance', nrow(temp4))

indonesian_full <- rbind(temp, temp1, temp2, temp3, temp4)

samples = unique(indonesian_new_test_heuristics$Sample)

language <- unique(indonesian_new_test_heuristics$Language)

together = 0


for (sample in as.vector(samples)){
  for (sample_size in as.vector(unique(indonesian_full$Sample_size))){
    for (split in as.vector(unique(indonesian_full$Split))){
      for (replacement in as.vector(unique(indonesian_new_test_heuristics$Replacement))){
        for (metric in c('Accuracy', 'Precision', 'Recall', 'F1', 'Avg. Distance')){
          results <- subset(indonesian_full, Sample_size == sample_size & Split == split & Size == sample & Replacement == replacement)
          new_test_heuristics <- subset(indonesian_new_test_heuristics, Test_size == sample_size & Split == split & Feature == 'morph_overlap' & Sample == sample & Replacement == replacement)
          new_test_heuristics <- subset(new_test_heuristics, select = -Feature)
          names(new_test_heuristics) <- c('Language', 'Sample', 'Replacement', 'Split', 'Test_size', 'Test_id', 'Set', 'morph_overlap', 'Caveat')
          
          for (feature in c('ave_num_morph_ratio', 'dist_ave_num_morph', 'ave_morph_len_ratio')){
            
            if (feature == 'ave_num_morph_ratio'){
              new_test_heuristics$ave_num_morph_ratio <- subset(indonesian_new_test_heuristics, Test_size == sample_size & Split == split & Feature == feature & Sample == sample & Replacement == replacement)$Value
            }
            
            if (feature == 'dist_ave_num_morph'){
              new_test_heuristics$dist_ave_num_morph <- subset(indonesian_new_test_heuristics, Test_size == sample_size & Split == split & Feature == feature & Sample == sample & Replacement == replacement)$Value
            }
            
            if (feature == 'ave_morph_len_ratio'){
              new_test_heuristics$ave_morph_len_ratio <- subset(indonesian_new_test_heuristics, Test_size == sample_size & Split == split & Feature == feature & Sample == sample & Replacement == replacement)$Value
            }
            
          }
          
          together <- rbind(together, cbind(results, new_test_heuristics))
          
          
        }}}}}

together <- subset(together, Language != 0)
together$Sample <- as.numeric(together$Sample)

together$morph_overlap <- together$morph_overlap / 100

regression <- lm(Score ~ (morph_overlap + ave_num_morph_ratio + dist_ave_num_morph + ave_morph_len_ratio)*Replacement + (morph_overlap + ave_num_morph_ratio + dist_ave_num_morph + ave_morph_len_ratio)*Sample + (morph_overlap + ave_num_morph_ratio + dist_ave_num_morph + ave_morph_len_ratio)*Test_size + Metric, data = together)

summary <- data.frame(summary(regression)$coef)
summary$Factor <- rownames(summary)

indonesian_df <- data.frame(Language=character(), Factor=character(), Coef=numeric(), Q2.5=numeric(), Q97.5=numeric()) 


for (factor in as.vector(summary$Factor)){
  print(factor)
  coef = subset(summary, Factor == factor)$Estimate
  ci = data.frame(confint(regression, factor, level = 0.95))
  q2.5 = ci$X2.5..[1]
  q97.5 = ci$X97.5..[1]
  print(typeof(factor))
  indonesian_df[nrow(indonesian_df) + 1, ] <- c('indonesian', as.character(factor), round(coef, 2), round(q2.5, 2), round(q97.5, 2))
  write.csv(indonesian_df, 'indonesian_corr_new_test.txt', row.names = FALSE)
  
}

indonesian_df$Factor<-summary$Factor
indonesian_df$P_value<-summary$Pr...t..
indonesian_df$Language<-rep('indonesian',nrow(indonesian_df))

write.csv(indonesian_df, 'indonesian_corr_new_test.txt', row.names = FALSE)





########## Plotting every language ###############

get_legend<-function(myggplot){
  tmp <- ggplot_gtable(ggplot_build(myggplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)
}


#### Overall look at all languages ####

all_details <- rbind(mayo_details, nahuatl_details, wixarika_details, german_details, english_details, persian_details, russian_details, turkish_details, finnish_details, zulu_details, indonesian_details)

all_details$Value <- as.numeric(all_details$Value)

languages = unique(all_details$Language)
models = unique(all_details$Model)
metrics = unique(all_details$Metric)

details_info <- data.frame(Language=character(), Sample=character(), Replacement=character(), Metric=character(), Model=character(), Value=numeric(), First_best=character(), Overall_best=character(), Data_mean=numeric(), Data_min=numeric(), Data_max=numeric(), Data_variance=numeric(), First_variance=numeric(), Ave_diff=numeric(), Proportion=numeric())  

for (language in as.vector(languages)){
  language_data <- subset(all_details, Language==language)
  samples <- unique(language_data$Size)
  for (sample in as.vector(samples)){
    for (replacement in c('with', 'without')){
      for (metric in as.vector(metrics)){
        data <- subset(language_data, Size==sample & Replacement==replacement & Metric==metric)
        first_data <- subset(data, Split=='1')
        best_first <- unique((subset(first_data, Value == max(first_data$Value)))$Model)

        zero_CRF = 0
        first_CRF = 0
        second_CRF = 0
        third_CRF = 0
        fourth_CRF = 0
        seq = 0
        
        CRF = 0
        
        for (i in 1:50){
          
          split_data <- subset(data, Split==as.character(i))
          best <- subset(split_data, Value == max(split_data$Value))

          if (best$Model == '0-CRF'){
            zero_CRF = zero_CRF + 1
            CRF = CRF + 1
          }
          
          if (best$Model == '1-CRF'){
            first_CRF = first_CRF + 1
            CRF = CRF + 1
          }
          
          if (best$Model == '2-CRF'){
            second_CRF = second_CRF + 1
            CRF = CRF + 1
          }
          
          if (best$Model == '3-CRF'){
            third_CRF = third_CRF + 1
            CRF = CRF + 1
          }
          
          if (best$Model == '4-CRF'){
            fourth_CRF = fourth_CRF + 1
            CRF = CRF + 1
          }
          
          if (best$Model == 'Seq2seq'){
            seq = seq + 1
          }}
        
        zero_CRF = zero_CRF * 100 / 50
        first_CRF = first_CRF * 100 / 50
        second_CRF = second_CRF * 100 / 50
        third_CRF = third_CRF * 100 / 50
        fourth_CRF = fourth_CRF * 100 / 50
        seq = seq * 100 / 50
        
        CRF = CRF * 100 / 50
        
        overall_best = 0
        
        if (max(zero_CRF, first_CRF, second_CRF, third_CRF, fourth_CRF, seq) == zero_CRF){
          overall_best = '0-CRF'
        }
        
        if (max(zero_CRF, first_CRF, second_CRF, third_CRF, fourth_CRF, seq) == first_CRF){
          overall_best = '1-CRF'
        }
        
        if (max(zero_CRF, first_CRF, second_CRF, third_CRF, fourth_CRF, seq) == second_CRF){
          overall_best = '2-CRF'
        }
        
        if (max(zero_CRF, first_CRF, second_CRF, third_CRF, fourth_CRF, seq) == third_CRF){
          overall_best = '3-CRF'
        }
        
        if (max(zero_CRF, first_CRF, second_CRF, third_CRF, fourth_CRF, seq) == fourth_CRF){
          overall_best = '4-CRF'
        }
        
        if (max(zero_CRF, first_CRF, second_CRF, third_CRF, fourth_CRF, seq) == seq){
          overall_best = 'Seq2seq'
        }
        
        proportion <- 0
        
        for (model in as.vector(models)){
          model_data <- subset(data, Model == model)
          data_mean <- mean(model_data$Value)
          data_min <- min(model_data$Value)
          data_max <- max(model_data$Value)
          data_variance <- data_max - data_min
          first_variance <- data_max - (subset(first_data, Model==model))$Value
          ave_diff <- data_mean - (subset(first_data, Model==model))$Value
          
          if (model=='Morfessor'){
            proportion <- 0
          }
          
          if (model=='0-CRF'){
            proportion <- zero_CRF
          }
          
          if (model=='1-CRF'){
            proportion <- first_CRF
          }
          
          if (model=='2-CRF'){
            proportion <- second_CRF
          }
          
          if (model=='3-CRF'){
            proportion <- third_CRF
          }
          
          if (model=='4-CRF'){
            proportion <- fourth_CRF
          }
          
          if (model=='Seq2seq'){
            proportion <- seq
          }
          
         
          
          if (model == best_first & model == overall_best){
            details_info[nrow(details_info) + 1, ] <- c(language, sample, replacement, metric, model, unique(subset(first_data, Model==model)$Value), model, overall_best, round(data_mean,2), round(data_min, 2), round(data_max,2), round(data_variance,2), round(first_variance,2), round(ave_diff,2), round(proportion,2))
          }
          
          if (model == best_first & model != overall_best){
            details_info[nrow(details_info) + 1, ] <- c(language, sample, replacement, metric, model, unique(subset(first_data, Model==model)$Value), model, 'None', round(data_mean,2), round(data_min, 2), round(data_max,2), round(data_variance,2), round(first_variance,2), round(ave_diff,2), round(proportion,2))
          }
          
          if (model != best_first & model == overall_best){
            details_info[nrow(details_info) + 1, ] <- c(language, sample, replacement, metric, model, unique(subset(first_data, Model==model)$Value), 'None', overall_best, round(data_mean,2), round(data_min, 2), round(data_max,2), round(data_variance,2), round(first_variance,2), round(ave_diff,2), round(proportion,2))
          }
          
          if (model != best_first & model != overall_best){
            details_info[nrow(details_info) + 1, ] <- c(language, sample, replacement, metric, model, unique(subset(first_data, Model==model)$Value), 'None', 'None', round(data_mean,2), round(data_min, 2), round(data_max,2), round(data_variance,2), round(first_variance,2), round(ave_diff,2), round(proportion,2))
          }
          
          
        }
      }
    }
  }
}


write.csv(details_info, 'details_info.txt',row.names=FALSE)



ggplot(f1, aes(x = as.numeric(Data_variance))) +
  geom_histogram(color="darkblue",fill='white') + 
  facet_grid(Replacement ~ Sample) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times"),
        axis.text.x=element_text(size=15),
        axis.text.y=element_text(size=15)) + 
  theme(legend.position="none") +
  labs(fill = "") +
  xlab('')



ggplot(details_info, aes(x = as.numeric(Data_variance), color = Replacement)) +
  geom_density() + 
  facet_grid(Replacement ~ Sample) +
  scale_color_manual(values=c("#69b3a2", "#404080")) +
  theme_classic() + 
  theme(text = element_text(size=15, family="Times"),
        axis.text.x=element_text(size=15),
        axis.text.y=element_text(size=15)) + 
  theme(legend.position="top") +
  labs(fill = "") 


details_info$Data_max <- as.numeric(details_info$Data_max)
details_info$Data_mean <- as.numeric(details_info$Data_mean)
details_info$Data_min <- as.numeric((details_info$Data_min))
details_info$Data_variance <- as.numeric((details_info$Data_variance))
details_info$First_variance <- as.numeric((details_info$First_variance))
details_info$Ave_diff <- as.numeric((details_info$Ave_diff))
details_info$Proportion <- as.numeric((details_info$Proportion))

details_info$Sample <- factor(details_info$Sample,levels=c('500', '1000', '1500', '2000', '3000', '4000')) 


ggplot(subset(details_info, Metric=='F1'),  aes(x=Data_variance, color=Replacement, fill=Replacement)) +
  geom_histogram(aes(y = ..density..), alpha=0.6, binwidth = 2) +
  scale_fill_manual(values=c("darkgrey", "darkgreen")) +
  scale_color_manual(values=c("darkgrey", "darkgreen")) +
  theme_classic() +
  theme(
    legend.position="none",
    panel.spacing = unit(0.8, "lines"),
    text = element_text(size=16, family="Times")
  ) +
  xlab("") +
  ylab("Density") +
  facet_grid(Replacement ~ Sample)

ggplot(subset(details_info, Metric=='F1'),  aes(x=Ave_diff, color=Replacement, fill=Replacement)) +
  geom_histogram(aes(y = ..density..), alpha=0.6, binwidth = 2) +
  scale_fill_manual(values=c("darkblue", "darkred")) +
  scale_color_manual(values=c("darkblue", "darkred")) +
  theme_classic() +
  theme(
    legend.position="none",
    panel.spacing = unit(0.8, "lines"),
    text = element_text(size=16, family="Times")
  ) +
#  xlim(-5, 4.8) +
  xlab("") +
  ylab("Density") +
  facet_grid(Replacement ~ Sample)

c=0

for (language in as.vector(languages)){
  language_data <- subset(details_info, Language==language)
  samples <- unique(language_data$Sample)
  for (sample in as.vector(samples)){
    for (replacement in c('with', 'without')){
      data <- subset(language_data, Sample==sample&Replacement==replacement&First_best!='None')
      if (length(unique(data$First_best))!=1){
        c = c + 1
        
      }}}}
