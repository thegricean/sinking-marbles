theme_set(theme_bw(18))
setwd("~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/sinking-marbles/results/")
source("rscripts/summarySE.r")
source("rscripts/helpers.r")
load("data/r.RData") # the dataset

# histogram of trial types
ggplot(r,aes(x=Combination,fill=quantifier)) +
  geom_histogram() +
  theme(axis.text.x=element_text(angle=45,vjust=1,hjust=1))
ggsave(file="graphs/trial_histogram.pdf",height=9,width=13)

ggplot(r, aes(x=Prior, y=response, color=quantifier)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(~Proportion)
ggsave(file="graphs/raw_responses.pdf",width=12,height=8)

# normalized responses
agrr = aggregate(normresponse ~ Prior + Proportion + quantifier,data=r,FUN=mean)
agrr$CILow = aggregate(normresponse ~ Prior + Proportion + quantifier,data=r, FUN=ci.low)$normresponse
agrr$CIHigh = aggregate(normresponse ~ Prior + Proportion + quantifier,data=r,FUN=ci.high)$normresponse
agrr$YMin = agrr$normresponse - agrr$CILow
agrr$YMax = agrr$normresponse + agrr$CIHigh

ggplot(agrr, aes(x=Prior, y=normresponse, color=quantifier)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_line() +
  facet_wrap(~Proportion)+
  ylab("Mean normalized response")   
ggsave(file="graphs/norm_means.pdf",width=12,height=8)

ggplot(agrr, aes(x=Prior, y=normresponse, color=quantifier)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  #geom_line() +
  facet_grid(quantifier~Proportion) +
  ylab("Mean normalized response")   
ggsave(file="graphs/norm_means_byquantifier.pdf",width=12,height=8)

ggplot(agrr, aes(x=Prior, y=normresponse, color=quantifier)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth() +
  facet_grid(quantifier~Proportion) +
  ylab("Mean normalized response")   
ggsave(file="graphs/norm_means_byquantifier_smoothed.pdf",width=12,height=8)

# normalized responses, by quarter
agrr = aggregate(normresponse ~ Prior + Proportion + quantifier + Quarter,data=r,FUN=mean)
agrr$CILow = aggregate(normresponse ~ Prior + Proportion + quantifier+ Quarter,data=r, FUN=ci.low)$normresponse
agrr$CIHigh = aggregate(normresponse ~ Prior + Proportion + quantifier+ Quarter,data=r,FUN=ci.high)$normresponse
agrr$YMin = agrr$normresponse - agrr$CILow
agrr$YMax = agrr$normresponse + agrr$CIHigh

ggplot(agrr, aes(x=Prior, y=normresponse, color=Quarter)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth() +
  facet_grid(quantifier~Proportion) +
  ylab("Mean normalized response")   
ggsave(file="graphs/norm_means_byquarter_smoothed.pdf",width=12,height=8)

# raw responses
agrr = aggregate(response ~ Prior + Proportion + quantifier,data=r,FUN=mean)
agrr$CILow = aggregate(response ~ Prior + Proportion + quantifier,data=r, FUN=ci.low)$response
agrr$CIHigh = aggregate(response ~ Prior + Proportion + quantifier,data=r,FUN=ci.high)$response
agrr$YMin = agrr$response - agrr$CILow
agrr$YMax = agrr$response + agrr$CIHigh

ggplot(agrr, aes(x=Prior, y=response, color=quantifier)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_line() +
  facet_wrap(~Proportion)+
  ylab("Mean response")   
ggsave(file="graphs/raw_means.pdf",width=12,height=8)

ggplot(agrr, aes(x=Prior, y=response, color=quantifier)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_line() +
  facet_grid(quantifier~Proportion) +
  ylab("Mean response")   
ggsave(file="graphs/raw_means_byquantifier.pdf",width=12,height=8)

ggplot(agrr, aes(x=Prior, y=response, color=quantifier)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth() +
  facet_grid(quantifier~Proportion) +
  ylab("Mean response")   
ggsave(file="graphs/raw_means_byquantifier_smoothed.pdf",width=12,height=8)