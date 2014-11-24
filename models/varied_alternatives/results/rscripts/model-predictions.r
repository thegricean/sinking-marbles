library(ggplot2)
theme_set(theme_bw(18))
setwd("~/Dropbox/sinking_marbles/sinking-marbles/models/varied_alternatives/results/")
source("rscripts/helpers.r")

load("data/mp.RData")

mp = read.table("data/parsed_results.tsv", quote="", sep="\t", header=T)
nrow(mp)

summary(mp)
mp$Proportion = mp$NumState / mp$TotalMarbles
summary(mp)
mp$OptTotal = as.factor(paste(mp$SpeakerOptimality,mp$TotalMarbles))
mp$QUDTotal = as.factor(paste(mp$QUD,mp$TotalMarbles))
save(mp, file="data/mp.RData")

isall = subset(mp, QUD=="is-all")
ggplot(isall, aes(x=Proportion,y=PosteriorProbability,shape=as.factor(SpeakerOptimality),color=as.factor(TotalMarbles),group=OptTotal)) +
  geom_point() +
  geom_line() +
  facet_grid(Alternatives~PriorAllProbability)
  ggsave("graphs/byproportion-qud-all.pdf",width=25,height=25)

howmany = subset(mp, QUD=="how-many")
ggplot(howmany, aes(x=Proportion,y=PosteriorProbability,shape=as.factor(SpeakerOptimality),color=as.factor(TotalMarbles),group=OptTotal)) +
  geom_point() +
  geom_line() +
  facet_grid(Alternatives~PriorAllProbability)
ggsave("graphs/byproportion-qud-howmany.pdf",width=25,height=25)


ggplot(isall, aes(x=PriorAllProbability,y=PosteriorProbability,shape=as.factor(SpeakerOptimality),color=as.factor(TotalMarbles),group=OptTotal)) +
  geom_point() +
  geom_line() +
  facet_grid(Alternatives~Proportion)
ggsave("graphs/byprior-qud-isall.pdf",width=40,height=15)

ggplot(howmany, aes(x=PriorAllProbability,y=PosteriorProbability,shape=as.factor(SpeakerOptimality),color=as.factor(TotalMarbles),group=OptTotal)) +
  geom_point() +
  geom_line() +
  facet_grid(Alternatives~Proportion)
ggsave("graphs/byprior-qud-howmany.pdf",width=40,height=15)

allisall = subset(mp, Proportion == 1 & QUD == "is-all")
ggplot(allisall, aes(x=PriorAllProbability,y=PosteriorProbability,shape=as.factor(SpeakerOptimality),color=as.factor(TotalMarbles),group=OptTotal)) +
  geom_point() +
  geom_line() +
  facet_wrap(~Alternatives)
ggsave("graphs/allprobability-qud-isall.pdf",width=12)

allhowmany = subset(mp, Proportion == 1 & QUD == "how-many")
ggplot(allhowmany, aes(x=PriorAllProbability,y=PosteriorProbability,shape=as.factor(SpeakerOptimality),color=as.factor(TotalMarbles),group=OptTotal)) +
  geom_point() +
  geom_line() +
  facet_wrap(~Alternatives)
ggsave("graphs/allprobability-qud-howmany.pdf",width=12)

all = subset(mp, Proportion == 1 & SpeakerOptimality == 1)
ggplot(all, aes(x=PriorAllProbability,y=PosteriorProbability,shape=QUD,color=as.factor(TotalMarbles),group=QUDTotal)) +
  geom_point() +
  geom_line() +
  facet_wrap(~Alternatives)
ggsave("graphs/allprobability-quds.pdf",width=12)

head(mp)
nrow(mp)
hmbasic2 = subset(mp, QUD=="how-many" & Alternatives == "basic" & SpeakerOptimality == 2 & Proportion == 1 & TotalMarbles == 4)
nrow(hmbasic2)
summary(hmbasic2)
hmbasic2 = unique(hmbasic2)
hmbasic2 = droplevels(hmbasic2)

row.names(hmbasic2) = as.character(hmbasic2$PriorAllProbability)
head(hmbasic2)
hmbasic2.gprior = hmbasic2
save(hmbasic2.gprior, file="data/hmbasic2.gprior.RData")
