#' ---
#' title: "Prior probabilities in the interpretation of 'some': analysis of uniform prior wonky world model predictions"
#' author: "Judith Degen"
#' date: "January 12, 2014"
#' ---

library(ggplot2)
theme_set(theme_bw(18))
setwd("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/writing/_2015/_journal_cognition/models/graphs/")
source("../rscripts/helpers.r")

#' get model predictions
d = read.table("../modelresults/parsed_uniform_untruthful_results.tsv", quote="", sep="\t", header=T)
d$Type = "untruthful"
untruthful = d
d = read.table("../modelresults/parsed_uniform_uninformative_results.tsv", quote="", sep="\t", header=T)
d$Type = "uninformative"
uninformative = d

d = rbind(untruthful,uninformative)
d$Type = as.factor(d$Type)

table(d$Item)
nrow(d)
head(d)
summary(d)

# get prior expectations
priorexpectations = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/expectations.txt",sep="\t", header=T, quote="")
row.names(priorexpectations) = paste(priorexpectations$effect,priorexpectations$object)
d$PriorExpectation = priorexpectations[as.character(d$Item),]$expectation

# get smoothed prior probabilities
priorprobs = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/smoothed_15marbles_priors_withnames.txt",sep="\t", header=T, quote="")
head(priorprobs)
row.names(priorprobs) = priorprobs$Item
mpriorprobs = melt(priorprobs, id.vars=c("Item"))
head(mpriorprobs)
row.names(mpriorprobs) = paste(mpriorprobs$Item,mpriorprobs$variable)
d$PriorProbability = mpriorprobs[paste(as.character(d$Item)," X",d$State,sep=""),]$value
d$AllPriorProbability = priorprobs[paste(as.character(d$Item)),]$X15
head(d)
d$QUD = NULL
d$Alternatives = NULL

load("../mp-uniform.RData")
head(mp)
mp$Type = "cooperative"
mp = mp[,names(d)]
d = rbind(d,mp)

allprobs = droplevels(subset(d, State == 15 & Quantifier == "some"))
ggplot(allprobs, aes(x=PriorProbability, y=PosteriorProbability, shape=as.factor(SpeakerOptimality),color=Type)) +
  geom_point() +
  geom_smooth() +
  facet_grid(SpeakerOptimality~WonkyWorldPrior)
ggsave("model-predictions-unreliablespeaker.pdf")

best = droplevels(subset(allprobs, SpeakerOptimality == 2 & WonkyWorldPrior == .5))
ggplot(best, aes(x=PriorProbability, y=PosteriorProbability,color=Type)) +
  geom_point() +
  geom_smooth() +
  scale_x_continuous("Prior probability of all-state") +
  scale_y_continuous("Predicted posterior probability of all-state")
ggsave("model-predictions-unreliablespeaker-spopt2-wwprior.5.pdf",width=6,height=4)
ggsave("../../pics/modelpredictions-unreliablespeaker.pdf",width=6,height=4)
