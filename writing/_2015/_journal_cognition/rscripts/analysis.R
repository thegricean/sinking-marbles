setwd("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/writing/_2015/cogsci_2015/")
source("rscripts/helpers.r")

# load empirical expectations
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/13_sinking-marbles-priordv-15/results/data/r.RData")
agr = aggregate(response ~ quantifier + Item,data=r,FUN=mean)
summary(agr)
empirical_exps = droplevels(subset(agr, quantifier == "Some"))
nrow(empirical_exps)
head(empirical_exps)

# load empirical allstate probs
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/16_sinking-marbles-sliders-certain/results/data/r.RData")
# exclude people who are doing some sort of bullshit and not responding reasonably to all/none (see subject-variability.pdf for behavior on zero-slider)
tmp = subset(r,!workerid %in% c(0,22,43,98,100,103,117,118))
tmp=r
agrr = aggregate(normresponse ~ AllPriorProbability + Proportion + quantifier + Item,data=tmp,FUN=mean)
empirical_allprobs = droplevels(subset(agrr, Proportion == "100" & quantifier == "Some"))
nrow(empirical_allprobs)
head(empirical_allprobs)

empirical = data.frame(AllProbability=empirical_allprobs$normresponse, Expectation=empirical_exps$response)
head(empirical)

# load binomial model predictions
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/wonky_world/results/data/mp-binomial.RData")
mp_binomial = droplevels(subset(mp, QUD == "how-many" & Alternatives == "0_basic" & Quantifier == "some"))
nrow(mp_binomial)
summary(mp_binomial)
mp_binomial_allprobs = droplevels(subset(mp_binomial, State==15))
mp_binomial_exps = ddply(mp_binomial, .(Item, WonkyWorldPrior, SpeakerOptimality), summarise, Expectation=sum(State*PosteriorProbability))
nrow(mp_binomial_exps)

# load uniform model predictions
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/wonky_world/results/data/mp-uniform.RData")
mp_uniform = droplevels(subset(mp, QUD == "how-many" & Alternatives == "0_basic" & Quantifier == "some"))
nrow(mp_uniform)
summary(mp_uniform)
mp_uniform_allprobs = droplevels(subset(mp_uniform, State==15))
nrow(mp_uniform_allprobs)
mp_uniform_exps = ddply(mp_uniform, .(Item, WonkyWorldPrior, SpeakerOptimality), summarise, Expectation=sum(State*PosteriorProbability))
nrow(mp_uniform_exps)

# load rRSA model predictions

# allprobs
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/complex_prior/smoothed_unbinned15/results/data/mp.RData")
mp = droplevels(subset(mp, QUD == "how-many" & Alternatives == "0_basic"))
mp_regular_exps = ddply(mp, .(Item,SpeakerOptimality), summarise, Expectation=sum(State*PosteriorProbability))
mp_regular_allprobs = droplevels(subset(mp, QUD == "how-many" & Alternatives == "0_basic" &  State == 15))
head(mp_regular_exps)
head(mp_regular_allprobs)

#initialize results data.frame
#results = data.frame(WonkyWorldPrior = rep(rep(c(.1,.3,.5),9),2), SpeakerOptimality = rep(rep(rep(c(1,2,3),each=3),3),2), ModelType = rep(rep(c("rRSA","wRSA_uniform","wRSA_binomial"),each=9),2),Measure=rep(c("Expectation","AllStateProbability"),each=27))
results = data.frame(WonkyWorldPrior=factor(levels=c(.1,.3,.5)),SpeakerOptimality=factor(levels=c(1,2,3)),Model = factor(levels=c("rRSA","wRSA_uniform","wRSA_binomial")),Measure=factor(levels=c("Expectation","AllProbability")),MSE=numeric(),NRMSE=numeric(),R=numeric(),R2=numeric())

WonkyWorldPrior = c(.1,.3,.5)
SpeakerOptimality = c(1,2,3)

