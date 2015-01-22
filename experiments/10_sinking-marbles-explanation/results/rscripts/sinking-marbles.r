library(ggplot2)
theme_set(theme_bw(18))
setwd("~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/10_sinking-marbles-explanation/results/")
#setwd("~/Dropbox/sinking_marbles/sinking-marbles/experiments/5_sinking-marbles-nullutterance-priordv/results/")
source("rscripts/helpers.r")
#load("data/priors.RData")
load("data/r.RData")
r = read.table("data/sinking_marbles_explanation.tsv", sep="\t", header=T, quote="")
r$trial = r$slide_number_in_experiment - 2
nrow(r)
names(r)
r = r[,c("workerid", "rt", "effect", "cause","language","gender.1","age","gender","other_gender","quantifier", "object_level", "explanation", "object","num_objects","trial","enjoyment","asses","comments")]
#row.names(priors) = paste(priors$effect, priors$object)
#expectations = read.table("data/expectations.txt", quote="",sep="\t",header=T)
#row.names(expectations) = paste(expectations$effect, expectations$object)
#expectations5 = read.table("data/expectations5.txt", quote="",sep="\t",header=T)
#row.names(expectations5) = paste(expectations5$effect, expectations5$object)

#r$Prior = priors[paste(r$effect, r$object),]$response
r$object_level = factor(r$object_level, levels=c("object_high", "object_mid", "object_low"))
r$Half = as.factor(ifelse(r$trial < 16, 1, 2))
r$Quarter = as.factor(ifelse(r$trial < 8, 1, ifelse(r$trial < 16, 2, ifelse(r$trial < 24, 3, 4))))
summary(r)
r$Combination = as.factor(paste(r$cause,r$object,r$effect))
table(r$Combination)

#r$PriorBin = cut(r$Prior,breaks=c(0,quantile(r$Prior)))
#r$Expectation = expectations[paste(r$effect, r$object),]$expectation
#r$Expectation5 = expectations5[paste(r$effect, r$object),]$expectation
r$ObjectEffect = as.factor(paste(r$object,r$effect))

## add priors to data.frame
# load prior dataset
d = read.table("~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/1_sinking-marbles-prior/results/data/sinking-marbles-prior.tsv", sep="\t", header=T)

#' get items and priors
d$Item = paste(d$effect,d$object)
d$AllState = as.factor(ifelse(d$response == 100,1,0))
t = as.data.frame(prop.table(table(d$AllState,d$Item),mar=2))
t = t[t$Var1 == 1,]
row.names(t) = t$Var2

#' add prior all-state probability to megaframe
r$AllPrior = t[paste(r$effect,r$object),]$Freq

#' get unsmoothed prior expectation
t = as.data.frame(prop.table(table(d$response,d$Item),mar=2))
exps = ddply(t, .(Var2), summarize, expectation=sum(as.numeric(as.character(Var1))*Freq))  
row.names(exps) = exps$Var2

#' add prior expectation to megaframe
r$PriorExpectationUnsmoothed = exps[paste(r$effect,r$object),]$expectation/100

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


###### EXPLORATION
head(r)

## WHAT DO PEOPLE SAY ABOUT "ALL"?
write.table(r[r$quantifier == "All",c("AllPrior","PriorExpectationUnsmoothed","ObjectEffect","explanation")],file="data/explanations_all.tsv",sep="\t",row.names=F,quote=F)

## WHAT DO PEOPLE SAY ABOUT "SOME"?
write.table(r[r$quantifier == "Some",c("AllPrior","PriorExpectationUnsmoothed","ObjectEffect","explanation")],file="data/explanations_some.tsv",sep="\t",row.names=F,quote=F)

## WHAT DO PEOPLE SAY ABOUT "NONE"?
write.table(r[r$quantifier == "None",c("AllPrior","PriorExpectationUnsmoothed","ObjectEffect","explanation")],file="data/explanations_none.tsv",sep="\t",row.names=F,quote=F)

## WHAT DO PEOPLE SAY ABOUT FILLERS?
write.table(r[r$quantifier == "short_filler",c("AllPrior","PriorExpectationUnsmoothed","ObjectEffect","explanation")],file="data/explanations_shortfiller.tsv",sep="\t",row.names=F,quote=F)
write.table(r[r$quantifier == "long_filler",c("AllPrior","PriorExpectationUnsmoothed","ObjectEffect","explanation")],file="data/explanations_longfiller.tsv",sep="\t",row.names=F,quote=F)
