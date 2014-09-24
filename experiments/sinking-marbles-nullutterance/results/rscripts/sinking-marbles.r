library(ggplot2)
theme_set(theme_bw(18))
setwd("~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/sinking-marbles-nullutterance/results/")
source("rscripts/summarySE.r")
source("rscripts/helpers.r")
load("data/priors.RData")
r = read.table("data/sinking_marbles_nullutterance.tsv", sep="\t", header=T)
r$trial = r$slide_number_in_experiment - 2
r = r[,c("workerid", "rt", "effect", "cause","language","gender.1","age","gender","other_gender","quantifier", "object_level", "response", "object","slider_id","num_objects","trial","enjoyment","asses","comments")]
row.names(priors) = paste(priors$effect, priors$object)
r$Prior = priors[paste(r$effect, r$object),]$response
r$object_level = factor(r$object_level, levels=c("object_high", "object_mid", "object_low"))
r$Proportion = factor(ifelse(r$slider_id == "all","100",ifelse(r$slider_id == "lower_half","1-50",ifelse(r$slider_id == "upper_half","51-99","0"))),levels=c("0","1-50","51-99","100"))
r$Half = as.factor(ifelse(r$trial < 16, 1, 2))
r$Quarter = as.factor(ifelse(r$trial < 8, 1, ifelse(r$trial < 16, 2, ifelse(r$trial < 24, 3, 4))))
summary(r)
r$Combination = as.factor(paste(r$cause,r$object,r$effect))
table(r$Combination)

# compute normalized probabilities
nr = ddply(r, .(workerid,trial), summarize, normresponse=response/(sum(response)),workerid=workerid,Proportion=Proportion)
row.names(nr) = paste(nr$workerid,nr$trial,nr$Proportion)
r$normresponse = nr[paste(r$workerid,r$trial,r$Proportion),]$normresponse
# test: sums should add to 1
sums = ddply(r, .(workerid,trial), summarize, sum(normresponse))
colnames(sums) = c("workerid","trial","sum")
sums

save(r, file="data/r.RData")

##################

ggplot(aes(x=gender.1), data=r) +
  geom_histogram()

ggplot(aes(x=rt), data=r) +
  geom_histogram()

ggplot(aes(x=age), data=r) +
  geom_histogram()

ggplot(aes(x=enjoyment), data=r) +
  geom_histogram()

ggplot(aes(x=asses), data=r) +
  geom_histogram()

ggplot(aes(x=quantifier), data=r) +
  geom_histogram()

ggplot(aes(x=Answer.time_in_minutes), data=r) +
  geom_histogram()

unique(r$comments)
