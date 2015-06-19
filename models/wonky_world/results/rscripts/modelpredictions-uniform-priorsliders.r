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
load("data/mp-uniform-priorsliders.RData")
load("data/wr-uniform-priorsliders.RData")

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


# get empirical state posteriors:
load("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/16_sinking-marbles-sliders-certain/results/data/r.RData")
head(r)
# because posteriors come in 4 bins, make Bin variable for model prediction dataset:
mp$Proportion = as.factor(ifelse(mp$State == 0, "0", ifelse(mp$State == 15, "100", ifelse(mp$State < 8, "1-50", "51-99"))))

agr = aggregate(normresponse ~ Item + quantifier + Proportion,data=r,FUN=mean)
agr$Quantifier = as.factor(tolower(agr$quantifier))
row.names(agr) = paste(agr$Item, agr$Proportion, agr$Quantifier)
mp$PosteriorProbability_empirical = agr[paste(mp$Item,mp$Proportion,"some"),]$normresponse

head(mp)

# get slider prior probabilities
load(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/23_sinking-marbles-prior-sliders-exactly/results/data/agr-normresponses.RData")

sliderprobs = agr
head(sliderprobs)
nrow(sliderprobs)
row.names(sliderprobs) = paste(sliderprobs$Item,sliderprobs$slider_id)
mp$PriorProbability_slider = sliderprobs[paste(as.character(mp$Item),mp$State),]$normresponse
#mp$AllPriorProbability_slider = priorprobs[paste(as.character(mp$Item)),]$X15
head(mp)
mp[mp$Item == "sank marbles" & mp$WonkyWorldPrior == .5 & mp$SpeakerOptimality == 2,]

# get slider expectations
slexp = ddply(sliderprobs, .(Item), summarise, expectation=sum(slider_id*normresponse))
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
ggsave("graphs/2_slider_priors/model-empirical-uniform-howmany-2-basic-sliderprior.pdf",width=35,height=30)

#plot empirical against predicted expectations for "some"
load("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/13_sinking-marbles-priordv-15/results/data/r.RData")
summary(r)
r$Item = as.factor(paste(r$effect, r$object))
agr = aggregate(ProportionResponse ~ Item + quantifier, data=r, FUN=mean)
agr$Quantifier = as.factor(tolower(agr$quantifier))
row.names(agr) = paste(agr$Item, agr$Quantifier)
mp$PosteriorExpectation_empirical = agr[paste(mp$Item,"some"),]$ProportionResponse*15

pexpectations = ddply(mp, .(Item,SpeakerOptimality,PriorExpectation_slider, WonkyWorldPrior, PosteriorExpectation_empirical), summarise, PosteriorExpectation_predicted=sum(State*PosteriorProbability))
head(pexpectations)
some=pexpectations


library(hydroGOF)

test = ddply(some, .(SpeakerOptimality, WonkyWorldPrior), summarise, mse=gof(PosteriorExpectation_predicted, PosteriorExpectation_empirical)["MSE",],r=gof(PosteriorExpectation_predicted, PosteriorExpectation_empirical)["r",],R2=gof(PosteriorExpectation_predicted, PosteriorExpectation_empirical)["R2",])
test = test[order(test[,c("mse")]),]
head(test,10)
test = test[order(test[,c("r")],decreasing=T),]
head(test,10)
test = test[order(test[,c("R2")],decreasing=T),]
head(test,10)
head(some)


ggplot(some, aes(x=PosteriorExpectation_predicted, y=PosteriorExpectation_empirical,color=as.factor(SpeakerOptimality), shape=as.factor(WonkyWorldPrior))) +
  geom_point() +
  geom_smooth(method="lm") +
  geom_abline(intercept=0,slope=1,color="gray50") +
#  scale_x_continuous(limits=c(0,1)) +
#  scale_y_continuous(limits=c(0,1)) + 
#  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_grid(SpeakerOptimality~WonkyWorldPrior)
ggsave("graphs/2_slider_priors/model-empirical-uniform-sliderpior-expectations.pdf",width=20,height=10)

ggplot(some, aes(x=PriorExpectation_slider, y=PosteriorExpectation_predicted,color=as.factor(SpeakerOptimality), shape=as.factor(WonkyWorldPrior))) +
  geom_point() +
  geom_smooth(method="lm") +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,15)) +
  scale_y_continuous(limits=c(0,15)) + 
  #  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_grid(SpeakerOptimality~WonkyWorldPrior)
ggsave("graphs/2_slider_priors/model-uniform-priorslider-expectations.pdf",width=20,height=10)

# plot only empirical
un = unique(some[,c("Item","PriorExpectation_slider","PosteriorExpectation_empirical")])
nrow(un)
ggplot(un, aes(x=PriorExpectation_slider,y=PosteriorExpectation_empirical)) +
  geom_point() +
  geom_smooth(method="lm") +
  geom_abline(intercept=0,slope=1)
#  scale_x_continuous(limits=c(0,15)) +
#  scale_y_continuous(limits=c(0,15)) 
ggsave("graphs/2_slider_priors/some_empirical_expectation_priorslider.pdf",width=7)

#plot empirical against predicted allstate-prbabilities for "some"
allstate = droplevels(subset(mp, State == 15))

test = ddply(allstate, .(SpeakerOptimality, WonkyWorldPrior), summarise, mse=gof(PosteriorProbability, PosteriorProbability_empirical)["MSE",],r=gof(PosteriorProbability, PosteriorProbability_empirical)["r",],R2=gof(PosteriorProbability, PosteriorProbability_empirical)["R2",])
test = test[order(test[,c("mse")]),]
head(test,10)
test = test[order(test[,c("r")],decreasing=T),]
head(test,10)
test = test[order(test[,c("R2")],decreasing=T),]
head(test,10)

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
ggsave("graphs/2_slider_priors/model-empirical-uniform-priorslider-allstateprobs.pdf",width=20,height=10)

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
ggsave("graphs/2_slider_priors/model-uniform-priorslider-allstateprobs.pdf",width=20,height=10)

un = unique(allstate[,c("PriorProbability_slider","PosteriorProbability_empirical")])
nrow(un)
ggplot(un, aes(x=PriorProbability_slider, y=PosteriorProbability_empirical)) +
  geom_point() +
  geom_smooth(method="lm") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) 
ggsave("graphs/2_slider_priors/some_empirical_allprobs_priorslider.pdf",width=7)

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
ggsave(file="graphs/2_slider_priors/wonkinessplot_priorslider.pdf")

test = ddply(wonky, .(SpeakerOptimality, WonkyWorldPrior), summarise, mse=gof(PosteriorProbability, PosteriorProbability_empirical)["MSE",],r=gof(PosteriorProbability, PosteriorProbability_empirical)["r",],R2=gof(PosteriorProbability, PosteriorProbability_empirical)["R2",])
test = test[order(test[,c("mse")]),]
head(test,10)
test = test[order(test[,c("r")],decreasing=T),]
head(test,10)
test = test[order(test[,c("R2")],decreasing=T),]
head(test,10)

