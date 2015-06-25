library(tidyr)

setwd("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/bayesian_model_comparison/results/")
#setwd("~/Documents/research/sinking-marbles/bayesian_model_comparison/results")
#source("../rscripts/helpers.r")

## load empirical data and combine into one data.frame
# wonkiness
load("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/17_sinking-marbles-normal-sliders/results/data/r.RData")
wonkiness <- r[r$quantifier %in% c("Some","All","None"),] %>%
  select(Item,quantifier,response) %>%
  group_by(Item,quantifier) %>%
  summarise(mean.emp.val=mean(response)) %>%
  rename(Quantifier=quantifier)
wonkiness$Measure = "wonkiness"

ggplot(wonkiness, aes(x=mean.emp.val)) +
  geom_histogram() +
  facet_wrap(~Quantifier)

# comp_state
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/13_sinking-marbles-priordv-15/results/data/r.RData")
comp_state <- r[r$quantifier == c("Some"),] %>%
  select(Item,quantifier,response) %>%
  group_by(Item,quantifier) %>%
  summarise(mean.emp.val=mean(response)) %>%
  rename(Quantifier=quantifier)
comp_state$Measure = "comp_state"

ggplot(comp_state, aes(x=mean.emp.val)) +
  geom_histogram() +
  facet_wrap(~Quantifier)

# comp_allprob
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/16_sinking-marbles-sliders-certain/results/data/r.RData")
comp_allprob <- r[r$quantifier == c("Some") & r$Proportion == 100,] %>%
  select(Item,quantifier,normresponse) %>%
  group_by(Item,quantifier) %>%
  summarise(mean.emp.val=mean(normresponse)) %>%
  rename(Quantifier=quantifier)
comp_allprob$Measure = "comp_allprob"

ggplot(comp_allprob, aes(x=mean.emp.val)) +
  geom_histogram() +
  facet_wrap(~Quantifier)

empirical = as.data.frame(droplevels(rbind(comp_state,comp_allprob,wonkiness)))
nrow(empirical)
summary(empirical)
row.names(empirical) = paste(empirical$Item,empirical$Measure,empirical$Quantifier)
head(empirical)

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



