theme_set(theme_bw(18))
setwd("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/19_speaker_reliability_withins/results/")
source("rscripts/helpers.r")
load("data/r.RData") # the dataset
summary(r)
r = r[!is.na(r$normresponse),]

# histogram of trial types
ggplot(r,aes(x=Item,fill=quantifier)) +
  geom_histogram() +
  theme(axis.text.x=element_text(angle=45,vjust=1,hjust=1))
ggsave(file="graphs/trial_histogram.pdf",height=9,width=13)

# PAPER PLOT
# mean ratings on "all" slider on "some" trials
some100 = droplevels(subset(r, Proportion == "100" & quantifier == "Some"))
agr = aggregate(normresponse ~ AllPriorProbability  + trial_type + Item,data=some100,FUN=mean)
agr$CILow = aggregate(normresponse ~ AllPriorProbability + trial_type + Item,data=some100, FUN=ci.low)$normresponse
agr$CIHigh = aggregate(normresponse ~ AllPriorProbability + trial_type + Item,data=some100,FUN=ci.high)$normresponse
agr$YMin = agr$normresponse - agr$CILow
agr$YMax = agr$normresponse + agr$CIHigh

p=ggplot(agr, aes(x=AllPriorProbability,y=normresponse, color=trial_type)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth(method="lm") +
  scale_y_continuous(name="Posterior probability of all-state") +
  scale_x_continuous(name="Prior probability of all-state") +
  scale_color_discrete(name="Trial type",breaks=levels(agr$trial_type),labels=c("unreliable (court)", "unreliable (drunk)", "reliable (sober)"))
ggsave("graphs/norm_means_some_bycondition.pdf",width=6.5,height=4.5)
p
ggsave("graphs/norm_means_some_bycondition.png",width=7,height=4.5)
ggsave("../../../writing/_2015/_journal_cognition/pics/speakerreliabilityresults.pdf",width=7,height=4)


agr = aggregate(normresponse ~ AllPriorProbability  + trial_type + Item + block,data=some100,FUN=mean)
agr$CILow = aggregate(normresponse ~ AllPriorProbability + trial_type + Item+ block,data=some100, FUN=ci.low)$normresponse
agr$CIHigh = aggregate(normresponse ~ AllPriorProbability + trial_type + Item + block,data=some100,FUN=ci.high)$normresponse
agr$YMin = agr$normresponse - agr$CILow
agr$YMax = agr$normresponse + agr$CIHigh

p=ggplot(agr, aes(x=AllPriorProbability,y=normresponse, color=trial_type)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth(method="lm") +
  scale_y_continuous(name="Posterior probability of all-state") +
  scale_x_continuous(name="Prior probability of all-state") +
  scale_color_discrete(name="Trial type",breaks=levels(agr$trial_type),labels=c("unreliable (court)", "unreliable (drunk)", "reliable (sober)")) +
  facet_wrap(~block)
ggsave("../../../writing/_2015/_journal_cognition/pics/speakerreliabilityresults-byblock.pdf",width=12,height=3.7)

some100$Reliability = as.factor(ifelse(some100$trial_type == "sober","reliable","unreliable"))
centered = cbind(some100, myCenter(some100[,c("AllPriorProbability","Reliability")]))
m = lmer(normresponse ~ cAllPriorProbability * cReliability + (cAllPriorProbability * cReliability | Item) + (cAllPriorProbability * cReliability | workerid), data=centered)
summary(m)

m.simple = lmer(normresponse ~ cAllPriorProbability * Reliability - cAllPriorProbability + (cAllPriorProbability * cReliability | Item) + (cAllPriorProbability * cReliability | workerid), data=centered)
summary(m.simple)

library(lmerTest)

# by-subject ratings on "all" slider
p=ggplot(droplevels(r[r$Proportion == "100",]), aes(x=PriorExpectationProportion,y=normresponse, color=trial_type)) +
  geom_point() +
  geom_smooth() +
  scale_y_continuous(limits=c(0,1)) +
  facet_grid(workerid~quantifier)
ggsave("graphs/bysubject-effects.pdf",width=6,height=45)

ggplot(r, aes(x=PriorExpectationProportion, y=response, color=quantifier)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(~Proportion)
ggsave(file="graphs/raw_responses.pdf",width=12,height=8)

ggplot(r, aes(x=AllPriorProbability, y=response, color=quantifier)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(~Proportion)
ggsave(file="graphs/raw_responses_allprob.pdf",width=12,height=8)

# normalized responses
ggplot(r, aes(x=PriorExpectationProportion, y=normresponse, color=quantifier)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(~Proportion)
ggsave(file="graphs/norm_responses.pdf",width=12,height=8)

ggplot(r, aes(x=AllPriorProbability, y=normresponse, color=quantifier)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(~Proportion)
ggsave(file="graphs/norm_responses_allprob.pdf",width=12,height=8)

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

## HERE BEGIN THE BY TRIALTYPE PLOTS
agrr = aggregate(normresponse ~ AllPriorProbability + Proportion + quantifier + Item + trial_type,data=r,FUN=mean)
#agrr = droplevels(subset(agrr, Proportion == "100"))
ggplot(agrr, aes(x=AllPriorProbability, y=normresponse, color=trial_type)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth(method="lm") +
  facet_grid(quantifier~Proportion,scales="free_y") +
  ylab("Mean normalized response")   
ggsave(file="graphs/norm_means_byquantifier_smoothed_allprob_bytrialtype.pdf",width=12,height=8)

agrr = aggregate(normresponse ~ AllPriorProbability + Proportion + quantifier + Item + trial_type + Confused,data=r[r$Proportion == "100",],FUN=mean)
#agrr = droplevels(subset(agrr, Proportion == "100"))
ggplot(agrr, aes(x=AllPriorProbability, y=normresponse, color=trial_type)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth(method="lm") +
  scale_y_continuous(limits=c(0,1)) +
  facet_grid(Confused~quantifier,scales="free_y") +
  ylab("Mean normalized response")   
ggsave(file="graphs/norm_means_byquantifier_smoothed_allprob_bytrialtype_confused.pdf",width=12,height=6)

agrr = aggregate(response ~ AllPriorProbability + Proportion + quantifier + Item + trial_type,data=r,FUN=mean)
#agrr = droplevels(subset(agrr, Proportion == "100"))
ggplot(agrr, aes(x=AllPriorProbability, y=response, color=trial_type)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth() +
  facet_grid(quantifier~Proportion,scales="free_y") +
  ylab("Mean normalized response")   
ggsave(file="graphs/raw_means_byquantifier_smoothed_allprob_bytrialtype.pdf",width=12,height=8)

agrr = aggregate(normresponse ~ PriorExpectation + Proportion + quantifier + Item + trial_type + Confused,data=r[r$Proportion == "100",],FUN=mean)
#agrr = droplevels(subset(agrr, Proportion == "100"))
ggplot(agrr, aes(x=PriorExpectation, y=normresponse, color=trial_type)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth() +
  scale_y_continuous(limits=c(0,1)) +
  facet_grid(Confused~quantifier,scales="free_y") +
  ylab("Mean normalized response")   
ggsave(file="graphs/norm_means_byquantifier_smoothed_exp_bytrialtype_confused.pdf",width=12,height=8)

agrr = aggregate(normresponse ~ PriorExpectation + Proportion + quantifier + Item + trial_type,data=r,FUN=mean)
#agrr = droplevels(subset(agrr, Proportion == "100"))
ggplot(agrr, aes(x=PriorExpectation, y=normresponse, color=trial_type)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth() +
  facet_grid(quantifier~Proportion,scales="free_y") +
  ylab("Mean normalized response")   
ggsave(file="graphs/norm_means_byquantifier_smoothed_exp_bytrialtype.pdf",width=12,height=8)

agrr = aggregate(response ~ PriorExpectation + Proportion + quantifier + Item + trial_type,data=r,FUN=mean)
#agrr = droplevels(subset(agrr, Proportion == "100"))
ggplot(agrr, aes(x=PriorExpectation, y=response, color=trial_type)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth() +
  facet_grid(quantifier~Proportion,scales="free_y") +
  ylab("Mean raw response")   
ggsave(file="graphs/raw_means_byquantifier_smoothed_exp_bytrialtype.pdf",width=12,height=8)


agrr = aggregate(normresponse ~ AllPriorProbability + Proportion + quantifier + Item + trial_type + block,data=r,FUN=mean)
agrr = droplevels(subset(agrr, Proportion == "100"))
ggplot(agrr, aes(x=AllPriorProbability, y=normresponse, color=trial_type)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth() +
  facet_grid(quantifier~block,scales="free_y") +
  ylab("Mean normalized response")   
ggsave(file="graphs/norm_means_ub_byquantifier_smoothed_allprob_bytrialtype_byblock.pdf",width=10,height=8)

agrr = aggregate(response ~ AllPriorProbability + Proportion + quantifier + Item + trial_type + block,data=r,FUN=mean)
agrr = droplevels(subset(agrr, Proportion == "100"))
ggplot(agrr, aes(x=AllPriorProbability, y=response, color=trial_type)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth() +
  facet_grid(quantifier~block,scales="free_y") +
  ylab("Mean normalized response")   
ggsave(file="graphs/raw_means_ub_byquantifier_smoothed_allprob_bytrialtype_byblock.pdf",width=10,height=8)

agrr = aggregate(normresponse ~ PriorExpectation + Proportion + quantifier + Item + trial_type + block,data=r,FUN=mean)
agrr = droplevels(subset(agrr, Proportion == "100"))
ggplot(agrr, aes(x=PriorExpectation, y=normresponse, color=trial_type)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  #geom_smooth() +
  geom_smooth(method="lm") +  
  facet_grid(quantifier~block,scales="free_y") +
  ylab("Mean normalized response")   
ggsave(file="graphs/norm_means_ub_byquantifier_smoothed_exp_bytrialtype_byblock.pdf",width=10,height=8)

agrr = aggregate(response ~ PriorExpectation + Proportion + quantifier + Item + trial_type + block,data=r,FUN=mean)
agrr = droplevels(subset(agrr, Proportion == "100"))
ggplot(agrr, aes(x=PriorExpectation, y=response, color=trial_type)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth() +
  facet_grid(quantifier~block,scales="free_y") +
  ylab("Mean raw response")   
ggsave(file="graphs/raw_means_ub_byquantifier_smoothed_exp_bytrialtype_byblock.pdf",width=10,height=8)


###### COMPARISON WITH "STANDARD" EXPERIMENT

some = subset(r, Proportion == "100" & quantifier == "Some")
head(some)
nrow(some)
summary(some)
m = lmer(normresponse ~ AllPriorProbability + (1|workerid) + (1|Item),data=some)
summary(m)
library(lmerTest)

some$Experiment = "speakerreliability"

load("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/16_sinking-marbles-sliders-certain/results/data/r.RData")
somer = subset(r, Proportion == "100" & quantifier == "Some")
nrow(somer)
somer$Experiment = "regular"

comb = merge(some, somer, all=T)
nrow(comb)
comb$Experiment = as.factor(as.character(comb$Experiment))
summary(comb)
m = lmer(normresponse ~ AllPriorProbability*Experiment + (1|workerid) + (1|Item),data=comb)
summary(m)
library(lmerTest)

centered = cbind(comb, myCenter(comb[,c("AllPriorProbability","Experiment")]))
m = lmer(normresponse ~ cAllPriorProbability*cExperiment + (1|workerid) + (1|Item),data=centered)
summary(m)
library(lmerTest)
m = lmer(normresponse ~ cAllPriorProbability*cExperiment + (1|workerid) + (1|Item),data=centered)
summary(m)

agr=aggregate(normresponse~Item+AllPriorProbability+Experiment, data=comb, FUN=mean)
agr$CILow = aggregate(normresponse~Item+AllPriorProbability+Experiment, data=comb, FUN=ci.low)$normresponse
agr$CIHigh = aggregate(normresponse~Item+AllPriorProbability+Experiment, data=comb, FUN=ci.high)$normresponse
agr$YMin = agr$normresponse - agr$CILow
agr$YMax = agr$normresponse + agr$CIHigh
  
ggplot(agr, aes(x=AllPriorProbability, y=normresponse, color=Experiment)) +
  geom_point() +
#  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth(method="lm") +
  scale_x_continuous(name="Prior probability of all-state") +
  scale_y_continuous(name="Posterior probability of all-state")   
ggsave("graphs/reliable_vs_unreliable_some_means.pdf")
table(somer$Item)

ggplot(agr, aes(x=AllPriorProbability, y=normresponse, color=Experiment)) +
  geom_point() +
  #  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth(method="lm") +
  geom_text(aes(label=Item)) +
  scale_x_continuous(name="Prior probability of all-state") +
  scale_y_continuous(name="Posterior probability of all-state")   
ggsave("graphs/reliable_vs_unreliable_annotated.pdf",width=10,height=6)
table(somer$Item)

ggplot(comb, aes(x=AllPriorProbability, y=normresponse, color=Experiment)) +
  geom_point() +
  geom_smooth(method="lm")
ggsave("graphs/reliable_vs_unreliable_some.pdf")
