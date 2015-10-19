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
d = read.table("../modelresults/parsed_rsa_epsilonsmooth_results.tsv", quote="", sep="\t", header=T)

table(d$Item)
nrow(d)
head(d)
summary(d)


# get epsilon smoothed priors
priorprobs = read.table(file="/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/smoothed_15marbles_priors_epsilon.txt",sep="\t", header=T, quote="")
head(priorprobs)
row.names(priorprobs) = priorprobs$Item
priors = priorprobs %>%
  group_by(Item) %>%
  gather(State,Probability,X0:X15)
priors$State = gsub("X","",priors$State)
priors$State = as.numeric(as.character(gsub(".","",priors$State,fixed=T)))
priors$Item = gsub("\"","",priors$Item)
priors = as.data.frame(priors)
row.names(priors) = paste(as.character(priors$State),priors$Item)
priors$Item = as.factor(as.character(priors$Item))
# renormalize (because before you added .00001 to each state)
priors$Probability = priors$Probability/1.000016
summary(priors)

exps = priors %>%
  group_by(Item) %>%
  summarise(exp.val=sum(State*Probability))

# sanity check
ggplot(exps, aes(x=exp.val)) +
  geom_histogram()

exps = as.data.frame(exps)
exps$Item = gsub("\"","",exps$Item)
row.names(exps) = exps$Item

d$PriorProbability = priors[paste(d$State,d$Item),]$Probability
head(d)
d = unique(d)

d_all_prob = droplevels(subset(d, State == 15)) 
nrow(d_all_prob)
d_all_prob$sp.opt = as.factor(d_all_prob$SpeakerOptimality)

all=ggplot(d_all_prob[d_all_prob$SpeakerOptimality < 5,],aes(x=PriorProbability,y=PosteriorProbability,color=sp.opt,group=sp.opt)) +
  geom_point(size=3) +
  geom_smooth() +
  scale_color_discrete(name="Speaker\noptimality") +
  scale_x_continuous("Prior probability of all-state",limits=c(0,1)) +
  scale_y_continuous("Posterior probability of all-state",limits=c(0,1)) 
  #geom_text(aes(label=Item))
ggsave("epsilonsmooth-allprob.pdf",width=6.5,height=5)
  
d_comp_state = d[d$SpeakerOptimality < 5,] %>%
  group_by(Item,SpeakerOptimality) %>%
  summarise(exp.val=sum(State*PosteriorProbability))

d_comp_state = as.data.frame(d_comp_state)
d_comp_state$exp.val.prior = exps[as.character(d_comp_state$Item),]$exp.val
d_comp_state$sp.opt = as.factor(d_comp_state$SpeakerOptimality)

state=ggplot(d_comp_state, aes(x=exp.val.prior,y=exp.val,color=as.factor(SpeakerOptimality))) +
  geom_point(size=3) +
  geom_smooth() +
  scale_color_discrete(name="Speaker\noptimality") +
  scale_x_continuous("Expected value of prior distribution",breaks=c(0,3,6,9,12,15)) +
  scale_y_continuous("Expected value of posterior distribution",breaks=c(0,3,6,9,12,15))#  +
  #geom_text(aes(label=Item))
ggsave("epsilonsmooth-compstate.pdf",width=6.5,height=5)

library(gridExtra)
g <- ggplotGrob(state + theme(legend.position="right"))$grobs
legend <- g[[which(sapply(g, function(x) x$name) == "guide-box")]]
state_nolegend = state + theme(legend.position="none")
all_nolegend = all + theme(legend.position="none")

pdf("../../pics/epsilonsmooth-priordistributions.pdf",width=13,height=5)
grid.arrange(state_nolegend, all_nolegend, legend,nrow=1,widths=unit.c(unit(.45, "npc"), unit(.45, "npc"), unit(.1, "npc")))
dev.off()

