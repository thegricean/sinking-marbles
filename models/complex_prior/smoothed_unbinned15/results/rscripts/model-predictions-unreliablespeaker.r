#' ---
#' title: "Prior probabilities in the interpretation of 'some': analysis of model predictions and empirical data"
#' author: "Judith Degen"
#' date: "November 28, 2014"
#' ---

library(ggplot2)
theme_set(theme_bw(18))
setwd("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/complex_prior/smoothed_unbinned15/results/")
source("rscripts/helpers.r")

#' get model predictions
load("data/mp.RData")
mp = read.table("data/parsed_results.tsv", quote="", sep="\t", header=T)
nrow(mp)
head(mp)
summary(mp)

# get prior expectations
priorexpectations = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/expectations.txt",sep="\t", header=T, quote="")
row.names(priorexpectations) = paste(priorexpectations$effect,priorexpectations$object)
head(priorexpectations)
mp$PriorExpectation = priorexpectations[as.character(mp$Item),]$expectation

priorprobs = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/smoothed_15marbles_priors_withnames.txt",sep="\t", header=T, quote="")
head(priorprobs)
row.names(priorprobs) = paste(priorprobs$effect,priorprobs$object)
mpriorprobs = melt(priorprobs, id.vars=c("effect", "object"))
head(mpriorprobs)
row.names(mpriorprobs) = paste(mpriorprobs$effect,mpriorprobs$object,mpriorprobs$variable)
mp$PriorProbability = mpriorprobs[paste(as.character(mp$Item)," X",mp$State,sep=""),]$value
mp$AllPriorProbability = priorprobs[paste(as.character(mp$Item)),]$X15
head(mp)

# get empirical state posteriors:
load("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/3_sinking-marbles-nullutterance/results/data/r.RData")
head(r)
r$Item = as.factor(paste(r$effect,r$object))
# because posteriors come in 4 bins, make Bin variable for model prediction dataset:
mp$Proportion = as.factor(ifelse(mp$State == 0, "0", ifelse(mp$State == 15, "100", ifelse(mp$State < 8, "1-50", "51-99"))))

agr = aggregate(normresponse ~ Item + quantifier + Proportion,data=r,FUN=mean)
#agr$CILow = aggregate(normresponse ~ Item + quantifier + Proportion,data=r, FUN=ci.low)$normresponse
#agr$CIHigh = aggregate(normresponse ~ Item + quantifier + Proportion,data=r,FUN=ci.high)$normresponse
#agr$YMin = agr$normresponse - agr$CILow
#agr$YMax = agr$normresponse + agr$CIHigh
agr$Quantifier = as.factor(tolower(agr$quantifier))
row.names(agr) = paste(agr$Item, agr$Proportion, agr$Quantifier)
mp$PosteriorProbability_empirical = agr[paste(mp$Item,mp$Proportion,"some"),]$normresponse

summary(mp)
#plot empirical against predicted distributions for "some"
some = ddply(mp, .(Item, QUD, Alternatives, SpeakerOptimality, PriorExpectation, Proportion, PosteriorProbability_empirical), summarise, PosteriorProbability_predicted=sum(PosteriorProbability), PriorProbability_smoothed=sum(PriorProbability))
#some= subset(some, Quantifier == "some")
nrow(some)
head(some)
msome = melt(some, measure.vars=c("PosteriorProbability_empirical","PosteriorProbability_predicted","PriorProbability_smoothed"))
msome$ptype = as.factor(ifelse(msome$variable == "PosteriorProbability_empirical", "posterior (empirical)",ifelse(msome$variable == "PosteriorProbability_predicted","posterior (model)", "prior")))
head(msome)
nrow(msome)
summary(msome)

