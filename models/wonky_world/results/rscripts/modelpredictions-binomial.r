#' ---
#' title: "Prior probabilities in the interpretation of 'some': analysis of binomial prior wonky world model predictions"
#' author: "Judith Degen"
#' date: "January 19, 2014"
#' ---

library(ggplot2)
theme_set(theme_bw(18))
setwd("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/wonky_world/results/")
source("rscripts/helpers.r")

#' get model predictions
#load("data/mp-binomial.RData")
#load("data/wr-binomial.RData")

load("data/mp-binomial-laplace.RData")
load("data/wr-binomial-laplace.RData")

# toggle depending on whether you want to get the laplace smoothed or npudens smoothed results
#d = read.table("data/parsed_binomial_results.tsv", quote="", sep="\t", header=T)
d = read.table("data/parsed_binomial_results_laplace.tsv", quote="", sep="\t", header=T)
table(d$Item)
summary(d)
nrow(d)
head(d)
d[d$Item == "ate the seeds birds" & d$QUD=="how-many" & d$Alternatives=="0_basic" & d$SpeakerOptimality == 1,]
d[d$Item == "stuck to the wall baseballs" & d$QUD=="how-many" & d$Alternatives=="0_basic" & d$SpeakerOptimality == 2 & d$Wonky == "true",]
mp = ddply(d, .(Item, QUD, State, Alternatives, Quantifier, SpeakerOptimality, WonkyWorldPrior), summarise, PosteriorProbability=sum(PosteriorProbability))
head(mp)
#mp[mp$Item == "ate the seeds birds" & mp$QUD=="how-many" & mp$Alternatives=="0_basic" & mp$SpeakerOptimality == 1,]
wr = ddply(d, .(Item, QUD, Wonky, Alternatives, Quantifier, SpeakerOptimality, WonkyWorldPrior), summarise, PosteriorProbability=sum(PosteriorProbability))
wr[wr$Item == "ate the seeds birds" & wr$QUD=="how-many" & wr$Alternatives=="0_basic" & wr$SpeakerOptimality == 1,]


# get prior expectations -- toggle depending on whether you want laplace smoothing or npudens smoothing
priorexpectations = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/expectations.txt",sep="\t", header=T, quote="")
row.names(priorexpectations) = paste(priorexpectations$effect,priorexpectations$object)
#priorexpectations = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/expectations_laplace.txt",sep="\t", header=T, quote="")
#row.names(priorexpectations) = paste(priorexpectations$Item)
mp$PriorExpectation = priorexpectations[as.character(mp$Item),]$expectation
wr$PriorExpectation = priorexpectations[as.character(wr$Item),]$expectation


# get smoothed prior probabilities -- toggle depending on whether you want laplace smoothing or npudens smoothing
 priorprobs = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/smoothed_15marbles_priors_withnames.txt",sep="\t", header=T, quote="")
head(priorprobs)
row.names(priorprobs) = paste(priorprobs$effect,priorprobs$object)
mpriorprobs = melt(priorprobs, id.vars=c("effect", "object"))
head(mpriorprobs)
row.names(mpriorprobs) = paste(mpriorprobs$effect,mpriorprobs$object,mpriorprobs$variable)

#priorprobs = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/smoothed_15marbles_priors_withnames_laplace.txt",sep="\t", header=T, quote="")
#head(priorprobs)
#row.names(priorprobs) = paste(priorprobs$Item)
#mpriorprobs = melt(priorprobs, id.vars=c("Item"))
#head(mpriorprobs)
#row.names(mpriorprobs) = paste(mpriorprobs$Item,mpriorprobs$variable)
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
mp$PosteriorProbability_empirical = agr[paste(mp$Item,mp$Proportion,mp$Quantifier),]$normresponse

