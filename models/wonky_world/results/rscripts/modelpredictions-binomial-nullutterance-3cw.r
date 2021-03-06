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
load("data/mp-binomial_nullutterance_3cw.RData")

d = read.table("data/parsed_binomial_nullutterance_3coinweights_laplace_results.tsv", quote="", sep="\t", header=T)
table(d$Item)
nrow(d)
head(d)
d[d$Item == "ate the seeds birds" & d$QUD=="how-many" & d$Alternatives=="0_basic" & d$SpeakerOptimality == 1,]
d[d$Item == "stuck to the wall baseballs" & d$QUD=="how-many" & d$Alternatives=="0_basic" & d$SpeakerOptimality == 2 & d$Wonky == "true",]
mp = ddply(d, .(Quantifier,Item, State, SpeakerOptimality, WonkyWorldPrior,NullUtteranceCost), summarise, PosteriorProbability=sum(PosteriorProbability))
head(mp)
#mp[mp$Item == "ate the seeds birds" & mp$QUD=="how-many" & mp$Alternatives=="0_basic" & mp$SpeakerOptimality == 1,]
wr = ddply(d, .(Quantifier,Item, Wonky, SpeakerOptimality, WonkyWorldPrior,NullUtteranceCost), summarise, PosteriorProbability=sum(PosteriorProbability))
wr[wr$Item == "ate the seeds birds" & wr$QUD=="how-many" & wr$Alternatives=="0_basic" & wr$SpeakerOptimality == 1,]


# get prior expectations
#toggle
#priorexpectations = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/expectations.txt",sep="\t", header=T, quote="")
#row.names(priorexpectations) = paste(priorexpectations$effect,priorexpectations$object)
priorexpectations = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/expectations_laplace.txt",sep="\t", header=T, quote="")
row.names(priorexpectations) = priorexpectations$Item
mp$PriorExpectation = priorexpectations[as.character(mp$Item),]$expectation
wr$PriorExpectation = priorexpectations[as.character(wr$Item),]$expectation

# get smoothed prior probabilities
#toggle
#priorprobs = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/smoothed_15marbles_priors_withnames.txt",sep="\t", header=T, quote="")
#row.names(priorprobs) = paste(priorprobs$effect,priorprobs$object)
#mpriorprobs = melt(priorprobs, id.vars=c("effect", "object"))
#row.names(mpriorprobs) = paste(mpriorprobs$effect,mpriorprobs$object,mpriorprobs
priorprobs = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/smoothed_15marbles_priors_withnames_laplace.txt",sep="\t", header=T, quote="")
head(priorprobs)
row.names(priorprobs) = priorprobs$Item
mpriorprobs = melt(priorprobs, id.vars=c("Item"))
head(mpriorprobs)
row.names(mpriorprobs) = paste(mpriorprobs$Item,mpriorprobs$variable)
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
#msome = droplevels(subset(mp, Quantifier == "some"))
some =  ddply(mp[mp$Quantifier == "some",], .(Quantifier,Item, SpeakerOptimality, PriorExpectation, Proportion, WonkyWorldPrior, NullUtteranceCost, PosteriorProbability_empirical), summarise, PosteriorProbability_predicted=sum(PosteriorProbability), PriorProbability_smoothed=sum(PriorProbability))
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
# toggle
#ggsave("graphs/model-empirical-binomial_nullutterance-howmany-2-basic-cost5-3cw.pdf",width=35,height=30)
ggsave("graphs/model-empirical-binomial_nullutterance-howmany-2-basic-cost5-3cw-laplace.pdf",width=35,height=30)

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
head(mp)

pexpectations = ddply(mp, .(Quantifier,Item, SpeakerOptimality,PriorExpectation_smoothed, WonkyWorldPrior, NullUtteranceCost, PosteriorExpectation_empirical), summarise, PosteriorExpectation_predicted=sum(State*PosteriorProbability)/15)
head(pexpectations)
#some = pexpectations
some = droplevels(subset(pexpectations, Quantifier == "some"))

cors = ddply(some, .(SpeakerOptimality, WonkyWorldPrior, NullUtteranceCost), summarise, r=cor(PosteriorExpectation_predicted, PosteriorExpectation_empirical))
cors = cors[order(cors[,c("r")],decreasing=T),]
head(cors)
#.63

#CONTINUE HERE WITH NULLUTTERANCE STUFF
ggplot(some, aes(x=PosteriorExpectation_predicted, y=PosteriorExpectation_empirical,color=as.factor(WonkyWorldPrior)))+#, shape=as.factor(WonkyWorldPrior))) +
  geom_point() +
  geom_smooth(method="lm") +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
