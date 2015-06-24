library(tidyr)

setwd("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/bayesian_model_comparison/results/")
#setwd("~/Documents/research/sinking-marbles/bayesian_model_comparison/results")
#source("../rscripts/helpers.r")

d = read.csv("munged.csv",sep=",",quote="")
head(d)
summary(d)

# speaker optimality
d.speakOpt <-unique(d %>% 
  select(SpeakerOptimality, PosteriorProbability)) %>%
  group_by(SpeakerOptimality) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.speakOpt, aes(x=SpeakerOptimality, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())

# wonkiness prior
d.wonkiness <-unique(d %>% 
                      select(WonkinessPrior, PosteriorProbability)) %>%
  group_by(WonkinessPrior) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.wonkiness, aes(x=WonkinessPrior, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())


# LinkingBetaConcentration prior
d.lbc <-unique(d %>% 
          select(LinkingBetaConcentration, 
                 PosteriorProbability)) %>%
  group_by(LinkingBetaConcentration) %>%
  summarise(prob = sum(PosteriorProbability))

ggplot(d.lbc, aes(x=LinkingBetaConcentration, y=prob)) +
  geom_histogram(stat='identity', position=position_dodge())


