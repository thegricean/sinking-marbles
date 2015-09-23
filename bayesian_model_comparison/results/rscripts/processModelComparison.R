
to.n <- function(x) {return(as.numeric(as.character(x)))}
setwd("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/bayesian_model_comparison/results/")
setwd("~/Documents/research/sinking-marbles/bayesian_model_comparison/results")
#source("../rscripts/helpers.r")
#setwd("~/Documents/research/sinking-marbles/bayesian_model_comparison/results")
source("rscripts/helpers.r")

## load priors for generating plots 
priorprobs = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/24_sinking-marbles-prior-fourstep/results/data/smoothed_15marbles_priors_withnames.txt",sep="\t", header=T, quote="")
priorprobs = read.table(file="~/Documents/research/sinking-marbles/experiments/24_sinking-marbles-prior-fourstep/results/data/smoothed_15marbles_priors_withnames.txt",sep="\t", header=T, quote="")


row.names(priorprobs) = priorprobs$Item
nrow(priorprobs)

# prior all-state probability for each item
prior_allprobs = priorprobs[,c("Item","X15")]
row.names(prior_allprobs) = prior_allprobs$Item

# prior expectation for each item
gathered_probs <- priorprobs %>%
  gather(State,Probability,X0:X15)
gathered_probs$State = as.numeric(as.character(gsub("X","",gathered_probs$State)))
prior_exps <- gathered_probs %>%
  group_by(Item) %>%
  summarise(exp.val=sum(State*Probability))
prior_exps = as.data.frame(prior_exps)
row.names(prior_exps) = prior_exps$Item

## load empirical data and combine into one data.frame
# wonkiness

#load("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/11_sinking-marbles-normal/results/data/r.RData")
#load("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/17_sinking-marbles-normal-sliders/results/data/r.RData")
load("~/Documents/research/sinking-marbles/experiments/11_sinking-marbles-normal/results/data/r.RData")

wonkiness <- r[r$quantifier %in% c("Some","All","None"),] %>%
  select(Item,quantifier,numWonky) %>%
  group_by(Item,quantifier) %>%
  summarise(mean.emp.val=mean(numWonky),ci.low=ci.low(numWonky),ci.high=ci.high(numWonky)) %>%
  rename(Quantifier=quantifier)
wonkiness$CILow = wonkiness$mean.emp.val - wonkiness$ci.low
wonkiness$CIHigh = wonkiness$mean.emp.val + wonkiness$ci.high
wonkiness$Measure = "wonkiness"
wonkiness$PriorMeasure = "expected_value"

ggplot(wonkiness, aes(x=mean.emp.val)) +
  geom_histogram() +
  facet_wrap(~Quantifier)

# comp_state
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/13_sinking-marbles-priordv-15/results/data/r.RData")
load("~/Documents/research/sinking-marbles/experiments/13_sinking-marbles-priordv-15/results/data/r.RData")


comp_state <- r[r$quantifier == c("Some"),] %>%
  select(Item,quantifier,response) %>%
  group_by(Item,quantifier) %>%
  summarise(mean.emp.val=mean(response),ci.low=ci.low(response),ci.high=ci.high(response)) %>%
  rename(Quantifier=quantifier)
comp_state$CILow = comp_state$mean.emp.val - comp_state$ci.low
comp_state$CIHigh = comp_state$mean.emp.val + comp_state$ci.high
comp_state$Measure = "comp_state"
comp_state$PriorMeasure = "expected_value"

ggplot(comp_state, aes(x=mean.emp.val)) +
  geom_histogram() +
  facet_wrap(~Quantifier)

# comp_allprob
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/16_sinking-marbles-sliders-certain/results/data/r.RData")
load("~/Documents/research/sinking-marbles/experiments/16_sinking-marbles-sliders-certain/results/data/r.RData")


comp_allprob <- r[r$quantifier == c("Some") & r$Proportion == 100,] %>%
  select(Item,quantifier,normresponse) %>%
  group_by(Item,quantifier) %>%
  summarise(mean.emp.val=mean(normresponse),ci.low=ci.low(normresponse),ci.high=ci.high(normresponse)) %>%
  rename(Quantifier=quantifier)
comp_allprob$CILow = comp_allprob$mean.emp.val - comp_allprob$ci.low
comp_allprob$CIHigh = comp_allprob$mean.emp.val + comp_allprob$ci.high
comp_allprob$Measure = "comp_allprob"
comp_allprob$PriorMeasure = "all_prob"

ggplot(comp_allprob, aes(x=mean.emp.val)) +
  geom_histogram() +
  facet_wrap(~Quantifier)

empirical = as.data.frame(droplevels(rbind(comp_state,comp_allprob,wonkiness)))
nrow(empirical)
summary(empirical)
row.names(empirical) = paste(empirical$Item,empirical$Measure,empirical$Quantifier)
head(empirical)

empirical$Prior = -555
empirical[empirical$PriorMeasure == "expected_value",]$Prior = prior_exps[as.character(empirical[empirical$PriorMeasure == "expected_value",]$Item),]$exp.val
empirical[empirical$PriorMeasure == "all_prob",]$Prior = prior_allprobs[as.character(empirical[empirical$PriorMeasure == "all_prob",]$Item),]$X15

