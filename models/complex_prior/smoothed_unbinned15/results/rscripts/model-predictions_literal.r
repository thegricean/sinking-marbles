#' ---
#' title: "Prior probabilities in the interpretation of 'some': analysis of model predictions and empirical data"
#' author: "Judith Degen"
#' date: "November 28, 2014"
#' ---

library(ggplot2)
theme_set(theme_bw(18))
#setwd("~/Dropbox/thegricean_sinking-marbles/models/complex_prior/results/")
setwd("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/complex_prior/smoothed_unbinned15/results/")
source("rscripts/helpers.r")

#' get model predictions
load("data/mp.RData")
mp = read.table("data/parsed_results_literal.tsv", quote="", sep="\t", header=T)
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
load("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/16_sinking-marbles-sliders-certain/results/data/r.RData")
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

toplot = droplevels(subset(msome, QUD == "how-many" & SpeakerOptimality == 2 & Alternatives == "0_basic"))#"0_basic1_lownum2_extra4_twowords5_threewords"))
nrow(toplot)
toplot$Probability = as.factor(ifelse(toplot$ptype == "prior","prior","posterior"))
toplot$Prop = factor(toplot$Proportion, levels=c("1-50","51-99","100"))
ggplot(toplot, aes(x=Prop, y=value,color=ptype, group=ptype, size=Probability)) +
  geom_point() +
  geom_line() +
  scale_size_discrete(range=c(1,2)) +
  scale_color_manual(values=c("red","blue","black")) +
  facet_wrap(~Item)
ggsave("graphs/model-empirical-howmany-2-basic-literal.pdf",width=35,height=30)

#plot empirical against predicted allstate-prbabilities for "some"
allstate = droplevels(subset(mp, State == 15))
cors = ddply(allstate, .(Alternatives, QUD, SpeakerOptimality), summarise, r=cor(PosteriorProbability, PosteriorProbability_empirical))
cors = cors[order(cors[,c("r")],decreasing=T),]
head(cors)
# .57 correlation despite being shitty model

ggplot(allstate, aes(x=PosteriorProbability, y=PosteriorProbability_empirical)) +
  geom_point() +
  geom_smooth() +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) + #+  
  #  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_wrap(~SpeakerOptimality)
ggsave("graphs/model-empirical-allstateprobs-literal.pdf",width=30,height=10)

#maybe COGSCI plot basis? plot  predicted allstate-prbabilities for "some" as a function of prior allstate-probabilities

ggplot(allstate, aes(x=PriorProbability, y=PosteriorProbability)) +
  geom_point() +
  geom_smooth() +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
  #  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_wrap(~SpeakerOptimality)
ggsave("graphs/model-allstateprobs-literal.pdf",width=30,height=10)



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
ggsave("graphs/model-empirical-expectations-literal.pdf",width=30,height=10)


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
ggsave("graphs/model-expectations-literal.pdf",width=30,height=10)

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
ggsave("graphs/model-expectations-literal.pdf",width=5.5,height=4.5)#,width=30,height=10)
ggsave("~/cogsci/conferences_talks/_2015/2_cogsci_pasadena/wonky_marbles/paper/pics/model-expectations.pdf",width=5.5,height=4.5)
save(toplot, file="data/toplot-expectations.RData")


save(mp, file="data/mp_literal.RData")



