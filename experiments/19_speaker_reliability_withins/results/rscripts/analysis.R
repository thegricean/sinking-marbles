setwd("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/19_speaker_reliability_withins/results/")
source("rscripts/helpers.r")
library(lmerTest)
load("data/r.RData") # the dataset
summary(r)
r = r[!is.na(r$normresponse),]

some100 = droplevels(subset(r, Proportion == "100" & quantifier == "Some"))

some100$Reliability = as.factor(ifelse(some100$trial_type == "sober","reliable","unreliable"))
centered = cbind(some100, myCenter(some100[,c("AllPriorProbability","Reliability","Trial")]))
m = lmer(normresponse ~ cAllPriorProbability * cReliability + (cAllPriorProbability * cReliability | Item) + (cAllPriorProbability * cReliability | workerid), data=centered)
summary(m)
save(m, file="data/model.RData")

m.trial = lmer(normresponse ~ cAllPriorProbability * cReliability * cTrial + (cAllPriorProbability * cReliability| Item) + (cAllPriorProbability * cReliability| workerid), data=centered)
summary(m.trial)
save(m.trial, file="data/m.trial.RData")



