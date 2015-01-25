#' ---
#' title: "Prior probabilities in the interpretation of 'some': analysis of binomial_nullutterance prior wonky world model predictions"
#' author: "Judith Degen"
#' date: "January 12, 2014"
#' ---

library(ggplot2)
theme_set(theme_bw(18))
setwd("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/wonky_world/results/")
source("rscripts/helpers.r")

#' get model predictions
load("data/mp-binomial_nullutterance_coinweights.RData")
d = read.table("data/parsed_binomial_nullutterance_coinweights_results.tsv", quote="", sep="\t", header=T)
table(d$Item)
nrow(d)
head(d)
summary(d)
d[d$Item == "ate the seeds birds" & d$QUD=="how-many" & d$Alternatives=="0_basic" & d$SpeakerOptimality == 1,]
d[d$Item == "stuck to the wall baseballs" & d$QUD=="how-many" & d$Alternatives=="0_basic" & d$SpeakerOptimality == 2 & d$WonkyWorldPrior == .5,]
mp = ddply(d, .(Item, CoinWeight, SpeakerOptimality, WonkyWorldPrior,NullUtteranceCost), summarise, PosteriorProbability=sum(PosteriorProbability))
head(mp)


# get prior expectations
priorexpectations = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/expectations.txt",sep="\t", header=T, quote="")
row.names(priorexpectations) = paste(priorexpectations$effect,priorexpectations$object)
mp$PriorExpectation = priorexpectations[as.character(mp$Item),]$expectation

# get smoothed prior probabilities
priorprobs = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/smoothed_15marbles_priors_withnames.txt",sep="\t", header=T, quote="")
head(priorprobs)
row.names(priorprobs) = paste(priorprobs$effect,priorprobs$object)
mpriorprobs = melt(priorprobs, id.vars=c("effect", "object"))
head(mpriorprobs)
row.names(mpriorprobs) = paste(mpriorprobs$effect,mpriorprobs$object,mpriorprobs$variable)
mp$AllPriorProbability = priorprobs[paste(as.character(mp$Item)),]$X15
head(mp)
summary(mp)

mp$CoinWeight = as.numeric(as.character(mp$CoinWeight))
ggplot(mp, aes(x=PriorExpectation,y=PosteriorProbability,color=as.factor(WonkyWorldPrior),shape=as.factor(SpeakerOptimality))) +
  geom_point() +
  facet_grid(NullUtteranceCost~CoinWeight)

cw = subset(mp, !is.na(CoinWeight) & SpeakerOptimality == 2 & WonkyWorldPrior == .5)
p=ggplot(cw, aes(x=CoinWeight,y=PosteriorProbability)) +
  geom_point() +
  geom_line() +
  #scale_y_continuous(limits = c(0,.5)) +
  facet_grid(PriorExpectation~NullUtteranceCost)
#p
ggsave("graphs/posterior_coinweights_bypriorexp.pdf",height=35,width=6)

p=ggplot(cw, aes(x=CoinWeight,y=PosteriorProbability)) +
  geom_point() +
  geom_line() +
  #scale_y_continuous(limits = c(0,.5)) +
  facet_grid(AllPriorProbability~NullUtteranceCost)
#p
ggsave("graphs/posterior_coinweights_byallprob.pdf",height=35,width=6)


# CONTINUE HERE
#plot empirical against predicted distributions for "some"
msome = droplevels(subset(mp, Quantifier == "some"))
some =  ddply(msome, .(Item, SpeakerOptimality, PriorExpectation, Proportion, WonkyWorldPrior, NullUtteranceCost, PosteriorProbability_empirical), summarise, PosteriorProbability_predicted=sum(PosteriorProbability), PriorProbability_smoothed=sum(PriorProbability))
nrow(some)
head(some)
msome = melt(some, measure.vars=c("PosteriorProbability_empirical","PosteriorProbability_predicted","PriorProbability_smoothed"))
msome$ptype = as.factor(ifelse(msome$variable == "PosteriorProbability_empirical", "posterior (empirical)",ifelse(msome$variable == "PosteriorProbability_predicted","posterior (model)", "prior")))
head(msome)
nrow(msome)
summary(msome)

toplot = droplevels(subset(msome, SpeakerOptimality == 2 &  NullUtteranceCost == 5))#"0_basic1_lownum2_extra4_twowords5_threewords"))
nrow(toplot)
toplot$Probability = as.factor(ifelse(toplot$ptype == "prior","prior","posterior"))
toplot$Prop = factor(toplot$Proportion, levels=c("1-50","51-99","100"))
ggplot(toplot, aes(x=Prop, y=value,color=ptype, group=ptype, size=Probability)) +
  geom_point() +
  geom_line() +
  scale_size_discrete(range=c(1,2)) +
  scale_color_manual(values=c("red","blue","black")) +
  facet_wrap(WonkyWorldPrior~Item)
