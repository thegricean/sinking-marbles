#' ---
#' title: "Prior probabilities in the interpretation of 'some': analysis of uniform prior wonky world model predictions"
#' author: "Judith Degen"
#' date: "May 17, 2015"
#' ---

library(ggplot2)
theme_set(theme_bw(18))
setwd("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/wonky_world/results/")
source("rscripts/helpers.r")

#' get model predictions
load("data/mp-uniform-fourstep.RData")
d = read.table("data/parsed_uniform_fourstep_results.tsv", quote="", sep="\t", header=T)
table(d$Item)
nrow(d)
head(d)
summary(d)
d[d$Item == "ate the seeds birds" & d$QUD=="how-many" & d$Alternatives=="0_basic" & d$SpeakerOptimality == 1,]
d[d$Item == "stuck to the wall baseballs" & d$QUD=="how-many" & d$Alternatives=="0_basic" & d$SpeakerOptimality == 2 & d$Wonky == "true",]

mp = d %>%
  group_by(Item,State,Quantifier, SpeakerOptimality, WonkyWorldPrior) %>%
  summarise(PosteriorProbability=sum(PosteriorProbability))
mp  = as.data.frame(mp)
head(mp)
wr = d %>%
  group_by(Item, Wonky, Quantifier, SpeakerOptimality, WonkyWorldPrior) %>%
  summarise(PosteriorProbability=sum(PosteriorProbability))
wr = as.data.frame(wr)

# get smoothed prior probabilities
priorprobs = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/24_sinking-marbles-prior-fourstep/results/data/smoothed_15marbles_priors_withnames.txt",sep="\t", header=T, quote="")
head(priorprobs)
row.names(priorprobs) = priorprobs$Item
mpriorprobs = melt(priorprobs, id.vars=c("Item"))
head(mpriorprobs)
row.names(mpriorprobs) = paste(mpriorprobs$Item,mpriorprobs$variable)
mp$PriorProbability = mpriorprobs[paste(as.character(mp$Item)," X",mp$State,sep=""),]$value
mp$AllPriorProbability = priorprobs[paste(as.character(mp$Item)),]$X15
head(mp)

mpriorprobs$State = as.numeric(as.character(gsub("X","",mpriorprobs$variable)))
priorexps = mpriorprobs %>%
  group_by(Item) %>%
  summarise(expectation=sum(State*value))
summary(priorexps)
priorexps = as.data.frame(priorexps)
row.names(priorexps) = priorexps$Item
mp$PriorExpectation = priorexps[as.character(mp$Item),]$expectation
wr$PriorExpectation = priorexps[as.character(wr$Item),]$expectation

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
mp$PosteriorProbability_empirical = agr[paste(mp$Item,mp$Proportion,mp$Quantifier),]$normresponse

#plot empirical against predicted distributions for "some"
some = ddply(mp, .(Item, Quantifier, SpeakerOptimality, PriorExpectation, Proportion, WonkyWorldPrior, PosteriorProbability_empirical), summarise, PosteriorProbability_predicted=sum(PosteriorProbability), PriorProbability_smoothed=sum(PriorProbability))
some= subset(some, Quantifier == "some")
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
ggsave("graphs/model-empirical-uniform-howmany-2-basic-fourstep.pdf",width=35,height=30)

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
mp$PriorExpectation_smoothed = mp$PriorExpectation

pexpectations = ddply(mp, .(Item, Quantifier, SpeakerOptimality,PriorExpectation_smoothed, WonkyWorldPrior, PosteriorExpectation_empirical), summarise, PosteriorExpectation_predicted=sum(State*PosteriorProbability))
head(pexpectations)
some = droplevels(subset(pexpectations, Quantifier == "some"))
some$PosteriorExpectation_empirical = some$PosteriorExpectation_empirical*15

# cors = ddply(some, .(SpeakerOptimality, WonkyWorldPrior), summarise, r=cor(PosteriorExpectation_predicted, PosteriorExpectation_empirical))
# cors = cors[order(cors[,c("r")],decreasing=T),]
# head(cors)

# plot by-item diff in predicted and empirical expectation by confidence rating
confidence = read.table("../../../experiments/24_sinking-marbles-prior-fourstep/results/data/confidence.txt",sep="\t",quote="",header=T)
nrow(confidence)
head(confidence)
row.names(confidence) = confidence$Item

