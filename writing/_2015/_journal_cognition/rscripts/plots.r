#' ---
#' title: "Prior probabilities in the interpretation of 'some': analysis of uniform prior wonky world model predictions"
#' author: "Judith Degen"
#' date: "January 26, 2014"
#' ---

library(ggplot2)
theme_set(theme_bw(18))
setwd("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/writing/_2015/_journal_cognition/pics/")
source("../rscripts/helpers.r")

# get prior modes
priormodes = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/modes.txt",sep="\t", header=T, quote="")
row.names(priormodes) = paste(priormodes$Item)

# get prior expectations
priorexpectations = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/24_sinking-marbles-prior-fourstep/results/data/expectations.txt",sep="\t", header=T, quote="")
row.names(priorexpectations) = priorexpectations$Item

# histogram of expectations
exps = ggplot(priorexpectations, aes(x=expectation_corr)) +
  geom_histogram() +
  scale_x_continuous(name="Expected value of prior distribution",breaks=seq(1,15, by=2)) +
  scale_y_continuous(name="Number of cases",breaks=seq(0,8, by=2))
ggsave("priorexpectations-histogram.pdf",width=5,height=3.7)


# get prior allstate-probs
priorprobs = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/24_sinking-marbles-prior-fourstep/results/data/smoothed_15marbles_priors_withnames.txt",sep="\t", header=T, quote="")
row.names(priorprobs) = priorprobs$Item
head(priorprobs)

# histogram of allstate-probs
allprobs = ggplot(priorprobs, aes(x=X15)) +
  geom_histogram() +
  scale_x_continuous(name="Prior all-state probability") +
  scale_y_continuous(name="Number of cases")
ggsave("priorallprobs-histogram.pdf")

library(gridExtra)
pdf("priordistributions.pdf",width=10,height=4)
grid.arrange(exps, allprobs, nrow=1,widths=unit.c(unit(.5, "npc"), unit(.5, "npc")))
dev.off()

#####################################
# plot model predictions: expectations
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/wonky_world/results/data/mp-uniform.RData")

# plot expectations for unreliable speaker model: 
toplot = droplevels(subset(mp, Quantifier == "some"))
nrow(toplot)
head(toplot)
summary(toplot)
ub = droplevels(subset(toplot, State == 15))

ggplot(ub, aes(x=PriorProbability, y=PosteriorProbability, color=as.factor(SpeakerOptimality))) +
  geom_point() +#color="#00B0F6") + #values=c("#F8766D", "#A3A500", "#00BF7D", "#E76BF3", "#00B0F6")
  geom_smooth() +#color="#00B0F6") +
  #  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1), name="Prior all-state probability") +
  scale_y_continuous(limits=c(0,1), name="Model predicted posterior all-state probability") +
  facet_wrap(~WonkyWorldPrior)
ggsave("speakerreliability-ieoptimality.pdf",height=8,width=11)

# plot expectations for best basic model: 
toplot = droplevels(subset(mp, QUD == "how-many" & Alternatives == "0_basic" & Quantifier == "some" & WonkyWorldPrior == .5))
nrow(toplot)
pexpectations = ddply(toplot, .(Item), summarise, PosteriorExpectation_predicted=sum(State*PosteriorProbability)/15)
head(pexpectations)
some = pexpectations#droplevels(subset(pexpectations, Quantifier == "some"))



toplot = droplevels(subset(some, SpeakerOptimality == 2))
nrow(toplot)
head(toplot)
toplot$Mode = priormodes[as.character(toplot$Item),]$Mode

ggplot(toplot, aes(x=PriorExpectation_smoothed, y=PosteriorExpectation_predicted)) +
  geom_point(color="#00B0F6") + #values=c("#F8766D", "#A3A500", "#00BF7D", "#E76BF3", "#00B0F6")
  geom_smooth(color="#00B0F6") +
  #  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1), name="Prior expectation") +
  scale_y_continuous(limits=c(0,1), name="Model predicted posterior expectation")


