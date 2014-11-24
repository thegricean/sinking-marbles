library(ggplot2)
theme_set(theme_bw(18))
#setwd("~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/sinking-marbles-nullutterance-priordv/results/")
setwd("~/Dropbox/sinking_marbles/sinking-marbles/experiments/5_sinking-marbles-nullutterance-priordv/results/")
source("rscripts/summarySE.r")
source("rscripts/helpers.r")
load("data/priors.RData")
load("data/r.RData")
r = read.table("data/sinking_marbles_nullutterance-priordv.tsv", sep="\t", header=T)
r$trial = r$slide_number_in_experiment - 2
r = r[,c("workerid", "rt", "effect", "cause","language","gender.1","age","gender","other_gender","quantifier", "object_level", "response", "object","num_objects","trial","enjoyment","asses","comments")]
row.names(priors) = paste(priors$effect, priors$object)
expectations = read.table("data/expectations.txt", quote="",sep="\t",header=T)
row.names(expectations) = paste(expectations$effect, expectations$object)
expectations5 = read.table("data/expectations5.txt", quote="",sep="\t",header=T)
row.names(expectations5) = paste(expectations5$effect, expectations5$object)

r$Prior = priors[paste(r$effect, r$object),]$response
r$object_level = factor(r$object_level, levels=c("object_high", "object_mid", "object_low"))
r$Half = as.factor(ifelse(r$trial < 16, 1, 2))
r$Quarter = as.factor(ifelse(r$trial < 8, 1, ifelse(r$trial < 16, 2, ifelse(r$trial < 24, 3, 4))))
summary(r)
r$Combination = as.factor(paste(r$cause,r$object,r$effect))
table(r$Combination)
r$numresponse = as.numeric(as.character(r$response))
r = subset(r, !is.na(r$numresponse))
r$ProportionResponse = r$numresponse/r$num_objects
r$PriorBin = cut(r$Prior,breaks=c(0,quantile(r$Prior)))
r$Expectation = expectations[paste(r$effect, r$object),]$expectation
r$Expectation5 = expectations5[paste(r$effect, r$object),]$expectation
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