some$Confidence = confidence[as.character(some$Item),]$response
head(some)
some$PredictionDiff = some$PosteriorExpectation_predicted - some$PosteriorExpectation_empirical

ggplot(some, aes(y=PredictionDiff,x=Confidence)) +
  geom_point() +
  geom_smooth() +
  geom_hline(yintercept=0) +
  facet_grid(WonkyWorldPrior~SpeakerOptimality) #+
  #geom_text(aes(label=Item))
#ggsave(file="graphs/model-empirical-diff-by-confidence-annotated.pdf",width=20,height=16)
ggsave(file="graphs/model-empirical-diff-by-confidence.pdf",width=10,height=8)

ggplot(some, aes(y=abs(PredictionDiff),x=Confidence)) +
  geom_point() +
  geom_smooth() +
  facet_grid(WonkyWorldPrior~SpeakerOptimality) +
  geom_text(aes(label=Item),size=3,color="lightblue")
ggsave(file="graphs/model-empirical-diff-by-confidence-annotated.pdf",width=20,height=16)
#ggsave(file="graphs/model-empirical-absdiff-by-confidence.pdf",width=10,height=8)


library(hydroGOF)
#mses = ddply(some, .(SpeakerOptimality, WonkyWorldPrior), summarise, mse=mse(PosteriorExpectation_predicted, PosteriorExpectation_empirical))
#mses = mses[order(mses[,c("mse")]),]
#head(mses)

test = ddply(some, .(SpeakerOptimality, WonkyWorldPrior), summarise, mse=gof(PosteriorExpectation_predicted, PosteriorExpectation_empirical)["MSE",],r=gof(PosteriorExpectation_predicted, PosteriorExpectation_empirical)["r",],R2=gof(PosteriorExpectation_predicted, PosteriorExpectation_empirical)["R2",])
test = test[order(test[,c("mse")]),]
head(test,10)
test = test[order(test[,c("r")],decreasing=T),]
head(test,10)
test = test[order(test[,c("R2")],decreasing=T),]
head(test,10)
head(some)

some$ScaledPosteriorExpectation_predicted = some$PosteriorExpectation_predicted/15
some$ScaledPosteriorExpectation_empirical = some$PosteriorExpectation_empirical/15
test = ddply(some, .(SpeakerOptimality, WonkyWorldPrior), summarise, mse=gof(ScaledPosteriorExpectation_predicted, ScaledPosteriorExpectation_empirical)["MSE",],r=gof(ScaledPosteriorExpectation_predicted, ScaledPosteriorExpectation_empirical)["r",],R2=gof(ScaledPosteriorExpectation_predicted, ScaledPosteriorExpectation_empirical)["R2",])
test = test[order(test[,c("mse")]),]
head(test,10)
test = test[order(test[,c("r")],decreasing=T),]
head(test,10)
test = test[order(test[,c("R2")],decreasing=T),]
head(test,10)
head(some)
some$Predicted = some$ScaledPosteriorExpectation_predicted
some$Empirical = some$ScaledPosteriorExpectation_empirical
some[,c("Item","WonkyWorldPrior","SpeakerOptimality","Predicted","Empirical")] %>% 
  save(file="data/some-expectations.RData")

ggplot(some, aes(x=PosteriorExpectation_predicted, y=PosteriorExpectation_empirical,color=as.factor(SpeakerOptimality), shape=as.factor(WonkyWorldPrior))) +
  geom_point() +
  geom_smooth(method="lm") +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,15)) +
  scale_y_continuous(limits=c(0,15)) + 
#  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_grid(SpeakerOptimality~WonkyWorldPrior)
ggsave("graphs/model-empirical-uniform-expectations-fourstep.pdf",width=20,height=10)

ggplot(some, aes(x=PriorExpectation_smoothed, y=PosteriorExpectation_predicted,color=as.factor(SpeakerOptimality), shape=as.factor(WonkyWorldPrior))) +
  geom_point() +
  geom_smooth(method="lm") +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,15)) +
  scale_y_continuous(limits=c(0,15)) + 
  #  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_grid(SpeakerOptimality~WonkyWorldPrior)
ggsave("graphs/model-uniform-expectations-fourstep.pdf",width=20,height=10)

# plot for best values: wprior = .8, spopt=3
ggplot(some[some$WonkyWorldPrior==.8 & some$SpeakerOptimality == 3,], aes(x=PosteriorExpectation_predicted, y=PosteriorExpectation_empirical)) +
  geom_point() +
  scale_x_continuous(limits=c(0,15)) +
  scale_y_continuous(limits=c(0,15)) +  
  geom_abline(intercept=0,slope=1,color="gray60") +
  ggtitle("Best parameters (MSE=.85,r=.65): wprior=.8, spopt=3")