#toplot = droplevels(subset(msome, QUD == "how-many" & SpeakerOptimality == 2 & Alternatives == "0_basic"))#"0_basic1_lownum2_extra4_twowords5_threewords"))
toplot = droplevels(subset(msome, QUD == "how-many" & SpeakerOptimality == 0 & Alternatives == "0_basic"))
nrow(toplot)
toplot$Probability = as.factor(ifelse(toplot$ptype == "prior","prior","posterior"))
toplot$Prop = factor(toplot$Proportion, levels=c("1-50","51-99","100"))
ggplot(toplot, aes(x=Prop, y=value,color=ptype, group=ptype, size=Probability)) +
  geom_point() +
  geom_line() +
  scale_size_discrete(range=c(1,2)) +
  scale_color_manual(values=c("red","blue","black")) +
  facet_wrap(~Item)
ggsave("graphs/modelunreliable-empirical-howmany-2-basic.pdf",width=35,height=30)

#plot empirical against predicted allstate-prbabilities for "some"
allstate = droplevels(subset(mp, State == 15))
cors = ddply(allstate, .(Alternatives, QUD, SpeakerOptimality), summarise, r=cor(PosteriorProbability, PosteriorProbability_empirical))
cors = cors[order(cors[,c("r")],decreasing=T),]
head(cors)
# .57 correlation despite being shitty model

ggplot(allstate, aes(x=PosteriorProbability, y=PosteriorProbability_empirical,color=as.factor(SpeakerOptimality))) +
  geom_point() +
  geom_smooth() +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
  #  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_grid(QUD~Alternatives)
ggsave("graphs/model-empirical-allstateprobs.pdf",width=30,height=10)

#maybe COGSCI plot basis? plot  predicted allstate-prbabilities for "some" as a function of prior allstate-probabilities

ggplot(allstate, aes(x=PriorProbability, y=PosteriorProbability,color=as.factor(SpeakerOptimality))) +
  geom_point() +
  geom_smooth() +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
  #  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_grid(QUD~Alternatives)
ggsave("graphs/model-allstateprobs.pdf",width=30,height=10)



#plot empirical against predicted expectations for "some"
load("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/13_sinking-marbles-priordv-15/results/data/r.RData")
summary(r)
r$Item = as.factor(paste(r$effect, r$object))
agr = aggregate(ProportionResponse ~ Item + quantifier, data=r, FUN=mean)
#agr$CILow = aggregate(ProportionResponse ~ Item + quantifier,data=r, FUN=ci.low)$ProportionResponse
#agr$CIHigh = aggregate(ProportionResponse ~ Item + quantifier,data=r,FUN=ci.high)$ProportionResponse
#agr$YMin = agr$ProportionResponse - agr$CILow
#agr$YMax = agr$ProportionResponse + agr$CIHigh
agr$Quantifier = as.factor(tolower(agr$quantifier))
row.names(agr) = paste(agr$Item, agr$Quantifier)
mp$PosteriorExpectation_empirical = agr[paste(mp$Item,"some"),]$ProportionResponse
mp$PriorExpectation_smoothed = mp$PriorExpectation/15

pexpectations = ddply(mp, .(Item, QUD, Alternatives, SpeakerOptimality,PriorExpectation_smoothed, PosteriorExpectation_empirical), summarise, PosteriorExpectation_predicted=sum(State*PosteriorProbability)/15)
head(pexpectations)
summary(pexpectations)
some = pexpectations#droplevels(subset(pexpectations, Quantifier == "some"))

cors = ddply(some, .(Alternatives, QUD, SpeakerOptimality), summarise, r=cor(PosteriorExpectation_predicted, PosteriorExpectation_empirical))
cors = cors[order(cors[,c("r")],decreasing=T),]
head(cors)

ggplot(some, aes(x=PosteriorExpectation_predicted, y=PosteriorExpectation_empirical,color=as.factor(SpeakerOptimality))) +
  geom_point() +
  geom_smooth(method="lm") +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
  #  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_grid(QUD~Alternatives)
ggsave("graphs/model-empirical-expectations.pdf",width=30,height=10)


