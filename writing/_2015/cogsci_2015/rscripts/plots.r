#' ---
#' title: "Prior probabilities in the interpretation of 'some': analysis of uniform prior wonky world model predictions"
#' author: "Judith Degen"
#' date: "January 26, 2014"
#' ---

library(ggplot2)
theme_set(theme_bw(18))
setwd("/Users/titlis/cogsci/projects/stanford/projects/thegricean_sinking-marbles/writing/_2015/cogsci_2015/paper/pics/")
source("rscripts/helpers.r")

# get prior expectations
priorexpectations = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/expectations.txt",sep="\t", header=T, quote="")
row.names(priorexpectations) = paste(priorexpectations$effect, priorexpectations$object)

# histogram of expectations
ggplot(priorexpectations, aes(x=expectation_corr/15)) +
  geom_histogram() +
  scale_x_continuous(name="Expected value of prior distribution") +
  scale_y_continuous(name="Number of cases")
ggsave("priorexpectations-histogram.pdf")


# get prior allstate-probs
priorprobs = read.table(file="~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/experiments/12_sinking-marbles-prior15/results/data/smoothed_15marbles_priors_withnames.txt",sep="\t", header=T, quote="")
row.names(priorprobs) = paste(priorprobs$effect, priorprobs$object)
head(priorprobs)

# histogram of expectations
ggplot(priorprobs, aes(x=X15)) +
  geom_histogram() +
  scale_x_continuous(name="Prior all-state probability") +
  scale_y_continuous(name="Number of cases")
ggsave("priorallprobs-histogram.pdf")


#####################################
# plot model predictions: expectations
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/wonky_world/results/data/mp-uniform.RData")
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/wonky_world/results/data/mp-binomial.RData")

# plot expectations for best basic model: 
toplot = droplevels(subset(mp, QUD == "how-many" & Alternatives == "0_basic" & Quantifier == "some" & WonkyWorldPrior == .5))
nrow(toplot)

pexpectations = ddply(toplot, .(Item, SpeakerOptimality,PriorExpectation_smoothed, PosteriorExpectation_empirical), summarise, PosteriorExpectation_predicted=sum(State*PosteriorProbability)/15)
head(pexpectations)
some = pexpectations#droplevels(subset(pexpectations, Quantifier == "some"))

toplot = droplevels(subset(some, SpeakerOptimality == 2))
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
ggsave("model-expectations.pdf",width=5.5,height=4.5)#,width=30,height=10)
save(toplot, file="../data/toplot-expectations.RData")

toplot_w = toplot
# get rRSA predictions for qud=how-many, alts=0_basic, spopt=2
load("~/cogsci/projects/stanford/projects/thegricean_sinking-marbles/models/complex_prior/smoothed_unbinned15/results/data/toplot-expectations.RData")
toplot_r = toplot
head(toplot_w)
summary(toplot_r)
toplot_r$RSA = "regular"
toplot_w$RSA = "wonky"

# plot both rRSA and uniform wRSA expectation predictions in same plot
toplot = merge(toplot_r,toplot_w, all=T)
head(toplot)
nrow(toplot)
p_exps = ggplot(toplot, aes(x=PriorExpectation_smoothed*15, y=PosteriorExpectation_predicted*15, color=RSA)) +
  geom_point() + #color="#00B0F6") + #values=c("#F8766D", "#A3A500", "#00BF7D", "#E76BF3", "#00B0F6")
  geom_smooth() + #color="#00B0F6") +
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
head(toplot_w)
summary(toplot_r)
toplot_r$RSA = "regular"
toplot_w$RSA = "wonky"

# plot both rRSA and uniform wRSA expectation predictions in same plot
toplot = merge(toplot_r,toplot_w, all=T)
head(toplot)
nrow(toplot)
p_probs = ggplot(toplot, aes(x=PriorProbability, y=PosteriorProbability, color=RSA)) +
  geom_point() + #color="#00B0F6") + #values=c("#F8766D", "#A3A500", "#00BF7D", "#E76BF3", "#00B0F6")
  geom_smooth() + #color="#00B0F6") +
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
  scale_color_manual(values=c("#F8766D", "#A3A500", "#00BF7D", "#E76BF3", "#00B0F6"),breaks=levels(agr$quantifier),labels=c("all","long filler","none","short filler","some")) +
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
  scale_color_manual(values=c("#F8766D", "#A3A500", "#00BF7D", "#E76BF3", "#00B0F6"),breaks=levels(agr$quantifier),labels=c("all","long filler","none","short filler","some")) +
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
ggsave("subject-variability.pdf",width=8,height=35)


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



######### CLEAN UP REST OF THIS ##########