#plot empirical against predicted distributions for "some"
some = ddply(mp, .(Item, QUD, Alternatives, Quantifier, SpeakerOptimality, PriorExpectation, Proportion, WonkyWorldPrior, PosteriorProbability_empirical), summarise, PosteriorProbability_predicted=sum(PosteriorProbability), PriorProbability_smoothed=sum(PriorProbability))
some= subset(some, Quantifier == "some")
nrow(some)
head(some)
msome = melt(some, measure.vars=c("PosteriorProbability_empirical","PosteriorProbability_predicted","PriorProbability_smoothed"))
msome$ptype = as.factor(ifelse(msome$variable == "PosteriorProbability_empirical", "posterior (empirical)",ifelse(msome$variable == "PosteriorProbability_predicted","posterior (model)", "prior")))
head(msome)
nrow(msome)
summary(msome)

toplot = droplevels(subset(msome, QUD == "how-many" & SpeakerOptimality == 2 & Alternatives == "0_basic"))#"0_basic1_lownum2_extra4_twowords5_threewords"))
nrow(toplot)
toplot$Probability = as.factor(ifelse(toplot$ptype == "prior","prior","posterior"))
toplot$Prop = factor(toplot$Proportion, levels=c("1-50","51-99","100"))
ggplot(toplot, aes(x=Prop, y=value,color=ptype, group=ptype, size=Probability)) +
  geom_point() +
  geom_line() +
  scale_size_discrete(range=c(1,2)) +
  scale_color_manual(values=c("red","blue","black")) +
  facet_wrap(WonkyWorldPrior~Item)
ggsave("graphs/model-empirical-binomial-howmany-2-basic.pdf",width=35,height=30)
#ggsave("graphs/model-empirical-binomial-howmany-2-basic-laplace.pdf",width=35,height=30)

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
mp$PosteriorExpectation_empirical = agr[paste(mp$Item,mp$Quantifier),]$ProportionResponse
mp$PriorExpectation_smoothed = mp$PriorExpectation/15

pexpectations = ddply(mp, .(Item, QUD, Alternatives, Quantifier, SpeakerOptimality,PriorExpectation_smoothed, WonkyWorldPrior, PosteriorExpectation_empirical), summarise, PosteriorExpectation_predicted=sum(State*PosteriorProbability)/15)
head(pexpectations)
some = droplevels(subset(pexpectations, Quantifier == "some"))

cors = ddply(some, .(Alternatives, QUD, SpeakerOptimality, WonkyWorldPrior), summarise, r=cor(PosteriorExpectation_predicted, PosteriorExpectation_empirical))
cors = cors[order(cors[,c("r")],decreasing=T),]
head(cors)
# lowest wonkiness and speaker optimality does best: .68
# laplace: .6
ggplot(some, aes(x=PosteriorExpectation_predicted, y=PosteriorExpectation_empirical)) +
  geom_point() +
  geom_smooth(method="lm") +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0.25,.75)) +
  scale_y_continuous(limits=c(0.25,.75)) +  
  #  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_grid(SpeakerOptimality~WonkyWorldPrior)
#toggle
#ggsave("graphs/model-empirical-binomial-expectations.pdf",width=16,height=15)
ggsave("graphs/model-empirical-binomial-expectations-laplace.pdf",width=16,height=15)

ggplot(some, aes(x=PriorExpectation_smoothed, y=PosteriorExpectation_predicted)) +
  geom_point() +
  geom_smooth(method="lm") +
#  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
  #  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_grid(SpeakerOptimality~WonkyWorldPrior)
#toggle
#ggsave("graphs/model-binomial-expectations.pdf",width=20,height=15)
ggsave("graphs/model-binomial-expectations-laplace.pdf",width=16,height=15)


#plot empirical against predicted allstate-prbabilities for "some"
allstate = droplevels(subset(mp, State == 15 & Quantifier == "some"))
cors = ddply(allstate, .(Alternatives, QUD, SpeakerOptimality, WonkyWorldPrior), summarise, r=cor(PosteriorProbability, PosteriorProbability_empirical))
cors = cors[order(cors[,c("r")],decreasing=T),]
head(cors)
# only .49 correlation, best parameters: high wonky prior, low speaker optimality