#  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_grid(NullUtteranceCost~SpeakerOptimality)
# toggle
#ggsave("graphs/model-empirical-binomial_nullutterance-expectations-3cw.pdf",width=30,height=10)
ggsave("graphs/model-empirical-binomial_nullutterance-expectations-3cw-laplace.pdf")

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
#ggsave("graphs/model-binomial_nullutterance-expectations-3cw.pdf",width=15,height=10)
ggsave("graphs/model-binomial_nullutterance-expectations-3cw-laplace.pdf",width=15,height=10)

  
#plot empirical against predicted allstate-prbabilities for "some"
allstate = droplevels(subset(mp, State == 15 & Quantifier == "some"))
cors = ddply(allstate, .(SpeakerOptimality, WonkyWorldPrior, NullUtteranceCost), summarise, r=cor(PosteriorProbability, PosteriorProbability_empirical))
cors = cors[order(cors[,c("r")],decreasing=T),]
head(cors)
# .57 correlation with cheap nullutterance and high wonky world prior and high speaker optimality

ggplot(allstate, aes(x=PosteriorProbability, y=PosteriorProbability_empirical,color=as.factor(WonkyWorldPrior))) +
  geom_point() +
  geom_smooth() +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,.6)) +
  scale_y_continuous(limits=c(0,.6)) +  
  #  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_grid(NullUtteranceCost~SpeakerOptimality)
#ggsave("graphs/model-empirical-binomial_nullutterance-allstateprobs-3cw.pdf",width=20,height=20)
ggsave("graphs/model-empirical-binomial_nullutterance-allstateprobs-3cw-laplace.pdf",width=20,height=20)

#maybe COGSCI plot basis? plot  predicted allstate-prbabilities for "some" as a function of prior allstate-probabilities

ggplot(allstate, aes(x=PriorProbability, y=PosteriorProbability,color=as.factor(WonkyWorldPrior))) +
  geom_point() +
  geom_smooth() +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
  #  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_grid(NullUtteranceCost~SpeakerOptimality)
#ggsave("graphs/model-binomial_nullutterance-allstateprobs-3cw.pdf",width=15,height=10)
ggsave("graphs/model-binomial_nullutterance-allstateprobs-3cw-laplace.pdf",width=15,height=10)

# get empirical wonkiness posteriors
load("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/17_sinking-marbles-normal-sliders/results/data/r.RData")
head(r)
nrow(r)

agr = aggregate(response ~ Item + quantifier, FUN="mean", data=r)
agr$Wonky = 1-agr$response
row.names(agr) = paste(agr$Item, tolower(agr$quantifier))

wr$PosteriorProbability_empirical = agr[paste(wr$Item, wr$Quantifier),]$Wonky
head(wr)
wonky = droplevels(subset(wr, Wonky == "true"))

head(wonky)
toplot = droplevels(subset(wonky,  SpeakerOptimality == 2))

ggplot(toplot, aes(x=PriorExpectation, y=PosteriorProbability, color=as.factor(WonkyWorldPrior))) +
  geom_point() +
  geom_smooth() +
#  facet_grid(~NullUtteranceCost)
  facet_grid(Quantifier~NullUtteranceCost)
#ggsave(file="graphs/wonkinessplot-binomial_nullutterance_3cw.pdf",width=7,height=2.5)
ggsave(file="graphs/wonkinessplot-binomial_nullutterance_3cw-laplace.pdf",width=7)

cors = ddply(wonky[wonky$Quantifier == "some",], .(SpeakerOptimality, WonkyWorldPrior,NullUtteranceCost), summarise, r=cor(PosteriorProbability, PosteriorProbability_empirical))
cors = cors[order(cors[,c("r")],decreasing=T),]
head(cors,15)
# .69

ggplot(wonky[wonky$Quantifier == "some",], aes(x=PosteriorProbability, y=PosteriorProbability_empirical, color=as.factor(WonkyWorldPrior))) +
  geom_point() +
  geom_smooth(method="lm") +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
  facet_grid(NullUtteranceCost~SpeakerOptimality)
#ggsave("graphs/model-empirical-binomial_nullutterance-3cw-wonkiness.pdf", width=15,height=10)
ggsave("graphs/model-empirical-binomial_nullutterance-3cw-wonkiness-laplace.pdf", width=15,height=10)


#save(mp, file="data/mp-binomial_nullutterance_3cw.RData")
#save(wr, file="data/wr-binomial_nullutterance_3cw.RData")

save(mp, file="data/mp-binomial_nullutterance_3cw_laplace.RData")
save(wr, file="data/wr-binomial_nullutterance_3cw_laplace.RData")


########

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