ggsave("graphs/3_number_fourstep/model-empirical-fourstep-expectations.pdf",width=10,height=6)



#plot empirical against predicted allstate-prbabilities for "some"
allstate = droplevels(subset(mp, State == 15 & Quantifier == "some"))
#cors = ddply(allstate, .(SpeakerOptimality, WonkyWorldPrior), summarise, r=cor(PosteriorProbability, PosteriorProbability_empirical))
#cors = cors[order(cors[,c("r")],decreasing=T),]
#head(cors)

#mses = ddply(allstate, .(SpeakerOptimality, WonkyWorldPrior), summarise, mse=mse(PosteriorProbability, PosteriorProbability_empirical))
#mses = mses[order(mses[,c("mse")]),]
#head(mses)
# .46 correlation despite being shitty model
test = ddply(allstate, .(SpeakerOptimality, WonkyWorldPrior), summarise, mse=gof(PosteriorProbability, PosteriorProbability_empirical)["MSE",],r=gof(PosteriorProbability, PosteriorProbability_empirical)["r",],R2=gof(PosteriorProbability, PosteriorProbability_empirical)["R2",])
test = test[order(test[,c("mse")]),]
head(test,10)
test = test[order(test[,c("r")],decreasing=T),]
head(test,10)
test = test[order(test[,c("R2")],decreasing=T),]
head(test,10)
head(some)
allstate$Predicted = allstate$PosteriorProbability
allstate$Empirical = allstate$PosteriorProbability_empirical
allstate[,c("Item","WonkyWorldPrior","SpeakerOptimality","Predicted","Empirical")] %>% 
  save(file="data/some-allprobs.RData")

probs_and_exps = rbind(some[,c("Item","WonkyWorldPrior","SpeakerOptimality","Predicted","Empirical")],allstate[,c("Item","WonkyWorldPrior","SpeakerOptimality","Predicted","Empirical")])
nrow(probs_and_exps)
test = ddply(probs_and_exps, .(SpeakerOptimality, WonkyWorldPrior), summarise, mse=gof(Predicted, Empirical)["MSE",],r=gof(Predicted, Empirical)["r",],R2=gof(Predicted, Empirical)["R2",])
test = test[order(test[,c("mse")]),]
head(test,10)
test = test[order(test[,c("r")],decreasing=T),]
head(test,10)
test = test[order(test[,c("R2")],decreasing=T),]
head(test,10)
head(some)


toplot = probs_and_exps[probs_and_exps$WonkyWorldPrior == .7 &  probs_and_exps$SpeakerOptimality == 0,]
toplot$Type = rep(c("expectation","allprob"),each=90)
nrow(toplot)

ggplot(toplot, aes(x=Predicted,y=Empirical,color=Type)) +
  geom_point() +
  geom_smooth(method="lm") +
  geom_abline(intercept=0,slope=1)
ggsave(file="graphs/optimal-uniform-fourstep.pdf")

ggplot(allstate, aes(x=PosteriorProbability, y=PosteriorProbability_empirical,color=as.factor(WonkyWorldPrior), shape=as.factor(SpeakerOptimality))) +
  geom_point() +
  geom_smooth() +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
  #  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_grid(SpeakerOptimality~WonkyWorldPrior)
ggsave("graphs/model-empirical-uniform-allstateprobs-fourstep.pdf",width=30,height=10)

# plot for best values: wprior = .6, spopt=0
ggplot(allstate[allstate$WonkyWorldPrior==.6 & allstate$SpeakerOptimality == 0,], aes(x=PosteriorProbability, y=PosteriorProbability_empirical)) +
  geom_point() +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
  geom_abline(intercept=0,slope=1,color="gray60") +
  ggtitle("Best parameters (MSE=.0,r=.41): wprior=.6, spopt=0")
ggsave("graphs/3_number_fourstep/model-empirical-fourstep-allprobs.pdf",width=10,height=6)

# plot by-item diff in predicted and empirical expectation by confidence rating
confidence = read.table("../../../experiments/24_sinking-marbles-prior-fourstep/results/data/confidence.txt",sep="\t",quote="",header=T)
nrow(confidence)
head(confidence)
row.names(confidence) = confidence$Item