pexpectations = ddply(toplot, .(Item, SpeakerOptimality,PriorExpectation_smoothed, PosteriorExpectation_empirical), summarise, PosteriorExpectation_predicted=sum(State*PosteriorProbability)/15)
head(pexpectations)
some = pexpectations#droplevels(subset(pexpectations, Quantifier == "some"))

toplot = droplevels(subset(some, SpeakerOptimality == 2))
nrow(toplot)
head(toplot)
toplot$Mode = priormodes[as.character(toplot$Item),]$Mode

ggplot(toplot, aes(x=PriorExpectation_smoothed, y=PosteriorExpectation_predicted)) +
  geom_point(color="#00B0F6") + #values=c("#F8766D", "#A3A500", "#00BF7D", "#E76BF3", "#00B0F6")
  geom_smooth(color="#00B0F6") +
  #  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1), name="Prior expectation") +
  scale_y_continuous(limits=c(0,1), name="Model predicted posterior expectation")
#  geom_text(data=cors, aes(label=r)) +

#scale_size_discrete(range=c(1,2)) +
#scale_color_manual(values=c("red","blue","black")) 
ggsave("model-expectations.pdf",width=5.5,height=4.5)#,width=30,height=10)
save(toplot, file="../data/toplot-expectations.RData")

# plot by prior mode instead
ggplot(toplot, aes(x=Mode, y=PosteriorExpectation_predicted)) +
  geom_point(color="#00B0F6") + #values=c("#F8766D", "#A3A500", "#00BF7D", "#E76BF3", "#00B0F6")
  geom_smooth(color="#00B0F6") +
  #  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,15), name="Prior mode") +
  scale_y_continuous(limits=c(0,1), name="Model predicted posterior expectation")

toplot_w = toplot
# get rRSA predictions for qud=how-many, alts=0_basic, spopt=2
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/complex_prior/smoothed_unbinned15/results/data/toplot-expectations.RData")
toplot_r = toplot
head(toplot_w)
summary(toplot_r)
toplot_r$Model = "RSA"
toplot_w$Model = "wRSA"

# plot regular rsa predictions
ggplot(toplot_r, aes(x=PriorExpectation_smoothed*15, y=PosteriorExpectation_predicted*15)) +
  geom_point(color="#007fb1") + #values=c("#F8766D", "#A3A500", "#00BF7D", "#E76BF3", "#00B0F6")
  geom_smooth(color="#007fb1") +
  #  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,15), breaks=seq(1,15,by=2), name="Prior expected number of objects") +
  scale_y_continuous(limits=c(0,15), breaks=seq(1,15,by=2), name="Posterior predicted number of objects")
#  geom_text(data=cors, aes(label=r)) +

#scale_size_discrete(range=c(1,2)) +
#scale_color_manual(values=c("red","blue","black")) 
ggsave("model-expectations-rrsa.pdf",width=6.5,height=4.5)#,width=30,height=10)

# plot both rRSA and uniform wRSA expectation predictions in same plot
toplot = merge(toplot_r,toplot_w, all=T)
head(toplot)
nrow(toplot)
p_exps = ggplot(toplot, aes(x=PriorExpectation_smoothed*15, y=PosteriorExpectation_predicted*15, color=Model)) +
  geom_point() + #color="#00B0F6") + #values=c("#F8766D", "#A3A500", "#00BF7D", "#E76BF3", "#00B0F6")
  geom_smooth() + #color="#00B0F6") +
  scale_color_manual(values=c("#007fb1", "#4ecdff")) +
  #  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,15), breaks=seq(1,15,by=2), name="Prior expected number of objects") +
  scale_y_continuous(limits=c(0,15), breaks=seq(1,15,by=2), name="Posterior predicted number of objects")
#  geom_text(data=cors, aes(label=r)) +
#scale_size_discrete(range=c(1,2)) +
#scale_color_manual(values=c("red","blue","black")) 
#ggsave("graphs/model-expectations.pdf",width=5.5,height=4.5)#,width=30,height=10)
ggsave("model-expectations-binomial-regular.pdf",width=6.5,height=4.5)
ggsave("model-expectations-uniform-regular.pdf",width=6.5,height=4.5)


