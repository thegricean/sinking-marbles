library(ggplot2)
theme_set(theme_bw(18))
setwd("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/11_sinking-marbles-normal/results/")
source("rscripts/helpers.r")

load("data/r.RData")
r1 = read.table("data/sinking_marbles.tsv", sep="\t", header=T, quote="")
r2 = read.csv("data/sinking_marbles.csv", header=T)
r2$workerid = as.numeric(as.character(r2$workerid))+60

r = rbind(r1,r2)
r$trial = r$slide_number_in_experiment - 2
r = r[,c("workerid", "rt", "effect", "cause","language","gender.1","age","gender","other_gender","quantifier", "object_level", "response", "object","num_objects","trial","enjoyment","asses","comments")]
r$Item = as.factor(paste(r$effect,r$object))

## add priors to data.frame
priorprobs = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/24_sinking-marbles-prior-fourstep/results/data/smoothed_15marbles_priors_withnames.txt",sep="\t", header=T, quote="")
# prior expectation for each item
gathered_probs <- priorprobs %>%
  gather(State,Probability,X0:X15)
gathered_probs$State = as.numeric(as.character(gsub("X","",gathered_probs$State)))
prior_exps <- gathered_probs %>%
  group_by(Item) %>%
  summarise(exp.val=sum(State*Probability))
prior_exps = as.data.frame(prior_exps)
row.names(prior_exps) = prior_exps$Item

r$PriorExpectation = prior_exps[as.character(r$Item),]$exp.val
summary(r)

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


ggplot(r, aes(x=PriorExpectation, fill=response)) +
  geom_histogram() +
  facet_grid(workerid~quantifier)
ggsave("graphs/subject_variability.pdf")
