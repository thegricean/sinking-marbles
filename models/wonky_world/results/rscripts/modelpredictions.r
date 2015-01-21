#' ---
#' title: "Prior probabilities in the interpretation of 'some': analysis of wonky world model predictions"
#' author: "Judith Degen"
#' date: "December 6, 2014"
#' ---

library(ggplot2)
theme_set(theme_bw(18))
setwd("/Users/titlis/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/models/wonky_world/results/")
source("rscripts/helpers.r")

#' get model predictions
load("data/mp.RData")
mp = read.table("data/parsed_marble_results.tsv", quote="", sep="\t", header=T)
nrow(mp)
head(mp)
wr = read.table("data/parsed_wonky_results.tsv", quote="", sep="\t", header=T)
head(wr)
wr = droplevels(subset(wr, Wonky == "true"))
rownames(wr) = paste(wr$Item, wr$QUD, wr$Alternatives, wr$SpeakerOptimality, wr$SmoothingBW)
mp$WonkyProbability = wr[paste(mp$Item,mp$QUD, mp$Alternatives, mp$SpeakerOptimality, mp$SmoothingBW),]$PosteriorProbability
#summary(mp)
#mp$QUDOpt = as.factor(paste(mp$QUD,mp$SpeakerOptimality))
mp$NormAllPrior = mp$PriorProbability.15/rowSums(mp[,6:21])

# get prior expectations
priorexpectations = read.table(file="~/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/1_sinking-marbles-prior/results/data/expectations.txt",sep="\t", header=T, quote="")
row.names(priorexpectations) = paste(priorexpectations$effect,priorexpectations$object)
mp$PriorExpectation = priorexpectations[as.character(mp$Item),]$expectation/100
save(mp, file="data/mp.RData")

expectations = ddply(mp, .(Item, QUD, Alternatives, SmoothingBW, SpeakerOptimality, NormAllPrior,PriorExpectation), summarize, expectation=sum(PosteriorProbability*seq(1,15,by=1)))
head(expectations)
expectations$ExpectationProportion = expectations$expectation/15
expectations$QUDOpt = as.factor(paste(expectations$QUD,expectations$SpeakerOptimality))

ggplot(expectations, aes(x=NormAllPrior,y=ExpectationProportion,color=as.factor(SpeakerOptimality),shape=QUD,group=QUDOpt)) +
  geom_point() +
  geom_smooth() +
  facet_grid(SmoothingBW~Alternatives)
ggsave("graphs/marble_expectations.pdf",width=25,height=7)

ggplot(expectations, aes(x=ExpectationProportion,fill=QUD)) +
  geom_histogram(position="dodge") +
  facet_grid(SpeakerOptimality~Alternatives,scales="free_y")
