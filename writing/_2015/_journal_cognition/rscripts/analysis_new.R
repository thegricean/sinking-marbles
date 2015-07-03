
to.n <- function(x) {return(as.numeric(as.character(x)))}
setwd("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/writing/_2015/cogsci_2015/")
source("rscripts/helpers.r")

## load priors for generating plots 
priorprobs = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/24_sinking-marbles-prior-fourstep/results/data/smoothed_15marbles_priors_withnames.txt",sep="\t", header=T, quote="")
row.names(priorprobs) = priorprobs$Item
nrow(priorprobs)

# prior all-state probability for each item
prior_allprobs = priorprobs[,c("Item","X15")]
row.names(prior_allprobs) = prior_allprobs$Item

# prior expectation for each item
gathered_probs <- priorprobs %>%
  gather(State,Probability,X0:X15)
gathered_probs$State = as.numeric(as.character(gsub("X","",gathered_probs$State)))
prior_exps <- gathered_probs %>%
  group_by(Item) %>%
  summarise(exp.val=sum(State*Probability))
prior_exps = as.data.frame(prior_exps)
row.names(prior_exps) = prior_exps$Item
summary(prior_exps)

# get empirical comprehension data expectations (comp_state)
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/13_sinking-marbles-priordv-15/results/data/r.RData")

r$Prior = prior_exps[as.character(r$Item),]$exp.val
# test "some"
centered = cbind(r[r$quantifier == "Some",],myCenter(r[r$quantifier == "Some",c("Prior","trial")]))
summary(centered)

m = lmer(response~Prior + (1+Prior|workerid) + (1|Item), data=centered)
summary(m)
m.0 = lmer(response~ + (1+Prior|workerid) + (1|Item), data=centered)
summary(m.0)
anova(m.0,m)

# test fillers
centered = cbind(r[r$quantifier %in% c("long_filler","short_filler"),],myCenter(r[r$quantifier %in% c("long_filler","short_filler"),c("Prior","trial")]))
summary(centered)

m = lmer(response~Prior + (1+Prior|workerid) + (1|Item), data=centered)
summary(m)
m.0 = lmer(response~ + (1+Prior|workerid) + (1|Item), data=centered)
summary(m.0)
anova(m.0,m)

# get empirical comprehension data (comp_allprob)
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/16_sinking-marbles-sliders-certain/results/data/r.RData")
# exclude the people who on average put less than 80% mass on right literal slider in all/none trials
# an = droplevels(subset(r, ((quantifier == "All" & Proportion == "100") | (quantifier == "None" & Proportion == "0"))))
# an = droplevels(subset(r, quantifier == "None" & Proportion == "0"))
# means = an %>%
#   group_by(workerid) %>%
#   summarise(meanresponse = mean(normresponse))
# nrow(means[means$meanresponse < .8,])
# head(means[means$meanresponse < .8,])

r$Prior = prior_allprobs[as.character(r$Item),]$X15
centered = cbind(r[r$quantifier == "Some" & r$Proportion == "100",],myCenter(r[r$quantifier == "Some" & r$Proportion == "100",c("Prior","trial")]))
summary(centered)

m = lmer(normresponse~Prior + (1+Prior|workerid) + (1|Item), data=centered)
summary(m)
m.0 = lmer(normresponse~ + (1+Prior|workerid) + (1|Item), data=centered)
summary(m.0)
anova(m.0,m)