# plot model predictions: allstate-probs
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/wonky_world/results/data/mp-uniform.RData")
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/wonky_world/results/data/mp-binomial.RData")

# plot expectations for best basic model: 
toplot = droplevels(subset(mp, QUD == "how-many" & Alternatives == "0_basic" & Quantifier == "some" & WonkyWorldPrior == .5 & State == 15))
nrow(toplot)

# adjust speaker optimality at will
toplot = droplevels(subset(toplot, SpeakerOptimality == 2))
nrow(toplot)
head(toplot)

ggplot(toplot, aes(x=PriorProbability, y=PosteriorProbability)) +
  geom_point(color="#00B0F6") + #values=c("#F8766D", "#A3A500", "#00BF7D", "#E76BF3", "#00B0F6")
  geom_smooth(color="#00B0F6") +
  #  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1), name="Prior probability of all-state") +
  scale_y_continuous(limits=c(0,1), name="Model predicted posterior probability of all-state")
#  geom_text(data=cors, aes(label=r)) +

#scale_size_discrete(range=c(1,2)) +
#scale_color_manual(values=c("red","blue","black")) 
ggsave("model-allprobs.pdf",width=5.5,height=4.5)#,width=30,height=10)
ggsave("model-uniform-allprobs.pdf",width=5.5,height=4.5)#,width=30,height=10)
save(toplot, file="../data/toplot-allprobs.RData")

toplot_w = toplot
# get rRSA predictions for qud=how-many, alts=0_basic, spopt=2
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/complex_prior/smoothed_unbinned15/results/data/mp.RData")
summary(mp)
toplot = droplevels(subset(mp, QUD == "how-many" & Alternatives == "0_basic" &  State == 15))
nrow(toplot)

# adjust speaker optimality at will
toplot = droplevels(subset(toplot, SpeakerOptimality == 2))
nrow(toplot)
head(toplot)

toplot_r = toplot

# plot only rrsa
ggplot(toplot_r, aes(x=PriorProbability, y=PosteriorProbability)) +
  geom_point(color="#007fb1") + #values=c("#F8766D", "#A3A500", "#00BF7D", "#E76BF3", "#00B0F6")
  geom_smooth(color="#007fb1") + #color="#00B0F6") +
  #scale_color_manual(values=c("#007fb1")) +
  #  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1), name="Prior probability of all-state") +
  scale_y_continuous(limits=c(0,1), name="Model predicted posterior probability of all-state")
#  geom_text(data=cors, aes(label=r)) +
#scale_size_discrete(range=c(1,2)) +
#scale_color_manual(values=c("red","blue","black")) 
#ggsave("graphs/model-expectations.pdf",width=5.5,height=4.5)#,width=30,height=10)
ggsave("model-allprobs-rrsa.pdf",width=6.5,height=4.5)

head(toplot_w)
summary(toplot_r)
toplot_r$Model = "RSA"
toplot_w$Model = "wRSA"

# plot both rRSA and uniform wRSA expectation predictions in same plot
toplot = merge(toplot_r,toplot_w, all=T)
head(toplot)
nrow(toplot)
p_probs = ggplot(toplot, aes(x=PriorProbability, y=PosteriorProbability, color=Model)) +
  geom_point() + #color="#00B0F6") + #values=c("#F8766D", "#A3A500", "#00BF7D", "#E76BF3", "#00B0F6")
  geom_smooth() + #color="#00B0F6") +
  scale_color_manual(values=c("#007fb1", "#4ecdff")) +
  #  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1), name="Prior probability of all-state") +
  scale_y_continuous(limits=c(0,1), name="Model predicted posterior probability of all-state")
#  geom_text(data=cors, aes(label=r)) +
#scale_size_discrete(range=c(1,2)) +
#scale_color_manual(values=c("red","blue","black")) 
#ggsave("graphs/model-expectations.pdf",width=5.5,height=4.5)#,width=30,height=10)
ggsave("model-allprobs-binomial-regular.pdf",width=6.5,height=4.5)
ggsave("model-allprobs-uniform-regular.pdf",width=6.5,height=4.5)