ggplot(allstate, aes(x=PosteriorProbability, y=PosteriorProbability_empirical)) +
  geom_point() +
  geom_smooth() +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,0.45)) +
  scale_y_continuous(limits=c(0,0.45)) +  
  #  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_grid(SpeakerOptimality~WonkyWorldPrior)
#toggle
ggsave("graphs/model-empirical-binomial-allstateprobs.pdf",width=16,height=15)
#ggsave("graphs/model-empirical-binomial-allstateprobs-laplace.pdf",width=16,height=15)

#maybe COGSCI plot basis? plot  predicted allstate-prbabilities for "some" as a function of prior allstate-probabilities

ggplot(allstate, aes(x=PriorProbability, y=PosteriorProbability)) +
  geom_point() +
  geom_smooth() +
#  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
  #  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_grid(SpeakerOptimality~WonkyWorldPrior)
#toggle
ggsave("graphs/model-binomial-allstateprobs.pdf",width=16,height=15)
#ggsave("graphs/model-binomial-allstateprobs-laplace.pdf",width=16,height=15)


# get empirical wonkiness posteriors
load("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/11_sinking-marbles-normal/results/data/r.RData")
head(r)
nrow(r)
r$Item = as.factor(paste(r$effect,r$object))

t = as.data.frame(prop.table(table(r$Item, r$quantifier, r$response), mar=c(1,2)))
head(t)
colnames(t) = c("Item","Quantifier","NormalMarbles","Proportion")
t[t$Var1=="ate the seeds birds",]
t$Quantifier = tolower(t$Quantifier)
tail(t)
t$Wonky = as.factor(ifelse(t$NormalMarbles == "yes","false","true"))
row.names(t) = paste(t$Item, t$Quantifier, t$Wonky)

wr$PosteriorProbability_empirical = t[paste(wr$Item, wr$Quantifier, wr$Wonky),]$Proportion
head(wr)
wonky = droplevels(subset(wr, Wonky == "true"))

cors = ddply(wonky, .(Alternatives, QUD, SpeakerOptimality, Quantifier, WonkyWorldPrior), summarise, r=cor(PosteriorProbability, PosteriorProbability_empirical))
cors = cors[order(cors[,c("r")],decreasing=T),]
head(cors,15)


ggplot(wonky, aes(x=PosteriorProbability, y=PosteriorProbability_empirical, color=as.factor(WonkyWorldPrior))) +
  geom_point() +
  geom_smooth(method="lm") +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
  facet_grid(Quantifier~SpeakerOptimality)
# toggle
ggsave("graphs/model-empirical-binomial-wonkiness.pdf", width=16,height=15)
#ggsave("graphs/model-empirical-binomial-wonkiness-laplace.pdf", width=16,height=15)



ggplot(wonky, aes(x=PriorExpectation, y=PosteriorProbability, color=as.factor(WonkyWorldPrior), shape=as.factor(SpeakerOptimality))) +
  geom_point() +
  geom_smooth() +
  scale_y_continuous(limits=c(0,1)) +  
  facet_grid(Quantifier~Alternatives)  
#toggle
ggsave("graphs/model-binomial-wonkiness.pdf", width=6,height=9)
#ggsave("graphs/model-binomial-wonkiness-laplace.pdf", width=6,height=9)

save(mp, file="data/mp-binomial.RData")
save(wr, file="data/wr-binomial.RData")

#save(mp, file="data/mp-binomial-laplace.RData")
#save(wr, file="data/wr-binomial-laplace.RData")






################

expectations = ddply(mp, .(Item, QUD, Alternatives, Quantifier, SpeakerOptimality, PriorExpectation), summarise, Expectation=sum(PosteriorProbability*State))
head(expectations)
tail(expectations)
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
  scale_y_continuous(name="Empirical mean all-state probability") +
  facet_wrap(~SmoothingBW)
ggsave("graphs/model-empirical.pdf")  
cor(mp_some_allstate$PosteriorProbability,mp_some_allstate$EmpiricalPosterior) # .51

head(subexp)
# get empirical expectations:
load("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/13_sinking-marbles-priordv-15/results/data/r.RData")
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

