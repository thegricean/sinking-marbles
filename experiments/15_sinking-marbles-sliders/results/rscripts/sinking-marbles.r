library(ggplot2)
theme_set(theme_bw(18))
#setwd("~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/sinking-marbles-nullutterance/results/")
setwd("~/Dropbox/sinking_marbles/sinking-marbles/experiments/3_sinking-marbles-nullutterance/results/")
source("rscripts/summarySE.r")
source("rscripts/helpers.r")
load("data/r.RData")
load("../../1_sinking-marbles-prior/results/data/priors.RData")
r1 = read.table("data/sinking_marbles_nullutterance1.tsv", sep="\t", header=T)
nrow(r1)
r2 = read.table("data/sinking_marbles_nullutterance2.tsv", sep="\t", header=T)
nrow(r2)
r = rbind(r1,r2)
nrow(r)
r$trial = r$slide_number_in_experiment - 2
r = r[,c("assignmentid","workerid", "rt", "effect", "cause","language","gender.1","age","gender","other_gender","quantifier", "object_level", "response", "object","slider_id","num_objects","trial","enjoyment","asses","comments","Answer.time_in_minutes")]
row.names(priors) = paste(priors$effect, priors$object)
r$Prior = priors[paste(r$effect, r$object),]$response
r$Prior.0 = priors[paste(r$effect, r$object),]$r_none
r$Prior.1 = priors[paste(r$effect, r$object),]$r_lower_half
r$Prior.2 = priors[paste(r$effect, r$object),]$r_upper_half
r$Prior.3 = priors[paste(r$effect, r$object),]$r_all
r$object_level = factor(r$object_level, levels=c("object_high", "object_mid", "object_low"))
r$Proportion = factor(ifelse(r$slider_id == "all","100",ifelse(r$slider_id == "lower_half","1-50",ifelse(r$slider_id == "upper_half","51-99","0"))),levels=c("0","1-50","51-99","100"))
r$Half = as.factor(ifelse(r$trial < 16, 1, 2))
r$Quarter = as.factor(ifelse(r$trial < 8, 1, ifelse(r$trial < 16, 2, ifelse(r$trial < 24, 3, 4))))
summary(r)
r$Combination = as.factor(paste(r$cause,r$object,r$effect))
table(r$Combination)

# compute normalized probabilities
nr = ddply(r, .(assignmentid,trial), summarize, normresponse=response/(sum(response)),assignmentid=assignmentid,Proportion=Proportion)
row.names(nr) = paste(nr$assignmentid,nr$trial,nr$Proportion)
r$normresponse = nr[paste(r$assignmentid,r$trial,r$Proportion),]$normresponse
# test: sums should add to 1
sums = ddply(r, .(assignmentid,trial), summarize, sum(normresponse))
colnames(sums) = c("assignmentid","trial","sum")
summary(sums)
sums[is.na(sums$sum),]

save(r, file="data/r.RData")

##################

ggplot(aes(x=gender.1), data=r) +
  geom_histogram()

ggplot(aes(x=rt), data=r) +
  geom_histogram() +
  scale_x_continuous(limits=c(0,50000))

ggplot(aes(x=age), data=r) +
  geom_histogram()

ggplot(aes(x=age,fill=gender.1), data=r) +
  geom_histogram()

ggplot(aes(x=enjoyment), data=r) +
  geom_histogram()

ggplot(aes(x=asses), data=r) +
  geom_histogram()

ggplot(aes(x=quantifier), data=r) +
  geom_histogram()

ggplot(aes(x=Answer.time_in_minutes), data=r) +
  geom_histogram()

ggplot(aes(x=age,y=Answer.time_in_minutes,color=gender.1), data=unique(r[,c("assignmentid","age","Answer.time_in_minutes","gender.1")])) +
  geom_point() +
  geom_smooth()

unique(r$comments)

all = subset(r, quantifier == "Some" & Proportion == 100)
nrow(all)
summary(all)
save(all, file="data/all_empirical.RData")
