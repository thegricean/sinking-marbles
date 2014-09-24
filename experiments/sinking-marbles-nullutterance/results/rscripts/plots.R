theme_set(theme_bw(18))
setwd("~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/sinking-marbles-nullutterance/results/")
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
ggplot(r, aes(x=Prior, y=normresponse, color=quantifier)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(~Proportion)
ggsave(file="graphs/norm_responses.pdf",width=12,height=8)

agrr = aggregate(normresponse ~ Prior + Proportion + quantifier + Combination,data=r,FUN=mean)
agrr$CILow = aggregate(normresponse ~ Prior + Proportion + quantifier + Combination,data=r, FUN=ci.low)$normresponse
agrr$CIHigh = aggregate(normresponse ~ Prior + Proportion + quantifier + Combination,data=r,FUN=ci.high)$normresponse
agrr$YMin = agrr$normresponse - agrr$CILow
agrr$YMax = agrr$normresponse + agrr$CIHigh
save(agrr, file="data/agrr.RData")

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
  facet_grid(quantifier~Proportion,scales="free_y") +
  ylab("Mean normalized response")   
ggsave(file="graphs/norm_means_byquantifier_smoothed.pdf",width=12,height=8)

highprior = agrr[agrr$quantifier == "Some" & agrr$Proportion == "100" & agrr$Prior > 90,]
highprior[order(highprior[,c("normresponse")]),]

# normalized responses, by quarter
agrrq = aggregate(normresponse ~ Prior + Proportion + quantifier + Quarter,data=r,FUN=mean)
agrrq$CILow = aggregate(normresponse ~ Prior + Proportion + quantifier+ Quarter,data=r, FUN=ci.low)$normresponse
agrrq$CIHigh = aggregate(normresponse ~ Prior + Proportion + quantifier+ Quarter,data=r,FUN=ci.high)$normresponse
agrrq$YMin = agrrq$normresponse - agrrq$CILow
agrrq$YMax = agrrq$normresponse + agrrq$CIHigh
save(agrrq, file="data/agrrq.RData")

ggplot(agrrq, aes(x=Prior, y=normresponse, color=Quarter)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth() +
  facet_grid(quantifier~Proportion) +
  ylab("Mean normalized response")   
ggsave(file="graphs/norm_means_byquarter_smoothed.pdf",width=12,height=8)

# raw responses
agrrr = aggregate(response ~ Prior + Proportion + quantifier,data=r,FUN=mean)
agrrr$CILow = aggregate(response ~ Prior + Proportion + quantifier,data=r, FUN=ci.low)$response
agrrr$CIHigh = aggregate(response ~ Prior + Proportion + quantifier,data=r,FUN=ci.high)$response
agrrr$YMin = agrrr$response - agrrr$CILow
agrrr$YMax = agrrr$response + agrrr$CIHigh
save(agrrr, file="data/agrrr.RData")

ggplot(agrrr, aes(x=Prior, y=response, color=quantifier)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_line() +
  facet_wrap(~Proportion)+
  ylab("Mean response")   
ggsave(file="graphs/raw_means.pdf",width=12,height=8)

ggplot(agrrr, aes(x=Prior, y=response, color=quantifier)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_line() +
  facet_grid(quantifier~Proportion) +
  ylab("Mean response")   
ggsave(file="graphs/raw_means_byquantifier.pdf",width=12,height=8)

ggplot(agrrr, aes(x=Prior, y=response, color=quantifier)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth() +
  facet_grid(quantifier~Proportion, scales="free_y") +
  ylab("Mean response")   
ggsave(file="graphs/raw_means_byquantifier_smoothed.pdf",width=12,height=8)