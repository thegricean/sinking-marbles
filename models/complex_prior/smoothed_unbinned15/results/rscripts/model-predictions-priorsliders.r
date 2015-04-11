#' ---
#' title: "Prior probabilities in the interpretation of 'some': analysis of model predictions and empirical data"
#' author: "Judith Degen"
#' date: "November 28, 2014"
#' ---

library(ggplot2)
theme_set(theme_bw(18))
setwd("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/complex_prior/smoothed_unbinned15/results/")
source("rscripts/helpers.r")

#' get model predictions
load("data/mp.RData")
mp = read.table("data/parsed_priorslider_results.tsv", quote="", sep="\t", header=T)
nrow(mp)
head(mp)
summary(mp)
mp$Item = as.factor(gsub("_"," ",mp$Item))

# get prior expectations
priorexpectations = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/expectations.txt",sep="\t", header=T, quote="")
row.names(priorexpectations) = paste(priorexpectations$effect,priorexpectations$object)
head(priorexpectations)
mp$PriorExpectation_number = priorexpectations[as.character(mp$Item),]$expectation

priorprobs = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/smoothed_15marbles_priors_withnames.txt",sep="\t", header=T, quote="")
head(priorprobs)
row.names(priorprobs) = paste(priorprobs$effect,priorprobs$object)
mpriorprobs = melt(priorprobs, id.vars=c("effect", "object"))
head(mpriorprobs)
row.names(mpriorprobs) = paste(mpriorprobs$effect,mpriorprobs$object,mpriorprobs$variable)
mp$PriorProbability_number = mpriorprobs[paste(as.character(mp$Item)," X",mp$State,sep=""),]$value
mp$AllPriorProbability_number = priorprobs[paste(as.character(mp$Item)),]$X15
head(mp)

load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/23_sinking-marbles-prior-sliders-exactly/results/data/agr-normresponses.RData")
row.names(agr) = paste(agr$State, agr$Item)
mp$PriorProbability_slider = agr[paste(mp$State, mp$Item),]$prior_slider
mp$PriorProbability_slider_ymin = agr[paste(mp$State, mp$Item),]$YMin
mp$PriorProbability_slider_ymax = agr[paste(mp$State, mp$Item),]$YMax

save(mp, file="data/mp-sliderpriors.RData")

ub = droplevels(subset(mp, State == 15))
agr = aggregate(PosteriorProbability ~ Item + SpeakerOptimality + PriorProbability_slider + PriorProbability_slider_ymin + PriorProbability_slider_ymax, FUN=mean, data=ub)
agr$CILow = aggregate(PosteriorProbability ~ Item + SpeakerOptimality, FUN=ci.low, data=ub)$PosteriorProbability
agr$CIHigh = aggregate(PosteriorProbability ~ Item + SpeakerOptimality, FUN=ci.high, data=ub)$PosteriorProbability
agr$YMin = agr$PosteriorProbability - agr$CILow
agr$YMax = agr$PosteriorProbability + agr$CIHigh

ggplot(agr, aes(x=PriorProbability_slider, y=PosteriorProbability, color=as.factor(SpeakerOptimality))) +
  geom_point() +
  #geom_line() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  #geom_errorbarh(aes(xmin=PriorProbability_slider_ymin,xmax=PriorProbability_slider_ymax)) +
  facet_wrap(~SpeakerOptimality)
ggsave("graphs/mp-priorsliders.pdf",height=7)


######################
# get empirical state posteriors:
load("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/16_sinking-marbles-sliders-certain/results/data/r.RData")
head(r)
# because posteriors come in 4 bins, make Bin variable for model prediction dataset:
mp$Proportion = as.factor(ifelse(mp$State == 0, "0", ifelse(mp$State == 15, "100", ifelse(mp$State < 8, "1-50", "51-99"))))

some = droplevels(subset(r, quantifier == "Some"))
agr = aggregate(normresponse ~ Item + Proportion,data=r,FUN=mean)
agr$CILow = aggregate(normresponse ~ Item + Proportion,data=r, FUN=ci.low)$normresponse
agr$CIHigh = aggregate(normresponse ~ Item + Proportion,data=r,FUN=ci.high)$normresponse
agr$YMin = agr$normresponse - agr$CILow
agr$YMax = agr$normresponse + agr$CIHigh
row.names(agr) = paste(agr$Item, agr$Proportion)
mp$PosteriorProbability_empirical = agr[paste(mp$Item,mp$Proportion),]$normresponse
mp$PosteriorProbability_empirical_ymin = agr[paste(mp$Item,mp$Proportion),]$YMin
mp$PosteriorProbability_empirical_ymax = agr[paste(mp$Item,mp$Proportion),]$YMax

ub = droplevels(subset(mp, State == 15))
agr = aggregate(PosteriorProbability ~ Item + SpeakerOptimality + PosteriorProbability_empirical + PosteriorProbability_empirical_ymin + PosteriorProbability_empirical_ymax, FUN=mean, data=ub)
agr$CILow = aggregate(PosteriorProbability ~ Item + SpeakerOptimality, FUN=ci.low, data=ub)$PosteriorProbability
agr$CIHigh = aggregate(PosteriorProbability ~ Item + SpeakerOptimality, FUN=ci.high, data=ub)$PosteriorProbability
agr$YMin = agr$PosteriorProbability - agr$CILow
agr$YMax = agr$PosteriorProbability + agr$CIHigh

ggplot(agr, aes(x=PosteriorProbability, y=PosteriorProbability_empirical, color=as.factor(SpeakerOptimality))) +
  geom_point() +
  #geom_line() +
  geom_errorbarh(aes(xmin=YMin,xmax=YMax)) +
  geom_errorbar(aes(ymin=PosteriorProbability_empirical_ymin,ymax=PosteriorProbability_empirical_ymax)) +
  geom_abline(intercept=0,slope=1,color="gray60") +
  facet_wrap(~SpeakerOptimality)
ggsave("graphs/mp-empirical-priorsliders.pdf",height=7)