i = 1
for (spopt in SpeakerOptimality) {
  regular = data.frame(AllProbability = mp_regular_allprobs[mp_regular_allprobs$SpeakerOptimality == spopt,]$PosteriorProbability, Expectation = mp_regular_exps[mp_regular_exps$SpeakerOptimality == spopt,]$Expectation)  
  g = as.data.frame(gof(empirical, regular))
  results[i,]$WonkyWorldPrior = NA
  results[i,]$SpeakerOptimality = spopt      
  results[i,]$Model = "rRSA"
  results[i,]$Measure = "Expectation"
  results[i,]$MSE = g["MSE","Expectation"]
  results[i,]$NRMSE = g["NRMSE","Expectation"]      
  results[i,]$R = g["r","Expectation"]      
  results[i,]$R2 = g["R2","Expectation"]
  i = i+1
  results[i,]$WonkyWorldPrior = NA
  results[i,]$SpeakerOptimality = spopt      
  results[i,]$Model = "rRSA"
  results[i,]$Measure = "AllProbability"
  results[i,]$MSE = g["MSE","AllProbability"]
  results[i,]$NRMSE = g["NRMSE","AllProbability"]      
  results[i,]$R = g["r","AllProbability"]      
  results[i,]$R2 = g["R2","AllProbability"]
  i = i+1    
  
  for (ww in WonkyWorldPrior) {
      binomial = data.frame(AllProbability = mp_binomial_allprobs[mp_binomial_allprobs$WonkyWorldPrior == ww & mp_binomial_allprobs$SpeakerOptimality == spopt,]$PosteriorProbability, Expectation = mp_binomial_exps[mp_binomial_exps$WonkyWorldPrior == ww & mp_binomial_exps$SpeakerOptimality == spopt,]$Expectation)
      g = as.data.frame(gof(empirical, binomial))
      results[i,]$WonkyWorldPrior = ww
      results[i,]$SpeakerOptimality = spopt     
      results[i,]$Model = "wRSA_binomial"
      results[i,]$Measure = "Expectation"
      results[i,]$MSE = g["MSE","Expectation"]
      results[i,]$NRMSE = g["NRMSE","Expectation"]      
      results[i,]$R = g["r","Expectation"]      
      results[i,]$R2 = g["R2","Expectation"]
      i = i+1
      results[i,]$WonkyWorldPrior = ww
      results[i,]$SpeakerOptimality = spopt      
      results[i,]$Model = "wRSA_binomial"
      results[i,]$Measure = "AllProbability"
      results[i,]$MSE = g["MSE","AllProbability"]
      results[i,]$NRMSE = g["NRMSE","AllProbability"]      
      results[i,]$R = g["r","AllProbability"]      
      results[i,]$R2 = g["R2","AllProbability"]
      i = i+1      
      uniform = data.frame(AllProbability = mp_uniform_allprobs[mp_uniform_allprobs$WonkyWorldPrior == ww & mp_uniform_allprobs$SpeakerOptimality == spopt,]$PosteriorProbability, Expectation = mp_uniform_exps[mp_uniform_exps$WonkyWorldPrior == ww & mp_uniform_exps$SpeakerOptimality == spopt,]$Expectation)  
      g = as.data.frame(gof(empirical, uniform))
      results[i,]$WonkyWorldPrior = ww
      results[i,]$SpeakerOptimality = spopt      
      results[i,]$Model = "wRSA_uniform"
      results[i,]$Measure = "Expectation"
      results[i,]$MSE = g["MSE","Expectation"]
      results[i,]$NRMSE = g["NRMSE","Expectation"]      
      results[i,]$R = g["r","Expectation"]      
      results[i,]$R2 = g["R2","Expectation"]
      i = i+1
      results[i,]$WonkyWorldPrior = ww
      results[i,]$SpeakerOptimality = spopt      
      results[i,]$Model = "wRSA_uniform"
      results[i,]$Measure = "AllProbability"
      results[i,]$MSE = g["MSE","AllProbability"]
      results[i,]$NRMSE = g["NRMSE","AllProbability"]      
      results[i,]$R = g["r","AllProbability"]      
      results[i,]$R2 = g["R2","AllProbability"]
      i = i+1      

  }
  
}

results
m = melt(results, measure.var=c("MSE","NRMSE","R","R2"))
head(m)
m[is.na(m$WonkyWorldPrior),]$WonkyWorldPrior=.5
ggplot(m, aes(x=Model, y=value, color=SpeakerOptimality, shape=WonkyWorldPrior, group=paste(SpeakerOptimality, WonkyWorldPrior))) +
  geom_point() +
  geom_line() +
  facet_grid(variable~Measure, scales="free_y")
ggsave("gof_measures.pdf",width=7,height=9)

results[is.na(results$WonkyWorldPrior),]$WonkyWorldPrior=.5
# to report in paper:
results[results$SpeakerOptimality == 2 & results$WonkyWorldPrior == .5,]


### WONKINESS GOF
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

# get gof for wonkiness with SpeakerOptimality == 2 & WonkyWorldPrior == .5
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/wonky_world/results/data/wr-uniform.RData")

predictions = droplevels(subset(wr, QUD == "how-many" & Alternatives == "0_basic" & WonkyWorldPrior == .5 & Wonky == "true" & SpeakerOptimality == 2))
nrow(predictions)

predictions = predictions[ order(predictions$Quantifier, predictions$Item),]

plot(empirical$response,predictions$PosteriorProbability)
g = gof(empirical$response,predictions$PosteriorProbability)
g



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