# plot posterior expectation against prior expectation
ggplot(some, aes(x=PriorExpectation_smoothed, y=PosteriorExpectation_predicted,color=as.factor(SpeakerOptimality))) +
  geom_point() +
  geom_smooth(method="lm") +
#  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
  #  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_grid(QUD~Alternatives)
ggsave("graphs/model-expectations.pdf",width=30,height=10)

# plot posterior expectation against prior expectation for basic model with speaker optimality =2 and qud = how-many and alternatives = basic
toplot = droplevels(subset(some, QUD=="how-many" & Alternatives == "0_basic" & SpeakerOptimality == 2))
ggplot(toplot, aes(x=PriorExpectation_smoothed, y=PosteriorExpectation_predicted)) +
  geom_point(color="#00B0F6") + #values=c("#F8766D", "#A3A500", "#00BF7D", "#E76BF3", "#00B0F6")
  geom_smooth(color="#00B0F6") +
  #  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1), name="Prior expectation") +
  scale_y_continuous(limits=c(0,1), name="Model predicted posterior expectation")
  #  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) 
ggsave("graphs/model-expectations.pdf",width=5.5,height=4.5)#,width=30,height=10)
ggsave("~/cogsci/conferences_talks/_2015/2_cogsci_pasadena/wonky_marbles/paper/pics/model-expectations.pdf",width=5.5,height=4.5)
save(toplot, file="data/toplot-expectations.RData")


save(mp, file="data/mp.RData")



expectations = ddply(mp, .(Item, QUD, Alternatives, SpeakerOptimality, NormAllPrior,PriorExpectation), summarize, expectation=sum(PosteriorProbability*seq(1,15,by=1)))
head(expectations)
expectations$ExpectationProportion = expectations$expectation/15
expectations$QUDOpt = as.factor(paste(expectations$QUD,expectations$SpeakerOptimality))

ggplot(expectations, aes(x=NormAllPrior,y=ExpectationProportion,color=as.factor(SpeakerOptimality),shape=QUD,group=QUDOpt)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(~Alternatives)
ggsave("graphs/expectations.pdf",width=12,height=7)

ggplot(expectations, aes(x=ExpectationProportion,fill=QUD)) +
  geom_histogram(position="dodge") +
  facet_grid(SpeakerOptimality~Alternatives,scales="free_y")
ggsave("graphs/expectation_histograms.pdf",width=12)

  
subexp = subset(expectations, SpeakerOptimality == 2 & QUD == "how-many")
ggplot(subexp, aes(x=NormAllPrior,y=ExpectationProportion)) +
  geom_point() +
  geom_smooth() +
  facet_wrap(~Alternatives)
ggsave("graphs/expectations_spopt2_qudhowmany.pdf",width=12,height=7)

ggplot(subexp, aes(x=PriorExpectation,y=ExpectationProportion)) +
  geom_point() +
  geom_smooth() +
  geom_abline(intercept=0,slope=1) +
  facet_wrap(~Alternatives)
ggsave("graphs/expectations_bypriorexp_spopt2_qudhowmany.pdf",width=12,height=7)

ggplot(subset(subexp,Alternatives=="0_basic"), aes(x=PriorExpectation,y=ExpectationProportion)) +
  geom_point() +
  geom_smooth() +
  geom_abline(intercept=0,slope=1,color="gray70")  +
  scale_x_continuous(name="Prior expectation") +
  scale_y_continuous(name="Posterior expectation") 
ggsave("graphs/expectations_bypriorexp_spopt2_qudhowmany_alternativesbasic.pdf",width=12,height=7)
ggsave("graphs/modelpredictions_expectations.pdf")

ggplot(subset(mp, Alternatives=="0_basic" & SpeakerOptimality == 2 & QUD == "how-many" & NumState == 15), aes(x=NormAllPrior,y=PosteriorProbability)) +
  geom_point() +
  #geom_smooth() +
  #geom_abline(intercept=0,slope=1,color="gray70") +
  scale_x_continuous(name="Prior probability of all-state") +
  scale_y_continuous(name="Posterior probability of all-state")   
ggsave("graphs/modelpredictions_allstate.pdf")



# get empirical posteriors:
load("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/3_sinking-marbles-nullutterance/results/data/r.RData")
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
  scale_y_continuous(name="Empirical mean all-state probability") 
ggsave("graphs/model-empirical.pdf")  
cor(mp_some_allstate$PosteriorProbability,mp_some_allstate$EmpiricalPosterior) # .51

head(subexp)
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

ggplot(subexp, aes(x=ExpectationProportion, y=EmpiricalMean_good)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin_good,ymax=YMax_good)) +
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

