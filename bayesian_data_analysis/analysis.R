library(tidyr)
setwd("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/bayesian_data_analysis/")
source("helpers.r")

# get Bayesian data analysis results
# level 2 model
d <- read.csv('inferBinomialParams.csv',header=F)
# level 1 model
d <- read.csv('inferBinomialParams_level1model.csv',header=F)

# level 1 model
d.tidy <- d %>% 
  select(V1,V2,V5,V6) %>%
  rename(item = V1,
         exp.val = V2,
         phi = V5,
         theta = V6) %>%
  gather(parameter, value, -item)

# level 2 model
# note: this theta is actually a posterior predictive
d.tidy <- d %>% 
  rename(item = V1,
         exp.val = V2,
         gamma = V3,
         delta = V4,
         phi = V5,
         theta = V6) %>%
  gather(parameter, value, -item)





# get prior expectations
priorexpectations = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/expectations.txt",sep="\t", header=T, quote="")
row.names(priorexpectations) = paste(priorexpectations$effect, priorexpectations$object)

# get item mapping for bayesian data analysis dataset
items = data.frame(ID=paste("i",seq(0,89),sep=""),Item=row.names(priorexpectations))
row.names(items) = items$ID

d.tidy$Item = items[as.character(d.tidy$item),]$Item
head(d.tidy)
d.tidy.randomsample<- d.tidy[d.tidy$Item%in%sample(levels(d.tidy$Item),10),]
ggplot(data=d.tidy.randomsample, aes(x = value))+
  facet_grid(Item~parameter,scales='free')+
  geom_histogram()

d.stats <- d.tidy %>%
  group_by(Item, parameter) %>%
  summarise(mn = mean(value))
head(d.stats)
nrow(d.stats)

# this is the basic data.frame to fill with all other values
d.spread <- d.stats %>% spread(parameter,mn)
head(d.spread)

d.spread$prior_Expectation = priorexpectations[as.character(d.spread$Item),]$expectation_corr

# prior expectations correlate pretty well
ggplot(d.spread, aes(x=exp.val,y=prior_Expectation)) +
  geom_point() 

# get prior allstate-probs
priorprobs = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/smoothed_15marbles_priors_withnames.txt",sep="\t", header=T, quote="")
row.names(priorprobs) = paste(priorprobs$effect, priorprobs$object)
head(priorprobs)

d.spread$prior_AllProb = priorprobs[as.character(d.spread$Item),]$X15

# get uniform model predictions: expectations & allstate-probs
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/wonky_world/results/data/mp-uniform.RData")

# get expectations for best basic model: 
toplot = droplevels(subset(mp, QUD == "how-many" & Alternatives == "0_basic" & Quantifier == "some" & WonkyWorldPrior == .5 & SpeakerOptimality == 2))
nrow(toplot)

pexpectations.uniform = ddply(toplot, .(Item, SpeakerOptimality,PriorExpectation_smoothed, PosteriorExpectation_empirical), summarise, PosteriorExpectation_predicted=sum(State*PosteriorProbability)/15)
nrow(pexpectations.uniform)
some = pexpectations.uniform
row.names(pexpectations.uniform) = pexpectations.uniform$Item

d.spread$m_uniform_Expectation = pexpectations.uniform[as.character(d.spread$Item),]$PosteriorExpectation_predicted*15

allprobs.uniform = droplevels(subset(toplot, SpeakerOptimality == 2 & State == 15))
row.names(allprobs.uniform) = allprobs.uniform$Item

d.spread$m_uniform_AllProb = allprobs.uniform[as.character(d.spread$Item),]$PosteriorProbability
summary(d.spread)

# get binomial model predictions: expectations & allstate-probs
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/wonky_world/results/data/mp-binomial.RData")

# get expectations for best basic model: 
toplot = droplevels(subset(mp, QUD == "how-many" & Alternatives == "0_basic" & Quantifier == "some" & WonkyWorldPrior == .5 & SpeakerOptimality == 2))
nrow(toplot)

