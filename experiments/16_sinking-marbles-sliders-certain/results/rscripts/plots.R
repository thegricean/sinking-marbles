theme_set(theme_bw(18))
setwd("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/16_sinking-marbles-sliders-certain/results/")
#setwd("~/Dropbox/thegricean_sinking-marbles/experiments/16_sinking-marbles-sliders-certain/results/")
source("rscripts/summarySE.r")
source("rscripts/helpers.r")
load("data/r.RData") # the dataset
summary(r)

# histogram of trial types
ggplot(r,aes(x=Item,fill=quantifier)) +
  geom_histogram() +
  theme(axis.text.x=element_text(angle=45,vjust=1,hjust=1))
ggsave(file="graphs/trial_histogram.pdf",height=9,width=13)

# subject variability
an = droplevels(subset(r, quantifier %in% c("None","All") & Proportion %in% c("0","100")))
agr = aggregate(normresponse~quantifier+Proportion+workerid,FUN=mean,data=an)
agr$YMin = agr$normresponse - aggregate(normresponse~quantifier+Proportion+workerid,FUN=ci.low,data=an)$normresponse
agr$YMax = agr$normresponse + aggregate(normresponse~quantifier+Proportion+workerid,FUN=ci.high,data=an)$normresponse
p=ggplot(agr,aes(x=Proportion, y=normresponse,color=quantifier)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  facet_wrap(~workerid)
ggsave(p,file="graphs/subject_variability.pdf",width=30,height=30)

# subject variability
# p=ggplot(r,aes(x=quantifier, fill=Proportion)) +
#   geom_histogram() +
#   facet_grid(Item~workerid)
# ggsave(p,file="graphs/subject_variability.pdf",width=30,height=30)

ggplot(r, aes(x=PriorExpectationProportion, y=response, color=quantifier)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(~Proportion)
ggsave(file="graphs/raw_responses_bypriorexp.pdf",width=12,height=8)

ggplot(r, aes(x=AllPriorProbability, y=response, color=quantifier)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(~Proportion)
ggsave(file="graphs/raw_responses_byallprob.pdf",width=12,height=8)

# normalized responses
ggplot(r, aes(x=PriorExpectationProportion, y=normresponse, color=quantifier)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(~Proportion)
ggsave(file="graphs/norm_responses_bypriorexp.pdf",width=12,height=8)

ggplot(r, aes(x=AllPriorProbability, y=normresponse, color=quantifier)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(~Proportion)
ggsave(file="graphs/norm_responses_byallprob.pdf",width=12,height=8)

load("data/agrr.RData")
agrr = aggregate(normresponse ~ AllPriorProbability + Proportion + quantifier + Item,data=r,FUN=mean)
agrr$CILow = aggregate(normresponse ~ AllPriorProbability + Proportion + quantifier + Item,data=r, FUN=ci.low)$normresponse
agrr$CIHigh = aggregate(normresponse ~ AllPriorProbability + Proportion + quantifier + Item,data=r,FUN=ci.high)$normresponse
agrr$YMin = agrr$normresponse - agrr$CILow
agrr$YMax = agrr$normresponse + agrr$CIHigh
save(agrr, file="data/agrr.RData")

ggplot(agrr, aes(x=AllPriorProbability, y=normresponse, color=quantifier)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_line() +
  facet_wrap(~Proportion)+
  ylab("Mean normalized response")   
ggsave(file="graphs/norm_means.pdf",width=12,height=8)

ggplot(agrr, aes(x=AllPriorProbability, y=normresponse, color=quantifier)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  #geom_line() +
  facet_grid(quantifier~Proportion) +
  ylab("Mean normalized response")   
ggsave(file="graphs/norm_means_byquantifier.pdf",width=12,height=8)

ggplot(agrr, aes(x=AllPriorProbability, y=normresponse, color=quantifier)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth() +
  facet_grid(quantifier~Proportion,scales="free_y") +
  ylab("Mean normalized response")   
ggsave(file="graphs/norm_means_byquantifier_smoothed.pdf",width=12,height=8)

agrr = aggregate(normresponse ~ PriorExpectationProportion + AllPriorProbability + Proportion + quantifier + Item,data=r,FUN=mean)
ggplot(agrr, aes(x=AllPriorProbability, y=normresponse, color=quantifier)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth() +
  facet_grid(quantifier~Proportion,scales="free_y") +
  ylab("Mean normalized response")   
ggsave(file="graphs/norm_means_byquantifier_smoothed_byallprob.pdf",width=12,height=8)


highprior = agrr[agrr$quantifier == "Some" & agrr$Proportion == "100" & agrr$PriorExpectationProportion > .90,]
highprior[order(highprior[,c("normresponse")]),]



ub = subset(agrr, Proportion == "100")
ub = droplevels(ub)
ggplot(ub, aes(x=PriorExpectationProportion, y = normresponse, color=quantifier)) +
  geom_point() +
  geom_smooth()
ggsave(file="graphs/norm_means_ub.pdf")

ggplot(ub, aes(x=AllPriorProbability, y = normresponse, color=quantifier)) +
  geom_point() +
  geom_smooth()
ggsave(file="graphs/norm_means_ub_byallprob.pdf")

ggplot(ub, aes(x=AllPriorProbability, y = normresponse, color=quantifier)) +
  geom_point() +
  geom_smooth() +
  geom_abline(intercept=0,slope=1,color="gray70") +
  scale_x_continuous(name="Prior probability of all-state") +
  scale_y_continuous(name="Mean probability of all-state after 'some'")
ggsave(file="graphs/empirical_allstate.pdf",height=6)

ggplot(ub, aes(x=AllPriorProbability, y = normresponse, color=quantifier)) +
  geom_point() +
  geom_smooth() +
  geom_text(aes(label=Item))
ggsave(file="graphs/norm_means_ub_annotated_cprior.pdf",height=20,width=27)



some = subset(r, Proportion == "100" & quantifier == "Some")
head(some)
nrow(some)
summary(some)
m = lmer(normresponse ~ AllPriorProbability + (1|workerid) + (1|Item),data=some)
summary(m)
library(lmerTest)

m = lmer(normresponse ~ PriorExpectationProportion + (1|workerid) + (1|Item),data=some)
summary(m)