ggsave("graphs/model-empirical-binomial_nullutterance-howmany-2-basic-cost5.pdf",width=35,height=30)

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

pexpectations = ddply(mp, .(Quantifier, Item, SpeakerOptimality,PriorExpectation_smoothed, WonkyWorldPrior, NullUtteranceCost, PosteriorExpectation_empirical), summarise, PosteriorExpectation_predicted=sum(CoinWeight*PosteriorProbability)/15)
head(pexpectations)
#some = pexpectations
some = droplevels(subset(pexpectations, Quantifier == "some"))

cors = ddply(some, .(SpeakerOptimality, WonkyWorldPrior, NullUtteranceCost), summarise, r=cor(PosteriorExpectation_predicted, PosteriorExpectation_empirical))
cors = cors[order(cors[,c("r")],decreasing=T),]
head(cors)

ggplot(some, aes(x=PosteriorExpectation_predicted, y=PosteriorExpectation_empirical,color=as.factor(SpeakerOptimality)))+#, shape=as.factor(WonkyWorldPrior))) +
  geom_point() +
  geom_smooth(method="lm") +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
#  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_grid(NullUtteranceCost~WonkyWorldPrior)
ggsave("graphs/model-empirical-binomial_nullutterance-expectations.pdf",width=30,height=10)

ggplot(some, aes(x=PriorExpectation_smoothed, y=PosteriorExpectation_predicted,color=as.factor(WonkyWorldPrior)))+#, shape=as.factor(WonkyWorldPrior))) +
  geom_point() +
  geom_smooth(method="lm") +
  #geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
  #  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_grid(NullUtteranceCost~SpeakerOptimality)
ggsave("graphs/model-binomial_nullutterance-expectations.pdf",width=15,height=10)

  
#plot empirical against predicted allCoinWeight-prbabilities for "some"
allCoinWeight = droplevels(subset(mp, CoinWeight == 15 & Quantifier == "some"))
cors = ddply(allCoinWeight, .(SpeakerOptimality, WonkyWorldPrior), summarise, r=cor(PosteriorProbability, PosteriorProbability_empirical))
cors = cors[order(cors[,c("r")],decreasing=T),]
head(cors)
# .53 correlation

ggplot(allCoinWeight, aes(x=PosteriorProbability, y=PosteriorProbability_empirical,color=as.factor(WonkyWorldPrior))) +
  geom_point() +
  geom_smooth() +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
  #  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_grid(SpeakerOptimality~NullUtteranceCost)
ggsave("graphs/model-empirical-binomial_nullutterance-allCoinWeightprobs.pdf",width=20,height=20)

#maybe COGSCI plot basis? plot  predicted allCoinWeight-prbabilities for "some" as a function of prior allCoinWeight-probabilities

ggplot(allCoinWeight, aes(x=PriorProbability, y=PosteriorProbability,color=as.factor(WonkyWorldPrior))) +
  geom_point() +
  geom_smooth() +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
  #  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_grid(NullUtteranceCost~SpeakerOptimality)
ggsave("graphs/model-binomial_nullutterance-allCoinWeightprobs.pdf",width=15,height=10)

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

head(wonky)
toplot = droplevels(subset(wonky,  SpeakerOptimality == 2))

ggplot(toplot, aes(x=PriorExpectation, y=PosteriorProbability, color=Quantifier)) +
  geom_point() +
  geom_smooth() +
  facet_grid(WonkyWorldPrior~NullUtteranceCost)
ggsave(file="graphs/wonkinessplot.pdf",width=6)

cors = ddply(wonky, .(SpeakerOptimality, Quantifier, WonkyWorldPrior,NullUtteranceCost), summarise, r=cor(PosteriorProbability, PosteriorProbability_empirical))
cors = cors[order(cors[,c("r")],decreasing=T),]
head(cors,15)


wonky_all = subset(wonky, Quantifier == "all")
wonky_none = subset(wonky, Quantifier == "none")
wonky_some = subset(wonky, Quantifier == "some")

ggplot(wonky_all, aes(x=PosteriorProbability, y=PosteriorProbability_empirical, color=as.factor(WonkyWorldPrior))) +
  geom_point() +
  geom_smooth(method="lm") +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
  facet_grid(NullUtteranceCost~SpeakerOptimality)
ggsave("graphs/model-empirical-binomial_nullutterance-wonkiness_all.pdf", width=15,height=10)

ggplot(wonky_none, aes(x=PosteriorProbability, y=PosteriorProbability_empirical, color=as.factor(WonkyWorldPrior))) +
  geom_point() +
  geom_smooth(method="lm") +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
  facet_grid(NullUtteranceCost~SpeakerOptimality)
ggsave("graphs/model-empirical-binomial_nullutterance-wonkiness_none.pdf", width=15,height=10)

