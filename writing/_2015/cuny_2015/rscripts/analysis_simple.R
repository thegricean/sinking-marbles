setwd("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/writing/_2015/cogsci_2015/")
source("rscripts/helpers.r")

###############################################
# get goodness of fit measures for uniform wRSA; first individually for each 
# dataset (allstate-probs, expectations, wonkiness ratings), then jointly
###############################################

####### EXPECTATIONS
# load empirical expectations
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/13_sinking-marbles-priordv-15/results/data/r.RData")
agr = aggregate(response ~ quantifier + Item,data=r,FUN=mean)
summary(agr)
empirical = droplevels(subset(agr, quantifier == "Some"))
nrow(empirical)
head(empirical)

# load rRSA model predictions
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/complex_prior/smoothed_unbinned15/results/data/toplot-expectations.RData")
head(toplot)
nrow(toplot)

plot(empirical$response,toplot$PosteriorExpectation_predicted*15)
gof_rRSA = gof(empirical$response,toplot$PosteriorExpectation_predicted*15)
gof_rRSA
# MSE: 14.53
# r: .68
# NRMSE: 120.80


# load uniform model predictions
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/wonky_world/results/data/mp-uniform.RData")
summary(mp)
pmodel = droplevels(subset(mp, Quantifier == "some" & Alternatives == "0_basic" & SpeakerOptimality == 2 & WonkyWorldPrior == .5 & QUD == "how-many"))
nrow(pmodel)
predictions = ddply(pmodel, .(Item), summarise, PosteriorExpectation_predicted=sum(State*PosteriorProbability))
nrow(predictions)
head(predictions)

plot(empirical$response,predictions$PosteriorExpectation_predicted)
gof_uniform = gof(empirical$response,predictions$PosteriorExpectation_predicted)
gof_uniform
# MSE: 2.15
# r: .67
# NRMSE: 123.20

# load binomial model predictions
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/wonky_world/results/data/mp-binomial.RData")
summary(mp)
pmodel = droplevels(subset(mp, Quantifier == "some" & Alternatives == "0_basic" & SpeakerOptimality == 2 & WonkyWorldPrior == .5 & QUD == "how-many"))
nrow(pmodel)
predictions = ddply(pmodel, .(Item), summarise, PosteriorExpectation_predicted=sum(State*PosteriorProbability))
nrow(predictions)
head(predictions)

plot(empirical$response,predictions$PosteriorExpectation_predicted)
gof_binomial = gof(empirical$response,predictions$PosteriorExpectation_predicted)
gof_binomial
# MSE: 5.86
# r: .66
# NRMSE: 150.70

####### ALLSTATE-PROBS 
# load empirical allprobs
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/16_sinking-marbles-sliders-certain/results/data/r.RData")

# exclude people who are doing some sort of bullshit and not responding reasonably to all/none (see subject-variability.pdf for behavior on zero-slider)
tmp = subset(r,!workerid %in% c(0,22,43,98,100,103,117,118))
agrr = aggregate(normresponse ~ AllPriorProbability + Proportion + quantifier + Item,data=tmp,FUN=mean)
empirical = subset(agrr, Proportion == "100" & quantifier == "Some")
empirical = droplevels(empirical)
nrow(empirical)
head(empirical)

# load rRSA model predictions
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/complex_prior/smoothed_unbinned15/results/data/mp.RData")
summary(mp)
toplot = droplevels(subset(mp, QUD == "how-many" & Alternatives == "0_basic" &  State == 15 & SpeakerOptimality == 2))
nrow(toplot)
head(toplot)

plot(empirical$normresponse,toplot$PosteriorProbability)
gof_rRSA = gof(empirical$normresponse,toplot$PosteriorProbability)
gof_rRSA
# MSE: .07
# r = .46
# NRMSE: 103.5

# load uniform model predictions
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/wonky_world/results/data/mp-uniform.RData")
summary(mp)
predictions = droplevels(subset(mp, Quantifier == "some" & Alternatives == "0_basic" & SpeakerOptimality == 2 & WonkyWorldPrior == .5 & QUD == "how-many" & State == 15))
nrow(predictions)
head(predictions)

plot(empirical$normresponse,predictions$PosteriorProbability)
gof_uniform = gof(empirical$normresponse,predictions$PosteriorProbability)
gof_uniform
# MSE: .01
# r: .47
# NRMSE: 88.20

# load binomial model predictions
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/wonky_world/results/data/mp-binomial.RData")
summary(mp)
predictions = droplevels(subset(mp, Quantifier == "some" & Alternatives == "0_basic" & SpeakerOptimality == 2 & WonkyWorldPrior == .5 & QUD == "how-many" & State == 15))
nrow(predictions)
head(predictions)

plot(empirical$normresponse,predictions$PosteriorProbability)
gof_binomial = gof(empirical$normresponse,predictions$PosteriorProbability)
gof_binomial
# MSE: .02
# r: .47
# NRMSE: 118.70


####### WONKINESS-PROBS 
# load empirical wonkiness probs
load("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/17_sinking-marbles-normal-sliders/results/data/r.RData")
head(r)
nrow(r)

toplot = aggregate(response ~ quantifier + Item + PriorExpectation, FUN="mean", data=r)
toplot = droplevels(subset(toplot, quantifier %in% c("All","Some","None")))
nrow(toplot)
head(toplot)

# figure out where empirical values are missing and assign NAs, so gof doesn't return crap
t = as.data.frame(table(toplot$quantifier, toplot$Item))
head(t)
t[t$Freq == 0,]
toplot = rbind(toplot, data.frame(quantifier=t[t$Freq == 0,]$Var1,Item=t[t$Freq == 0,]$Var2,PriorExpectation=NA,response=NA))
nrow(toplot)
summary(toplot)
empirical = toplot[ order(toplot$quantifier, toplot$Item),]
nrow(empirical)
head(empirical)

# load uniform model predictions
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/wonky_world/results/data/wr-uniform.RData")
summary(wr)

# plot expectations for best basic model: 
predictions = droplevels(subset(wr, QUD == "how-many" & Alternatives == "0_basic" & WonkyWorldPrior == .5 & Wonky == "true" & SpeakerOptimality == 2))
nrow(predictions)

predictions = predictions[ order(predictions$Quantifier, predictions$Item),]

plot(empirical$response,predictions$PosteriorProbability)
gof_uniform = gof(empirical$response,predictions$PosteriorProbability)
gof_uniform
# MSE: .07
# r: .7
# NRMSE: 87.30

# load binomial model predictions
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/wonky_world/results/data/wr-binomial.RData")
summary(wr)

# plot expectations for best basic model: 
predictions = droplevels(subset(wr, QUD == "how-many" & Alternatives == "0_basic" & WonkyWorldPrior == .5 & Wonky == "true" & SpeakerOptimality == 2))
nrow(predictions)

predictions = predictions[ order(predictions$Quantifier, predictions$Item),]

plot(empirical$response,predictions$PosteriorProbability)
gof_binomial = gof(empirical$response,predictions$PosteriorProbability)
gof_binomial
# MSE: .09
# r: .67
# NRMSE: 110.90

