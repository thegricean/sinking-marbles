library(ggplot2)
theme_set(theme_bw(18))
setwd("~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/14_sinking-marbles-wonky/results/")
source("rscripts/helpers.r")

load("data/r.RData")
r = read.table("data/sinking_marbles.csv", sep=",", header=T)
r$trial = r$slide_number_in_experiment - 2
nrow(r)
head(r)
r = r[,c("workerid", "rt", "effect", "cause","language","gender.1","age","gender","other_gender","quantifier", "object_level", "response", "object","num_objects","trial","enjoyment","asses","comments","strangedescription")]

## add priors to data.frame
# load prior dataset
expectations = read.table("~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/expectations.txt", quote="",sep="\t",header=T)
row.names(expectations) = paste(expectations$effect, expectations$object)
head(expectations)
nrow(expectations)

r$PriorExpectation = expectations[paste(r$effect, r$object),]$expectation
r$Half = as.factor(ifelse(r$trial < 16, 1, 2))
r$Quarter = as.factor(ifelse(r$trial < 8, 1, ifelse(r$trial < 16, 2, ifelse(r$trial < 24, 3, 4))))
summary(r)
r$Item = as.factor(paste(r$object,r$effect))
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