ggsave("graphs/expectation_histograms.pdf",width=12)

  
subexp = subset(expectations, SpeakerOptimality == 2 & QUD == "how-many" & SmoothingBW == "bwdf")
ggplot(subexp, aes(x=NormAllPrior,y=ExpectationProportion)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(~Alternatives)
ggsave("graphs/expectations_spopt2_qudhowmany_bwdf.pdf",width=12,height=7)

ggplot(subset(subexp,Alternatives=="0_basic"), aes(x=PriorExpectation,y=ExpectationProportion)) +
  geom_point() +
  geom_smooth(method="lm") +
#  geom_abline(intercept=0,slope=1,color="gray70")  +
  scale_x_continuous(name="Prior expectation") +
  scale_y_continuous(name="Posterior expectation") 
ggsave("graphs/expectations_bypriorexp_spopt2_qudhowmany_alternativesbasic.pdf",width=12,height=7)
ggsave("graphs/modelpredictions_expectations.pdf")

dd = droplevels(subset(subexp,Alternatives=="0_basic"))
m = lm(ExpectationProportion ~ PriorExpectation, data=dd)
summary(m)

ggplot(subset(mp, Alternatives=="0_basic" & SpeakerOptimality == 2 & QUD == "how-many" & NumState == 15), aes(x=NormAllPrior,y=PosteriorProbability,color=SmoothingBW)) +
  geom_point() +
  #geom_smooth() +
  #geom_abline(intercept=0,slope=1,color="gray70") +
  scale_x_continuous(name="Prior probability of all-state") +
  scale_y_continuous(name="Posterior probability of all-state")   
ggsave("graphs/modelpredictions_allstate.pdf")



# get empirical posteriors:
load("/Users/titlis/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/3_sinking-marbles-nullutterance/results/data/r.RData")
head(r)
some = subset(r, quantifier == "Some" & Proportion == 100)
some$Item = as.factor(paste(some$effect, some$object))
head(some$normresponse)
# get model predictions for all-state with basic alts, spopt==2, and qud==how-many
mp_some_allstate = subset(mp, Alternatives=="0_basic" & SpeakerOptimality == 2 & QUD == "how-many" & NumState == 15)
head(mp_some_allstate)
nrow(mp_some_allstate)

agr = aggregate(normresponse ~ Item,data=some,FUN=mean)
agr$CILow = aggregate(normresponse ~ Item,data=some, FUN=ci.low)$normresponse
agr$CIHigh = aggregate(normresponse ~ Item,data=some,FUN=ci.high)$normresponse
agr$YMin = agr$normresponse - agr$CILow
agr$YMax = agr$normresponse + agr$CIHigh
row.names(agr) = agr$Item
head(agr)
mp_some_allstate$EmpiricalPosterior = agr[as.character(mp_some_allstate$Item),]$normresponse
mp_some_allstate$YMin = agr[as.character(mp_some_allstate$Item),]$YMin
mp_some_allstate$YMax = agr[as.character(mp_some_allstate$Item),]$YMax

ggplot(mp_some_allstate, aes(x=PosteriorProbability, y=EmpiricalPosterior)) +
  geom_point() +
  geom_smooth() +
#  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_abline(x=0,slope=1,color="gray70") +
  scale_x_continuous(name="Model predicted posterior all-state probability") +
  scale_y_continuous(name="Empirical mean all-state probability") +
  facet_wrap(~SmoothingBW)
ggsave("graphs/model-empirical.pdf")  
cor(mp_some_allstate$PosteriorProbability,mp_some_allstate$EmpiricalPosterior) # .51

head(subexp)
# get empirical expectations:
load("/Users/titlis/cogsci/projects/stanford/projects/sinking_marbles/sinking-marbles/experiments/5_sinking-marbles-nullutterance-priordv/results/data/r.RData")
head(r)
some = subset(r, quantifier == "Some")
some$Item = as.factor(paste(some$effect, some$object))
rownames(some) = some$Item
# plot subject variability
ggplot(some, aes(x=ProportionResponse)) +
  geom_histogram() + 
  facet_wrap(~workerid)
ggsave("graphs/some_subjectvariability.pdf",width=12,height=10)


# mark the people who chose at most 3 middle values to respond to "some" with
some$NoVariance = as.factor(ifelse(some$workerid %in% c("8","24","27","37","52","54","61","72","79","108","113"),1,0))

agr = aggregate(ProportionResponse ~ Item,data=some,FUN=mean)
agr$CILow = aggregate(ProportionResponse ~ Item,data=some, FUN=ci.low)$ProportionResponse
agr$CIHigh = aggregate(ProportionResponse ~ Item,data=some,FUN=ci.high)$ProportionResponse
agr$YMin = agr$ProportionResponse - agr$CILow
agr$YMax = agr$ProportionResponse + agr$CIHigh
row.names(agr) = agr$Item

subexp$EmpiricalMean = agr[as.character(subexp$Item),]$ProportionResponse
subexp$YMin = agr[as.character(subexp$Item),]$YMin
subexp$YMax = agr[as.character(subexp$Item),]$YMax

ggplot(subexp, aes(x=ExpectationProportion, y=EmpiricalMean)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_abline(intercept=0,slope=1,color="gray70") +
  geom_smooth(method="lm") +
  #scale_y_continuous(breaks=seq(0,1,0.1)) +
  facet_wrap(~Alternatives)
ggsave("graphs/modelpredictions.pdf",width=12,height=7)

cors = ddply(subexp, .(Alternatives), summarize, Correlation=cor(ExpectationProportion,EmpiricalMean))
cors # best correlation is with basic alternatives (some, none, all -- .6) and basic+many/most/few/afew (-- .59)

# split up by subject vairance on "some" trials
agr = aggregate(ProportionResponse ~ Item + NoVariance,data=some,FUN=mean)
agr$CILow = aggregate(ProportionResponse ~ Item + NoVariance,data=some, FUN=ci.low)$ProportionResponse
agr$CIHigh = aggregate(ProportionResponse ~ Item + NoVariance,data=some,FUN=ci.high)$ProportionResponse
agr$YMin = agr$ProportionResponse - agr$CILow
agr$YMax = agr$ProportionResponse + agr$CIHigh
agrgood = subset(agr, NoVariance == 0)
agrbad = subset(agr, NoVariance == 1)
row.names(agrgood) = agrgood$Item
row.names(agrbad) = agrbad$Item
nrow(agrgood)
nrow(agrbad)
subexp$EmpiricalMean_good = agrgood[as.character(subexp$Item),]$ProportionResponse
subexp$YMin_good = agrgood[as.character(subexp$Item),]$YMin
subexp$YMax_good = agrgood[as.character(subexp$Item),]$YMax


ggplot(subexp, aes(x=ExpectationProportion, y=EmpiricalMean)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_abline(intercept=0,slope=1,color="gray70") +
  geom_smooth(method="lm") +
  #scale_y_continuous(breaks=seq(0,1,0.1)) +
  facet_wrap(~Alternatives)
ggsave("graphs/modelpredictions_good.pdf",width=12,height=7)



subexp$EmpiricalMean_bad = agrbad[as.character(subexp$Item),]$ProportionResponse
subexp$YMin_bad = agrbad[as.character(subexp$Item),]$YMin
subexp$YMax_bad = agrbad[as.character(subexp$Item),]$YMax

ggplot(subexp, aes(x=ExpectationProportion, y=EmpiricalMean_bad)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin_bad,ymax=YMax_bad)) +
  geom_abline(intercept=0,slope=1,color="gray70") +
  geom_smooth(method="lm") +
  #scale_y_continuous(breaks=seq(0,1,0.1)) +
  facet_wrap(~Alternatives)
ggsave("graphs/modelpredictions_bad.pdf",width=12,height=7)

cors = ddply(subexp, .(Alternatives), summarize, Correlation=cor(ExpectationProportion,EmpiricalMean))
cors # best correlation is with basic alternatives (some, none, all -- .6) and basic+many/most/few/afew (.22)

# plot wonkiness
wonk = unique(mp[,c("PriorExpectation","WonkyProbability","Item","SmoothingBW","Alternatives","SpeakerOptimality","QUD")])
nrow(wonk)
ggplot(wonk, aes(x=PriorExpectation,y=WonkyProbability, color=as.factor(SpeakerOptimality), shape=QUD)) +
  geom_point() +
  geom_smooth() +
  facet_grid(SmoothingBW~Alternatives,scales="free")
ggsave("graphs/wonky_probabilities.pdf",width=20,height=7)

wonk = unique(mp[,c("NormAllPrior","WonkyProbability","Item","SmoothingBW","Alternatives","SpeakerOptimality","QUD")])
nrow(wonk)
ggplot(wonk, aes(x=NormAllPrior,y=WonkyProbability, color=as.factor(SpeakerOptimality), shape=QUD)) +
  geom_point() +
  geom_smooth() +
  facet_grid(SmoothingBW~Alternatives,scales="free")
ggsave("graphs/wonky_probabilities_byallprior.pdf",width=20,height=7)