#' get model predictions
load("data/mp-uniform.RData")
#d = read.table("data/parsed_uniform_results.tsv", quote="", sep="\t", header=T)
table(d$Item)
nrow(d)
head(d)
d[d$Item == "ate the seeds birds" & d$QUD=="how-many" & d$Alternatives=="0_basic" & d$SpeakerOptimality == 1,]
d[d$Item == "stuck to the wall baseballs" & d$QUD=="how-many" & d$Alternatives=="0_basic" & d$SpeakerOptimality == 2 & d$Wonky == "true",]
mp = ddply(d, .(Item, QUD, State, Alternatives, Quantifier, SpeakerOptimality, WonkyWorldPrior), summarise, PosteriorProbability=sum(PosteriorProbability))
head(mp)
#mp[mp$Item == "ate the seeds birds" & mp$QUD=="how-many" & mp$Alternatives=="0_basic" & mp$SpeakerOptimality == 1,]
wr = ddply(d, .(Item, QUD, Wonky, Alternatives, Quantifier, SpeakerOptimality, WonkyWorldPrior), summarise, PosteriorProbability=sum(PosteriorProbability))
wr[wr$Item == "ate the seeds birds" & wr$QUD=="how-many" & wr$Alternatives=="0_basic" & wr$SpeakerOptimality == 1,]



# get smoothed prior probabilities
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
mp$PosteriorExpectation_empirical = agr[paste(mp$Item,mp$Quantifier),]$ProportionResponse
mp$PriorExpectation_smoothed = mp$PriorExpectation/15

pexpectations = ddply(mp, .(Item, QUD, Alternatives, Quantifier, SpeakerOptimality,PriorExpectation_smoothed, WonkyWorldPrior, PosteriorExpectation_empirical), summarise, PosteriorExpectation_predicted=sum(State*PosteriorProbability)/15)
head(pexpectations)
some = droplevels(subset(pexpectations, Quantifier == "some"))

cors = ddply(some, .(Alternatives, QUD, SpeakerOptimality, WonkyWorldPrior), summarise, r=cor(PosteriorExpectation_predicted, PosteriorExpectation_empirical))
cors = cors[order(cors[,c("r")],decreasing=T),]
head(cors)

ggplot(some, aes(x=PosteriorExpectation_predicted, y=PosteriorExpectation_empirical,color=as.factor(SpeakerOptimality), shape=as.factor(WonkyWorldPrior))) +
  geom_point() +
  geom_smooth(method="lm") +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
#  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_grid(QUD~Alternatives)
ggsave("graphs/model-empirical-uniform-expectations.pdf",width=30,height=10)

  
#plot empirical against predicted allstate-prbabilities for "some"
allstate = droplevels(subset(mp, State == 15 & Quantifier == "some"))
cors = ddply(allstate, .(Alternatives, QUD, SpeakerOptimality, WonkyWorldPrior), summarise, r=cor(PosteriorProbability, PosteriorProbability_empirical))
cors = cors[order(cors[,c("r")],decreasing=T),]
head(cors)
# .59 correlation despite being shitty model

ggplot(allstate, aes(x=PosteriorProbability, y=PosteriorProbability_empirical,color=as.factor(WonkyWorldPrior), shape=as.factor(SpeakerOptimality))) +
  geom_point() +
  geom_smooth() +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
  #  geom_text(data=cors, aes(label=r)) +
  #scale_size_discrete(range=c(1,2)) +
  #scale_color_manual(values=c("red","blue","black")) +
  facet_grid(QUD~Alternatives)
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
  facet_grid(QUD~Alternatives)
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
toplot = droplevels(subset(wonky, Alternatives == "0_basic" & WonkyWorldPrior == .4 & SpeakerOptimality == 2))

ggplot(toplot, aes(x=PriorExpectation, y=PosteriorProbability, color=Quantifier)) +
  geom_point() +
  geom_smooth() 
ggsave(file="graphs/wonkinessplot.pdf",width=6)

cors = ddply(wonky, .(Alternatives, QUD, SpeakerOptimality, Quantifier, WonkyWorldPrior), summarise, r=cor(PosteriorProbability, PosteriorProbability_empirical))
cors = cors[order(cors[,c("r")],decreasing=T),]
head(cors,15)

wonky_all = subset(wonky, Quantifier == "all")
wonky_none = subset(wonky, Quantifier == "none")
wonky_some = subset(wonky, Quantifier == "some")

ggplot(wonky_all, aes(x=PosteriorProbability, y=PosteriorProbability_empirical, color=as.factor(WonkyWorldPrior), shape=as.factor(SpeakerOptimality))) +
  geom_point() +
  geom_smooth(method="lm") +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
  facet_grid(QUD~Alternatives)
ggsave("graphs/model-empirical-uniform-wonkiness_all.pdf", width=30,height=10)

ggplot(wonky_none, aes(x=PosteriorProbability, y=PosteriorProbability_empirical, color=as.factor(WonkyWorldPrior), shape=as.factor(SpeakerOptimality))) +
  geom_point() +
  geom_smooth(method="lm") +
  geom_abline(intercept=0,slope=1,color="gray50") +
  scale_x_continuous(limits=c(0,1)) +
  scale_y_continuous(limits=c(0,1)) +  
  facet_grid(QUD~Alternatives)
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



