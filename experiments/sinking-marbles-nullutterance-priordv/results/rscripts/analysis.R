setwd("~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/sinking-marbles-nullutterance-priordv/results/")
source("rscripts/helpers.r")
load("data/r.RData")

some = subset(r, quantifier == "Some")
some = droplevels(some)
nrow(some)

# positive effect of prior on response for just "some" data
m = lmer(ProportionResponse ~ Prior + (1|workerid), data=some)
summary(m)
pvals = pvals.fnc(m)
pvals

centered = cbind(r, myCenter(r[,c("quantifier","Prior")]))

# OK so there's definitely an effect of the prior on "some" interpretation 
m = lmer(ProportionResponse ~ cPrior*quantifier + (1+quantifier|workerid), data=centered)
summary(m)

m = lmer(ProportionResponse ~ cPrior*quantifier + (1|workerid), data=centered)
summary(m)
pvals = pvals.fnc(m)
pvals