library(gridExtra)
#  share a legend between multiple plots
g <- ggplotGrob(p_exps + theme(legend.position="right"))$grobs
legend <- g[[which(sapply(g, function(x) x$name) == "guide-box")]]
p_exps_nolegend = p_exps + theme(legend.position="none")
p_probs_nolegend = p_probs + theme(legend.position="none")

#pdf("rsa-predictions-uniform.pdf",width=10,height=4)
pdf("rsa-predictions.pdf",width=10,height=4)
grid.arrange(p_exps_nolegend, p_probs_nolegend, legend,nrow=1,widths=unit.c(unit(.45, "npc"), unit(.45, "npc"), unit(.1, "npc")))
dev.off()

s = subset(r, quantifier=="Some" & Proportion == "100")
nrow(s)

library(lmerTest)
m=lmer(normresponse ~ AllPriorProbability + (1+AllPriorProbability|workerid) + (1|Item), data=s)
summary(m)



#####################################
# plot model predictions: wonkiness
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/wonky_world/results/data/wr-uniform.RData")
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/wonky_world/results/data/wr-binomial.RData")

# plot expectations for best basic model: 
toplot = droplevels(subset(wr, WonkyWorldPrior == .5 & Wonky == "true"))
nrow(toplot)
toplot$Mode = priormodes[as.character(toplot$Item),]$Mode

toplot = droplevels(subset(toplot, SpeakerOptimality == 2))
mod = toplot
nrow(toplot)
head(toplot)

p_wmodel = ggplot(toplot, aes(x=PriorExpectation, y=PosteriorProbability,color=Quantifier)) +
  geom_point() + #color="#00B0F6") + #values=c("#F8766D", "#A3A500", "#00BF7D", "#E76BF3", "#00B0F6")
  geom_smooth() + #color="#00B0F6") +
  #  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_color_manual(values=c("#F8766D","#00BF7D","#00B0F6")) +
  scale_x_continuous(breaks=seq(1,15,by=2),name="Prior expected number of objects") +
  scale_y_continuous(breaks=seq(0,1,by=.25),name="Model predicted wonkiness probability")

ggsave("model-wonkiness-uniform.pdf",width=5.5,height=4)#,width=30,height=10)
ggsave("model-wonkiness-binomial.pdf",width=5.5,height=4)#,width=30,height=10)

# plot by mode
ggplot(toplot, aes(x=Mode, y=PosteriorProbability,color=Quantifier)) +
  geom_point() + #color="#00B0F6") + #values=c("#F8766D", "#A3A500", "#00BF7D", "#E76BF3", "#00B0F6")
  geom_smooth() + #color="#00B0F6") +
  #  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_color_manual(values=c("#F8766D","#00BF7D","#00B0F6")) +
  scale_x_continuous(breaks=seq(1,15,by=2),name="Prior expected number of objects") +
  scale_y_continuous(breaks=seq(0,1,by=.25),name="Model predicted wonkiness probability")

############
# empirical wonkiness posteriors
############
load("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/17_sinking-marbles-normal-sliders/results/data/r.RData")
head(r)
nrow(r)

ggplot(r, aes(x=response, fill=quantifier)) +
  geom_histogram() +
  facet_grid(workerid~quantifier)
ggsave("subject-variability-wonkiness.pdf",width=7,height=25)

toplot = aggregate(response ~ quantifier + Item + PriorExpectation, FUN="mean", data=r)
toplot = droplevels(subset(toplot, quantifier %in% c("All","Some","None")))
toplot$Quantifier = factor(tolower(toplot$quantifier), levels=c("all", "none","some"))
toplot$Mode = priormodes[as.character(toplot$Item),]$Mode

p_wempirical = ggplot(toplot, aes(x=PriorExpectation, y=response, color=Quantifier)) +
  geom_point() +
  geom_smooth() +
  scale_color_manual(values=c("#F8766D","#00BF7D","#00B0F6")) +
  scale_x_continuous(breaks=seq(1,15,by=2),name="Prior expected number of objects") +
  scale_y_continuous(breaks=seq(0,1,by=.25),name="Mean empirical wonkiness probability")  
