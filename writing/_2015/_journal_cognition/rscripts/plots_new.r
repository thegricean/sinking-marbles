#' ---
#' title: "Prior probabilities in the interpretation of 'some': analysis of uniform prior wonky world model predictions"
#' author: "Judith Degen"
#' date: "January 26, 2014"
#' ---

library(ggplot2)
library(wesanderson)
theme_set(theme_bw(18))
setwd("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/writing/_2015/_journal_cognition/")
source("rscripts/helpers.r")

## load priors for generating plots 
priorprobs = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/smoothed_15marbles_priors_withnames.txt",sep="\t", header=T, quote="")
row.names(priorprobs) = priorprobs$Item
nrow(priorprobs)

# prior all-state probability for each item
prior_allprobs = priorprobs[,c("Item","X15")]
row.names(prior_allprobs) = prior_allprobs$Item

# prior expectation for each item
gathered_probs <- priorprobs %>%
  gather(State,Probability,X0:X15)
gathered_probs$State = as.numeric(as.character(gsub("X","",gathered_probs$State)))
prior_exps <- gathered_probs %>%
  group_by(Item) %>%
  summarise(exp.val=sum(State*Probability))
prior_exps = as.data.frame(prior_exps)
row.names(prior_exps) = prior_exps$Item
summary(prior_exps)

# histogram of expectations
exps = ggplot(prior_exps, aes(x=exp.val)) +
  geom_histogram() +
  scale_x_continuous(name="Expected value of prior distribution",breaks=seq(1,15, by=2)) +
  scale_y_continuous(name="Number of cases",breaks=seq(0,8, by=2))
ggsave("pics/priorexpectations-histogram.pdf",width=5,height=3.7)

# histogram of allstate-probs
allprobs = ggplot(prior_allprobs, aes(x=X15)) +
  geom_histogram() +
  scale_x_continuous(name="Prior all-state probability") +
  scale_y_continuous(name="Number of cases")
ggsave("priorallprobs-histogram.pdf")

pdf("pics/priordistributions.pdf",width=10,height=3.5)
grid.arrange(exps, allprobs, nrow=1,widths=unit.c(unit(.5, "npc"), unit(.5, "npc")))
dev.off()

### PLOT COMPREHENSION RESULTS
# expectations
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/13_sinking-marbles-priordv-15/results/data/r.RData")

r$PriorExpectationProportion = prior_exps[as.character(r$Item),]$exp.val
# exclude people who weren't literal above some threshold
# lit = droplevels(r[r$quantifier %in% c("All","None"),]) %>% 
#   group_by(workerid,quantifier) %>%
#   summarise(Mean=mean(response))
# lit = as.data.frame(lit)
# lit = lit %>% spread(quantifier,Mean)
# lit$Literal = as.factor(as.character(ifelse(lit$All > .80*15 & lit$None < .20*15,"literal","non-literal")))
# table(lit$Literal)
# row.names(lit) = as.character(lit$workerid)
# r$Literal = lit[as.character(r$workerid),]$Literal

agr = aggregate(ProportionResponse ~ PriorExpectationProportion + quantifier + Item,data=r,FUN=mean)

min(agr[agr$quantifier == "Some",]$ProportionResponse)
max(agr[agr$quantifier == "Some",]$ProportionResponse)
agr$Quantifier = factor(x=agr$quantifier, levels=c("Some","All","None","long_filler","short_filler"))