corsgood = ddply(subexp, .(Alternatives), summarize, Correlation=cor(ExpectationProportion,EmpiricalMean_good))
cors # best correlation is with basic alternatives (some, none, all -- .6) and basic+many/most/few/afew (-- .59)

# prior expectations
agr = aggregate(ProportionResponse ~ Item,data=some,FUN=mean)
agr$CILow = aggregate(ProportionResponse ~ Item,data=some, FUN=ci.low)$ProportionResponse
agr$CIHigh = aggregate(ProportionResponse ~ Item,data=some,FUN=ci.high)$ProportionResponse
agr$YMin = agr$ProportionResponse - agr$CILow
agr$YMax = agr$ProportionResponse + agr$CIHigh
row.names(agr) = agr$Item

exps = read.csv("data/expectations_15_bw5_prior.txt",header=T,sep="\t")
exps$EmpiricalMean = agr[paste(exps$effect, exps$object),]$ProportionResponse
exps$YMin = agr[paste(exps$effect, exps$object),]$YMin
exps$YMax = agr[paste(exps$effect, exps$object),]$YMax
exps$Expectation = exps$expectation/100

ggplot(exps, aes(x=Expectation, y=EmpiricalMean)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_abline(intercept=0,slope=1,color="gray70") +
  geom_smooth(method="lm") 
ggsave("graphs/prior_expectation.pdf",width=4.5,height=3)

#0.008312938/sum(0.005127138,0.00545222,0.005461004,0.005362598,0.005405903,0.005763719,0.006450809,0.007313772,0.008111662,0.008657936,0.008930543,0.009054953,0.009158519,0.009213201,0.009011604,0.008312938)

p=ggplot(mp, aes(x=NumState,y=PosteriorProbability,shape=as.factor(SpeakerOptimality),color=QUD,group=QUDOpt)) +
  geom_point() +
  geom_line() +
  facet_grid(Item~Alternatives,scales="free_y") +
  theme(axis.text.x=element_text(size=6))
ggsave("graphs/full-dists.pdf",height=45,width=12)

# plot prior versus posterior expectations
pp = data.frame(PriorExpectation = exps$Expectation[1:89],PosteriorExpectation = subexp[subexp$Alternatives == "0_basic",]$ExpectationProportion, Item=subexp[subexp$Alternatives == "0_basic",]$Item)
head(pp)

ggplot(pp, aes(x=PriorExpectation,y=PosteriorExpectation)) +
  geom_point()

ggplot(pp, aes(x=PriorExpectation,y=PosteriorExpectation)) +
  geom_point() +
  geom_abline(intercept=0,slope=1,color="gray70") +
  geom_text(aes(label=Item,y=PosteriorExpectation+.01),color="gray60",size=2)
ggsave("graphs/prior_posterior.pdf")


## expectation for posterior under uniform prior, 15 states
sum(seq(1,15,by=1) * c(0.07111111111111111, 0.07111111111111111, 0.07111111111111111, 0.07111111111111111, 0.07111111111111111, 0.07111111111111111, 0.07111111111111111, 0.07111111111111111, 0.07111111111111111, 0.07111111111111111, 0.07111111111111111, 0.07111111111111111, 0.07111111111111111, 0.07111111111111111, 0.004444444444444445))/15
