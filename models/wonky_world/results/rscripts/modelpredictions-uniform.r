#' ---
#' title: "Prior probabilities in the interpretation of 'some': analysis of uniform prior wonky world model predictions"
#' author: "Judith Degen"
#' date: "January 12, 2014"
#' ---

library(ggplot2)
theme_set(theme_bw(18))
setwd("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/wonky_world/results/")
source("rscripts/helpers.r")

#' get model predictions
load("data/mp-uniform.RData")
d = read.table("data/parsed_uniform_results.tsv", quote="", sep="\t", header=T)
table(d$Item)
nrow(d)
head(d)
summary(d)
d[d$Item == "ate the seeds birds" & d$QUD=="how-many" & d$Alternatives=="0_basic" & d$SpeakerOptimality == 1,]
d[d$Item == "stuck to the wall baseballs" & d$QUD=="how-many" & d$Alternatives=="0_basic" & d$SpeakerOptimality == 2 & d$Wonky == "true",]
mp = ddply(d, .(Item, State, Quantifier, SpeakerOptimality, WonkyWorldPrior), summarise, PosteriorProbability=sum(PosteriorProbability))
head(mp)
#mp[mp$Item == "ate the seeds birds" & mp$QUD=="how-many" & mp$Alternatives=="0_basic" & mp$SpeakerOptimality == 1,]
wr = ddply(d, .(Item, Wonky, Quantifier, SpeakerOptimality, WonkyWorldPrior), summarise, PosteriorProbability=sum(PosteriorProbability))
wr[wr$Item == "ate the seeds birds" & wr$QUD=="how-many" & wr$Alternatives=="0_basic" & wr$SpeakerOptimality == 1,]


# get prior expectations
priorexpectations = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/expectations.txt",sep="\t", header=T, quote="")
row.names(priorexpectations) = paste(priorexpectations$effect,priorexpectations$object)
mp$PriorExpectation = priorexpectations[as.character(mp$Item),]$expectation
wr$PriorExpectation = priorexpectations[as.character(wr$Item),]$expectation

# get smoothed prior probabilities
priorprobs = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/smoothed_15marbles_priors_withnames.txt",sep="\t", header=T, quote="")
head(priorprobs)
row.names(priorprobs) = priorprobs$Item
mpriorprobs = melt(priorprobs, id.vars=c("Item"))
head(mpriorprobs)
row.names(mpriorprobs) = paste(mpriorprobs$Item,mpriorprobs$variable)
mp$PriorProbability = mpriorprobs[paste(as.character(mp$Item)," X",mp$State,sep=""),]$value
mp$AllPriorProbability = priorprobs[paste(as.character(mp$Item)),]$X15
head(mp)

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
ggsave("graphs/model-empirical-uniform-howmany-2-basic.pdf",width=35,height=30)

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
mp$PosteriorExpectation_empirical = agr[paste(mp$Item,mp$Quantifier),]$ProportionResponse*15
mp$PriorExpectation_smoothed = mp$PriorExpectation

pexpectations = ddply(mp, .(Item, Quantifier, SpeakerOptimality,PriorExpectation_smoothed, WonkyWorldPrior, PosteriorExpectation_empirical), summarise, PosteriorExpectation_predicted=sum(State*PosteriorProbability))
head(pexpectations)
some = droplevels(subset(pexpectations, Quantifier == "some"))

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
some$Predicted = some$ScaledPosteriorExpectation_predicted
some$Empirical = some$ScaledPosteriorExpectation_empirical
some[,c("Item","WonkyWorldPrior","SpeakerOptimality","Predicted","Empirical")] %>% 
  save(file="data/some-expectations-originalpriors.RData")

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
ggsave("graphs/model-empirical-uniform-expectations.pdf",width=20,height=10)

ggplot(some, aes(x=PriorExpectation_smoothed, y=PosteriorExpectation_predicted,color=as.factor(SpeakerOptimality), shape=as.factor(WonkyWorldPrior))) +
  geom_point() +
  geom_smooth(method="lm") +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) + 
  #  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_grid(SpeakerOptimality~WonkyWorldPrior)
ggsave("graphs/model-uniform-expectations.pdf",width=20,height=10)

#plot empirical against predicted allstate-prbabilities for "some"
allstate = droplevels(subset(mp, State == 15 & Quantifier == "some"))

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
  save(file="data/some-allprobs-originalpriors.RData")

probs_and_exps = rbind(some[,c("Item","WonkyWorldPrior","SpeakerOptimality","Predicted","Empirical")],allstate[,c("Item","WonkyWorldPrior","SpeakerOptimality","Predicted","Empirical")])
nrow(probs_and_exps)
test = ddply(probs_and_exps, .(SpeakerOptimality, WonkyWorldPrior), summarise, mse=gof(Predicted, Empirical)["MSE",],r=gof(Predicted, Empirical)["r",],R2=gof(Predicted, Empirical)["R2",])
test = test[order(test[,c("mse")]),]
head(test,10)
test = test[order(test[,c("r")],decreasing=T),]
head(test,10)
test = test[order(test[,c("R2")],decreasing=T),]
head(test,10)

toplot = probs_and_exps[probs_and_exps$WonkyWorldPrior == .7 &  probs_and_exps$SpeakerOptimality == 0,]
toplot$Type = rep(c("expectation","allprob"),each=90)
nrow(toplot)