pexpectations.binomial = ddply(toplot, .(Item, SpeakerOptimality,PriorExpectation_smoothed, PosteriorExpectation_empirical), summarise, PosteriorExpectation_predicted=sum(State*PosteriorProbability)/15)
head(pexpectations.binomial)
row.names(pexpectations.binomial) = pexpectations.binomial$Item

d.spread$m_binomial_Expectation = pexpectations.binomial[as.character(d.spread$Item),]$PosteriorExpectation_predicted*15

allprobs.binomial = droplevels(subset(toplot, SpeakerOptimality == 2 & State == 15))
row.names(allprobs.binomial) = allprobs.binomial$Item

d.spread$m_binomial_AllProb = allprobs.binomial[as.character(d.spread$Item),]$PosteriorProbability
summary(d.spread)


# get empirical expectations
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/13_sinking-marbles-priordv-15/results/data/r.RData")

exps.empirical = aggregate(ProportionResponse ~ PriorExpectationProportion + quantifier + Item,data=r,FUN=mean)
exps.empirical = droplevels(subset(exps.empirical, quantifier == "Some"))
head(exps.empirical)
row.names(exps.empirical) = exps.empirical$Item

d.spread$empirical_Expectation = exps.empirical[as.character(d.spread$Item),]$ProportionResponse*15

# get empirical allstate-probs
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/16_sinking-marbles-sliders-certain/results/data/r.RData")

# exclude people who are doing some sort of bullshit and not responding reasonably to all/none (see subject-variability.pdf for behavior on zero-slider)
tmp = subset(r,!workerid %in% c(0,22,43,98,100,103,117,118))
agrr = aggregate(normresponse ~ AllPriorProbability + Proportion + quantifier + Item,data=tmp,FUN=mean)
agrr = aggregate(normresponse ~ AllPriorProbability + Proportion + quantifier + Item,data=r,FUN=mean)
allprobs.empirical = subset(agrr, Proportion == "100")
allprobs.empirical = droplevels(allprobs.empirical)
allprobs.empirical = droplevels(subset(allprobs.empirical, quantifier == "Some"))
nrow(allprobs.empirical)
row.names(allprobs.empirical) = allprobs.empirical$Item

d.spread$empirical_AllProb = allprobs.empirical[as.character(d.spread$Item),]$normresponse


################
# histogram of mean phi
ggplot(d.spread, aes(x=theta)) +
  geom_histogram()
ggsave("graphs/mean_theta.pdf")

# histogram of mean phi
ggplot(d.spread, aes(x=phi)) +
  geom_histogram()
ggsave("graphs/mean_phi.pdf")

# phi vs theta
ggplot(d.spread, aes(x=phi,y=theta)) +
  geom_point()
ggsave("graphs/mean_phi_theta.pdf")

d.spread$PhiBin = cut(d.spread$phi,breaks=c(0,.25,.5,1))
summary(d.spread)

ggplot(d.spread, aes(x=phi,y=prior_Expectation, color=PhiBin)) +
  geom_point()
ggsave("graphs/mean_phi_by_prior.pdf")

ggplot(d.spread, aes(x=m_uniform_AllProb, y=empirical_AllProb,  color=PhiBin)) +
  geom_point() +
  geom_abline(xintercept=0,slope=1) +
  geom_smooth()

ggplot(d.spread, aes(x=m_binomial_AllProb, y=empirical_AllProb,  color=PhiBin)) +
  geom_point() +
  geom_abline(xintercept=0,slope=1) +
  geom_smooth()

ggplot(d.spread, aes(x=m_uniform_Expectation, y=empirical_Expectation,  color=PhiBin)) +
  geom_point() +
  geom_abline(xintercept=0,slope=1) +
  geom_smooth()

ggplot(d.spread, aes(x=m_binomial_Expectation, y=empirical_Expectation,  color=PhiBin)) +
  geom_point() +
  geom_abline(xintercept=0,slope=1) +
  geom_smooth()

