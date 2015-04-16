#' ---
#' title: "Prior probabilities in the interpretation of 'some': analysis of uniform prior wonky world model predictions with prior slider DV"
#' author: "Judith Degen"
#' date: "March 12, 2015"
#' ---

library(ggplot2)
library(hydroGOF)
theme_set(theme_bw(18))
setwd("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/wonky_world/results/")
source("rscripts/helpers.r")

#' get model predictions
load("data/mp-uniform.RData")
d = read.table("data/parsed_uniform_priorslider_results.tsv", quote="", sep="\t", header=T)
names(d)
table(d$Item)
nrow(d)
head(d)
summary(d)

agrmp = aggregate(PosteriorProbability ~ Item + State + SpeakerOptimality + WonkyWorldPrior + Wonky, FUN="mean", data=d)
nrow(agrmp)
summary(agrmp)
agrmp$CILow = aggregate(PosteriorProbability ~ Item + State + SpeakerOptimality + WonkyWorldPrior + Wonky, FUN="ci.low", data=d)$PosteriorProbability
agrmp$CIHigh = aggregate(PosteriorProbability ~ Item + State + SpeakerOptimality + WonkyWorldPrior + Wonky, FUN="ci.high", data=d)$PosteriorProbability

mp = ddply(agrmp, .(Item, State, SpeakerOptimality, WonkyWorldPrior), summarise, PosteriorProbability=sum(PosteriorProbability))
summary(mp)
head(mp)
#mp[mp$Item == "ate the seeds birds" & mp$QUD=="how-many" & mp$Alternatives=="0_basic" & mp$SpeakerOptimality == 1,]
wr = ddply(agrmp, .(Item, Wonky, SpeakerOptimality, WonkyWorldPrior), summarise, PosteriorProbability=sum(PosteriorProbability))
summary(wr)
wr[wr$Item == "ate the seeds birds" & wr$QUD=="how-many" & wr$Alternatives=="0_basic" & wr$SpeakerOptimality == 1,]

mp$Item = gsub("_"," ",mp$Item)
wr$Item = gsub("_"," ",wr$Item)

# get prior expectations
priorexpectations = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/expectations.txt",sep="\t", header=T, quote="")
row.names(priorexpectations) = paste(priorexpectations$effect,priorexpectations$object)
mp$PriorExpectation_number = priorexpectations[as.character(mp$Item),]$expectation_corr
wr$PriorExpectation_number = priorexpectations[as.character(wr$Item),]$expectation_corr

# get smoothed prior probabilities
priorprobs = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/smoothed_15marbles_priors_withnames.txt",sep="\t", header=T, quote="")
head(priorprobs)
row.names(priorprobs) = paste(priorprobs$effect,priorprobs$object)
mpriorprobs = melt(priorprobs, id.vars=c("effect", "object"))
head(mpriorprobs)
row.names(mpriorprobs) = paste(mpriorprobs$effect,mpriorprobs$object,mpriorprobs$variable)
mp$PriorProbability_number = mpriorprobs[paste(as.character(mp$Item)," X",mp$State,sep=""),]$value
mp$AllPriorProbability_number = priorprobs[paste(as.character(mp$Item)),]$X15
wr$AllPriorProbability_number = priorprobs[paste(as.character(wr$Item)),]$X15
head(wr)

# get empirical state posteriors:
load("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/16_sinking-marbles-sliders-certain/results/data/r.RData")
head(r)
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

head(mp)

