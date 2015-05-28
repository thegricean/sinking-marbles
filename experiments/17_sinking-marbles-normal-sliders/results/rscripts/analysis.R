setwd("~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/sinking-marbles-nullutterance-priordv/results/")
source("rscripts/helpers.r")
load("data/r.RData")

some = subset(r, quantifier == "Some")
some = droplevels(some)
nrow(some)

# positive effect of prior on response for just "some" data
m = lmer(ProportionResponse ~ Prior + (1|workerid) + (1|Combination), data=some)
summary(m)
pvals = pvals.fnc(m)
pvals

m.crossed = lmer(ProportionResponse ~ Prior + (1+Combination|workerid) + (1|Combination), data=some)
summary(m.crossed)

m.0a = lmer(ProportionResponse ~ Prior + (1|workerid), data=some)
summary(m.0a)

m.0b = lmer(ProportionResponse ~ Prior + (1|Combination), data=some)
summary(m.0b)

anova(m.0a,m) # adding item variability doesn't do anything
anova(m.0b,m) # adding subject variability definitely matters

centered = cbind(r, myCenter(r[,c("quantifier","Prior")]))

# OK so there's definitely an effect of the prior on "some" interpretation 
m = lmer(ProportionResponse ~ cPrior*quantifier + (1+quantifier|workerid), data=centered)
summary(m)

m = lmer(ProportionResponse ~ cPrior*quantifier + (1|workerid), data=centered)
summary(m)
pvals = pvals.fnc(m)
pvals