ggplot(toplot, aes(x=Predicted,y=Empirical,color=Type)) +
  geom_point() +
  geom_smooth(method="lm") +
  geom_abline(intercept=0,slope=1)
ggsave(file="graphs/optimal-uniform.pdf")

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
ggsave("graphs/model-empirical-uniform-allstateprobs.pdf",width=30,height=10)

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
ggsave("graphs/model-uniform-allstateprobs.pdf",width=30,height=10)

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
toplot = droplevels(subset(wonky,  WonkyWorldPrior == .6 & SpeakerOptimality == 2))

ggplot(toplot, aes(x=PriorExpectation, y=PosteriorProbability, color=Quantifier)) +
  geom_point() +
  geom_smooth() 
ggsave(file="graphs/wonkinessplot.pdf",width=6)

test = ddply(wonky, .(SpeakerOptimality, WonkyWorldPrior), summarise, mse=gof(PosteriorProbability, PosteriorProbability_empirical)["MSE",],r=gof(PosteriorProbability, PosteriorProbability_empirical)["r",],R2=gof(PosteriorProbability, PosteriorProbability_empirical)["R2",])
test = test[order(test[,c("mse")]),]
head(test,10)
test = test[order(test[,c("r")],decreasing=T),]
head(test,10)
test = test[order(test[,c("R2")],decreasing=T),]
head(test,10)
test

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
ggsave("graphs/model-empirical-uniform-wonkiness_all.pdf", width=30,height=10)

ggplot(wonky_none, aes(x=PosteriorProbability, y=PosteriorProbability_empirical, color=as.factor(WonkyWorldPrior), shape=as.factor(SpeakerOptimality))) +
  geom_point() +
  geom_smooth(method="lm") +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
  facet_grid(WonkyWorldPrior~SpeakerOptimality)
ggsave("graphs/model-empirical-uniform-wonkiness_none.pdf", width=30,height=10)

ggplot(wonky_some, aes(x=PosteriorProbability, y=PosteriorProbability_empirical, color=as.factor(WonkyWorldPrior), shape=as.factor(SpeakerOptimality))) +
  geom_point() +
  geom_smooth(method="lm") +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
  facet_grid(QUD~Alternatives)
ggsave("graphs/model-empirical-uniform-wonkiness_some.pdf", width=30,height=10)



ggplot(wonky_all, aes(x=PriorExpectation, y=PosteriorProbability, color=as.factor(WonkyWorldPrior), shape=as.factor(SpeakerOptimality))) +
  geom_point() +
  geom_smooth() +
  scale_y_continuous(limits=c(0,1)) +  
  facet_grid(QUD~Alternatives)  
ggsave("graphs/model-uniform-all-wonkiness.pdf", width=30,height=10)

ggplot(wonky_none, aes(x=PriorExpectation, y=PosteriorProbability, color=as.factor(WonkyWorldPrior), shape=as.factor(SpeakerOptimality))) +
  geom_point() +
  geom_smooth() +
  scale_y_continuous(limits=c(0,1)) +  
  facet_grid(QUD~Alternatives)  
ggsave("graphs/model-uniform-none-wonkiness.pdf", width=30,height=10)

ggplot(wonky_some, aes(x=PriorExpectation, y=PosteriorProbability, color=as.factor(WonkyWorldPrior), shape=as.factor(SpeakerOptimality))) +
  geom_point() +
  geom_smooth() +
  scale_y_continuous(limits=c(0,1)) +  
  facet_grid(QUD~Alternatives)  
ggsave("graphs/model-uniform-some-wonkiness.pdf", width=30,height=10)

save(mp, file="data/mp-uniform.RData")
save(wr, file="data/wr-uniform.RData")

wonky[wonky$Quantifier == "all" & wonky$PriorExpectation < 4 & wonky$Alternatives == "0_basic" & wonky$QUD == "how-many" & wonky$SpeakerOptimality == 2,]

# get model predictions for all-state with basic alts, spopt==2, and qud==how-many
mp_some_allstate = subset(mp, Alternatives=="0_basic" & SpeakerOptimality == 2 & QUD == "how-many" & State == 15)
head(mp_some_allstate)
nrow(mp_some_allstate)



# plot expectations for best basic model: 
toplot = droplevels(subset(mp, QUD == "how-many" & Alternatives == "0_basic" & Quantifier == "some" & WonkyWorldPrior == .5))
nrow(toplot)

pexpectations = ddply(toplot, .(Item, SpeakerOptimality,PriorExpectation_smoothed, PosteriorExpectation_empirical), summarise, PosteriorExpectation_predicted=sum(State*PosteriorProbability)/15)
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
ggsave("~/cogsci/conferences_talks/_2015/2_cogsci_pasadena/wonky_marbles/paper/pics/model-expectations-uniform.pdf",width=5.5,height=4.5)
save(toplot, file="data/toplot-expectations.RData")

toplot_w = toplot
load("../../complex_prior/smoothed_unbinned15/results/data/toplot-expectations.RData")
toplot_r = toplot
head(toplot_w)
summary(toplot_r)
toplot_r$RSA = "regular"
toplot_w$RSA = "wonky"
  
# plot both rRSA and uniform wRSA expectation predictions in same plot
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
ggsave("~/cogsci/conferences_talks/_2015/2_cogsci_pasadena/wonky_marbles/paper/pics/model-expectations-uniform-regular.pdf",width=6.5,height=4.5)