# get slider prior probabilities
load(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/23_sinking-marbles-prior-sliders-exactly/results/data/agr-normresponses.RData")

sliderprobs = agr
head(sliderprobs)
nrow(sliderprobs)
row.names(sliderprobs) = paste(sliderprobs$Item,sliderprobs$State)
mp$PriorProbability_slider = sliderprobs[paste(as.character(mp$Item),mp$State),]$prior_slider
#mp$AllPriorProbability_slider = priorprobs[paste(as.character(mp$Item)),]$X15
head(mp)

# get slider expectations
slexp = ddply(sliderprobs, .(Item), summarise, expectation=sum(State*prior_slider))
summary(slexp)
head(slexp)
row.names(slexp) = as.character(slexp$Item)

mp$PriorExpectation_slider = slexp[as.character(mp$Item),]$expectation
wr$PriorExpectation_slider = slexp[as.character(wr$Item),]$expectation


save(mp, file="data/mp-uniform-priorsliders.RData")
save(wr, file="data/wr-uniform-priorsliders.RData")



###### HERE WE START WITH ALL THE INTERESTING PLOTTING
#plot empirical against predicted distributions for "some"
some = ddply(mp, .(Item, SpeakerOptimality, PriorExpectation_slider, Proportion, WonkyWorldPrior, PosteriorProbability_empirical), summarise, PosteriorProbability_predicted=sum(PosteriorProbability), PriorProbability_smoothed=sum(PriorProbability_slider))
nrow(some)
head(some)
msome = melt(some, measure.vars=c("PosteriorProbability_empirical","PosteriorProbability_predicted","PriorProbability_smoothed"))
msome$ptype = as.factor(ifelse(msome$variable == "PosteriorProbability_empirical", "posterior (empirical)",ifelse(msome$variable == "PosteriorProbability_predicted","posterior (model)", "prior")))
head(msome)
nrow(msome)
summary(msome)

toplot = droplevels(subset(msome,  SpeakerOptimality == 2))#"0_basic1_lownum2_extra4_twowords5_threewords"))
nrow(toplot)
toplot$Probability = as.factor(ifelse(toplot$ptype == "prior","prior","posterior"))
toplot$Prop = factor(toplot$Proportion, levels=c("1-50","51-99","100"))
ggplot(toplot, aes(x=Prop, y=value,color=ptype, group=ptype, size=Probability)) +
  geom_point() +
  geom_line() +
  scale_size_discrete(range=c(1,2)) +
  scale_color_manual(values=c("red","blue","black")) +
  facet_wrap(WonkyWorldPrior~Item)
ggsave("graphs/model-empirical-uniform-howmany-2-basic-sliderprior.pdf",width=35,height=30)

#plot empirical against predicted expectations for "some"
load("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/13_sinking-marbles-priordv-15/results/data/r.RData")
summary(r)
r$Item = as.factor(paste(r$effect, r$object))
agr = aggregate(ProportionResponse ~ Item + quantifier, data=r, FUN=mean)
agr$Quantifier = as.factor(tolower(agr$quantifier))
row.names(agr) = paste(agr$Item, agr$Quantifier)
mp$PosteriorExpectation_empirical = agr[paste(mp$Item,"some"),]$ProportionResponse

pexpectations = ddply(mp, .(Item,SpeakerOptimality,PriorExpectation_slider, WonkyWorldPrior, PosteriorExpectation_empirical), summarise, PosteriorExpectation_predicted=sum(State*PosteriorProbability)/15)
head(pexpectations)
some=pexpectations

cors = ddply(some, .(SpeakerOptimality, WonkyWorldPrior), summarise, r=cor(PosteriorExpectation_predicted, PosteriorExpectation_empirical))
cors = cors[order(cors[,c("r")],decreasing=T),]
head(cors)

mses = ddply(some, .(SpeakerOptimality, WonkyWorldPrior), summarise, mse=mse(PosteriorExpectation_predicted, PosteriorExpectation_empirical))
mses = mses[order(mses[,c("mse")]),]
head(mses)

ggplot(some, aes(x=PosteriorExpectation_predicted, y=PosteriorExpectation_empirical,color=as.factor(SpeakerOptimality), shape=as.factor(WonkyWorldPrior))) +
  geom_point() +
  geom_smooth(method="lm") +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) + 
#  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_grid(SpeakerOptimality~WonkyWorldPrior)
ggsave("graphs/model-empirical-uniform-sliderpior-expectations.pdf",width=20,height=10)