ggsave(file="empirical-wonkiness.pdf",width=5.5,height=4)


library(gridExtra)
#  share a legend between multiple plots
g <- ggplotGrob(p_wmodel + theme(legend.position="right"))$grobs
legend <- g[[which(sapply(g, function(x) x$name) == "guide-box")]]
p_wmodel_nolegend = p_wmodel + theme(legend.position="none")
p_wempirical_nolegend = p_wempirical + theme(legend.position="none")

#pdf("rsa-predictions-uniform.pdf",width=10,height=4)
pdf("wonkiness-fullplot.pdf",width=12,height=5)
grid.arrange(p_wmodel_nolegend, p_wempirical_nolegend, legend,nrow=1,widths=unit.c(unit(.45, "npc"), unit(.45, "npc"), unit(.1, "npc")))
dev.off()


# scatterplot of mdoel vs empirical
head(toplot)
toplot$PosteriorProbability = toplot$response
head(mod)
toplot$Type = "empirical"
mod$Type = "model"

pl = merge(mod, toplot, all=T)
summary(pl)
pl$Type = as.factor(as.character(pl$Type))
topl = pl %>% select(Item, Quantifier,PosteriorProbability,Type) %>%
  spread(Type,PosteriorProbability)
summary(topl)

ggplot(topl, aes(x=model,y=empirical,color=Quantifier,group=1)) +
  geom_point() +
  geom_smooth(method="lm") +
  scale_color_manual(values=c("#F8766D","#00BF7D","#00B0F6"))
cor(topl$model,topl$empirical,use="pairwise.complete.obs") # cor=.69

library(hydroGOF)
gof(topl$model,topl$empirical,na.rm=T,do.spearman=T)

#plot by mode
ggplot(toplot, aes(x=Mode, y=response, color=Quantifier)) +
  geom_point() +
  geom_smooth() +
  scale_color_manual(values=c("#F8766D","#00BF7D","#00B0F6")) +
  scale_x_continuous(breaks=seq(1,15,by=2),name="Prior expected number of objects") +
  scale_y_continuous(breaks=seq(0,1,by=.25),name="Mean empirical wonkiness probability")  



###############
## EMPIRICAL PLOTS
###############

# expectations
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/13_sinking-marbles-priordv-15/results/data/r.RData")

agr = aggregate(ProportionResponse ~ PriorExpectationProportion + quantifier + Item,data=r,FUN=mean)
#agr$CILow = aggregate(ProportionResponse ~ PriorExpectationProportion + quantifier + Item,data=r, FUN=ci.low)$ProportionResponse
#agr$CIHigh = aggregate(ProportionResponse ~ PriorExpectationProportion + quantifier + Item,data=r,FUN=ci.high)$ProportionResponse
#agr$YMin = agr$ProportionResponse - agr$CILow
#agr$YMax = agr$ProportionResponse + agr$CIHigh

min(agr[agr$quantifier == "Some",]$ProportionResponse)
max(agr[agr$quantifier == "Some",]$ProportionResponse)