p_eexps = ggplot(agr, aes(x=PriorExpectationProportion, y=ProportionResponse*15, color=Quantifier, shape=Quantifier)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth(method="lm") +
  scale_color_manual(values=c(wes_palette("Darjeeling")[1:3],"black","gray40")) +#values=c("#F8766D", "black", "#00BF7D", "gray30", "#00B0F6"),breaks=levels(agr$quantifier),labels=c("all","long filler","none","short filler","some")) +
  scale_y_continuous(breaks=seq(1,15,by=2),name="Posterior mean number of objects") +
  #  geom_abline(intercept=0,slope=1,color="gray70") +
  scale_x_continuous(breaks=seq(1,15,by=2),name="Prior mean number of objects")  
p_eexps
ggsave(file="empirical_exps.pdf")#,width=5,height=3.7)


# allstate-probs
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/16_sinking-marbles-sliders-certain/results/data/r.RData")

# exclude people who are doing some sort of bullshit and not responding reasonably to all/none (see subject-variability.pdf for behavior on zero-slider)
#tmp = subset(r,!workerid %in% c(0,22,43,98,100,103,117,118))
r$AllPriorProbability = prior_allprobs[as.character(r$Item),]$X15
tmp=r
agrr = aggregate(normresponse ~ AllPriorProbability + Proportion + quantifier + Item,data=tmp,FUN=mean)
agrr = aggregate(normresponse ~ AllPriorProbability + Proportion + quantifier + Item,data=r,FUN=mean)
ub = subset(agrr, Proportion == "100")
ub = droplevels(ub)
ub$Quantifier = factor(x=ub$quantifier, levels=c("Some","All","None","long_filler","short_filler"))

p_eprobs = ggplot(ub, aes(x=AllPriorProbability, y = normresponse, color=Quantifier, shape=Quantifier)) +
  geom_point() +
  geom_smooth(method="lm") +
  scale_color_manual(values=c(wes_palette("Darjeeling")[1:3],"black","gray40")) +#values=c("#F8766D", "black", "#00BF7D", "gray30", "#00B0F6"),breaks=levels(agr$quantifier),labels=c("all","long filler","none","short filler","some")) +
  scale_y_continuous(limits=c(0,1),name="Posterior probability of all-state ") +
  #  geom_abline(intercept=0,slope=1,color="gray70") +
  scale_x_continuous(limits=c(0,1),name="Prior probability of all-state")  
p_eprobs
ggsave(file="empirical-allprobs.pdf")#,width=5,height=3.7)

library(gridExtra)
#  share a legend between multiple plots
g <- ggplotGrob(p_eexps + theme(legend.position="right"))$grobs
legend <- g[[which(sapply(g, function(x) x$name) == "guide-box")]]
p_eexps_nolegend = p_eexps + theme(legend.position="none")
p_eprobs_nolegend = p_eprobs + theme(legend.position="none")

pdf("pics/empirical-results.pdf",width=10,height=4)
grid.arrange(p_eexps_nolegend, p_eprobs_nolegend, legend,nrow=1,widths=unit.c(unit(.45, "npc"), unit(.45, "npc"), unit(.1, "npc")))
dev.off()

### PLOT WONKY RESULTS
load("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/11_sinking-marbles-normal/results/data/r.RData")

r$PriorExpectation = prior_exps[as.character(r$Item),]$exp.val
ans = r %>%
  filter(quantifier %in% c("All","None","Some")) %>%
  group_by(quantifier, Item, PriorExpectation) %>%
  summarise(mean.prop=mean(numWonky))

p_wempirical =ggplot(ans,aes(x=PriorExpectation,y=mean.prop,color=quantifier)) +
  geom_point() +
  geom_smooth() +
  scale_color_manual(values=c(wes_palette("Darjeeling")[1:3])) +
  scale_y_continuous(limits=c(-0.1,1.2),breaks=seq(0,1,by=.2),name="Proportion of `wonky' judgments") +
  scale_x_continuous(limits=c(0,15),breaks=seq(1,15,by=2),name="Prior mean number of objects") 

# get wonky model predictions
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/wonky_world/results/data/wr-uniform.RData")

# plot expectations for best basic model: 
toplot = droplevels(subset(wr, WonkyWorldPrior == .5 & Wonky == "true"))
nrow(toplot)

toplot = droplevels(subset(toplot, SpeakerOptimality == 2))
nrow(toplot)
head(toplot)
#toplot$quantifier = capitalize(as.character(toplot$Quantifier))
toplot$Quantifier = factor(toplot$Quantifier, levels=c("all","none","some"))

p_wmodel = ggplot(toplot, aes(x=PriorExpectation, y=PosteriorProbability,color=Quantifier,shape=Quantifier)) +
  geom_point() + 
  geom_smooth() + 
  scale_color_manual(values=c(wes_palette("Darjeeling")[1:3],"black","gray40")) +   
  #scale_color_manual(values=c("#F8766D","#00BF7D","#00B0F6")) +
  scale_x_continuous(limits=c(0,15),breaks=seq(1,15,by=2),name="Prior mean number of objects") +
  scale_y_continuous(limits=c(-0.1,1.2),breaks=seq(0,1,by=.25),name="Predicted posterior wonkiness probability") +
  theme(plot.margin=unit(c(0,0,0,0),units="cm")) 
p_wmodel


pdf("pics/wonkiness-results.pdf",width=10,height=4)
#grid.arrange(p_wmodel, p_wempirical, legend,nrow=1,widths=unit.c(unit(.45, "npc"), unit(.45, "npc"), unit(.1, "npc")))
grid.arrange(p_wmodel, p_wempirical, nrow=1,widths=unit.c(unit(.5, "npc"), unit(.5, "npc"), unit(.1, "npc")))
dev.off()


## PLOT SPEAKER RELIABILITY RESULTS
load("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/19_speaker_reliability_withins/results/data/r.RData")
r = r[!is.na(r$normresponse),]
r$AllPriorProbability = prior_allprobs[as.character(r$Item),]$X15

some100 = droplevels(subset(r, Proportion == "100" & quantifier == "Some"))
agr = aggregate(normresponse ~ AllPriorProbability  + trial_type + Item,data=some100,FUN=mean)
agr$CILow = aggregate(normresponse ~ AllPriorProbability + trial_type + Item,data=some100, FUN=ci.low)$normresponse
agr$CIHigh = aggregate(normresponse ~ AllPriorProbability + trial_type + Item,data=some100,FUN=ci.high)$normresponse
agr$YMin = agr$normresponse - agr$CILow
agr$YMax = agr$normresponse + agr$CIHigh

p=ggplot(agr, aes(x=AllPriorProbability,y=normresponse, color=trial_type)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth(method="lm") +
  scale_y_continuous(name="Posterior probability of all-state") +
  scale_x_continuous(name="Prior probability of all-state") +
  scale_color_manual(values=c(wes_palette("Darjeeling")[1:3]),name="Trial type",breaks=levels(agr$trial_type),labels=c("uninformative (court)", "unreliable (drunk)", "cooperative (sober)"))
p
ggsave("pics/speakerreliabilityresults.pdf",width=7,height=4)

some100$Reliability = as.factor(ifelse(some100$trial_type == "sober","reliable","unreliable"))
centered = cbind(some100, myCenter(some100[,c("AllPriorProbability","Reliability","Trial")]))
m = lmer(normresponse ~ cAllPriorProbability * cReliability + (cAllPriorProbability * cReliability | Item) + (cAllPriorProbability * cReliability | workerid), data=centered)
summary(m)
save(m, file="data/model.RData")

m.trial = lmer(normresponse ~ cAllPriorProbability * cReliability * cTrial + (cAllPriorProbability * cReliability| Item) + (cAllPriorProbability * cReliability| workerid), data=centered)
summary(m.trial)

m.trial.nopr = lmer(normresponse ~ cAllPriorProbability + cReliability + cTrial + cReliability:cTrial + cAllPriorProbability:cTrial + cAllPriorProbability:cReliability:cTrial + (cAllPriorProbability * cReliability| Item) + (cAllPriorProbability * cReliability| workerid), data=centered)
summary(m.trial.nopr)

anova(m.trial.nopr,m.trial) # 

m.trial.nopt = lmer(normresponse ~ cAllPriorProbability + cReliability + cTrial + cAllPriorProbability:cReliability + cReliability:cTrial + cAllPriorProbability:cReliability:cTrial + (cAllPriorProbability * cReliability| Item) + (cAllPriorProbability * cReliability| workerid), data=centered)
summary(m.trial.nopr)

anova(m.trial.nopt,m.trial)

# spell out all the interactions
#m.trial = lmer(normresponse ~ cAllPriorProbability + cReliability + cTrial + cAllPriorProbability:cReliability + cReliability:cTrial + cAllPriorProbability:cTrial + cAllPriorProbability:cReliability:cTrial + (cAllPriorProbability * cReliability| Item) + (cAllPriorProbability * cReliability| workerid), data=centered)


# PLOT SPEAKER RELIABILITY RESULTS BY BLOCK
agr = aggregate(normresponse ~ AllPriorProbability  + trial_type + Item + block,data=some100,FUN=mean)
agr$CILow = aggregate(normresponse ~ AllPriorProbability + trial_type + Item + block,data=some100, FUN=ci.low)$normresponse
agr$CIHigh = aggregate(normresponse ~ AllPriorProbability + trial_type + Item + block,data=some100,FUN=ci.high)$normresponse
agr$YMin = agr$normresponse - agr$CILow
agr$YMax = agr$normresponse + agr$CIHigh

p=ggplot(agr, aes(x=AllPriorProbability,y=normresponse, color=trial_type)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth(method="lm") +
  scale_y_continuous(name="Posterior probability of all-state") +
  scale_x_continuous(name="Prior probability of all-state") +
  scale_color_manual(values=c(wes_palette("Darjeeling")[1:3]),name="Trial type",breaks=levels(agr$trial_type),labels=c("uninformative (court)", "unreliable (drunk)", "cooperative (sober)")) +
  facet_wrap(~block)
p
ggsave("pics/speakerreliabilityresults-byblock.pdf",width=12,height=4)



#####################################
# plot model predictions: expectations
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/wonky_world/results/data/mp-uniform.RData")


library(dplyr)
library(plyr)
# plot expectations for best basic model: 
toplot = droplevels(subset(mp, Quantifier == "some" & WonkyWorldPrior == .5))
nrow(toplot)
pexpectations = ddply(toplot, .(Item), summarise, PosteriorExpectation_predicted=sum(State*PosteriorProbability)/15)
head(pexpectations)
some = pexpectations#droplevels(subset(pexpectations, Quantifier == "some"))

toplot = some
nrow(toplot)
head(toplot)
toplot$Mode = priormodes[as.character(toplot$Item),]$Mode

ggplot(toplot, aes(x=PriorExpectation_smoothed, y=PosteriorExpectation_predicted)) +
  geom_point(color="#00B0F6") + #values=c("#F8766D", "#A3A500", "#00BF7D", "#E76BF3", "#00B0F6")
  geom_smooth(color="#00B0F6") +
  #  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1), name="Prior expectation") +
  scale_y_continuous(limits=c(0,1), name="Model predicted posterior expectation")



load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/wonky_world/results/data/mp-uniform.RData")

# plot expectations for best basic model: 
toplot = droplevels(subset(mp, Quantifier == "some" & WonkyWorldPrior == .5 & State == 15))
nrow(toplot)

# adjust speaker optimality at will
toplot = droplevels(subset(toplot, SpeakerOptimality == 2))
nrow(toplot)
head(toplot)

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
toplot_r$Model = "RSA"
toplot_w$Model = "wRSA"

# plot both rRSA and uniform wRSA expectation predictions in same plot
toplot = merge(toplot_r,toplot_w, all=T)
head(toplot)
nrow(toplot)
p_probs = ggplot(toplot, aes(x=PriorProbability, y=PosteriorProbability, color=Model)) +
  geom_point() + #color="#00B0F6") + #values=c("#F8766D", "#A3A500", "#00BF7D", "#E76BF3", "#00B0F6")
  geom_smooth() + #color="#00B0F6") +
  scale_color_manual(values=c("darkred",wes_palette("Darjeeling")[1])) +
  #  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1), name="Prior mean all-state probability") +
  scale_y_continuous(limits=c(0,1), name="Predicted posterior all-state probability")  
p_probs
ggsave("pred_probs.pdf")

p_probs = ggplot(toplot_r, aes(x=PriorProbability, y=PosteriorProbability, color=Model)) +
  geom_point() + #color="#00B0F6") + #values=c("#F8766D", "#A3A500", "#00BF7D", "#E76BF3", "#00B0F6")
  geom_smooth() + #color="#00B0F6") +
  scale_color_manual(values=c("darkred")) +
  #  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1), name="Prior all-state probability") +
  scale_y_continuous(limits=c(0,1), name="Posterior all-state probability") 
p_probs
ggsave("pred_prob_rsa.pdf")


# plot model predictions: expectations
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/wonky_world/results/data/mp-uniform.RData")


# plot expectations for best basic model: 
toplot = droplevels(subset(mp, Quantifier == "some" & WonkyWorldPrior == .5))
nrow(toplot)

pexpectations = ddply(toplot, .(Item, SpeakerOptimality,PriorExpectation), summarise, PosteriorExpectation_predicted=sum(State*PosteriorProbability)/15)
head(pexpectations)
some = pexpectations#droplevels(subset(pexpectations, Quantifier == "some"))

toplot = droplevels(subset(some, SpeakerOptimality == 2))
nrow(toplot)
head(toplot)
toplot_w = toplot

# get rRSA predictions for qud=how-many, alts=0_basic, spopt=2
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/complex_prior/smoothed_unbinned15/results/data/toplot-expectations.RData")
toplot_r = toplot
head(toplot_w)
summary(toplot_r)
toplot_r$Model = "RSA"
toplot_r$PriorExpectation = toplot_r$PriorExpectation_smoothed*15
toplot_w$Model = "wRSA"

# plot both rRSA and uniform wRSA expectation predictions in same plot
toplot = merge(toplot_r,toplot_w, all=T)
head(toplot)
nrow(toplot)

p_exps = ggplot(toplot, aes(x=PriorExpectation, y=PosteriorExpectation_predicted*15, color=Model)) +
  geom_point() + #color="#00B0F6") + #values=c("#F8766D", "#A3A500", "#00BF7D", "#E76BF3", "#00B0F6")
  geom_smooth() + #color="#00B0F6") +
  scale_color_manual(values=c("darkred",wes_palette("Darjeeling")[1])) +#values=c("#007fb1", "#4ecdff")) +
  #  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,15), breaks=seq(1,15,by=2), name="Prior mean number of objects") +
  scale_y_continuous(limits=c(0,15), breaks=seq(1,15,by=2), name="Predicted posterior number of objects") 
p_exps
ggsave("pred_exps.pdf")

p_exps = ggplot(toplot_r, aes(x=PriorExpectation, y=PosteriorExpectation_predicted*15, color=Model)) +
  geom_point() + #color="#00B0F6") + #values=c("#F8766D", "#A3A500", "#00BF7D", "#E76BF3", "#00B0F6")
  geom_smooth() + #color="#00B0F6") +
  scale_color_manual(values=c("darkred")) +#values=c("#007fb1", "#4ecdff")) +
  #  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,15), breaks=seq(1,15,by=2), name="Prior expectation") +
  scale_y_continuous(limits=c(0,15), breaks=seq(1,15,by=2), name="Posterior expectation") 
p_exps
ggsave("pred_exps_rsa.pdf")

library(gridExtra)
#  share a legend between multiple plots
g <- ggplotGrob(p_exps + theme(legend.position="right"))$grobs
legend <- g[[which(sapply(g, function(x) x$name) == "guide-box")]]
p_exps_nolegend = p_exps + theme(legend.position="none")
p_probs_nolegend = p_probs + theme(legend.position="none")

pdf("rsa-predictions.pdf",width=12,height=4.9)
grid.arrange(p_exps_nolegend, p_probs_nolegend, legend,nrow=1,widths=unit.c(unit(.45, "npc"), unit(.45, "npc"), unit(.1, "npc")))
dev.off()


# expectations
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/13_sinking-marbles-priordv-15/results/data/r.RData")

agr = aggregate(ProportionResponse ~ PriorExpectationProportion + quantifier + Item,data=r,FUN=mean)

min(agr[agr$quantifier == "Some",]$ProportionResponse)
max(agr[agr$quantifier == "Some",]$ProportionResponse)
agr$Quantifier = factor(x=agr$quantifier, levels=c("Some","All","None","long_filler","short_filler"))

p_eexps = ggplot(agr, aes(x=PriorExpectationProportion*15, y=ProportionResponse*15, color=Quantifier, shape=Quantifier)) +
  geom_point() +
  #geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  geom_smooth(method="lm") +
  scale_color_manual(values=c(wes_palette("Darjeeling")[1:3],"black","gray40")) +#values=c("#F8766D", "black", "#00BF7D", "gray30", "#00B0F6"),breaks=levels(agr$quantifier),labels=c("all","long filler","none","short filler","some")) +
  scale_y_continuous(breaks=seq(1,15,by=2),name="Posterior mean number of objects") +
  #  geom_abline(intercept=0,slope=1,color="gray70") +
  scale_x_continuous(breaks=seq(1,15,by=2),name="Prior mean number of objects")  
p_eexps
ggsave(file="empirical_exps.pdf")#,width=5,height=3.7)


# allstate-probs
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/16_sinking-marbles-sliders-certain/results/data/r.RData")

# exclude people who are doing some sort of bullshit and not responding reasonably to all/none (see subject-variability.pdf for behavior on zero-slider)
tmp = subset(r,!workerid %in% c(0,22,43,98,100,103,117,118))
agrr = aggregate(normresponse ~ AllPriorProbability + Proportion + quantifier + Item,data=tmp,FUN=mean)
agrr = aggregate(normresponse ~ AllPriorProbability + Proportion + quantifier + Item,data=r,FUN=mean)
ub = subset(agrr, Proportion == "100")
ub = droplevels(ub)
ub$Quantifier = factor(x=ub$quantifier, levels=c("Some","All","None","long_filler","short_filler"))

p_eprobs = ggplot(ub, aes(x=AllPriorProbability, y = normresponse, color=Quantifier, shape=Quantifier)) +
  geom_point() +
  geom_smooth(method="lm") +
  scale_color_manual(values=c(wes_palette("Darjeeling")[1:3],"black","gray40")) +#values=c("#F8766D", "black", "#00BF7D", "gray30", "#00B0F6"),breaks=levels(agr$quantifier),labels=c("all","long filler","none","short filler","some")) +
  scale_y_continuous(limits=c(0,1),name="Posterior probability of all-state ") +
  #  geom_abline(intercept=0,slope=1,color="gray70") +
  scale_x_continuous(limits=c(0,1),name="Prior probability of all-state")  
p_eprobs
ggsave(file="empirical-allprobs.pdf")#,width=5,height=3.7)

library(gridExtra)
#  share a legend between multiple plots
g <- ggplotGrob(p_eexps + theme(legend.position="right"))$grobs
legend <- g[[which(sapply(g, function(x) x$name) == "guide-box")]]
p_eexps_nolegend = p_eexps + theme(legend.position="none")
p_eprobs_nolegend = p_eprobs + theme(legend.position="none")

pdf("empirical-results.pdf",width=12,height=4.9)
grid.arrange(p_eexps_nolegend, p_eprobs_nolegend, legend,nrow=1,widths=unit.c(unit(.45, "npc"), unit(.45, "npc"), unit(.1, "npc")))
dev.off()


load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/wonky_world/results/data/wr-uniform.RData")

# plot expectations for best basic model: 
toplot = droplevels(subset(wr, WonkyWorldPrior == .5 & Wonky == "true"))
nrow(toplot)
toplot$Mode = priormodes[as.character(toplot$Item),]$Mode

toplot = droplevels(subset(toplot, SpeakerOptimality == 2))
nrow(toplot)
head(toplot)
#toplot$quantifier = capitalize(as.character(toplot$Quantifier))
toplot$Quantifier = factor(toplot$Quantifier, levels=c("some","all","none"))

p_wmodel = ggplot(toplot, aes(x=PriorExpectation, y=PosteriorProbability,color=Quantifier,shape=Quantifier)) +
  geom_point() + 
  geom_smooth() + 
  scale_color_manual(values=c(wes_palette("Darjeeling")[1:3],"black","gray40")) +   
  #scale_color_manual(values=c("#F8766D","#00BF7D","#00B0F6")) +
  scale_x_continuous(breaks=seq(1,15,by=2),name="Prior mean number of objects") +
  scale_y_continuous(breaks=seq(0,1,by=.25),name="Predicted posterior wonkiness probability") +
  theme(plot.margin=unit(c(0,0,0,0),units="cm")) 
p_wmodel
ggsave("model-wonkiness-uniform.pdf",width=6.8,height=5)#,width=30,height=10)

############
# empirical wonkiness posteriors
############
load("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/17_sinking-marbles-normal-sliders/results/data/r.RData")
head(r)
nrow(r)

toplot = aggregate(response ~ quantifier + Item + PriorExpectation, FUN="mean", data=r)
toplot = droplevels(subset(toplot, quantifier %in% c("All","Some","None")))
toplot$Quantifier = factor(tolower(toplot$quantifier), levels=c("all", "none","some"))
toplot$Mode = priormodes[as.character(toplot$Item),]$Mode
toplot$quantifier = capitalize(as.character(toplot$Quantifier))
toplot$Quantifier = factor(toplot$quantifier, levels=c("Some","All","None"))

p_wempirical = ggplot(toplot, aes(x=PriorExpectation, y=response, color=Quantifier,shape=Quantifier)) +
  geom_point() +
  geom_smooth() +
  scale_color_manual(values=c(wes_palette("Darjeeling")[1:3],"black","gray40")) +   
  scale_x_continuous(breaks=seq(1,15,by=2),name="Prior mean number of objects") +
  scale_y_continuous(breaks=seq(0,1,by=.25),name="Mean empirical wonkiness probability")  +
  theme(plot.margin=unit(c(0,0,0,0),units="cm")) 
p_wempirical
ggsave(file="empirical-wonkiness.pdf",width=6.8,height=5)


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
