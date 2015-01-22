setwd("~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/sinking-marbles-nullutterance-priordv/results/")
source("rscripts/helpers.r")
load("data/r.RData")

some = subset(r, quantifier == "Some")
some = droplevels(some)
nrow(some)

# positive effect of PriorExpectationProportionon response for just "some" data
m = lmer(ProportionResponse ~ PriorExpectationProportion + (1|workerid) + (1|Item), data=some)
summary(m)
pvals = pvals.fnc(m)
pvals

# reported in COGSCI paper
m.slopes = lmer(ProportionResponse ~ PriorExpectationProportion+ (1+PriorExpectationProportion|workerid) + (1|Item), data=some)
summary(m.slopes)

m.0a = lmer(ProportionResponse ~ PriorExpectationProportion+ (1|workerid), data=some)
summary(m.0a)

m.0b = lmer(ProportionResponse ~ PriorExpectationProportion+ (1|Item), data=some)
summary(m.0b)

anova(m.0a,m) # adding item variability doesn't do anything
anova(m.0b,m) # adding subject variability definitely matters

centered = cbind(r, myCenter(r[,c("quantifier","PriorExpectationProportion")]))

# OK so there's definitely an effect of the PriorExpectationProportionon "some" interpretation 
m = lmer(ProportionResponse ~ cPriorExpectationProportion*quantifier + (1+quantifier|workerid), data=centered)
summary(m)

m = lmer(ProportionResponse ~ cPrior*quantifier + (1|workerid), data=centered)
summary(m)