ggplot(some, aes(x=PriorExpectation_slider, y=PosteriorExpectation_predicted*15,color=as.factor(SpeakerOptimality), shape=as.factor(WonkyWorldPrior))) +
  geom_point() +
  geom_smooth(method="lm") +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,15)) +
  scale_y_continuous(limits=c(0,15)) + 
  #  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_grid(SpeakerOptimality~WonkyWorldPrior)
ggsave("graphs/model-uniform-priorslider-expectations.pdf",width=20,height=10)

# plot only empirical
un = unique(some[,c("Item","PriorExpectation_slider","PosteriorExpectation_empirical")])
nrow(un)
ggplot(un, aes(x=PriorExpectation_slider,y=PosteriorExpectation_empirical*15)) +
  geom_point() +
  geom_smooth(method="lm") +
  scale_x_continuous(limits=c(0,15)) +
  scale_y_continuous(limits=c(0,15)) 
ggsave("graphs/some_empirical_expectation_priorslider.pdf",width=7)

#plot empirical against predicted allstate-prbabilities for "some"
allstate = droplevels(subset(mp, State == 15))
cors = ddply(allstate, .(SpeakerOptimality, WonkyWorldPrior), summarise, r=cor(PosteriorProbability, PosteriorProbability_empirical))
cors = cors[order(cors[,c("r")],decreasing=T),]
head(cors)

mses = ddply(allstate, .(SpeakerOptimality, WonkyWorldPrior), summarise, mse=mse(PosteriorProbability, PosteriorProbability_empirical))
mses = mses[order(mses[,c("mse")]),]
head(mses)
# best: .001 mse for spopt = 0, wwprior = .7

ggplot(allstate, aes(x=PosteriorProbability, y=PosteriorProbability_empirical,color=as.factor(WonkyWorldPrior), shape=as.factor(SpeakerOptimality))) +
  geom_point() +
  geom_smooth() +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous() +#limits=c(0,1)) +
  scale_y_continuous() +#limits=c(0,1)) +  
  #  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_grid(SpeakerOptimality~WonkyWorldPrior)
ggsave("graphs/model-empirical-uniform-priorslider-allstateprobs.pdf",width=20,height=10)

#maybe COGSCI plot basis? plot  predicted allstate-prbabilities for "some" as a function of prior allstate-probabilities

ggplot(allstate, aes(x=PriorProbability_slider, y=PosteriorProbability,color=as.factor(WonkyWorldPrior), shape=as.factor(SpeakerOptimality))) +
  geom_point() +
  geom_smooth() +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
  #  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_grid(SpeakerOptimality~WonkyWorldPrior)
ggsave("graphs/model-uniform-priorslider-allstateprobs.pdf",width=20,height=10)

un = unique(allstate[,c("PriorProbability_slider","PosteriorProbability_empirical")])
nrow(un)
ggplot(un, aes(x=PriorProbability_slider, y=PosteriorProbability_empirical)) +
  geom_point() +
  geom_smooth(method="lm") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) 
ggsave("graphs/some_empirical_allprobs_priorslider.pdf",width=7)

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

wr$PosteriorProbability_empirical = t[paste(wr$Item, "some", wr$Wonky),]$Proportion
head(wr)
wonky = droplevels(subset(wr, Wonky == "true"))

head(wonky)
#toplot = droplevels(subset(wonky,  WonkyWorldPrior == .6 & SpeakerOptimality == 2))
#head(toplot)

ggplot(wonky, aes(x=PriorExpectation_slider, y=PosteriorProbability)) +
  geom_point() +
  geom_smooth() +
  facet_grid(WonkyWorldPrior ~ SpeakerOptimality)
ggsave(file="graphs/wonkinessplot_priorslider.pdf")

cors = ddply(wonky, .(SpeakerOptimality, Quantifier, WonkyWorldPrior), summarise, r=cor(PosteriorProbability, PosteriorProbability_empirical))
cors = cors[order(cors[,c("r")],decreasing=T),]
head(cors,15)

mses = ddply(wonky, .(SpeakerOptimality, WonkyWorldPrior), summarise, mse=mse(PosteriorProbability, PosteriorProbability_empirical))
mses = mses[order(mses[,c("mse")]),]
head(mses,15)
