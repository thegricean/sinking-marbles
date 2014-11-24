library(ggplot2)
theme_set(theme_bw(18))
setwd("~/Dropbox/sinking_marbles/sinking-marbles/models/_results/")
source("rscripts/helpers.r")

load("../varied_alternatives/results/data/hmbasic2.gprior.RData")
load("../complex_prior/results/data/hmbasic2.cprior.RData")
load("data/all_empirical.RData")
summary(all)
head(hmbasic2.gprior)
all$ModelPredictionMeanPrior = hmbasic2.gprior[as.character(round(all$Prior/100,2)),]$PosteriorProbability
all$ModelPredictionPropPrior = hmbasic2.cprior[paste(all$Prior.0,all$Prior.1,all$Prior.2,all$Prior.3),]$PosteriorProbability
head(all)

ggplot(all, aes(x=ModelPredictionMeanPrior,y=ModelPredictionPropPrior)) +
  geom_point()
ggsave("graphs/compared_modelpredictions.pdf")

agr = aggregate(normresponse ~ ModelPredictionMeanPrior + ModelPredictionPropPrior, data=all, FUN=mean)
agr$CILow = aggregate(normresponse ~ ModelPredictionMeanPrior + ModelPredictionPropPrior, data=all, FUN=ci.low)$normresponse
agr$CIHigh = aggregate(normresponse ~ ModelPredictionMeanPrior + ModelPredictionPropPrior, data=all,FUN=ci.high)$normresponse
agr$YMin = agr$normresponse - agr$CILow
agr$YMax = agr$normresponse + agr$CIHigh

ggplot(agr, aes(x=ModelPredictionMeanPrior,y=normresponse)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_abline(intercept=0,slope=1)
ggsave("graphs/empirical-vs-meanprior.pdf")

ggplot(agr, aes(x=ModelPredictionPropPrior,y=normresponse)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +  
  geom_abline(intercept=0,slope=1)
ggsave("graphs/empirical-vs-propprior.pdf")

cor(agr$normresponse,agr$ModelPredictionPropPrior) # .50
cor(agr$normresponse,agr$ModelPredictionMeanPrior) # .55
