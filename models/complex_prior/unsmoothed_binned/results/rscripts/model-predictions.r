library(ggplot2)
theme_set(theme_bw(18))
setwd("~/Dropbox/sinking_marbles/sinking-marbles/models/complex_prior/results/")
source("rscripts/helpers.r")

load("data/mp.RData")

mp = read.table("data/parsed_results.tsv", quote="", sep="\t", header=T)
nrow(mp)

summary(mp)
mp$QUDOpt = as.factor(paste(mp$QUD,mp$SpeakerOptimality))
save(mp, file="data/mp.RData")

ggplot(mp, aes(x=NumState,y=PosteriorProbability,shape=as.factor(SpeakerOptimality),color=QUD,group=QUDOpt)) +
  geom_point() +
  geom_line() +
  facet_grid(PriorProbability.100~Alternatives)
ggsave("graphs/full-dists.pdf",height=45)

isall = subset(mp, QUD=="is-all")
howmany = subset(mp, QUD=="how-many")

ggplot(mp, aes(x=PriorProbability.100,y=PosteriorProbability,shape=as.factor(SpeakerOptimality),color=QUD,group=QUDOpt)) +
  geom_point() +
  geom_line() +
  facet_grid(Alternatives~NumState)
ggsave("graphs/byprior.pdf",width=10,height=10)

all = subset(mp, NumState == 3)
ggplot(all, aes(x=PriorProbability.100,y=PosteriorProbability,color=as.factor(SpeakerOptimality))) +
  geom_point() +
  geom_smooth() +
  scale_y_continuous(limits=c(0,1)) +
  facet_grid(QUD~Alternatives)
ggsave("graphs/allprobability-byopt-byqud.pdf",width=12)

head(mp)
nrow(mp)
hmbasic2 = subset(mp, QUD=="how-many" & Alternatives == "basic" & SpeakerOptimality == 2 & NumState == 3)
nrow(hmbasic2)
summary(hmbasic2)
hmbasic2 = droplevels(hmbasic2)
row.names(hmbasic2) = paste(hmbasic2$PriorProbability.0,hmbasic2$PriorProbability.1to50,hmbasic2$PriorProbability.51to99,hmbasic2$PriorProbability.100)
head(hmbasic2)
hmbasic2.cprior = hmbasic2
save(hmbasic2.cprior, file="data/hmbasic2.cprior.RData")
