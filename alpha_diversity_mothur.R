alpha_div <- read.table(file = "bmd_only.opti_mcc.groups.summary", sep = "\t", header = T)
design <- read.table(file = "../../BMD_design.txt", sep = "\t", header = TRUE)
alpha_div_merge <- merge(alpha_div, design, by.x = "group", by.y = "name")
unique(alpha_div_merge$day)
str(alpha_div_merge)
alpha_div_merge$day <- factor(alpha_div_merge$day)
alpha_div_merge$trt_day <- paste(alpha_div_merge$trt, alpha_div_merge$day, sep = "_")
alpha_div_merge$location <- factor(alpha_div_merge$location, levels = c("jc", "ic", "cc"))
str(alpha_div_merge)

#subset(alpha_div_merge, trt_day=="ctrl_14")

qplot(trt, sobs, geom = "boxplot", colour = trt, data = alpha_div_merge, size = I(0.3), facets = location~day)
qplot(trt, chao, geom = "boxplot", colour = trt, data = alpha_div_merge, size = I(0.3), facets = location~day)
qplot(trt, ace, geom = "boxplot", colour = trt, data = alpha_div_merge, size = I(0.3), facets = location~day)
qplot(trt, coverage, geom = "boxplot", colour = trt, data = alpha_div_merge, size = I(0.3), facets = location~day)
qplot(trt, invsimpson, geom = "boxplot", colour = trt, data = alpha_div_merge, size = I(0.3), facets = location~day)
qplot(trt, shannon, geom = "boxplot", colour = trt, data = alpha_div_merge, size = I(0.3), facets = location~day)

#Get figures for manuscript.
chao <- ggplot(alpha_div_merge, aes(trt, chao)) + 
  geom_boxplot(aes(color = trt)) + 
  ylim(c(0,650)) +
  facet_grid(location~day) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))
ggsave("../../analysis/chao_contents.png")

shannon <- ggplot(alpha_div_merge, aes(trt, shannon)) + 
  geom_boxplot(aes(color = trt)) + 
  ylim(c(0,6)) +
  facet_grid(location~day)  +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))
ggsave("../../analysis/shannon_contents.png")

chao <- ggplot(subset(alpha_div_merge, location == "cc" ), aes(trt, chao)) + 
  geom_boxplot(aes(color = trt)) + 
  ylim(c(0,650)) +
  facet_grid(.~day) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))
ggsave("../../analysis/chao_contents_cc.png", width = 7, height = 3)


##Run the ANOVAs for statistics
locations <- unique(alpha_div_merge$location)
days <- unique(alpha_div_merge$day)
ad_metrics <- c("sobs", "chao", "ace", "invsimpson", "shannon")
tukey_summary <- data.frame(c(1, 1, 1, 1, 1)) 
rm(tukey_summary)
l <- "cc"
d <- 7
m <- "sobs"
for(l in locations){
  print(l)
  for(d in days){
    print(d)
    for(m in ad_metrics){
      print(m)
      aov_temp <- aov(get(m) ~ trt, data = subset(alpha_div_merge, location == l & day == d))
      summary(aov_temp)
      if (summary(aov_temp)[[1]][["Pr(>F)"]][[1]]){
        tukey_out <- TukeyHSD(aov_temp)
        tukey_out_df <- as.data.frame(tukey_out$trt)
        tukey_out_df$location <- l
        tukey_out_df$day <- d
        tukey_out_df$ad_metric <- m
        if (exists("tukey_summary")) {
          tukey_summary <- rbind(tukey_summary, tukey_out_df)
        } else {
          tukey_summary <- tukey_out_df
        }
      }
    }
  }
}
tukey_summary$q.value <- fdrtool(tukey_summary$`p adj`, statistic="pvalue", plot=F,verbose=F)$qval

write.table(tukey_summary, file = "tukey_summary.txt", sep = "\t", quote = FALSE)

#sobs.aov_cc <- aov(sobs ~ trt, data = subset(alpha_div_merge, location =="cc" & day == 2))
#summary(sobs.aov_cc)
#tukey_out <- TukeyHSD(sobs.aov_cc)
#tukey_out_df <- as.data.frame(tukey_out$trt)