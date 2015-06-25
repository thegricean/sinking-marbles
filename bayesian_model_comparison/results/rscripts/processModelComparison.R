library(tidyr)

setwd("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/bayesian_model_comparison/results/")
#setwd("~/Documents/research/sinking-marbles/bayesian_model_comparison/results")
#source("../rscripts/helpers.r")

### parse results for one spopt parameter and no wonkiness softmax
d = read.csv("munged_regular.csv",sep=",",quote="")
head(d)
summary(d)

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


