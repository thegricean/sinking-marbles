#' ---
#' title: "Prior probabilities in the interpretation of 'some': analysis of wonky world model predictions"
#' author: "Judith Degen"
#' date: "December 6, 2014"
#' ---

library(ggplot2)
theme_set(theme_bw(18))
setwd("/Users/titlis/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/models/wonky_world/results/")
source("rscripts/helpers.r")

#' get model predictions
load("data/an.RData")
load("data/mp.RData")
nrow(mp)
head(mp)
an = read.table("data/parsed_wonky_noneall_results.tsv", quote="", sep="\t", header=T)
summary(an)
#wr = read.table("data/parsed_wonky_results.tsv", quote="", sep="\t", header=T)
#head(wr)
#wr = droplevels(subset(wr, Wonky == "true"))
#rownames(wr) = paste(wr$Item, wr$QUD, wr$Alternatives, wr$SpeakerOptimality, wr$SmoothingBW)
mp = unique(mp[,c("Item","QUD","Alternatives","SpeakerOptimality","SmoothingBW","NormAllPrior","PriorExpectation")])
rownames(mp) = paste(mp$Item, mp$QUD, mp$Alternatives, mp$SpeakerOptimality, mp$SmoothingBW)
an$NormAllPrior = mp[paste(an$Item, an$QUD, an$Alternatives, an$SpeakerOptimality, an$SmoothingBW),]$NormAllPrior
an$PriorExpectation = mp[paste(an$Item, an$QUD, an$Alternatives, an$SpeakerOptimality, an$SmoothingBW),]$PriorExpectation
summary(an)

table(an$Quantifier,an$Item)
# get empirical wonkiness ratings
load("/Users/titlis/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/11_sinking-marbles-normal/results/data/r.RData")
head(r)
summary(r)
some = subset(r, quantifier %in% c("All","None"))
some$Item = as.factor(paste(some$effect, some$object))
some = droplevels(some)
head(some$response)

t = as.data.frame(prop.table(table(some$Item,some$quantifier,some$response),mar=c(1,2)))
head(t)
t[t$Var1 == "ate the seeds birds",]
t = droplevels(subset(t, Var3 == "no"))
rownames(t) = paste(t$Var1,tolower(t$Var2))
nrow(t)
an$EmpiricalWonkyProportion = t[paste(an$Item,an$Quantifier),]$Freq

head(an)
tail(an)

wtrue = subset(an, Wonky == "true")

ggplot(wtrue, aes(x=PosteriorProbability,y=EmpiricalWonkyProportion,color=SmoothingBW,shape=as.factor(paste(SpeakerOptimality,QUD)))) +
  geom_point() +
  geom_smooth() +
  facet_grid(Alternatives~Quantifier)
ggsave("graphs/model-vs-empirical.pdf",width=12,height=20)

ggplot(wtrue, aes(x=PriorExpectation,y=PosteriorProbability,color=SmoothingBW,shape=as.factor(paste(SpeakerOptimality,QUD)))) +
  geom_point() +
  geom_smooth() +
  facet_grid(Alternatives~Quantifier)
ggsave("graphs/model_bypriorexpectation.pdf",width=12,height=20)

ggplot(wtrue, aes(x=NormAllPrior,y=PosteriorProbability,color=SmoothingBW,shape=as.factor(paste(SpeakerOptimality,QUD)))) +
  geom_point() +
  geom_smooth() +
  facet_grid(Alternatives~Quantifier)
ggsave("graphs/model_byallprior.pdf",width=12,height=20)

tmp = droplevels(subset(wtrue, SpeakerOptimality == 2 & QUD == "how-many" & SmoothingBW == "bwdf" & Alternatives == "0_basic"))
ggplot(tmp, aes(x=PriorExpectation,y=PosteriorProbability)) +
  geom_point() +
  geom_smooth() +
  geom_text(aes(label=Item)) +
  facet_grid(Alternatives~Quantifier)
ggsave("graphs/annotated.pdf",height=12,width=20)
