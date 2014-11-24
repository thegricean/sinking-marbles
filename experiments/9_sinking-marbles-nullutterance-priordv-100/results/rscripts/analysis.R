<<<<<<< HEAD

setwd("~/Dropbox/sinking_marbles/sinking-marbles/experiments/9_sinking-marbles-nullutterance-priordv-100/results/")
setwd("~/Dropbox/sinking_marbles/sinking-marbles/experiments/5_sinking-marbles-nullutterance-priordv/results/")
=======
setwd("~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/sinking-marbles-nullutterance-priordv/results/")
>>>>>>> 9607c7af133d2d9c79c1c3f488761f75e0075578
source("rscripts/helpers.r")
load("data/r.RData")

some = subset(r, quantifier == "Some")
some = droplevels(some)
nrow(some)

<<<<<<< HEAD
centered = cbind(some, myCenter(some[,c("Prior","ProportionResponse")]))

# positive effect of prior on response for just "some" data
m = lmer(ProportionResponse ~ Prior + (1|workerid) + (1|effect), data=some)
summary(m)

m = lmer(ProportionResponse ~ cPrior + (1|workerid) + (1|effect), data=centered)
summary(m)

m.slope = lmer(ProportionResponse ~ Prior + (1+Prior|workerid) + (1|effect), data=some)
summary(m)

m.0a = lmer(ProportionResponse ~ Prior + (1|effect), data=some)
summary(m.0a)

m.0b = lmer(ProportionResponse ~ Prior + (1|workerid), data=some)
summary(m.0b)

anova(m.0a,m) # adding subject variability gives better fit than item variability alone
anova(m.0b,m) # adding item variability doesn't give better fit than subject variability alone
anova(m,m.slope) # adding prior slopes gives better fit --> there is subject variability in how much use is made of the prior


=======
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
>>>>>>> 9607c7af133d2d9c79c1c3f488761f75e0075578