allstate$Confidence = confidence[as.character(allstate$Item),]$response
head(allstate)
allstate$PredictionDiff = allstate$PosteriorProbability - allstate$PosteriorProbability_empirical

ggplot(allstate, aes(y=PredictionDiff,x=Confidence)) +
  geom_point() +
  geom_smooth() +
  geom_hline(yintercept=0) +
  facet_grid(WonkyWorldPrior~SpeakerOptimality) #+
#geom_text(aes(label=Item))
#ggsave(file="graphs/model-empirical-diff-by-confidence-annotated.pdf",width=20,height=16)
ggsave(file="graphs/model-empirical-allprobs-diff-by-confidence.pdf",width=10,height=8)

ggplot(allstate, aes(y=abs(PredictionDiff),x=Confidence)) +
  geom_point() +
  geom_smooth() +
  facet_grid(WonkyWorldPrior~SpeakerOptimality) #+
#geom_text(aes(label=Item))
#ggsave(file="graphs/model-empirical-diff-by-confidence-annotated.pdf",width=20,height=16)
ggsave(file="graphs/model-empirical-allprobs-absdiff-by-confidence.pdf",width=10,height=8)


#maybe COGSCI plot basis? plot  predicted allstate-prbabilities for "some" as a function of prior allstate-probabilities

ggplot(allstate, aes(x=PriorProbability, y=PosteriorProbability,color=as.factor(WonkyWorldPrior), shape=as.factor(SpeakerOptimality))) +
  geom_point() +
  geom_smooth() +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
  #  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_grid(SpeakerOptimality~WonkyWorldPrior)
ggsave("graphs/model-uniform-allstateprobs-fourstep.pdf",width=30,height=10)

# get empirical wonkiness posteriors
load("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/17_sinking-marbles-normal-sliders/results/data/r.RData")
head(r)
nrow(r)

agr = aggregate(response~Item+quantifier,data=r,FUN=mean)
row.names(agr) = paste(agr$Item,tolower(agr$quantifier))

wr$PosteriorProbability_empirical = agr[paste(wr$Item, wr$Quantifier),]$response
head(wr)
wonky = droplevels(subset(wr, Wonky == "true"))

test = ddply(wonky, .(SpeakerOptimality, WonkyWorldPrior,Quantifier), summarise, mse=gof(PosteriorProbability, PosteriorProbability_empirical)["MSE",],r=gof(PosteriorProbability, PosteriorProbability_empirical)["r",],R2=gof(PosteriorProbability, PosteriorProbability_empirical)["R2",])
test = test[order(test[,c("mse")]),]
head(test,20)
test = test[order(test[,c("r")],decreasing=T),]
head(test,10)
test = test[order(test[,c("R2")],decreasing=T),]
head(test,10)


# plot for best values: wprior = .3, spopt=0
ggplot(wonky[wonky$WonkyWorldPrior==.3 & wonky$SpeakerOptimality == 0,], aes(x=PosteriorProbability, y=PosteriorProbability_empirical,color=Quantifier)) +
  geom_point() +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
  geom_abline(intercept=0,slope=1,color="gray60") +
  ggtitle("Best parameters (MSE=.03/.05/.08,r=.58/.62/.63): wprior=.3, spopt=0")
ggsave("graphs/3_number_fourstep/model-empirical-fourstep-wonkiness.pdf",width=10,height=6)



ggplot(wonky, aes(x=PriorExpectation,y=PosteriorProbability,color=Quantifier)) +
  geom_point() +
  geom_smooth() +
  facet_grid(SpeakerOptimality~WonkyWorldPrior)
ggsave("graphs/3_number_fourstep/model-wonkiness.pdf",width=14,height=8)

# plot by-item diff in predicted and empirical expectation by confidence rating
confidence = read.table("../../../experiments/24_sinking-marbles-prior-fourstep/results/data/confidence.txt",sep="\t",quote="",header=T)
nrow(confidence)
head(confidence)
row.names(confidence) = confidence$Item

wonky$Confidence = confidence[as.character(wonky$Item),]$response
head(wonky)
wonky$PredictionDiff = wonky$PosteriorProbability - wonky$PosteriorProbability_empirical

wonky_all = subset(wonky, Quantifier == "all")
wonky_none = subset(wonky, Quantifier == "none")
wonky_some = subset(wonky, Quantifier == "some")