ggplot(wonky_some, aes(x=PosteriorProbability, y=PosteriorProbability_empirical, color=as.factor(WonkyWorldPrior))) +
  geom_point() +
  geom_smooth(method="lm") +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
  facet_grid(NullUtteranceCost~SpeakerOptimality)
ggsave("graphs/model-empirical-binomial_nullutterance-wonkiness_some.pdf", width=15,height=10)



ggplot(wonky_all, aes(x=PriorExpectation, y=PosteriorProbability, color=as.factor(WonkyWorldPrior))) +
  geom_point() +
  geom_smooth() +
  scale_y_continuous(limits=c(0,1)) +  
  facet_grid(NullUtteranceCost~SpeakerOptimality)
ggsave("graphs/model-binomial_nullutterance-all-wonkiness.pdf", width=15,height=10)

ggplot(wonky_none, aes(x=PriorExpectation, y=PosteriorProbability, color=as.factor(WonkyWorldPrior))) +
  geom_point() +
  geom_smooth() +
  scale_y_continuous(limits=c(0,1)) +  
  facet_grid(NullUtteranceCost~SpeakerOptimality)  
ggsave("graphs/model-binomial_nullutterance-none-wonkiness.pdf", width=15,height=10)

ggplot(wonky_some, aes(x=PriorExpectation, y=PosteriorProbability, color=as.factor(WonkyWorldPrior))) +
  geom_point() +
  geom_smooth() +
  scale_y_continuous(limits=c(0,1)) +  
  facet_grid(NullUtteranceCost~SpeakerOptimality) 
ggsave("graphs/model-binomial_nullutterance-some-wonkiness.pdf", width=15,height=10)

save(mp, file="data/mp-binomial_nullutterance.RData")
save(wr, file="data/wr-binomial_nullutterance.RData")


########

wonky[wonky$Quantifier == "all" & wonky$PriorExpectation < 4 & wonky$Alternatives == "0_basic" & wonky$QUD == "how-many" & wonky$SpeakerOptimality == 2,]

# get model predictions for all-CoinWeight with basic alts, spopt==2, and qud==how-many
mp_some_allCoinWeight = subset(mp, Alternatives=="0_basic" & SpeakerOptimality == 2 & QUD == "how-many" & CoinWeight == 15)
head(mp_some_allCoinWeight)
nrow(mp_some_allCoinWeight)



# plot expectations for best basic model: 
toplot = droplevels(subset(mp, QUD == "how-many" & Alternatives == "0_basic" & Quantifier == "some" & WonkyWorldPrior == .5))
nrow(toplot)

pexpectations = ddply(toplot, .(Item, SpeakerOptimality,PriorExpectation_smoothed, PosteriorExpectation_empirical), summarise, PosteriorExpectation_predicted=sum(CoinWeight*PosteriorProbability)/15)
head(pexpectations)
some = pexpectations#droplevels(subset(pexpectations, Quantifier == "some"))

cors = ddply(some, .(SpeakerOptimality), summarise, r=cor(PosteriorExpectation_predicted, PosteriorExpectation_empirical))
cors = cors[order(cors[,c("r")],decreasing=T),]
head(cors)

toplot = droplevels(subset(some, SpeakerOptimality == 1))
nrow(toplot)
head(toplot)

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
ggsave("~/cogsci/conferences_talks/_2015/2_cogsci_pasadena/wonky_marbles/paper/pics/model-expectations-binomial_nullutterance.pdf",width=5.5,height=4.5)
save(toplot, file="data/toplot-expectations.RData")

toplot_w = toplot
load("../../complex_prior/smoothed_unbinned15/results/data/toplot-expectations.RData")
toplot_r = toplot
head(toplot_w)
summary(toplot_r)
toplot_r$RSA = "regular"
toplot_w$RSA = "wonky"
  
# plot both rRSA and binomial_nullutterance wRSA expectation predictions in same plot
toplot = merge(toplot_r,toplot_w, all=T)
head(toplot)
nrow(toplot)
ggplot(toplot, aes(x=PriorExpectation_smoothed, y=PosteriorExpectation_predicted, shape=RSA)) +
  geom_point(color="#00B0F6") + #values=c("#F8766D", "#A3A500", "#00BF7D", "#E76BF3", "#00B0F6")
  geom_smooth(color="#00B0F6") +
  #  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1), name="Prior expectation") +
  scale_y_continuous(limits=c(0,1), name="Model predicted posterior expectation")
#  geom_text(data=cors, aes(label=r)) +
#scale_size_discrete(range=c(1,2)) +
#scale_color_manual(values=c("red","blue","black")) 
#ggsave("graphs/model-expectations.pdf",width=5.5,height=4.5)#,width=30,height=10)
ggsave("~/cogsci/conferences_talks/_2015/2_cogsci_pasadena/wonky_marbles/paper/pics/model-expectations-binomial_nullutterance-regular.pdf",width=6.5,height=4.5)
