library(ggplot2)
theme_set(theme_bw(18))
setwd("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/17_sinking-marbles-normal-sliders/results/")
source("rscripts/helpers.r")

load("data/r.RData")
r = read.csv("data/sinking_marbles.csv")#, sep=",", header=T, quote="")
r$trial = r$slide_number_in_experiment - 2
head(r)
r = r[,c("workerid", "rt", "effect", "cause","language","gender.1","age","gender","other_gender","quantifier", "object_level", "response", "object","num_objects","trial","enjoyment","asses","comments")]
r$Item = as.factor(paste(r$effect,r$object))
r$response = 1 - r$response

## add priors to data.frame
priorexpectations = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/expectations.txt",sep="\t", header=T, quote="")
row.names(priorexpectations) = paste(priorexpectations$effect,priorexpectations$object)
r$PriorExpectation = priorexpectations[as.character(r$Item),]$expectation
r$PriorExpectationProportion = r$PriorExpectation/15

priorprobs = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/smoothed_15marbles_priors_withnames.txt",sep="\t", header=T, quote="")
head(priorprobs)
row.names(priorprobs) = paste(priorprobs$effect,priorprobs$object)
mpriorprobs = melt(priorprobs, id.vars=c("effect", "object"))
head(mpriorprobs)
row.names(mpriorprobs) = paste(mpriorprobs$effect,mpriorprobs$object,mpriorprobs$variable)
r$PriorProbability = mpriorprobs[paste(as.character(r$Item)," X",r$State,sep=""),]$value
r$AllPriorProbability = priorprobs[paste(as.character(r$Item)),]$X15
head(r)

r$Half = as.factor(ifelse(r$trial < 16, 1, 2))
r$Quarter = as.factor(ifelse(r$trial < 8, 1, ifelse(r$trial < 16, 2, ifelse(r$trial < 24, 3, 4))))
summary(r)

table(r$Item)

save(r, file="data/r.RData")

##################

ggplot(aes(x=gender.1), data=r) +
  geom_histogram()

ggplot(aes(x=rt), data=r) +
  geom_histogram() +
  scale_x_continuous(limits=c(0,20000))

ggplot(aes(x=age), data=r) +
  geom_histogram()

ggplot(aes(x=enjoyment), data=r) +
  geom_histogram()

ggplot(aes(x=asses), data=r) +
  geom_histogram()

ggplot(aes(x=quantifier), data=r) +
  geom_histogram()

head(r$comments)
unique(r$comments)


ggplot(r, aes(x=response)) +
  geom_histogram() +
  facet_grid(workerid~quantifier)
ggsave("graphs/subject_variability.pdf",width=10,height=30)