ggplot(wonky_all, aes(x=PosteriorProbability, y=PosteriorProbability_empirical, color=as.factor(WonkyWorldPrior), shape=as.factor(SpeakerOptimality))) +
  geom_point() +
  geom_smooth(method="lm") +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
  facet_grid(WonkyWorldPrior~SpeakerOptimality)
ggsave("graphs/model-empirical-uniform-wonkiness_all-fourstep.pdf", width=30,height=10)

ggplot(wonky_none, aes(x=PosteriorProbability, y=PosteriorProbability_empirical, color=as.factor(WonkyWorldPrior), shape=as.factor(SpeakerOptimality))) +
  geom_point() +
  geom_smooth(method="lm") +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
  facet_grid(WonkyWorldPrior~SpeakerOptimality)
ggsave("graphs/model-empirical-uniform-wonkiness_none-fourstep.pdf", width=30,height=10)

ggplot(wonky_some, aes(x=PosteriorProbability, y=PosteriorProbability_empirical, color=as.factor(WonkyWorldPrior), shape=as.factor(SpeakerOptimality))) +
  geom_point() +
  geom_smooth(method="lm") +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) #+  
  #facet_grid(QUD~Alternatives)
ggsave("graphs/model-empirical-uniform-wonkiness_some-fourstep.pdf", width=30,height=10)


ggplot(wonky, aes(x=Confidence,y=abs(PredictionDiff),color=Quantifier)) +
  geom_point() +
  geom_smooth() +
  facet_grid(WonkyWorldPrior~SpeakerOptimality)
ggsave("graphs/model-empirical-uniform-wonkiness-fourstep-abs-confidence.pdf", width=12,height=10)

ggplot(wonky, aes(x=Confidence,y=PredictionDiff,color=Quantifier)) +
  geom_point() +
  geom_smooth() +
  facet_grid(WonkyWorldPrior~SpeakerOptimality)
ggsave("graphs/model-empirical-uniform-wonkiness-fourstep-confidence.pdf", width=12,height=10)

ggplot(wonky_all, aes(x=Confidence,y=PredictionDiff)) +
  geom_point() +
  geom_smooth() +
  geom_hline(yintercept=0) +
  facet_grid(WonkyWorldPrior~SpeakerOptimality)
ggsave("graphs/model-empirical-uniform-wonkiness-all-fourstep-confidence.pdf", width=12,height=10)


ggplot(wonky_all, aes(x=Confidence,y=abs(PredictionDiff))) +
  geom_point() +
  geom_smooth() +
  facet_grid(WonkyWorldPrior~SpeakerOptimality)
ggsave("graphs/model-empirical-uniform-wonkiness-all-fourstep-abs-confidence.pdf", width=12,height=10)

ggplot(wonky_some, aes(x=Confidence,y=PredictionDiff)) +
  geom_point() +
  geom_smooth() +
  geom_hline(yintercept=0) +
  facet_grid(WonkyWorldPrior~SpeakerOptimality)
ggsave("graphs/model-empirical-uniform-wonkiness-some-fourstep-confidence.pdf", width=12,height=10)

ggplot(wonky_some, aes(x=Confidence,y=abs(PredictionDiff))) +
  geom_point() +
  geom_smooth() +
  facet_grid(WonkyWorldPrior~SpeakerOptimality)
ggsave("graphs/model-empirical-uniform-wonkiness-some-fourstep-abs-confidence.pdf", width=12,height=10)

ggplot(wonky_none, aes(x=Confidence,y=PredictionDiff)) +
  geom_point() +
  geom_smooth() +
  geom_hline(yintercept=0) +
  facet_grid(WonkyWorldPrior~SpeakerOptimality)
ggsave("graphs/model-empirical-uniform-wonkiness-none-fourstep-confidence.pdf", width=12,height=10)

ggplot(wonky_none, aes(x=Confidence,y=abs(PredictionDiff))) +
  geom_point() +
  geom_smooth() +
  facet_grid(WonkyWorldPrior~SpeakerOptimality)
ggsave("graphs/model-empirical-uniform-wonkiness-none-fourstep-abs-confidence.pdf", width=12,height=10)

save(mp, file="data/mp-uniform-fourstep.RData")
save(wr, file="data/wr-uniform-fourstep.RData")

wonky[wonky$Quantifier == "all" & wonky$PriorExpectation < 4 & wonky$Alternatives == "0_basic" & wonky$QUD == "how-many" & wonky$SpeakerOptimality == 2,]