# plot all empirical results
ggplot(empirical, aes(x=Prior,y=mean.emp.val,color=Quantifier)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(~Measure,scales="free")
ggsave("graphs/empirical_curves.pdf",width=15)
ggsave("graphs/empirical_curves.png",width=15)

# plot all empirical results with error bars
ggplot(empirical, aes(x=Prior,y=mean.emp.val,color=Quantifier)) +
  geom_point() +
  geom_smooth() +
  geom_errorbar(aes(ymin=CILow,ymax=CIHigh)) +
  facet_wrap(~Measure,scales="free")
ggsave("graphs/empirical_curves_errbars.pdf",width=15)

items = droplevels(subset(empirical, Item %in% c("stuck to the wall baseballs","fell down shelves","landed flat pancakes","melted ice cubes")))

ggplot(items, aes(x=Prior,y=mean.emp.val,color=Quantifier)) +
  geom_point(size=4) +
  geom_errorbar(aes(ymin=CILow,ymax=CIHigh)) +
  geom_text(aes(label=Item),size=4) +
  facet_wrap(~Measure,scales="free")
ggsave("graphs/empirical_curves_selected.pdf",width=15)
ggsave("graphs/empirical_curves_selected.png",width=15)

### parse results for one spopt parameter and no wonkiness softmax
d = read.csv("munged_regular.csv",sep=",",quote="")
head(d)
summary(d)

## plot posterior predictive -- scatterplot of model vs human
d.postpred<-d %>%
  mutate(Probability = to.n(Probability)) %>%
  group_by(Measure,Item,Quantifier,Response) %>%
  summarise(exp.val = sum(PosteriorProbability*Probability))

d.postpred.expval <- d.postpred %>%
  group_by(Measure,Item,Quantifier) %>%
  summarise(mean.exp.val = sum(Response*exp.val))


#add empirical values
d.postpred.expval$mean.emp.val = empirical[paste(d.postpred.expval$Item,d.postpred.expval$Measure,d.postpred.expval$Quantifier),]$mean.emp.val

#make scatterplot of model against human 
ggplot(d.postpred.expval, aes(x=mean.exp.val,y=mean.emp.val,color=Quantifier)) +
  geom_point() +
  geom_abline(intercept=0,slope=1,color="gray60") +
  facet_wrap(~Measure,scales='free')
ggsave("graphs/scatterplots/regular_model-vs-human.pdf",width=14)

# add priors
d.postpred.expval$Prior = -555
d.postpred.expval[d.postpred.expval$Measure %in% c("comp_state","wonkiness"),]$Prior = prior_exps[as.character(d.postpred.expval[d.postpred.expval$Measure  %in% c("comp_state","wonkiness"),]$Item),]$exp.val
d.postpred.expval[d.postpred.expval$Measure == "comp_allprob",]$Prior = prior_allprobs[as.character(d.postpred.expval[d.postpred.expval$Measure == "comp_allprob",]$Item),]$X15

# plot all model predictions
ggplot(d.postpred.expval, aes(x=Prior,y=mean.exp.val,color=Quantifier)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(~Measure,scales="free")
ggsave("graphs/model_curves_regular.pdf",width=15)


## plot parameter posteriors
# since munged_regular.csv has parameter values repeated for all items in posterior predictive
# take only unique rows (unique sets of parameter values)
d.params <- unique(d %>% select(SpeakerOptimality, 
                         WonkinessPrior,
                         LinkingBetaConcentration,
                         PosteriorProbability))

# speaker optimality
d.speakOpt <- d.params %>% 
  group_by(SpeakerOptimality) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.speakOpt, aes(x=SpeakerOptimality, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge(),width=.1)
ggsave("graphs/regular_spopt.png",width=8,height=6)

# wonkiness prior
d.wonkiness <-d.params %>% 
  group_by(WonkinessPrior) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.wonkiness, aes(x=WonkinessPrior, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())
ggsave("graphs/regular_wprior.png",width=8,height=6)

# LinkingBetaConcentration prior
d.lbc <- d.params %>% 
  group_by(LinkingBetaConcentration) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.lbc, aes(x=LinkingBetaConcentration, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())
ggsave("graphs/regular_linkbetaconcentration.png",width=8,height=6)

### parse results for three spopt parameters and no wonkiness softmax
d = read.csv("munged_3speakers.csv",sep=",",quote="")
nrow(d)
head(d)
summary(d)

## plot posterior predictive -- scatterplot of model vs human
d.postpred<-d %>%
  mutate(Probability = to.n(Probability)) %>%
  group_by(Measure,Item,Quantifier,Response) %>%
  summarise(exp.val = sum(PosteriorProbability*Probability))

d.postpred.expval <- d.postpred %>%
  group_by(Measure,Item,Quantifier) %>%
  summarise(mean.exp.val = sum(Response*exp.val))

#add empirical values
d.postpred.expval$mean.emp.val = empirical[paste(d.postpred.expval$Item,d.postpred.expval$Measure,d.postpred.expval$Quantifier),]$mean.emp.val

#make scatterplot of model against human 
ggplot(d.postpred.expval, aes(x=mean.exp.val,y=mean.emp.val,color=Quantifier)) +
  geom_point() +
  geom_abline(intercept=0,slope=1,color="gray60") +
  facet_wrap(~Measure,scales='free')
ggsave("graphs/scatterplots/3speakers_model-vs-human.pdf",width=14)

# add priors
d.postpred.expval$Prior = -555
d.postpred.expval[d.postpred.expval$Measure %in% c("comp_state","wonkiness"),]$Prior = prior_exps[as.character(d.postpred.expval[d.postpred.expval$Measure  %in% c("comp_state","wonkiness"),]$Item),]$exp.val
d.postpred.expval[d.postpred.expval$Measure == "comp_allprob",]$Prior = prior_allprobs[as.character(d.postpred.expval[d.postpred.expval$Measure == "comp_allprob",]$Item),]$X15

# plot all model predictions
ggplot(d.postpred.expval, aes(x=Prior,y=mean.exp.val,color=Quantifier)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(~Measure,scales="free")
ggsave("graphs/model_curves_3speakers.pdf",width=15)

# since munged_xxx.csv has parameter values repeated for all items in posterior predictive
# take only unique rows (unique sets of parameter values)
d.params <- unique(d %>% select(SpeakerOptimality1, 
                                SpeakerOptimality2,
                                SpeakerOptimality3,
                                WonkinessPrior,
                                LinkingBetaConcentration,
                                PosteriorProbability))

# speaker optimality 1
d.speakOpt1 <- d.params %>% 
  group_by(SpeakerOptimality1) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.speakOpt1, aes(x=SpeakerOptimality1, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())
ggsave("graphs/3spopt_compstate_spopt.png",width=8,height=6)

# speaker optimality 2
d.speakOpt2 <- d.params %>% 
  group_by(SpeakerOptimality2) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.speakOpt2, aes(x=SpeakerOptimality2, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())
ggsave("graphs/3spopt_compallprob_spopt.png",width=8,height=6)

# speaker optimality 3
d.speakOpt3 <- d.params %>% 
  group_by(SpeakerOptimality3) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.speakOpt3, aes(x=SpeakerOptimality3, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())
ggsave("graphs/3spopt_wonkiness_spopt.png",width=8,height=6)

# wonkiness prior
d.wonkiness <-d.params %>% 
  group_by(WonkinessPrior) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.wonkiness, aes(x=WonkinessPrior, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())
ggsave("graphs/3spopt_wprior.png",width=8,height=6)

# LinkingBetaConcentration prior
d.lbc <- d.params %>% 
  group_by(LinkingBetaConcentration) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.lbc, aes(x=LinkingBetaConcentration, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())
ggsave("graphs/3spopt_linkbetaconcentration.png",width=8,height=6)


### parse results for one spopt parameter and wonkiness softmax
d = read.csv("munged_wonkysoftmax.csv",sep=",",quote="")
head(d)
summary(d)

## plot posterior predictive -- scatterplot of model vs human
d.postpred<-d %>%
  mutate(Probability = to.n(Probability)) %>%
  group_by(Measure,Item,Quantifier,Response) %>%
  summarise(exp.val = sum(PosteriorProbability*Probability))

d.postpred.expval <- d.postpred %>%
  group_by(Measure,Item,Quantifier) %>%
  summarise(mean.exp.val = sum(Response*exp.val))

#add empirical values
d.postpred.expval$mean.emp.val = empirical[paste(d.postpred.expval$Item,d.postpred.expval$Measure,d.postpred.expval$Quantifier),]$mean.emp.val

#make scatterplot of model against human 
ggplot(d.postpred.expval, aes(x=mean.exp.val,y=mean.emp.val,color=Quantifier)) +
  geom_point() +
  geom_abline(intercept=0,slope=1,color="gray60") +
  facet_wrap(~Measure,scales='free')
ggsave("graphs/scatterplots/wonkysoftmax_model-vs-human.pdf",width=14)

# add priors
d.postpred.expval$Prior = -555
d.postpred.expval[d.postpred.expval$Measure %in% c("comp_state","wonkiness"),]$Prior = prior_exps[as.character(d.postpred.expval[d.postpred.expval$Measure  %in% c("comp_state","wonkiness"),]$Item),]$exp.val
d.postpred.expval[d.postpred.expval$Measure == "comp_allprob",]$Prior = prior_allprobs[as.character(d.postpred.expval[d.postpred.expval$Measure == "comp_allprob",]$Item),]$X15

# plot all model predictions
ggplot(d.postpred.expval, aes(x=Prior,y=mean.exp.val,color=Quantifier)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(~Measure,scales="free")
ggsave("graphs/model_curves_wonkysoftmax.pdf",width=15)

# since munged_regular.csv has parameter values repeated for all items in posterior predictive
# take only unique rows (unique sets of parameter values)
d.params <- unique(d %>% select(SpeakerOptimality, 
                                WonkinessPrior,
                                LinkingBetaConcentration,
                                WonkySoftmax,
                                PosteriorProbability))

# speaker optimality
d.speakOpt <- d.params %>% 
  group_by(SpeakerOptimality) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.speakOpt, aes(x=SpeakerOptimality, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())
ggsave("graphs/wonkysoftmax_spopt.png",width=8,height=6)

# wonkiness prior
d.wonkiness <-d.params %>% 
  group_by(WonkinessPrior) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.wonkiness, aes(x=WonkinessPrior, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())
ggsave("graphs/wonkysoftmax_wprior.png",width=8,height=6)

# wonkysoftmax 
d.wsoftmax <-d.params %>% 
  group_by(WonkySoftmax) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.wsoftmax, aes(x=WonkySoftmax, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())
ggsave("graphs/wonkysoftmax_wsoftmax.png",width=8,height=6)

# LinkingBetaConcentration prior
d.lbc <- d.params %>% 
  group_by(LinkingBetaConcentration) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.lbc, aes(x=LinkingBetaConcentration, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())
ggsave("graphs/wonkysoftmax_linkbetaconcentration.png",width=8,height=6)


### parse results for three spopt parameters and wonkiness softmax
d = read.csv("munged_3sp-ws.csv",sep=",",quote="")
nrow(d)
head(d)
summary(d)

## plot posterior predictive -- scatterplot of model vs human
d.postpred<-d %>%
  mutate(Probability = to.n(Probability)) %>%
  group_by(Measure,Item,Quantifier,Response) %>%
  summarise(exp.val = sum(PosteriorProbability*Probability))

d.postpred.expval <- d.postpred %>%
  group_by(Measure,Item,Quantifier) %>%
  summarise(mean.exp.val = sum(Response*exp.val))

#add empirical values
d.postpred.expval$mean.emp.val = empirical[paste(d.postpred.expval$Item,d.postpred.expval$Measure,d.postpred.expval$Quantifier),]$mean.emp.val

#make scatterplot of model against human 
ggplot(d.postpred.expval, aes(x=mean.exp.val,y=mean.emp.val,color=Quantifier)) +
  geom_point() +
  geom_abline(intercept=0,slope=1,color="gray60") +
  facet_wrap(~Measure,scales='free')
ggsave("graphs/scatterplots/3sp-ws_model-vs-human.pdf",width=14)

# add priors
d.postpred.expval$Prior = -555
d.postpred.expval[d.postpred.expval$Measure %in% c("comp_state","wonkiness"),]$Prior = prior_exps[as.character(d.postpred.expval[d.postpred.expval$Measure  %in% c("comp_state","wonkiness"),]$Item),]$exp.val
d.postpred.expval[d.postpred.expval$Measure == "comp_allprob",]$Prior = prior_allprobs[as.character(d.postpred.expval[d.postpred.expval$Measure == "comp_allprob",]$Item),]$X15

# plot all model predictions
ggplot(d.postpred.expval, aes(x=Prior,y=mean.exp.val,color=Quantifier)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(~Measure,scales="free")
ggsave("graphs/model_curves_3sp-ws.pdf",width=15)


# since munged_xxx.csv has parameter values repeated for all items in posterior predictive
# take only unique rows (unique sets of parameter values)
d.params <- unique(d %>% select(SpeakerOptimality1, 
                                SpeakerOptimality2,
                                SpeakerOptimality3,
                                WonkinessPrior,
                                LinkingBetaConcentration,
                                WonkySoftmax,
                                PosteriorProbability))

# speaker optimality 1
d.speakOpt1 <- d.params %>% 
  group_by(SpeakerOptimality1) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.speakOpt1, aes(x=SpeakerOptimality1, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())
ggsave("graphs/3sp-ws_compstate_spopt.png",width=8,height=6)

# speaker optimality 2
d.speakOpt2 <- d.params %>% 
  group_by(SpeakerOptimality2) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.speakOpt2, aes(x=SpeakerOptimality2, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())
ggsave("graphs/3sp-ws_compallprob_spopt.png",width=8,height=6)

# speaker optimality 3
d.speakOpt3 <- d.params %>% 
  group_by(SpeakerOptimality3) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.speakOpt3, aes(x=SpeakerOptimality3, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())
ggsave("graphs/3sp-ws_wonkiness_spopt.png",width=8,height=6)

# wonkiness prior
d.wonkiness <-d.params %>% 
  group_by(WonkinessPrior) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.wonkiness, aes(x=WonkinessPrior, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())
ggsave("graphs/3sp-ws_wprior.png",width=8,height=6)

# LinkingBetaConcentration prior
d.lbc <- d.params %>% 
  group_by(LinkingBetaConcentration) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.lbc, aes(x=LinkingBetaConcentration, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge(),width=.2)
ggsave("graphs/3sp-ws_linkbetaconcentration.png",width=8,height=6)

# wonkysoftmax 
d.wsoftmax <-d.params %>% 
  group_by(WonkySoftmax) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.wsoftmax, aes(x=WonkySoftmax, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())
ggsave("graphs/3sp-ws_wsoftmax.png",width=8,height=6)


### parse results for three spopt parameters and wonkiness softmax and 2 different beta linking functions for wonkiness and allprob task
d = read.csv("munged_3sp-ws-2betas.csv",sep=",",quote="")
nrow(d)
head(d)
summary(d)

## plot posterior predictive -- scatterplot of model vs human
d.postpred<-d %>%
  mutate(Probability = to.n(Probability)) %>%
  group_by(Measure,Item,Quantifier,Response) %>%
  summarise(exp.val = sum(PosteriorProbability*Probability))

d.postpred.expval <- d.postpred %>%
  group_by(Measure,Item,Quantifier) %>%
  summarise(mean.exp.val = sum(Response*exp.val))

#add empirical values
d.postpred.expval$mean.emp.val = empirical[paste(d.postpred.expval$Item,d.postpred.expval$Measure,d.postpred.expval$Quantifier),]$mean.emp.val

#make scatterplot of model against human 
ggplot(d.postpred.expval, aes(x=mean.exp.val,y=mean.emp.val,color=Quantifier)) +
  geom_point() +
  geom_abline(intercept=0,slope=1,color="gray60") +
  facet_wrap(~Measure,scales='free')
ggsave("graphs/scatterplots/3sp-ws-2betas_model-vs-human.pdf",width=14)

# add priors
d.postpred.expval$Prior = -555
d.postpred.expval[d.postpred.expval$Measure %in% c("comp_state","wonkiness"),]$Prior = prior_exps[as.character(d.postpred.expval[d.postpred.expval$Measure  %in% c("comp_state","wonkiness"),]$Item),]$exp.val
d.postpred.expval[d.postpred.expval$Measure == "comp_allprob",]$Prior = prior_allprobs[as.character(d.postpred.expval[d.postpred.expval$Measure == "comp_allprob",]$Item),]$X15

# plot all model predictions
ggplot(d.postpred.expval, aes(x=Prior,y=mean.exp.val,color=Quantifier)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(~Measure,scales="free")
ggsave("graphs/model_curves_3sp-ws-2betas.pdf",width=15)

# since munged_xxx.csv has parameter values repeated for all items in posterior predictive
# take only unique rows (unique sets of parameter values)
d.params <- unique(d %>% select(SpeakerOptimality1, 
                                SpeakerOptimality2,
                                SpeakerOptimality3,
                                WonkinessPrior,
                                LinkingBetaConcentration_allprob,
                                LinkingBetaConcentration_wonky,
                                WonkySoftmax,
                                PosteriorProbability))

# speaker optimality 1
d.speakOpt1 <- d.params %>% 
  group_by(SpeakerOptimality1) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.speakOpt1, aes(x=SpeakerOptimality1, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())
ggsave("graphs/3sp-ws-2betas_compstate_spopt.png",width=8,height=6)

# speaker optimality 2
d.speakOpt2 <- d.params %>% 
  group_by(SpeakerOptimality2) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.speakOpt2, aes(x=SpeakerOptimality2, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())
ggsave("graphs/3sp-ws-2betas_compallprob_spopt.png",width=8,height=6)

# speaker optimality 3
d.speakOpt3 <- d.params %>% 
  group_by(SpeakerOptimality3) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.speakOpt3, aes(x=SpeakerOptimality3, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())
ggsave("graphs/3sp-ws-2betas_wonkiness_spopt.png",width=8,height=6)

# wonkiness prior
d.wonkiness <-d.params %>% 
  group_by(WonkinessPrior) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.wonkiness, aes(x=WonkinessPrior, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())
ggsave("graphs/3sp-ws-2betas_wprior.png",width=8,height=6)

# LinkingBetaConcentration_allprob prior
d.lbc <- d.params %>% 
  group_by(LinkingBetaConcentration_allprob) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.lbc, aes(x=LinkingBetaConcentration_allprob, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge(),width=.2)
ggsave("graphs/3sp-ws-2betas_linkbetaconcentration_allprob.png",width=8,height=6)

# LinkingBetaConcentration_wonky prior
d.lbc <- d.params %>% 
  group_by(LinkingBetaConcentration_wonky) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.lbc, aes(x=LinkingBetaConcentration_wonky, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge(),width=.2)
ggsave("graphs/3sp-ws-2betas_linkbetaconcentration_wonky.png",width=8,height=6)

# wonkysoftmax 
d.wsoftmax <-d.params %>% 
  group_by(WonkySoftmax) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.wsoftmax, aes(x=WonkySoftmax, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())
ggsave("graphs/3sp-ws-2betas_wsoftmax.png",width=8,height=6)



### parse results for three spopt parameters and 2 linking sigmas for wonkiness and allprob task
d = read.csv("munged_3sp-2sigmas.csv",sep=",",quote="")
nrow(d)
head(d)
summary(d)

## plot posterior predictive -- scatterplot of model vs human
d.postpred<-d %>%
  mutate(Probability = to.n(Probability)) %>%
  group_by(Measure,Item,Quantifier,Response) %>%
  summarise(exp.val = sum(PosteriorProbability*Probability))

d.postpred.expval <- d.postpred %>%
  group_by(Measure,Item,Quantifier) %>%
  summarise(mean.exp.val = sum(Response*exp.val))

#add empirical values
d.postpred.expval$mean.emp.val = empirical[paste(d.postpred.expval$Item,d.postpred.expval$Measure,d.postpred.expval$Quantifier),]$mean.emp.val

#make scatterplot of model against human 
ggplot(d.postpred.expval, aes(x=mean.exp.val,y=mean.emp.val,color=Quantifier)) +
  geom_point() +
  geom_abline(intercept=0,slope=1,color="gray60") +
  facet_wrap(~Measure,scales='free')
ggsave("graphs/scatterplots/3sp-2sigmas_model-vs-human.pdf",width=14)

# add priors
d.postpred.expval$Prior = -555
d.postpred.expval[d.postpred.expval$Measure %in% c("comp_state","wonkiness"),]$Prior = prior_exps[as.character(d.postpred.expval[d.postpred.expval$Measure  %in% c("comp_state","wonkiness"),]$Item),]$exp.val
d.postpred.expval[d.postpred.expval$Measure == "comp_allprob",]$Prior = prior_allprobs[as.character(d.postpred.expval[d.postpred.expval$Measure == "comp_allprob",]$Item),]$X15

# plot all model predictions
ggplot(d.postpred.expval, aes(x=Prior,y=mean.exp.val,color=Quantifier)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(~Measure,scales="free")
ggsave("graphs/model_curves_3sp-2sigmas.pdf",width=15)

# since munged_xxx.csv has parameter values repeated for all items in posterior predictive
# take only unique rows (unique sets of parameter values)
d.params <- unique(d %>% select(SpeakerOptimality1, 
                                SpeakerOptimality2,
                                SpeakerOptimality3,
                                Sigma_allprob,
                                Sigma_wonky,
                                WonkinessPrior,
                                PosteriorProbability))

# speaker optimality 1
d.speakOpt1 <- d.params %>% 
  group_by(SpeakerOptimality1) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.speakOpt1, aes(x=SpeakerOptimality1, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())
ggsave("graphs/3sp-2sigmas_compstate_spopt.png",width=8,height=6)

# speaker optimality 2
d.speakOpt2 <- d.params %>% 
  group_by(SpeakerOptimality2) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.speakOpt2, aes(x=SpeakerOptimality2, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())
ggsave("graphs/3sp-2sigmas_compallprob_spopt.png",width=8,height=6)

# speaker optimality 3
d.speakOpt3 <- d.params %>% 
  group_by(SpeakerOptimality3) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.speakOpt3, aes(x=SpeakerOptimality3, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())
ggsave("graphs/3sp-2sigmas_wonkiness_spopt.png",width=8,height=6)

# wonkiness prior
d.wonkiness <-d.params %>% 
  group_by(WonkinessPrior) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.wonkiness, aes(x=WonkinessPrior, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())
ggsave("graphs/3sp-2sigmas_wprior.png",width=8,height=6)

# linking sigma allprob
d.lbc <- d.params %>% 
  group_by(Sigma_allprob) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.lbc, aes(x=Sigma_allprob, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge(),width=.2)
ggsave("graphs/3sp-2sigmas_allprob.png",width=8,height=6)

# linking sigma wonky
d.lbc <- d.params %>% 
  group_by(Sigma_wonky) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.lbc, aes(x=Sigma_wonky, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge(),width=.2)
ggsave("graphs/3sp-2sigmas_wonky.png",width=8,height=6)



### parse results for three spopt parameters and wonkiness softmax and 2 different beta linking functions for wonkiness and allprob task
d = read.csv("munged_enumerated.csv",sep=",",quote="")
nrow(d)
head(d)
summary(d)

# since munged_xxx.csv has parameter values repeated for all items in posterior predictive
# take only unique rows (unique sets of parameter values)
d.params <- unique(d %>% select(SpeakerOptimality, 
                                LinkingBetaConcentration,
                                WonkinessPrior,
                                WonkySoftmax,
                                PosteriorProbability))

# speaker optimality 1
d.speakOpt <- d.params %>% 
  group_by(SpeakerOptimality) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.speakOpt, aes(x=SpeakerOptimality, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())
ggsave("graphs/enumerated_spopt.png",width=8,height=6)

# wonkiness prior
d.wonkiness <-d.params %>% 
  group_by(WonkinessPrior) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.wonkiness, aes(x=WonkinessPrior, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())
ggsave("graphs/enumerated_wprior.png",width=8,height=6)

# LinkingBetaConcentration_allprob prior
d.lbc <- d.params %>% 
  group_by(LinkingBetaConcentration) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.lbc, aes(x=LinkingBetaConcentration, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge(),width=.2)
ggsave("graphs/enumerated_linkbetaconcentration.png",width=8,height=6)

# LinkingBetaConcentration_wonky prior
d.lbc <- d.params %>% 
  group_by(WonkySoftmax) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.lbc, aes(x=WonkySoftmax, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge(),width=.2)
ggsave("graphs/enumerated_wonkysoftmax.png",width=8,height=6)



### MHT's code

backoutSamples <- function(totalN, prob, response){
  return(rep(response,prob*totalN))
}

library(coda)
estimate_mode <- function(s) {
  d <- density(s)
  return(d$x[which.max(d$y)])
}
HPDhi<- function(s){
  m <- HPDinterval(mcmc(s))
  return(m["var1","upper"])
}
HPDlo<- function(s){
  m <- HPDinterval(mcmc(s))
  return(m["var1","lower"])
}




# d0<-read.csv('wonkyFBTPosterior_wonkyTF_so_wp_phi_sigma_offset_scale_ws_CTS_mh5000b2500.csv',header=F)
# d<-read.csv('wonkyFBTPosterior_wonkyTF_so_wp_phi_sigma_offset_scale_ws_CTS_mh2000b1000.csv',header=F)
#d<-read.csv('wonkyFBTPosterior_wonkyTF_so_wp_phi_sigma_offset_scale_ws_CTS_mh15000b5000.csv', header=F)
#d<-read.csv('wonkyFBTPosterior_wonkyTF_so_wp_phi_allProb-scale-offset-sigma_CTS_hashMH50000compiled.csv')
#d<-read.csv('wonkyFBTPosterior_wonkyTF_so_wp_phi_allProb-scale-offset-sigma_wonkiness-scale-offset_CTS_hashMH50000compiled.csv')
#d<-read.csv('wonkyFBTPosterior_wonkyTF_so_wp_phi_allProb-scale-offset-sigma_CTS_hashMH50000compiled.csv')
#d<-read.csv('wonkyFBTPosterior_wonkyTF_so_wp_phi_allProb-scale-offset-sigma_wonkiness-scale_CTS_hashMH50000compiled.csv')
#d<-read.csv('wonkyFBTPosterior_wonkyTF_so_wp_phi_allProb-scale-offset_wonkiness-scale-offset_CTS_hashMH50000compiled.csv')
#d<-read.csv('wonkyFBTPosterior_wonkySlider_so_wp_phi_allProb-scale-offset-sigma_wonkiness-scale-offset-sigma_CTS_incrMH50000.csv')
prefix<-"allQ_wonkyTF_so_wp_phi_allProb-sigma-scale-offset_wonky-softmax_CTS_hashMH"

prefix<-"allQ_wonkyTF_2so_wp_phi_allProb-sigma-scale-offset_wonky-softmax_CTS_hashMH"
prefix<-"justCompState2xdata_fellDownCardTowers_soAtLeast1_originalPriors_so_wp_NOphi_CTS_hashMH"
prefix<-"justCompState2xdata_paramsByItem_soAtLeast1_originalPriors_so_wp_NOphi_CTS_incrMH"
prefix<-"justCompState2xdata_paramsByItem_originalPriors_so_wp_NOphi_CTS_incrMH"
prefix<-"justCompState2xdata_soByItem_originalPriors_so_wp_NOphi_CTS_incrMH"




prefix<-"justCompState_wRepData_originalPriors_so_wp_phi_CTS_allProb-sigma-scale-offset_incrMH"
prefix<-"justCompState_wRepData_originalPriors_so_wp_phi_CTS_incrMH"
prefix<-"justCompState_wRepData_originalPriors_so_wp_phiByItem_CTS_incrMH"




#prefix<-"allQ_originalPriors_wonkyTF_2so_wp_phi_allProb-sigma-scale-offset_CTS_incrMH"


prefix<-"fullPost_expecatationLink_sharedSigma_justCompState_wRepData_originalPriors_so_wp_noPhi_CTS_incrMH"
prefix<-"expecatationLink_sharedSigma_justCompState_wRepData_originalPriors_so_wp_noPhi_CTS_incrMH"

prefix<-"basicRSA_FBTPosterior_expecatationLink_sharedSigma_justCompState_wRepData_inclZero_4stepPriors_so_wp_noPhi_CTS_hashMH"
prefix<-"wonkyRSA_FBTPosterior_expecatationLink_sharedSigma_justCompState_wRepData_inclZero_originalPriors_so_wp_noPhi_CTS_hashMH"
prefix<-"basicRSA_FBTPosterior_expecatationLink_sharedSigma_justCompState_wRepData_inclZero_bdaPriors50k_so_wp_noPhi_CTS_incrMH"
prefix<-"regularRSA_FBTPosterior_expecatationLink_sharedSigma_justCompState_wRepData_inclZero_bdaPriors50k_so_wp_noPhi_CTS_incrMH"
prefix<-"wonkyRSA_FBTPosterior_expecatationLink_sharedSigma_justCompState_wRepData_inclZero_bdaPriors50k_so_wp_noPhi_CTS_incrMH"




samples<-10000
#d<-read.csv(paste("wonkyFBTPosterior_",prefix,samples,'0burn',samples/2,'0a.csv',sep=''))
#d<-read.csv(paste("wonkyFBTPosterior_",prefix,samples,'burn0a.csv',sep=''))
#d<-read.csv(paste("wonkyRSA_FBTPosterior_",prefix,samples,'burn0a.csv',sep=''))
d<-read.csv(paste(prefix,samples,'burn',samples/2,'a.csv',sep=''))




# d<-bind_rows(d,d0)
# d<- d %>%
#   rename(Parameter = V1,
#          Item = V2,
#          Quantifier = V3,
#          Response = V4,
#          Probability = V5)


# ggplot(d.params,aes(x=Response,y=Probability))+
#   geom_bar(stat='identity', position=position_dodge())+
#   facet_wrap(~Parameter,scales="free")



## params by item

d.paramsByItem <- d %>%
  filter(!((Parameter%in%c("comp_allprob", "comp_state","wonkiness")) | (Item=='na')))

## for continuous variables
d.paramsByItem <- data.frame(Parameter = rep(d.paramsByItem$Parameter, 1+samples*d.paramsByItem$Probability),
                             Item = rep(d.paramsByItem$Item, 1+samples*d.paramsByItem$Probability),
                       Response = rep(to.n(d.paramsByItem$Value), 1+samples*d.paramsByItem$Probability))

ggplot(d.paramsByItem, aes(x=Response))+
  geom_histogram()+
  facet_wrap(~Item)


d.paramSummary<- d.paramsByItem %>%
  group_by(Parameter, Item) %>%
  summarise( MAP = estimate_mode(Response),
             credHi = HPDhi(Response),
             credLo = HPDlo(Response))


d.paramsWpriors<-left_join(d.paramSummary, prior_exps)


d.paramsWpriors$priorQuantile <- d.paramsWpriors$priorQuantile
d.paramsWpriors$binnedExpVal = cut(d.paramsWpriors$exp.val,breaks=5)


d.paramsWpriors$Item<-with(d.paramsWpriors %>% filter(Parameter=='phi'), 
                             reorder(Item, MAP, function(x) -x))





ggplot(data=d.paramsWpriors, aes(x=Item, y=MAP, fill=binnedExpVal))+
  geom_bar(stat='identity',position=position_dodge(), alpha=0.5)+
  geom_errorbar(aes(ymin=credLo, ymax=credHi),position=position_dodge())+
  facet_wrap(~Parameter, scales='free')+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+
  scale_fill_brewer(palette='Set1')

d.paramsWpriors %>% group_by(Parameter) %>% summarise(mean(MAP))

table(d.paramsWpriors$binnedExpVal)


ggplot(data=d.paramsWpriors, aes(x=MAP))+
  geom_histogram(binwidth=0.002)
# ggplot(d.params,aes(x=Response))+
#   geom_histogram()+
#   facet_wrap(~Parameter,scales="free")
# 
# ###




d.params <- d %>%
  #filter(!(Parameter%in%c("comp_allprob", "comp_state","wonkiness"))& (Item=='na')) %>%
  filter((Item=='na')) %>%#
  select(-Item, -Quantifier)

## for continuous variables
d.params <- data.frame(Parameter = rep(d.params$Parameter, 1+samples*d.params$Probability),
                       Response = rep(to.n(d.params$Value), 1+samples*d.params$Probability))


ggplot(d.params,aes(x=Response))+
  geom_histogram()+
  facet_wrap(~Parameter,scales="free")

ggsave(paste("graphs/model_curves/postparams-",prefix,samples,".pdf",sep=''),width=15)





d.params %>%
  group_by(Parameter) %>%
  summarise(MAP = estimate_mode(Response),
            credHi = HPDhi(Response),
            credLo = HPDlo(Response))


d.postpred <-  d %>% 
  filter(Bin %in% c("rawExpectation", "linkedExpectation")) %>%
  rename(Type = Bin) %>%
  #filter(Bin %in% c("rawExpectation")) %>%
  filter(Parameter%in%c("comp_allprob", "comp_state","wonkiness")) %>%
  mutate(Probability = to.n(Probability),
         Value = to.n(Value))


d.postpred <-  d %>% 
  filter(Parameter%in%c("comp_allprob", "comp_state","wonkiness")) %>%
  mutate(Probability = to.n(Probability),
         Value = to.n(Value))



d.postpred <- data.frame(Parameter = rep(d.postpred$Parameter, 
                                         1+samples*d.postpred$Probability),
                         Type = rep(d.postpred$Type,
                                    1+samples*d.postpred$Probability),
                         Item = rep(d.postpred$Item, 
                                    1+samples*d.postpred$Probability),
                         Quantifier = rep(d.postpred$Quantifier,
                                          1+samples*d.postpred$Probability),
                         Response = rep(d.postpred$Value, 
                                        1+samples*d.postpred$Probability))



## plot posterior predictive -- scatterplot of model vs human
d.pp <- d.postpred %>%
  rename(Measure=Parameter) %>%
  group_by(Measure,Item,Quantifier, Type) %>%
  summarise(MAPexpval = estimate_mode(Response),
            credHi = HPDhi(Response),
            credLo = HPDlo(Response))

d.pp$Prior = -555
d.pp[d.pp$Measure %in% c("comp_state","wonkiness"),]$Prior = prior_exps[as.character(d.pp[d.pp$Measure  %in% c("comp_state","wonkiness"),]$Item),]$exp.val
d.pp[d.pp$Measure == "comp_allprob",]$Prior = prior_allprobs[as.character(d.pp[d.pp$Measure == "comp_allprob",]$Item),]$X15

# plot all model predictions
ggplot(d.pp %>% filter(Type=='linkedExpectation'), 
       aes(x=Prior,y=MAPexpval,color=Quantifier)) +
  geom_point() +
  # geom_errorbar(aes(ymin = credLo, ymax = credHi))+
  #geom_smooth() +
  #facet_wrap(~Measure,scales="free")
facet_wrap(~Measure,scales="free")


ggsave(paste("graphs/model_curves/postpred-",prefix,samples,".pdf",sep=''),width=15)


for (meas in levels(factor(d.pp$Measure))){
  print(range((d.pp %>% filter((Measure==meas) & (Quantifier=='Some')))$MAPexpval))
#  print(range((d.pp %>% filter((Measure==meas) & (Quantifier=='Some')))$Prior))
}



#add empirical values
d.pp$mean.emp.val = empirical[paste(d.pp$Item,d.pp$Measure,d.pp$Quantifier),]$mean.emp.val



#make scatterplot of model against human 
ggplot(d.pp, aes(x=MAPexpval,y=mean.emp.val,color=Quantifier)) +
  geom_point() +
  geom_errorbarh(aes(xmin = credLo, xmax = credHi))+
  geom_abline(intercept=0,slope=1,color="gray60") +
  facet_wrap(~Measure,scales='free')

# 
# ggsave("graphs/scatterplots/logisticlink_model-vs-human.pdf",width=14)


with((d.pp %>% filter(Measure=='wonkiness')),cor(MAPexpval,mean.emp.val,use='pairwise.complete.obs'))
with((d.pp %>% filter(Measure=='comp_state')),cor(MAPexpval,mean.emp.val,use='pairwise.complete.obs'))
with((d.pp %>% filter(Measure=='comp_allprob')),cor(MAPexpval,mean.emp.val,use='pairwise.complete.obs'))



some.wonkiness<-d.pp %>% filter(Measure=='wonkiness' & Quantifier == 'Some')



#full posterior

d.postpred <-  d %>% 
  filter(Parameter%in%c("comp_allprob", "comp_state","wonkiness") & 
           (Bin!="expectation")) %>%
  mutate(Probability = to.n(Probability),
         Value = to.n(Value))

d.postpred <- data.frame(Parameter = rep(d.postpred$Parameter, 
                                         1+samples*d.postpred$Probability),
                         Item = rep(d.postpred$Item, 
                                    1+samples*d.postpred$Probability),
                         Quantifier = rep(d.postpred$Quantifier,
                                          1+samples*d.postpred$Probability),
                         Bin = rep(d.postpred$Bin,
                                          1+samples*d.postpred$Probability),
                         Response = rep(d.postpred$Value, 
                                        1+samples*d.postpred$Probability))






d.fullpost <- d.postpred %>%
  group_by(Parameter, Item, Quantifier, Bin) %>%
  summarise(MAP = estimate_mode(Response),
            credHigh = HPDhi(Response),
            credLow = HPDlo(Response)) %>%
  mutate(Bin = to.n(Bin))


ggplot(d.fullpost %>% filter(Item =='ate the seeds birds' &
                               Quantifier == 'Some'),
       aes(x=Bin, y = MAP))+
  geom_bar(position=position_dodge(), stat='identity', alpha=0.5)+
  geom_errorbar(aes(ymin=credLow, ymax=credHigh), position=position_dodge())+
  facet_wrap(~Item)


cs.data<- read.csv("~/Documents/research/sinking-marbles/bayesian_model_comparison/data/empirical_binarywonky_nozero.csv")


cs.tidy<-cs.data %>% filter(measure=='comp_state') %>%
  rename(Item = item,
         Quantifier= utterance)

ggplot(cs.tidy %>% filter(utterance=='Some'), 
       aes(x=response))+
  geom_histogram(binwidth=1)+
  facet_wrap(~item)



i = 'melted pencils'
ggplot(d.fullpost %>% filter( Quantifier == 'Some'),
       aes(x=Bin, y = MAP))+
  geom_bar(position=position_dodge(), stat='identity', alpha=0.5)+
  geom_errorbar(aes(ymin=credLow, ymax=credHigh), position=position_dodge())+
  geom_histogram(data=cs.tidy %>% filter(Quantifier=='Some'),
                 aes(x=response, 
                     y=(..count..)/tapply(..count..,..PANEL..,sum)[..PANEL..]
                     ),
                 binwidth=1,
                 fill='blue',
                 alpha=0.3,
                 position=position_dodge())+
  facet_wrap(~Item)


ggsave(paste("graphs/model_curves/fullPosteriors-",prefix,samples,".pdf",sep=''),width=25, height=15)




# parameter exploration
prefix<-"justComp_logProbs_enumerate_wEnds"
prefix<-"justCompState_logProbs_enumerate_wEnds"

prefix<-"regularRSA_logProbs_factorState_justComp_justSome_so-sigma_enumerate"


#prefix<-"allQ_originalPriors_wonkyTF_2so_wp_phi_allProb-sigma-scale-offset_CTS_incrMH"




#samples<-3000

d<-read.csv(paste(prefix,'.csv',sep=''))

d.p<-d %>% rename(wonkyPrior = Parameter,
             phi = Item,
             optimality = Quantifier,
             logProb = Value) %>%
  group_by(wonkyPrior, optimality, phi) %>%
  summarise(val = sum(logProb*Probability))

ggplot(d.p, aes(x=wonkyPrior, y = optimality, fill=val))+
  geom_tile()+
  facet_wrap(~phi)+
  geom_point(data = d.p[which.max(d.p$val),], 
            aes(x=wonkyPrior, y = optimality), color='black', size=3)

d.p[which.max(d.p$val),]

prefix<-"justComp_preds_enumerate_noEnds"


d<-read.csv(paste("wonkyFBTPosterior_",prefix,'.csv',sep=''))



