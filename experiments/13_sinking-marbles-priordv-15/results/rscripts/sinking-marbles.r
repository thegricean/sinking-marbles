library(ggplot2)
theme_set(theme_bw(18))
setwd("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/13_sinking-marbles-priordv-15/results/")
source("rscripts/helpers.r")
# load second round of data
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/25_sinking-marbles-priordv-15_replication/results/data/r.RData")
rnew = r
# load this first round of data
load("data/r_original.RData")

## NO NEED TO RUN AGAIN
r = read.table("data/sinking_marbles.tsv", sep="\t", header=T, quote="")
r$trial = r$slide_number_in_experiment - 2
r = r[,c("workerid", "rt", "effect", "cause","language","gender.1","age","gender","other_gender","quantifier", "object_level", "response", "object","num_objects","trial","enjoyment","asses","comments")]
expectations = read.table("data/expectations.txt", quote="",sep="\t",header=T)
row.names(expectations) = paste(expectations$effect, expectations$object)
head(expectations)
nrow(expectations)

r$Half = as.factor(ifelse(r$trial < 16, 1, 2))
r$Quarter = as.factor(ifelse(r$trial < 8, 1, ifelse(r$trial < 16, 2, ifelse(r$trial < 24, 3, 4))))
summary(r)
r$Item = as.factor(paste(r$effect,r$object))
table(r$Item)
r$numresponse = as.numeric(as.character(r$response))
table(r$quantifier,r$numresponse)
r$ProportionResponse = r$numresponse/r$num_objects
r$PriorExpectation = expectations[paste(r$effect, r$object),]$expectation

####################
# combine old and new datasets
d = merge(r,rnew,all=T)
r = d

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