p_eexps = ggplot(agr, aes(x=PriorExpectationProportion*15, y=ProportionResponse*15, color=quantifier)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth(method="lm") +
  scale_color_manual(values=c("#F8766D", "black", "#00BF7D", "gray30", "#00B0F6"),breaks=levels(agr$quantifier),labels=c("all","long filler","none","short filler","some")) +
  scale_y_continuous(breaks=seq(1,15,by=2),name="Posterior mean number of objects") +
  #  geom_abline(intercept=0,slope=1,color="gray70") +
  scale_x_continuous(breaks=seq(1,15,by=2),name="Prior mean number of objects")  
ggsave(file="meanresponses.pdf",width=5,height=3.7)


# allstate-probs
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/16_sinking-marbles-sliders-certain/results/data/r.RData")

# exclude people who are doing some sort of bullshit and not responding reasonably to all/none (see subject-variability.pdf for behavior on zero-slider)
tmp = subset(r,!workerid %in% c(0,22,43,98,100,103,117,118))
agrr = aggregate(normresponse ~ AllPriorProbability + Proportion + quantifier + Item,data=tmp,FUN=mean)
agrr = aggregate(normresponse ~ AllPriorProbability + Proportion + quantifier + Item,data=r,FUN=mean)
ub = subset(agrr, Proportion == "100")
ub = droplevels(ub)

p_eprobs = ggplot(ub, aes(x=AllPriorProbability, y = normresponse, color=quantifier)) +
  geom_point() +
  geom_smooth(method="lm") +
  scale_color_manual(values=c("#F8766D", "black", "#00BF7D", "gray30", "#00B0F6"),breaks=levels(agrr$quantifier),labels=c("all","long filler","none","short filler","some")) +
  scale_y_continuous(limits=c(0,1),name="Posterior probability of all-state ") +
  #  geom_abline(intercept=0,slope=1,color="gray70") +
  scale_x_continuous(limits=c(0,1),name="Prior probability of all-state")  
ggsave(file="empirical-allprobs.pdf",width=5,height=3.7)


library(gridExtra)
#  share a legend between multiple plots
g <- ggplotGrob(p_eexps + theme(legend.position="right"))$grobs
legend <- g[[which(sapply(g, function(x) x$name) == "guide-box")]]
p_eexps_nolegend = p_eexps + theme(legend.position="none")
p_eprobs_nolegend = p_eprobs + theme(legend.position="none")

pdf("empirical-results.pdf",width=10,height=4)
grid.arrange(p_eexps_nolegend, p_eprobs_nolegend, legend,nrow=1,widths=unit.c(unit(.45, "npc"), unit(.45, "npc"), unit(.1, "npc")))
dev.off()


# plot subejct variability for exclusion
ggplot(r[r$Proportion == "0",], aes(x=normresponse,fill=quantifier)) +
  geom_histogram() +
  facet_grid(workerid~quantifier)  
ggsave("subject-variability.pdf",width=5.5,height=4)







######################
### NOAH'S MODEL PREDICTIONS
rsa_allstate = read.csv(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/ndg-code/RSA-allstate.csv",header=F)
head(rsa_allstate)
colnames(rsa_allstate) = c("BinomialCW","PosteriorAllProbability")
ggplot(rsa_allstate, aes(x=BinomialCW,y=PosteriorAllProbability)) +
  geom_point(color="#00B0F6") +
  scale_x_continuous(limits=c(0,1), name="Binomial coin weight") +
  scale_y_continuous(limits=c(0,1), name="Predicted posterior probability of all-state")  
ggsave("noahs-allstate-predictions.pdf",width=4.5,height=3.5)  

rsa_expectation = read.csv(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/ndg-code/RSA-expectation.csv",header=F)
head(rsa_expectation)
colnames(rsa_expectation) = c("PriorExpectation","PosteriorExpectation")
ggplot(rsa_expectation, aes(x=PriorExpectation/15,y=PosteriorExpectation/15)) +
  geom_point(color="#00B0F6") +
  scale_x_continuous(limits=c(0,1), name="Prior expectation") +
  scale_y_continuous(limits=c(0,1), name="Predicted posterior expectation")  
ggsave("noahs-expectation-predictions.pdf",width=4.5,height=3.5)  

rsa_expall = read.csv(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/ndg-code/RSA-expectedVsallstate.csv",header=F)
head(rsa_expall)
colnames(rsa_expall) = c("PriorExpectation","PosteriorExpectation")
ggplot(rsa_expall, aes(x=PriorExpectation/15,y=PosteriorExpectation)) +
  geom_point(color="#00B0F6") +
  scale_x_continuous(limits=c(0,1), name="Prior expectation") +
  scale_y_continuous(limits=c(0,1), name="Predicted posterior probability of all-state")  
ggsave("noahs-allstate-predictions-bypriorexp.pdf",width=4.5,height=3.5)  


