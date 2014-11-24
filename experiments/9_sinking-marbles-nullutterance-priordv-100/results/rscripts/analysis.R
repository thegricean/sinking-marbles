
setwd("~/Dropbox/sinking_marbles/sinking-marbles/experiments/9_sinking-marbles-nullutterance-priordv-100/results/")
setwd("~/Dropbox/sinking_marbles/sinking-marbles/experiments/5_sinking-marbles-nullutterance-priordv/results/")
source("rscripts/helpers.r")
load("data/r.RData")

some = subset(r, quantifier == "Some")
some = droplevels(some)
nrow(some)

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



